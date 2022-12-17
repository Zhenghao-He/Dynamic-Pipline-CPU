`timescale 1ns / 1ps

`include "define.vh"

module ext(
    input [2:0] ent_sig,

    input [4:0] data5,
    input [7:0] data8,
    input [15:0] data16,
    input [31:0] data32,
    output reg [31:0] data_out
);

always @(*) begin
    case (ent_sig)
        `EXTEND32_NON: data_out<=data32;
        `EXTEND8_Z: data_out<={24'b0,data8};
        `EXTEND16_SL2_S: data_out=data16[15]?{14'h3fff,data16,2'b0}:{14'b0,data16,2'b0};
        `EXTEND16_S: data_out<={{16{data16[15]}},data16};
        `EXTEND5_Z: data_out<={27'b0,data5};
        `EXTEND8_S: data_out<={{24{data8[7]}},data8};
        `EXTEND16_Z: data_out<={16'b0,data16};    
        default: 
        begin
            data_out<=32'b0;
        end
    endcase
end
endmodule
