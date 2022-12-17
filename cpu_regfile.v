`timescale 1ns / 1ps

module RF(
    input clk,
   input rst,
   input we,//Ğ´ÓĞĞ§ĞÅºÅwrite_enable
   input [4:0] raddr1,
   input [4:0] raddr2,
   input [4:0] waddr,
   input [31:0] wdata,
   output[31:0] rdata1,
   output[31:0] rdata2,
   output [31:0] reg_28
    );
    reg [31:0] array_reg[31:0]; 
    integer i;
    assign rdata1= (raddr1==0)?0:array_reg[raddr1];
    assign rdata2= (raddr2==0)?0:array_reg[raddr2];
    assign reg_28=array_reg[28];
    always @(posedge clk or posedge rst) begin
        if (rst)
        begin
            for(i=0;i<32;i=i+1)
                array_reg[i] = 0;
        end
        else
        begin
            if(we && waddr!=0)begin
                array_reg[waddr]=wdata;
            end    
        end
    end
endmodule