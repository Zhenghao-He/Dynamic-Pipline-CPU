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
    input [31:0] z,
    input [31:0] rt,
    input [31:0] ex_ir,
    input [1:0] condition,
    input [31:0] hi,
    input [31:0] lo,
    output reg [31:0] reg_Z,
    output reg [31:0] reg_mem,
    output reg [31:0] reg_ir,
    output reg [31:0] reg_HI,
    output reg [31:0] reg_LO,
    output [6:0] flow_waddr,
    output dmem_read,
    output n_mul
    );

    
    wire dmem_write;
    wire [1:0] dmemory_width;
    wire [2:0] mem_sel;
    wire [53:0] decoded_instr;
    wire [31:0] dmem_out,ext_out;
    assign n_mul=(ex_ir[5:0]==6'b000010&&ex_ir[31:26]==6'b011100);
    instr_decoder inst_de(.instr_code(ex_ir),.decoder_ena(1),.i(decoded_instr));
    controller con_me(.inst(ex_ir),.decoded_instr(decoded_instr),.waddr(flow_waddr),.dmem_read(dmem_read),.dmem_write(dmem_write),.dmemory_width(dmemory_width),.mem_sel(mem_sel));
    dmem DMEM(.clk(clk),  .wena(dmem_write), .word_width(dmemory_width),  .addr(z-32'h10010000),.data_in(rt),  .data_out(dmem_out)  );
    ext ext_me(.ent_sig(mem_sel),.data8(dmem_out[7:0]),.data16(dmem_out[15:0]),.data32(dmem_out),.data_out(ext_out));

    always @(negedge clk or posedge rst) 
    begin 
        if (rst) 
        begin
            reg_ir<=`IR_NON;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: reg_ir<=ex_ir;
                `COND_STALL: reg_ir<=reg_ir;
                `COND_ZERO: reg_ir<=`IR_NON;
                default: 
                begin end
            endcase
        end
    end

    always @(posedge clk or posedge rst) 
    begin  
        if (rst) 
        begin
            reg_HI<=32'b0;
            reg_LO<=32'b0;
            reg_Z<=32'b0;
            reg_mem<=32'b0;
        end 
        else 
        begin
            case (condition)
                `COND_FLOW: 
                begin
                    reg_HI<=hi;
                    reg_LO<=lo;
                    reg_Z<=z;
                    reg_mem<=ext_out;
                end
                `COND_STALL: 
                begin
                    reg_HI<=reg_HI;
                    reg_LO<=reg_LO;
                    reg_Z<=reg_Z;
                    reg_mem<=reg_mem;
                end
                `COND_ZERO: 
                begin
                    reg_HI<=32'b0;
                    reg_LO<=32'b0;
                    reg_Z<=32'b0;
                    reg_mem<=32'b0;
                end
                default: 
                begin end
            endcase
        end
    end


endmodule

