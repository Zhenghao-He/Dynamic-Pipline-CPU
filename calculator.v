`timescale 1ns / 1ps
`include "define.vh"

module calculator(
    input clk,
    input rst,     
    input ena,  
    input [31:0] a,
    input [31:0] b,
    input [1:0] calc,
    
    output reg [31:0] oLO,
    output reg [31:0] oHI,
    output reg sum_finish,
    input cpu_stall
    );

    wire clock;
    reg Start_sig;
    reg busy;
    wire b_Mul;
    wire b_Mulu;
    wire b_Divu;
    wire b_Div;

    wire f_Mul;
    wire f_Mulu;
    wire f_Divu;
    wire f_Div;
    wire Start_sig_mult;
    wire Start_sig_multu;
    wire Start_sig_div;
    wire Start_sig_divu;
    
    wire [63:0] res_Mul,res_Mulu,res_Div,res_Divu;
    
    reg [1:0] calc_2;

    assign Start_sig_mult=Start_sig&&(calc==`MUL);
    assign Start_sig_multu=Start_sig&&(calc==`MULU);
    assign Start_sig_div=Start_sig&&(calc==`DIV);
    assign Start_sig_divu=Start_sig&&(calc==`DIVU);
    assign clock=~clk;

    DIVU divu(.dividend(a),.divisor(b),.start(Start_sig_divu),.clock(clock),.reset(rst),.q(res_Divu[31:0]),.r(res_Divu[63:32]),.busy(b_Divu),.finish(f_Divu),.cpu_stall(cpu_stall));
    DIV div(.dividend(a),.divisor(b),.start(Start_sig_div),.clock(clock),.reset(rst),.q(res_Div[31:0]),.r(res_Div[63:32]),.busy(b_Div),.finish(f_Div),.cpu_stall(cpu_stall));
    MULTU mulu(.clk(clock),.reset(rst),.start(Start_sig_multu),.a(a),.b(b),.z(res_Mulu),.busy(b_Mulu),.finish(f_Mulu),.cpu_stall(cpu_stall));
    MULT mul(.clk(clock),.reset(rst),.start(Start_sig_mult),.a(a),.b(b),.z(res_Mul),.busy(b_Mul),.finish(f_Mul),.cpu_stall(cpu_stall));
    


    always @(posedge ena or posedge busy or posedge rst) 
    begin
        if (rst) 
        begin
            Start_sig=0;
        end 
        else 
        begin
            if (busy) 
                Start_sig=0;
            else if(ena)
                Start_sig=1;
        end
    end
    always @(negedge clk) 
    begin
        calc_2=calc;
    end

    always @(*) 
    begin
        case (calc)
            `MULU: 
            begin
                busy=b_Mulu;
            end
            `MUL: 
            begin
                busy=b_Mul;
            end
            `DIVU: 
            begin
                busy=b_Divu;
            end
            `DIV: 
            begin
                busy=b_Div;
            end
            default: 
            begin 

            end
        endcase
    end

    always @(*) 
    begin
        case (calc_2)
            `MULU: 
            begin
                oLO=res_Mulu[31:0];
                oHI=res_Mulu[63:32];
                sum_finish=f_Mulu;
            end
            `MUL: 
            begin
                oLO=res_Mul[31:0];
                oHI=res_Mul[63:32];
                sum_finish=f_Mul;
            end
            `DIVU: 
            begin
                oLO=res_Divu[31:0];
                oHI=res_Divu[63:32];
                sum_finish=f_Divu;
            end
            `DIV: 
            begin
                oLO=res_Div[31:0];
                oHI=res_Div[63:32];
                sum_finish=f_Div;
            end
            default: 
            begin 

            end
        endcase
    end



   
endmodule
