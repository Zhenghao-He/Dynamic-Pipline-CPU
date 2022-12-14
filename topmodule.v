`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/21 13:20:28
// Design Name: 
// Module Name: topmodule
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

module time_divider #(parameter N=1234)(
    input clk,
    output reg oclk=0
    );
    integer cnt=0;
    always@(posedge clk)
    begin
        if(cnt==N)
//        if(cnt==(N-1)/2)
        begin
            cnt<=0;
            oclk<=~oclk;
        end
        else
            cnt<=cnt+1;
    end
endmodule


module topmodule(
    input clk_in,
    input reset,
    input cpu_stall,
    output [7:0] o_seg,
    output [7:0] o_sel
    );

    wire clk_data;
    wire clk_seg;
    wire [31:0]pc;
    wire [31:0]inst;
    wire [31:0] reg_28;

    time_divider #(10000000) u1(.clk(clk_in),.oclk(clk_data));

    sccomp_dataflow dataflow(.clk(clk_data),.reset(reset),.inst(inst),.pc(pc),.reg_28(reg_28),.cpu_stall(cpu_stall));

    seg7x16 seg(clk_in,reset,1'b1,reg_28,o_seg,o_sel);

endmodule

