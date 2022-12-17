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
    input [31:0] id_Rt,
    input [31:0] id_IR,

    output reg [31:0] rHI,
    output reg [31:0] rLO,
    output reg [31:0] rZ,
    output reg [31:0] rRt,
    output reg [31:0] rIR,

    //control signal
    input [1:0] cond,
    output stallForcc,   //cause controller to stall 32 periods
    output cal_finish,
    output overstall,    //next IR_NON
    output [6:0] flow_waddr,

    //for program in
    input cpu_stall
    );

    wire [31:0] cal_lo,cal_hi;
    wire [1:0] cal_sel;
    (* KEEP = "{TRUE|FALSE|SOFT}" *) wire cal_ena;
    wire [31:0] alu_z;
    wire [3:0] aluc;
    wire [53:0] decoded_instr;
    wire overflow;
    (* KEEP = "{TRUE|FALSE|SOFT}" *) assign stallForcc=cal_ena;
    assign overstall=overflow&alu_overflow;
    instr_decoder inst_de(
        .instr_code(id_IR),
        .decoder_ena(1),
        .i(decoded_instr)
    );
    controller controller_ex(
        .inst(id_IR),
        .decoded_instr(decoded_instr),
        // .judge_beq(1'b0), 
        // .judge_bgez(1'b0), 
        .waddr(flow_waddr),
        .aluc(aluc),
        .cal_sel(cal_sel),
        .cal_ena(cal_ena),
        .overflow(overflow)
    );

    calculator cal(
        .clk(clk), 
        .a(ALUa), 
        .b(ALUb),
        .calc(cal_sel),
        .rst(rst),      
        .ena(cal_ena),  
        .oLO(cal_lo),
        .oHI(cal_hi),
        .sum_finish(cal_finish),
        .cpu_stall(cpu_stall)
    );
wire alu_overflow;
    alu alu_inst(
        .a(ALUa),
        .b(ALUb),
        .aluc(aluc),
        .r(alu_z),
        .overflow(alu_overflow)
    );

    always @(posedge clk or posedge rst) begin  
        if (rst) begin
            rZ<=32'b0;
            rRt<=32'b0;
        end else begin
            case (cond)
                `COND_FLOW: begin
                    rZ<=alu_z;
                    rRt<=id_Rt;
                end
                `COND_STALL: begin
                    rZ<=rZ;
                    rRt<=rRt;
                end
                `COND_ZERO: begin
                    rZ<=32'b0;
                    rRt<=32'b0;
                end
                default: begin end
            endcase
        end
    end

    always @(negedge clk or posedge rst) begin  
        if (rst) begin
            rHI<=32'b0;
            rLO<=32'b0;
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `COND_FLOW: begin
                    rHI<=cal_hi;
                    rLO<=cal_lo;
                    rIR<=id_IR;
                end
                `COND_STALL: begin
                    rHI<=rHI;
                    rLO<=rLO;
                    rIR<=rIR;
                end
                `COND_ZERO: begin
                    rHI<=32'b0;
                    rLO<=32'b0;
                    rIR<=`IR_NON;
                end
                default: begin end
            endcase
        end
    end
endmodule
