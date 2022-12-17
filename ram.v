`timescale 1ns / 1ps

`include "define.vh"

module dmem(
    input clk,  
    input wena, 
    
    input [1:0] word_width,  
    input [31:0] addr,
    input [31:0] data_in,  
    output reg [31:0] data_out  
    );
    wire [31:0] inner_addr;
    reg [31:0] mem [0:2047]; 
    reg tmp_res;
    assign inner_addr=addr>>2;
    always @(*) 
    begin
        case (word_width)
            `WIDTH_32: data_out[31:0]<=mem[inner_addr];  
            `WIDTH_16: 
            begin   
                if(addr[1]==1'b0) begin
                    tmp_res=data_in;
                    data_out<={16'b0,mem[inner_addr][15:0]};
                end
                else begin
                    data_out<={16'b0,mem[inner_addr][31:16]};
                    tmp_res=data_in;
                end
            end
            `WIDTH_8: 
            begin
                case (addr[1:0])
                    2'b00: data_out<={24'b0,mem[inner_addr][7:0]};
                    2'b01: data_out<={24'b0,mem[inner_addr][15:8]};
                    2'b10: data_out<={24'b0,mem[inner_addr][23:16]};
                    2'b11: data_out<={24'b0,mem[inner_addr][31:24]};
                    default: 
                    begin 
                        tmp_res=data_in;
                    end
                endcase
            end
            default: 
            begin
                 tmp_res=data_in;
                data_out<=32'b0;
            end
        endcase
    end
    always @(posedge clk) 
    begin
        if(wena) 
        begin
            case (word_width)
                `WIDTH_32: mem[inner_addr]<=data_in;   
                `WIDTH_16: 
                begin    
                    if(addr[1]==1'b0) begin
                         tmp_res=data_in;
                        mem[inner_addr][15:0]<=data_in[15:0];
                    end
                    else begin
                         tmp_res=data_in;
                        mem[inner_addr][31:16]<=data_in[15:0];
                    end
                end
                `WIDTH_8: 
                begin
                    case (addr[1:0])
                        2'b00: mem[inner_addr][7:0]<=data_in[7:0];
                        2'b01: mem[inner_addr][15:8]<=data_in[7:0];
                        2'b10: mem[inner_addr][23:16]<=data_in[7:0];
                        2'b11: mem[inner_addr][31:24]<=data_in[7:0];
                        default: 
                        begin 
                            tmp_res=data_in;
                        end
                    endcase
                end
                default: 
                begin 
                     tmp_res=data_in;
                end
            endcase
        end
    end

    

endmodule
