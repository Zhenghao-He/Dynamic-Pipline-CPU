`timescale 1ns / 1ps

`include "define.vh"

module sccomp_dataflow(
    input clk,  
    input reset, 
    input cpu_stall,
    output [31:0] pc,
    output [31:0] inst,
    output [31:0] reg_28
    );
    wire forward_ALUa_w,forward_ALUb_w,forward_Rt_w;
    wire [1:0] cond0,cond1,cond2,cond3,cond4;
    wire [31:0] forward_ALUa,forward_ALUb,forward_Rt;
    wire [6:0] flow_raddr1,flow_raddr2,flow_waddr1,flow_waddr2,flow_waddr3;
    
    
    wire [2:0] mux_pc_sel;
    wire [31:0] connect,npc_ext,regfile_Rs,cp0_EPC,cp0_intr_addr;
    wire [31:0] if_NPC,if_IR;
    wire hi_w,lo_w,cp0_w,regfile_w;
    wire [4:0] regfile_Rdc;wire [31:0] regfile_Rd,Rd_out_for_LO;
    wire [31:0] id_ALUa,id_ALUb,id_Rt,id_IR,ext_out;
    wire [31:0] me_HI,me_LO,me_Z,me_MEM,me_IR;
    wire ex_from_mem,me_from_mem;
    wire ex_mul,me_mul;
    wire [31:0] ex_HI,ex_LO,ex_Z,ex_Rt,ex_IR;
    wire mult_div_stall,cal_finish,overflow_stall;
    assign inst=if_IR;
    assign npc_ext = ext_out+if_NPC;
    instruction_fetch if_inst(
        .clk(clk),  
        .reset(reset),    
        .connect(connect),
        .npc_ext(npc_ext),
        .regfile_Rs(regfile_Rs),
        .cp0_EPC(cp0_EPC),
        .cp0_intr_addr(cp0_intr_addr),
        .oNPC(if_NPC),
        .rPC(pc),
        .rIR(if_IR),
        .cond(cond0),
        .mux_pc_sel(mux_pc_sel)
    );

    
    

    instruction_decode id_inst(
        .clk(clk),
        .reset(reset),
        .if_IR(if_IR),
        .if_NPC(if_NPC),
        .regfile_Rdc(regfile_Rdc),   
        .regfile_Rd(regfile_Rd),   
        .Rd_out_for_LO(Rd_out_for_LO),
        .rALUa(id_ALUa),
        .rALUb(id_ALUb),
        .rRt(id_Rt),
        .rIR(id_IR),
        .cp0_EPC(cp0_EPC),
        .cp0_intr_addr(cp0_intr_addr),
        .ext_out(ext_out),
        .connect(connect),
        .regfile_Rs(regfile_Rs),
        .regfile_Rt(),
        .cond(cond1),
        .mux_pc_sel(mux_pc_sel),
        .hi_w(hi_w),
        .lo_w(lo_w),
        .regfile_w(regfile_w),
        .cp0_w(cp0_w),
        .flow_raddr1(flow_raddr1),
        .flow_raddr2(flow_raddr2),
        .forward_ALUa(forward_ALUa),
        .forward_ALUb(forward_ALUb),
        .forward_Rt(forward_Rt),
        .forward_ALUa_w(forward_ALUa_w),
        .forward_ALUb_w(forward_ALUb_w),
        .forward_Rt_w(forward_Rt_w),

        //for program out
        .reg_28(reg_28)
    );

    

    execute ex_inst(
        .clk(clk),
        .reset(reset),
        .alua(id_ALUa),
        .alub(id_ALUb),
        .id_Rt(id_Rt),
        .id_IR(id_IR),
        .rHI(ex_HI),
        .rLO(ex_LO),
        .rZ(ex_Z),
        .rRt(ex_Rt),
        .rIR(ex_IR),
        .cond(cond2),
        .mult_div_stall(mult_div_stall),   //cause controller to stall 32 periods
        .cal_finish(cal_finish),
        .overflow_stall(overflow_stall),
        .flow_waddr(flow_waddr1),

        //for program in
        .cpu_stall(cpu_stall)
    );

    

    memory_access me_inst(
        .clk(clk),
        .reset(reset),
        .ex_HI(ex_HI),
        .ex_LO(ex_LO),
        .ex_Z(ex_Z),
        .ex_Rt(ex_Rt),
        .ex_IR(ex_IR),
        .rHI(me_HI),
        .rLO(me_LO),
        .rZ(me_Z),
        .rMEM(me_MEM),
        .rIR(me_IR),
        .cond(cond3),
        .flow_waddr(flow_waddr2),
        .dmem_r(ex_from_mem),
        .use_mul(ex_mul)
    );

    write_back wb_inst(
        .clk(clk),
        .reset(reset),
        .me_HI(me_HI),
        .me_LO(me_LO),
        .me_Z(me_Z),
        .me_MEM(me_MEM),
        .me_IR(me_IR),
        .mux_Rdc_out(regfile_Rdc),
        .mux_Rd_out(regfile_Rd),
        .Rd_out_for_LO(Rd_out_for_LO),
        .cond(cond4),
        .hi_w(hi_w),
        .lo_w(lo_w),
        .cp0_w(cp0_w),
        .regfile_w(regfile_w),
        .flow_waddr(flow_waddr3),
        .dmem_r(me_from_mem),
        .use_mul(me_mul)
    );

    flow_control flow_control_inst(
        .clk(clk),.reset(reset),
        .raddr1(flow_raddr1),.raddr2(flow_raddr2),.waddr1(flow_waddr1),.waddr2(flow_waddr2),.waddr3(flow_waddr3),
        .mult_div_stall(mult_div_stall),.mult_div_over(cal_finish),.overflow_stall(overflow_stall),
        /*-----------flow_control-----------*/
        .cond0(cond0),.cond1(cond1),.cond2(cond2),.cond3(cond3),.cond4(cond4),
        /*-----------flow_data-----------*/
        .id_ALUa(forward_ALUa),.id_ALUb(forward_ALUb),.id_Rt(forward_Rt),.id_ALUa_w(forward_ALUa_w),.id_ALUb_w(forward_ALUb_w),.id_Rt_w(forward_Rt_w),
        .ex_HI(ex_HI),.ex_LO(ex_LO),.ex_Z(ex_Z),.ex_from_mem(ex_from_mem),.ex_mul(ex_mul),
        .me_HI(me_HI),.me_LO(me_LO),.me_Z(me_Z),.me_MEM(me_MEM),.me_from_mem(me_from_mem),.me_mul(me_mul),
        //for program in
        .cpu_stall(cpu_stall)
    );
endmodule
