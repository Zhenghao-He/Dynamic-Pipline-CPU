`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/09 23:00:02
// Design Name: 
// Module Name: write_back
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



module write_back(
    input clk,
    input rst,
    input [31:0] hi,
    input [31:0] lo,
    input [31:0] z,
    input [31:0] me_mem,
    input [31:0] me_ir,
    input [1:0] condition,
    output hi_wena,
    output lo_wena,
    output cp0_wena,
    output rf_wena,
    output [4:0] mux_Rdc_res,
    output [31:0] mux_Rd_res,
    output [31:0] rdToLo,
    output [6:0] flow_waddr,
    output dmem_read,
    output n_mul
    );


    wire [1:0] mux_Rdc,mux_Rd;
    wire hi_wena_in;
    wire lo_wena_in;
    wire cp0_wena_in;
    wire rf_wena_in;
    wire [53:0] decoded_instr;
    wire we;
    assign we=(condition==`COND_FLOW);
    assign n_mul=(me_ir[5:0]==6'b000010&&me_ir[31:26]==6'b011100);
    assign rdToLo=lo;
    assign hi_wena=we&hi_wena_in;
    assign lo_wena=we&lo_wena_in;
    assign cp0_wena=we&cp0_wena_in;
    assign rf_wena=we&rf_wena_in;

    instr_decoder inst_de(.instr_code(me_ir),.decoder_ena(1),.i(decoded_instr));
    controller con_wb(.inst(me_ir),.decoded_instr(decoded_instr),.waddr(flow_waddr),.dmem_read(dmem_read),.mux_Rdc(mux_Rdc),.mux_Rd(mux_Rd),.hi_wena(hi_wena_in),.lo_wena(lo_wena_in),.rf_wena(rf_wena_in),.cp0_wena(cp0_wena_in));
    mux4 #(32) Rd(.choose(mux_Rd),.data1(z),.data2(me_mem),.data3(hi),.data4(lo),.data_out(mux_Rd_res));
    mux4 #(5) Rdc(.choose(mux_Rdc),.data1(me_ir[15:11]),.data2(me_ir[20:16]),.data3(5'd31),.data_out(mux_Rdc_res));
endmodule
