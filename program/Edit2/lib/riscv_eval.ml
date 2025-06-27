type riscv_inst = Riscv_gen.riscv_inst


module State = struct
  type value = int
  type regs  = (string, value) Hashtbl.t
  type mem   = (int, value)    Hashtbl.t
  type t = {
    regs : regs;
    mem  : mem;
    mutable sp : int;
    mutable pc : int;
    call_stack : int Stack.t;
  }
  let create ?(init_regs=[]) () =
    let r = Hashtbl.create 32 in
    List.iter (fun (k,v) -> Hashtbl.replace r k v) init_regs;
    { regs = r; mem = Hashtbl.create 128; sp = 0; pc = 0; call_stack = Stack.create () }
  let get_reg s r = try Hashtbl.find s.regs r with Not_found -> 0
  let set_reg s r v = Hashtbl.replace s.regs r v
end

let eval (prog : riscv_inst list) ?(state=State.create ()) () : State.t =
  (* ---------- 预处理 label -> 指令索引 ---------- *)
  let label_map = Hashtbl.create 32 in
  List.iteri
    (fun idx inst ->
       match inst with
       | Riscv_gen.RLabel l -> Hashtbl.replace label_map l idx
       | _ -> ())
    prog;

  (* ---------- 递归执行 ---------- *)
  let rec step st =
    if st.State.pc < 0 || st.pc >= List.length prog then st
    else (
      let goto idx = st.pc <- idx in
      let next ()  = st.pc <- st.pc + 1 in
      let v  r     = State.get_reg st r in
      let sv r x   = State.set_reg st r x in
      (* 执行一条指令，所有分支都返回 unit *)
      (match List.nth prog st.pc with
       | RAdd (d,a,b) -> sv d (v a + v b); next ()
       | RSub (d,a,b) -> sv d (v a - v b); next ()
       | RMul (d,a,b) -> sv d (v a * v b); next ()
       | RDiv (d,a,b) -> sv d (if v b = 0 then 0 else v a / v b); next ()
       | RRem (d,a,b) -> sv d (if v b = 0 then 0 else v a mod v b); next ()
       | RSlt (d,a,b) -> sv d (if v a <  v b then 1 else 0); next ()
       | RSle (d,a,b) -> sv d (if v a <= v b then 1 else 0); next ()
       | RSgt (d,a,b) -> sv d (if v a >  v b then 1 else 0); next ()
       | RSge (d,a,b) -> sv d (if v a >= v b then 1 else 0); next ()
       | RSeqz (d,a)  -> sv d (if v a = 0 then 1 else 0); next ()
       | RNeg (d,a)   -> sv d (- v a); next ()
       | RMv  (d,a)   -> sv d (v a); next ()
       | RLi  (d,i)   -> sv d i; next ()
       | RJ l         -> goto (Hashtbl.find label_map l)
       | RBnez (r,l)  ->
           if v r <> 0 then goto (Hashtbl.find label_map l) else next ()
       | RPush (r,ofs) ->
           let addr = st.sp + ofs in
           Hashtbl.replace st.mem addr (v r); next ()
       | RPop (d,ofs) ->
           let addr = st.sp + ofs in
           sv d (try Hashtbl.find st.mem addr with Not_found -> 0); next ()
       | RCall fn ->
           Stack.push (st.pc + 1) st.call_stack;
           goto (Hashtbl.find label_map fn)
       | RRet ret_opt ->
           (match ret_opt with Some r -> sv "a0" (v r) | None -> ());
           if Stack.is_empty st.call_stack
           then st.pc <- List.length prog         (* 结束程序 *)
           else goto (Stack.pop st.call_stack)
       | RLabel _ | RComment _ -> next ()
      );
      step st                                        (* 再递归跑下一条 *)
    )
  in
  step state
