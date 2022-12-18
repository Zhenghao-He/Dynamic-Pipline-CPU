`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/07 21:43:14
// Design Name: 
// Module Name: instruction_decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decode(
    input clk,
    input rst,
    input [31:0] if_ir, 
    input [31:0] if_npc,
    input [4:0] rdc,    
    input [31:0] rd,  
    input [31:0] rdToLo, 
    input [1:0] condition,
    input hi_wena,
    input lo_wena,
    input rf_wena,
    input cp0_wena,
    input [31:0] f_ALUa,
    input [31:0] f_ALUb,
    input [31:0] f_Rt,
    input f_ALUa_w,
    input f_ALUb_w,
    input f_Rt_w,
    output reg [31:0] reg_ALUa,
    output reg [31:0] reg_ALUb,
    output reg [31:0] reg_Rt,
    output reg [31:0] reg_IR,
    output [31:0] cp0_EPC,
    output [31:0] cp0_intr_addr,
    output [31:0] ext_out,
    output [31:0] connect,
    output [31:0] Rs,
    output [31:0] Rt,
    output [2:0] mux_pc,
    output [6:0] flow_raddr1,
    output [6:0] flow_raddr2,
    output [31:0] reg_28);

    assign connect={if_npc[31:28],if_ir[25:0],2'b0};

    reg [31:0] reg_HI,reg_LO;

    wire mux_lo_sig;
    wire mux_hi_sig;
    wire [31:0] lo_res,hi_res,mux_lo_res,mux_hi_res;
    wire [31:0] t_alua,t_alub;
    wire [31:0] cp0_res;
    wire [4:0] cp0_cause;

    wire [2:0] mux_ALUa;
    wire [1:0] mux_ALUb;
    wire [2:0] ext_sig;
    wire [53:0] decoded_instr;
    wire cp0_eret;
    wire cp0_exp;

    wire beq;
    wire bgez;
    wire  cp0_ena;
    wire mfc0;
    assign beq=((f_ALUa_w?f_ALUa:Rs)==(f_ALUb_w?f_ALUb:Rt));
    assign bgez=(f_ALUa_w?(f_ALUa[31]==1'b0):(Rs[31]==1'b0));
    wire [31:0]status;
    wire [4:0] cp0_addr;
    assign cp0_addr=cp0_wena?rdc:if_ir[15:11];
    instr_decoder inst_de(.instr_code(if_ir),.decoder_ena(1),.i(decoded_instr));
    controller con_id(.inst(if_ir),.decoded_instr(decoded_instr),.beq(beq), .bgez(bgez), .mux_pc_sel(mux_pc),.mux_ALUa(mux_ALUa),.mux_ALUb(mux_ALUb),.ext_sel(ext_sig),.cp0_exp(cp0_exp),.cp0_eret(cp0_eret),.cp0_cause(cp0_cause),.raddr1(flow_raddr1),.raddr2(flow_raddr2));

    RF rf(.clk(clk),  .rst(rst),  .we(rf_wena),   .raddr1({27'b0,if_ir[25:21]}),.raddr2({27'b0,if_ir[20:16]}),.waddr({27'b0,rdc}),.wdata(rd),.rdata1(Rs),.rdata2(Rt),.reg_28(reg_28));

    cp0 cp0_inst(.clk(clk),.rst(rst),.ena(cp0_ena),.mfc0(mfc0),.mtc0(cp0_wena),.pc(if_npc),.cp0_addr(cp0_addr),.wdata(rd), .exception(cp0_exp&&(condition==`COND_FLOW)),   .eret(cp0_eret&&(condition==`COND_FLOW)), .cause(cp0_cause),.rdata(cp0_res), .status(status), .exc_addr(cp0_EPC), .intr_addr(cp0_intr_addr));

    mux_len32_sel8 m_ALUa(.choose(mux_ALUa),.data1(reg_HI),.data2(reg_LO),.data3(if_npc),.data4(Rs),.data5(ext_out),.data6(cp0_res),.data7(32'b0),.data_out(t_alua));
    mux4 #(32) m_ALUb(.choose(mux_ALUb),.data1(32'd0),.data2(Rt),.data3(ext_out),.data_out(t_alub));
    ext ext_id(.ent_sig(ext_sig),.data5(if_ir[10:6]),.data16(if_ir[15:0]),.data_out(ext_out));




    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            reg_ALUa<=32'b0;
            reg_ALUb<=32'b0;
            reg_Rt<=32'b0;
            reg_HI<=32'b0;
            reg_LO<=32'b0;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: 
                begin
                    reg_ALUa<=f_ALUa_w?f_ALUa:t_alua;
                    reg_ALUb<=f_ALUb_w?f_ALUb:t_alub;
                    reg_Rt<=f_Rt_w?f_Rt:Rt;
                end
                `COND_STALL: 
                begin
                    reg_ALUa<=reg_ALUa;
                    reg_ALUb<=reg_ALUb;
                    reg_Rt<=reg_Rt;
                end
                `COND_ZERO: 
                begin
                    reg_ALUa<=32'b0;
                    reg_ALUb<=32'b0;
                    reg_Rt<=32'b0;
                end
                default: 
                begin 

                end
            endcase
            reg_HI<=hi_wena?rd:reg_HI;
            reg_LO<=lo_wena?(hi_wena?rdToLo:rd):reg_LO;
        end
    end

    always @(negedge clk or posedge rst) 
    begin   
        if (rst) 
        begin
            reg_IR<=`IR_NON;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: reg_IR<=if_ir;
                `COND_STALL: reg_IR<=reg_IR;
                `COND_ZERO: reg_IR<=`IR_NON;
                default: 
                begin 

                end
            endcase
        end
    end
endmodule

