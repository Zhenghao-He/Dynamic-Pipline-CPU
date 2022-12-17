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

    input [31:0] connect,
    input [31:0] npc_ext,
    input [31:0] regfile_Rs,
    input [31:0] cp0_EPC,
    input [31:0] cp0_intr_addr,

    output [31:0] oNPC,
    output reg [31:0] rPC,
    output reg [31:0] rIR,

    input [1:0] cond,
    input [2:0] mux_pc_sel
    );
    
    wire [31:0] imem_out,mux_pc_out;
    assign oNPC=rPC+32'h4;

    mux_len32_sel8 mux_Pc(
        .choose(mux_pc_sel),
        .data1(npc_ext),
        .data2(regfile_Rs),
        .data3(cp0_intr_addr),
        .data4(cp0_EPC),
        .data5(connect),
        .data6(oNPC),
        .data_out(mux_pc_out)
    );

    imem imem_inst(
        .addr(rPC),
        .meminst(imem_out)
    );


    always @(negedge clk or posedge rst) begin    
        if (rst) begin
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `COND_FLOW: rIR<=imem_out;
                `COND_STALL: rIR<=rIR;
                `COND_ZERO: rIR<=`IR_NON;
                default: begin end
            endcase
        end
    end
        always @(posedge clk or posedge rst) begin    
        if (rst) begin
            rPC<=`PC_ADDR_INIT;
        end else begin
            case (cond)
                `COND_FLOW: rPC<=mux_pc_out;
                `COND_STALL: rPC<=rPC;
                `COND_ZERO: rPC<=`PC_ADDR_INIT;
                default: begin end
            endcase
        end
    end

endmodule
