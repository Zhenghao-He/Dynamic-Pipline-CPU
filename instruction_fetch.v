`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 22:41:16
// Design Name: 
// Module Name: instruction_fetch
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


module instruction_fetch(
    input clk, 
    input rst,  
    input [2:0] mux_pc,
    input [31:0] connect,
    input [31:0] npc_ext,
    input [31:0] cp0_EPC,
    input [31:0] cp0_intr_addr,
    input [31:0] Rs,
    input [1:0] condition,
    
    output [31:0] npc,
    output reg [31:0] IR,
    output reg [31:0] PC
    ); 
    assign npc=PC+32'h4;
    wire [31:0] res_imem,res_pc;
            always @(posedge clk or posedge rst) 
        begin    
        if (rst) 
        begin
            PC<=32'h00400000;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: PC<=res_pc;
                `COND_STALL: PC<=PC;
                `COND_ZERO: PC<=32'h00400000;
                default: 
                begin 

                end
            endcase
        end
    end
    always @(negedge clk or posedge rst) 
    begin    
        if (rst) 
        begin
            IR<=`IR_NON;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: IR<=res_imem;
                `COND_STALL: IR<=IR;
                `COND_ZERO: IR<=`IR_NON;
                default: 
                begin 

                end
            endcase
        end
    end

    mux_len32_sel8 m_Pc(
        .choose(mux_pc),
        .data1(npc_ext),
        .data2(Rs),
        .data3(cp0_intr_addr),
        .data4(cp0_EPC),
        .data5(connect),
        .data6(npc),
        .data_out(res_pc)
    );

    imem IMEM(
        .addr(PC),
        .meminst(res_imem)
    );
endmodule
