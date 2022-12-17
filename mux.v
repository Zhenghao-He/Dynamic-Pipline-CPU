`timescale 1ns / 1ps
module mux4 # (parameter WIDTH=32)(
    input [WIDTH-1:0]data1,
    input [WIDTH-1:0]data2,
    input [WIDTH-1:0]data3,
    input [WIDTH-1:0]data4,
    input [1:0]choose,
    output reg [WIDTH-1:0]data_out
    
    );
    always@(*)
    begin
        case(choose)
            2'd0: data_out=data1;
            2'd1: data_out=data2;
            2'd2: data_out=data3;
            2'd3: data_out=data4;
        endcase
    end
    
endmodule
module mux_len32_sel8(
    input [2:0] choose,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] data3,
    input [31:0] data4,
    input [31:0] data5,
    input [31:0] data6,
    input [31:0] data7,
    input [31:0] data8,
    output reg [31:0] data_out
    );


    always @(*) begin
        case(choose)
            3'b000: data_out<=data1;
            3'b001: data_out<=data2;
            3'b010: data_out<=data3;
            3'b011: data_out<=data4;
            3'b100: data_out<=data5;
            3'b101: data_out<=data6;
            3'b110: data_out<=data7;
            3'b111: data_out<=data8;
            default: begin end
        endcase
    end
endmodule

