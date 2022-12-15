`timescale 1ns / 1ps

module mux_len32_sel8(
    input [2:0] sel,
    input [31:0] iData_1,
    input [31:0] iData_2,
    input [31:0] iData_3,
    input [31:0] iData_4,
    input [31:0] iData_5,
    input [31:0] iData_6,
    input [31:0] iData_7,
    input [31:0] iData_8,
    output reg [31:0] oData
    );


    always @(*) begin
        case(sel)
            3'b000: oData<=iData_1;
            3'b001: oData<=iData_2;
            3'b010: oData<=iData_3;
            3'b011: oData<=iData_4;
            3'b100: oData<=iData_5;
            3'b101: oData<=iData_6;
            3'b110: oData<=iData_7;
            3'b111: oData<=iData_8;
            default: begin end
        endcase
    end
endmodule


module mux_len32_sel4(
    input [1:0] sel,
    input [31:0] iData_1,
    input [31:0] iData_2,
    input [31:0] iData_3,
    input [31:0] iData_4,
    output reg [31:0] oData
    );

    //reg oData;  //wire in implementation

    always @(*) begin
        case(sel)
            2'b00: oData<=iData_1;
            2'b01: oData<=iData_2;
            2'b10: oData<=iData_3;
            2'b11: oData<=iData_4;
            default: begin end
        endcase
    end
endmodule


module mux_len5_sel4(
    input [1:0] sel,
    input [4:0] iData_1,
    input [4:0] iData_2,
    input [4:0] iData_3,
    input [4:0] iData_4,
    output reg [4:0] oData
    );

    //reg oData;  //wire in implementation

    always @(*) begin
        case(sel)
            2'b00: oData<=iData_1;
            2'b01: oData<=iData_2;
            2'b10: oData<=iData_3;
            2'b11: oData<=iData_4;
            default: begin end
        endcase
    end
endmodule