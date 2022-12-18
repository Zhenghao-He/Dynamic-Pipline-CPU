`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 22:57:51
// Design Name: 
// Module Name: execute
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
/////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module execute(
    input clk,
    input rst,
    input [31:0] ALUa,
    input [31:0] ALUb,
    input [31:0] Rt,
    input [31:0] id_ir,
    input cpu_stall,
    input [1:0] condition,
    output reg [31:0] reg_HI,
    output reg [31:0] reg_LO,
    output reg [31:0] reg_Z,
    output reg [31:0] reg_Rt,
    output reg [31:0] reg_IR,
    output stallForcc,  
    output finish_flag,
    output overstall,   
    output [6:0] flow_waddr  );

    wire [31:0] res_lo,res_hi;
    wire alu_overflow;
    reg n_nex_pc;
    reg pc;
    wire [1:0] cal_sel;
    wire cal_ena;
    wire [31:0] res_aluZ;
    wire [3:0] aluc;
    wire [53:0] decoded_instr;
    wire overflow;
    assign stallForcc=cal_ena;
    assign overstall=overflow&alu_overflow;
    instr_decoder inst_de(.instr_code(id_ir),.decoder_ena(1),.i(decoded_instr));
    controller controller_ex(.inst(id_ir),.decoded_instr(decoded_instr), .waddr(flow_waddr),.aluc(aluc),.cal_sel(cal_sel),.cal_ena(cal_ena),.overflow(overflow));

    calculator cal(.clk(clk), .a(ALUa), .b(ALUb),.calc(cal_sel),.rst(rst),.ena(cal_ena),.oLO(res_lo),.oHI(res_hi),.sum_finish(finish_flag),.cpu_stall(cpu_stall));

    alu alu_inst(.a(ALUa),.b(ALUb),.aluc(aluc),.r(res_aluZ),.overflow(alu_overflow));



    always @(negedge clk or posedge rst) 
    begin  
        if (rst) 
        begin
            reg_HI<=32'b0;
            reg_LO<=32'b0;
            reg_IR<=`IR_NON;
            n_nex_pc=pc;
        end else 
        begin
            case (condition)
                `COND_FLOW: 
                begin
                    n_nex_pc=pc;
                    reg_HI<=res_hi;
                    reg_LO<=res_lo;
                    reg_IR<=id_ir;
                end
                `COND_STALL: 
                begin
                    n_nex_pc=pc;
                    reg_HI<=reg_HI;
                    reg_LO<=reg_LO;
                    reg_IR<=reg_IR;
                end
                `COND_ZERO: 
                begin
                    n_nex_pc=pc;
                    reg_HI<=32'b0;
                    reg_LO<=32'b0;
                    reg_IR<=`IR_NON;
                end
                default: 
                begin 

                end
            endcase
        end
    end
        always @(posedge clk or posedge rst) 
    begin  
        if (rst) 
        begin
            n_nex_pc=pc;
            reg_Z<=32'b0;
            reg_Rt<=32'b0;
        end else 
        begin
            case (condition)
                `COND_FLOW: 
                begin
                    n_nex_pc=pc;
                    reg_Z<=res_aluZ;
                    reg_Rt<=Rt;
                end
                `COND_STALL: 
                begin
                    n_nex_pc=pc;
                    reg_Z<=reg_Z;
                    reg_Rt<=reg_Rt;
                end
                `COND_ZERO: 
                begin
                    n_nex_pc=pc;
                    reg_Z<=32'b0;
                    reg_Rt<=32'b0;
                end
                default: 
                begin 

                end
            endcase
        end
    end
endmodule
