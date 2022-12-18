`timescale 1ns / 1ps

module sccomp_dataflow(
    input clk,  
    input rst, 
    input cpu_stall,
    output [31:0] pc,
    output [31:0] inst,
    output [31:0] reg_28);
    wire [4:0] rdc;
    wire [31:0] rd,rdToLo;
    wire [31:0] id_ALUa;
    wire [31:0] id_ALUb;
    wire [31:0] id_Rt;
    wire [31:0] id_ir;
    wire [31:0] ext_out;
    wire [31:0] me_HI;
    wire [31:0] me_LO;
    wire [31:0] me_Z;
    wire [31:0] me_MEM;
    wire [31:0] me_ir;
    
    wire [31:0] ex_HI;
    wire [31:0] ex_LO;
    wire [31:0] ex_Z;
    wire [31:0] ex_Rt;
    wire [31:0] ex_ir;
    
    wire stallForcc;
    wire finish_flag;
    wire overstall;
    wire [1:0] condition0;
    wire [1:0] condition1;
    wire [1:0] condition2;
    wire [1:0] condition3;
    wire [1:0] condition4;
    wire [1:0] condition5;
    wire [31:0] f_ALUa,f_ALUb,f_Rt;
    wire [6:0] flow_raddr1;
    wire [6:0] flow_raddr2;
    wire [6:0] flow_waddr1;
    wire [6:0] flow_waddr2;
    wire [6:0] flow_waddr3;
    wire f_ALUa_w;
    wire f_ALUb_w;
    wire f_Rt_w;
    wire ex_mem;
    wire me_mem;
    wire ex_mul;
    wire me_mul;
    wire [2:0] mux_pc;
    wire [31:0] connect;
    wire [31:0] npc_ext;
    wire [31:0] Rs,cp0_EPC;
    wire [31:0] cp0_intr_addr;
    wire [31:0] if_npc,if_ir;
    wire hi_wena;
    wire lo_wena;
    wire cp0_wena;
    wire rf_wena;

    flow_control fc(.clk(clk),.rst(rst),.waddr1(flow_waddr1),.waddr2(flow_waddr2),.waddr3(flow_waddr3),.raddr1(flow_raddr1),.raddr2(flow_raddr2),.stallForcc(stallForcc),.overForcc(finish_flag),.overstall(overstall),.cond0(condition0),.cond1(condition1),.cond2(condition2),.cond3(condition3),.cond4(condition4),.cond5(condition5),.HI(ex_HI),.LO(ex_LO),.ex_Z(ex_Z),.ex_mem(ex_mem),.ex_mul(ex_mul),.me_HI(me_HI),.me_LO(me_LO),.me_Z(me_Z),.me_MEM(me_MEM),.me_mem(me_mem),.me_mul(me_mul),.cpu_stall(cpu_stall),.ALUa(f_ALUa),.ALUb(f_ALUb),.id_Rt(f_Rt),.ALUa_w(f_ALUa_w),.ALUb_w(f_ALUb_w),.id_Rt_w(f_Rt_w));
    instruction_fetch IF(.clk(clk),  .rst(rst),    .connect(connect),.npc_ext(npc_ext),.Rs(Rs),.cp0_EPC(cp0_EPC),.cp0_intr_addr(cp0_intr_addr),.npc(if_npc),.PC(pc),.IR(if_ir),.condition(condition0),.mux_pc(mux_pc));
    instruction_decode ID(.clk(clk),.rst(rst),.if_ir(if_ir),.if_npc(if_npc),.rdc(rdc),   .rd(rd),   .rdToLo(rdToLo),.reg_ALUa(id_ALUa),.reg_ALUb(id_ALUb),.reg_Rt(id_Rt),.reg_IR(id_ir),.cp0_EPC(cp0_EPC),.cp0_intr_addr(cp0_intr_addr),.ext_out(ext_out),.connect(connect),.Rs(Rs),.condition(condition1),.mux_pc(mux_pc),.hi_wena(hi_wena),.lo_wena(lo_wena),.rf_wena(rf_wena),.cp0_wena(cp0_wena),.flow_raddr1(flow_raddr1),.flow_raddr2(flow_raddr2),.f_ALUa(f_ALUa),.f_ALUb(f_ALUb),.f_Rt(f_Rt),.f_ALUa_w(f_ALUa_w),.f_ALUb_w(f_ALUb_w),.f_Rt_w(f_Rt_w),.reg_28(reg_28));
    execute EX(.clk(clk),.rst(rst),.ALUa(id_ALUa),.ALUb(id_ALUb),.Rt(id_Rt),.id_ir(id_ir),.reg_HI(ex_HI),.reg_LO(ex_LO),.reg_Z(ex_Z),.reg_Rt(ex_Rt),.reg_IR(ex_ir),.condition(condition2),.stallForcc(stallForcc),   .finish_flag(finish_flag),.overstall(overstall),.flow_waddr(flow_waddr1),.cpu_stall(cpu_stall));
    memory_access MEM(.clk(clk),.rst(rst),.hi(ex_HI),.lo(ex_LO),.z(ex_Z),.rt(ex_Rt),.ex_ir(ex_ir),.reg_HI(me_HI),.reg_LO(me_LO),.reg_Z(me_Z),.reg_mem(me_MEM),.reg_ir(me_ir),.condition(condition3),.flow_waddr(flow_waddr2),.dmem_read(ex_mem),.n_mul(ex_mul));
    write_back WB(.clk(clk),.rst(rst),.hi(me_HI),.lo(me_LO),.z(me_Z),.me_mem(me_MEM),.me_ir(me_ir),.mux_Rdc_res(rdc),.mux_Rd_res(rd),.rdToLo(rdToLo),.condition(condition4),.hi_wena(hi_wena),.lo_wena(lo_wena),.cp0_wena(cp0_wena),.rf_wena(rf_wena),.flow_waddr(flow_waddr3),.dmem_read(me_mem),.n_mul(me_mul));
    assign inst=if_ir;
    assign npc_ext = ext_out+if_npc;
endmodule
