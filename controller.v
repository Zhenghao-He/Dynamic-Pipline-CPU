`timescale 1ns / 1ps
`include "define.vh"

module controller(
    input [31:0] inst,
    input [53:0] decoded_instr,
    input judge_beq, 
    input judge_bgez,

    /*-----------flow_control-----------*/
    output reg [6:0] raddr1,
    output reg [6:0] raddr2,
    output reg [6:0] waddr,
    output reg dmem_r,

    /*-----------control-----------*/
    //ID
    output reg [2:0] mux_pc_sel,
    output reg [2:0] mux_ALUa_sel,
    output reg [1:0] mux_ALUb_sel,
    output reg [2:0] ext_sel,
    output reg cp0_exception,
    output reg cp0_eret,
    output reg [4:0] cp0_cause,
    //EX
    output reg [3:0] alu_sel,
    output reg [1:0] cal_sel,
    output reg cal_ena/*also for stall*/,
    output reg use_overflow,
    //ME
    output reg dmem_w,
    output reg [1:0] dmem_width,
    output reg [2:0] mem_sel,
    //WB
    output reg [1:0] mux_Rdc_sel,
    output reg [1:0] mux_Rd_sel,
    output reg hi_w,
    output reg lo_w,
    output reg regfile_w,
    output reg cp0_w
    );
    parameter Syscall=5'b01000,Break=5'b01001,Teq=5'b01101;
    always @(*) begin
            if(decoded_instr[0])begin    //add
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[1])begin    //addu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[2])begin    //sub
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SUB;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[3])begin    //subu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SUBU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[4])begin    //and
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_AND;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[5])begin    //or
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_OR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[6])begin    //xor
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_XOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[7])begin    //nor
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_NOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[8])begin    //slt
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLT;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[9])begin    //sltu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLTU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[10])begin    //sll
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[11])begin    //srl
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SRL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[12])begin    //sra
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SRA;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[13])begin    //sllv
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[14])begin    //srlv
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SRL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[15])begin    //srav
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SRA;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[16])begin    //jr
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_RS;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[17])begin    //addi
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[18])begin    //addiu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[19])begin    //andi
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_AND;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[20])begin    //ori
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_OR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[21])begin    //xori
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_XOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[22])begin    //lw
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_32;mem_sel<=`EXT32_NON;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[23])begin    //sw
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_32;mem_sel<=`EXT32_NON;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[24])begin    //beq
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_beq?`MUX_PC_NPCEXT:`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[25])begin    //bne
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_beq?`MUX_PC_NPC:`MUX_PC_NPCEXT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[26])begin    //slti
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLT;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[27])begin    //sltiu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLTU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[28])begin    //lui
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_LUI;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end       
            else if(decoded_instr[29])begin    //j
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_CONNECT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[30])begin    //jal
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,5'd31};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_CONNECT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[31])begin    //clz
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_CLZ;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[32])begin    //divu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_DIVU;cal_ena<=1'b1;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[33])begin    //div
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_DIV;cal_ena<=1'b1;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[34])begin    //mul
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b1;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_LO;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[35])begin    //multu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULTU;cal_ena<=1'b1;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[36])begin    //jarl
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_RS;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[37])begin    //bgez
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_bgez?`MUX_PC_NPCEXT:`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[38])begin    //lh
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[39])begin    //lb
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end        
            else if(decoded_instr[40])begin    //lbu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[41])begin    //lhu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end            
            else if(decoded_instr[42])begin    //sb
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[43])begin    //sh
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end          
            else if(decoded_instr[44])begin     //mfc0
                //FLOW
                raddr1<={`VIOLATION_CP0REG_HEAD,inst[15:11]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_CP0;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[45])begin     //mtc0
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[20:16]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_CP0REG_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_IMM0;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b1;
            end
            else if(decoded_instr[46])begin    //mfhi
                //FLOW
                raddr1<=`VIOLATION_HI;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_HI;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            else if(decoded_instr[47])begin    //mthi
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_HI;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b1;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[48])begin    //mflo
                //FLOW
                raddr1<=`VIOLATION_LO;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_LO;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end         
            else if(decoded_instr[49])begin    //mtlo
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_LO;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[50])begin     //eret
                //FLOW
                raddr1<={`VIOLATION_CP0REG_HEAD,5'd14};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_EPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b1;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[51])begin    //syscall
                //FLOW
                raddr1<={`VIOLATION_CP0REG_HEAD,5'd12};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_INTR_ADDR;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b1;cp0_eret<=1'b0;cp0_cause<=Syscall;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[52])begin    //teq
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_INTR_ADDR;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=judge_beq;cp0_eret<=1'b0;cp0_cause<=Teq;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            else if(decoded_instr[53])begin    //break
                //FLOW
                raddr1<={`VIOLATION_CP0REG_HEAD,5'd12};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_INTR_ADDR;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b1;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end

            else begin    //do nothing
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=Break;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end         
    end
endmodule
