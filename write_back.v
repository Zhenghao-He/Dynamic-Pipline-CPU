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

    input [31:0] me_HI,
    input [31:0] me_LO,
    input [31:0] me_Z,
    input [31:0] me_MEM,
    input [31:0] me_IR,

    output [4:0] mux_Rdc_out,
    output [31:0] mux_Rd_out,
    output [31:0] Rd_out_for_LO,

    //control signal
    input [1:0] cond,
    output hi_w,
    output lo_w,
    output cp0_wena,
    output regfile_wena,
    output [6:0] flow_waddr,
    output dmem_read,
    output use_mul
    );

    assign use_mul=(me_IR[31:26]==6'b011100&&me_IR[5:0]==6'b000010);
    assign Rd_out_for_LO=me_LO;

    wire [1:0] mux_Rdc,mux_Rd;
    wire hi_w_in,lo_w_in,cp0_wena_in,regfile_wena_in;
    wire [53:0] decoded_instr;
    wire write_ena=(cond==`COND_FLOW);
    assign hi_w=write_ena&hi_w_in;
    assign lo_w=write_ena&lo_w_in;
    assign cp0_wena=write_ena&cp0_wena_in;
    assign regfile_wena=write_ena&regfile_wena_in;
    instr_decoder inst_de(
        .instr_code(me_IR),
        .decoder_ena(1),
        .i(decoded_instr)
    );
    controller c_wb(
        .inst(me_IR),
        .decoded_instr(decoded_instr),
        .waddr(flow_waddr),
        .dmem_read(dmem_read),
        .mux_Rdc(mux_Rdc),
        .mux_Rd(mux_Rd),
        .hi_wena(hi_w_in),
        .lo_wena(lo_w_in),
        .regfile_wena(regfile_wena_in),
        .cp0_wena(cp0_wena_in)
    );
    mux4 #(32) Rd(
        .choose(mux_Rd),
        .data1(me_Z),
        .data2(me_MEM),
        .data3(me_HI),
        .data4(me_LO),
        .data_out(mux_Rd_out)
    );
    mux4 #(5) Rdc(
        .choose(mux_Rdc),
        .data1(me_IR[15:11]),
        .data2(me_IR[20:16]),
        .data3(5'd31),
        .data_out(mux_Rdc_out)
    );
endmodule
