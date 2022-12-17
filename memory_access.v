`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 22:58:58
// Design Name: 
// Module Name: memory_access
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




module memory_access(
    input clk,
    input rst,

    input [31:0] ex_HI,
    input [31:0] ex_LO,
    input [31:0] ex_Z,
    input [31:0] ex_Rt,
    input [31:0] ex_IR,

    output reg [31:0] rHI,
    output reg [31:0] rLO,
    output reg [31:0] rZ,
    output reg [31:0] rMEM,
    output reg [31:0] rIR,

    //control signal
    input [1:0] cond,
    output [6:0] flow_waddr,
    output dmem_read,
    output use_mul
    );

    assign use_mul=(ex_IR[31:26]==6'b011100&&ex_IR[5:0]==6'b000010);
    wire dmem_write;wire [1:0] dmemory_width;wire [31:0] dmem_out,ext_out;wire [2:0] mem_sel;
    wire [53:0] decoded_instr;
        instr_decoder inst_de(
        .instr_code(ex_IR),
        .decoder_ena(1),
        .i(decoded_instr)
    );
    controller controller_me(
        .inst(ex_IR),
        .decoded_instr(decoded_instr),
        // .judge_beq(1'b0), 
        // .judge_bgez(1'b0), 

        .waddr(flow_waddr),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmemory_width(dmemory_width),
        .mem_sel(mem_sel)
    );

    dmem dmem_inst(
        .clk(clk),  
        .wena(dmem_write), 
        .word_width(dmemory_width),  
        .addr(ex_Z-32'h10010000),
        .data_in(ex_Rt),  
        .data_out(dmem_out)  
    );

    ext ext_me(
        .ent_sig(mem_sel),
        .data8(dmem_out[7:0]),
        .data16(dmem_out[15:0]),
        .data32(dmem_out),
        .data_out(ext_out)
    );

    always @(posedge clk or posedge rst) begin    //execute
        if (rst) begin
            rHI<=32'b0;
            rLO<=32'b0;
            rZ<=32'b0;
            rMEM<=32'b0;
        end else begin
            case (cond)
                `COND_FLOW: begin
                    rHI<=ex_HI;
                    rLO<=ex_LO;
                    rZ<=ex_Z;
                    rMEM<=ext_out;
                end
                `COND_STALL: begin
                    rHI<=rHI;
                    rLO<=rLO;
                    rZ<=rZ;
                    rMEM<=rMEM;
                end
                `COND_ZERO: begin
                    rHI<=32'b0;
                    rLO<=32'b0;
                    rZ<=32'b0;
                    rMEM<=32'b0;
                end
                default: begin end
            endcase
        end
    end

    always @(negedge clk or posedge rst) begin    //flow
        if (rst) begin
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `COND_FLOW: rIR<=ex_IR;
                `COND_STALL: rIR<=rIR;
                `COND_ZERO: rIR<=`IR_NON;
                default: begin end
            endcase
        end
    end
endmodule

