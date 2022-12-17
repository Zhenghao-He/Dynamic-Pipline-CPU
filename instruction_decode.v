`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/07 21:43:14
// Design Name: 
// Module Name: instruction_decode
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


module instruction_decode(
    input clk,
    input rst,

    input [31:0] if_IR, //to read
    input [31:0] if_NPC,
    input [4:0] regfile_Rdc,    //also cp0
    input [31:0] regfile_Rd,    //also cp0,hi,lo
    input [31:0] Rd_out_for_LO, //add for lo *only when hi also write

    output reg [31:0] rALUa,
    output reg [31:0] rALUb,
    output reg [31:0] rRt,
    output reg [31:0] rIR,
    output [31:0] cp0_EPC,
    output [31:0] cp0_intr_addr,
    output [31:0] ext_out,
    output [31:0] connect,
    output [31:0] regfile_Rs,
    output [31:0] regfile_Rt,

    //control signal
    input [1:0] cond,
    output [2:0] mux_pc_sel,
    input hi_w,
    input lo_w,
    input regfile_wena,
    input cp0_wena,
    output [6:0] flow_raddr1,
    output [6:0] flow_raddr2,

    //forward
    input [31:0] forward_ALUa,
    input [31:0] forward_ALUb,
    input [31:0] forward_Rt,
    input forward_ALUa_w,
    input forward_ALUb_w,
    input forward_Rt_w,

    //for program out
    output [31:0] reg_28
    );

    assign connect={if_NPC[31:28],if_IR[25:0],2'b0};

    reg [31:0] rHI,rLO;

    wire mux_lo_sel,mux_hi_sel;
    wire [31:0] cal_lo_out,cal_hi_out,mux_lo_out,mux_hi_out;
    wire [31:0] alua,alub;
    wire [31:0] cp0_out;wire [4:0] cp0_cause;

    wire [2:0] mux_ALUa;wire [1:0] mux_ALUb;wire [2:0] ext_sel;
    wire [53:0] decoded_instr;
    wire cp0_eret,cp0_exp;

    wire beq,bgez;
    wire  cp0_ena,mfc0;
    assign beq=((forward_ALUa_w?forward_ALUa:regfile_Rs)==(forward_ALUb_w?forward_ALUb:regfile_Rt));
    assign bgez=(forward_ALUa_w?(forward_ALUa[31]==1'b0):(regfile_Rs[31]==1'b0));
    wire [31:0]status;
    wire [4:0] cp0_addr;
    assign cp0_addr=cp0_wena?regfile_Rdc:if_IR[15:11];
    instr_decoder inst_de(
        .instr_code(if_IR),
        .decoder_ena(1),
        .i(decoded_instr)
    );
    controller con_id(
        .inst(if_IR),
        .decoded_instr(decoded_instr),
        .beq(beq), 
        .bgez(bgez), 
        .mux_pc_sel(mux_pc_sel),
        .mux_ALUa(mux_ALUa),
        .mux_ALUb(mux_ALUb),
        .ext_sel(ext_sel),
        .cp0_exp(cp0_exp),
        .cp0_eret(cp0_eret),
        .cp0_cause(cp0_cause),
        .raddr1(flow_raddr1),
        .raddr2(flow_raddr2)
    );

    mux_len32_sel8 m_ALUa(
        .choose(mux_ALUa),
        .data1(rHI),
        .data2(rLO),
        .data3(if_NPC),
        .data4(regfile_Rs),
        .data5(ext_out),
        .data6(cp0_out),
        .data7(32'b0),
        .data_out(alua)
    );
    mux4 #(32) m_ALUb(
        .choose(mux_ALUb),
        .data1(32'd0),
        .data2(regfile_Rt),
        .data3(ext_out),
        .data_out(alub)
    );
    ext ext_id(
        .ent_sig(ext_sel),
        .data5(if_IR[10:6]),
        .data16(if_IR[15:0]),
        .data_out(ext_out)
    );


    RF rf(
        .clk(clk),  
        .rst(rst),  
        .we(regfile_wena),   
        .raddr1({27'b0,if_IR[25:21]}),
        .raddr2({27'b0,if_IR[20:16]}),
        .waddr({27'b0,regfile_Rdc}),
        .wdata(regfile_Rd),
        .rdata1(regfile_Rs),
        .rdata2(regfile_Rt),
        .reg_28(reg_28)
    );

    cp0 cp0_inst(
        .clk(clk),
        .rst(rst),
        .ena(cp0_ena),
        .mfc0(mfc0),
        .mtc0(cp0_wena),
        .pc(if_NPC),
        .cp0_addr(cp0_addr),
        .wdata(regfile_Rd), 
        .exception(cp0_exp&&(cond==`COND_FLOW)),   
        .eret(cp0_eret&&(cond==`COND_FLOW)), 
        .cause(cp0_cause),
        .rdata(cp0_out), 
        .status(status), 
        .exc_addr(cp0_EPC), 
        .intr_addr(cp0_intr_addr)
    );

    always @(negedge clk or posedge rst) 
    begin   
        if (rst) 
        begin
            rIR<=`IR_NON;
        end else 
        begin
            case (cond)
                `COND_FLOW: rIR<=if_IR;
                `COND_STALL: rIR<=rIR;
                `COND_ZERO: rIR<=`IR_NON;
                default: 
                begin 

                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            rALUa<=32'b0;
            rALUb<=32'b0;
            rRt<=32'b0;
            rHI<=32'b0;
            rLO<=32'b0;
        end 
        else 
        begin
            case (cond)
                `COND_FLOW: 
                begin
                    rALUa<=forward_ALUa_w?forward_ALUa:alua;
                    rALUb<=forward_ALUb_w?forward_ALUb:alub;
                    rRt<=forward_Rt_w?forward_Rt:regfile_Rt;
                end
                `COND_STALL: 
                begin
                    rALUa<=rALUa;
                    rALUb<=rALUb;
                    rRt<=rRt;
                end
                `COND_ZERO: 
                begin
                    rALUa<=32'b0;
                    rALUb<=32'b0;
                    rRt<=32'b0;
                end
                default: 
                begin 

                end
            endcase
            rHI<=hi_w?regfile_Rd:rHI;
            rLO<=lo_w?(hi_w?Rd_out_for_LO:regfile_Rd):rLO;
        end
    end

  
endmodule

