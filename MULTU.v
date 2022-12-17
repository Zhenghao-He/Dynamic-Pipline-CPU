`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/19 18:24:49
// Design Name: 
// Module Name: MULTU
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
/**/

module MULTU(
    input clk,
    input reset,    //active high
    input start,
    input [31:0] a, //multiplicand
    input [31:0] b, //multiplier
    output [63:0] z,
    output reg busy,
    output reg finish,

    //for program in
    input cpu_stall
    );
    
//    reg [5:0] cnt;
//    reg [31:0] multa,multb;
//    reg [31:0] multpart;
//    reg shiftr;
//    wire cf;
//    wire [31:0] add;
        reg [63:0] temp;
    reg [63:0]temp_a;
    reg [31:0] temp_b;
    integer cnt=0;
assign z=temp;
    always@(posedge clk or posedge reset)
    begin
        if(reset) begin
            cnt<=0;

            busy<=0;
            finish<=0;
        end
        else begin
            if(start) begin
                cnt<=0;
        temp<=0;
            temp_a<={32'b0,a};//无符号加0
            temp_b<=b;

                busy<=1;
                finish<=0;
            end else if(busy) begin
                if (!cpu_stall) begin
                  temp<=0;
         temp_a<={32'b0,a};//无符号加0
         temp_b<=b;
         cnt<=0;
                    for(cnt=0;cnt<32;cnt=cnt+1)
               begin
                  
                   if(temp_b[0])
                   begin
                       temp=temp+temp_a;
                   end
                   else
                   begin
                   end
                   temp_b=temp_b>>1;
                   temp_a=temp_a << 1;
               end
                            
                            busy<=0;
                            finish<=1;
                        
                end
            end
            else
                finish<=0;
        end
    end
endmodule