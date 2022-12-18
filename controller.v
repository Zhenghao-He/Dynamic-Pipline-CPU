`timescale 1ns / 1ps
`include "define.vh"

module controller(
    input [31:0] inst,
    input [53:0] decoded_instr,
    input beq, 
    input bgez,
    output [6:0] raddr1,
    output [6:0] raddr2,
    output reg [6:0] waddr,
    output reg dmem_read,
    output reg [2:0] mux_pc_sel,
    output reg [2:0] mux_ALUa,
    output reg [1:0] mux_ALUb,
    output reg [2:0] ext_sel,
    output reg cp0_exp,
    output reg cp0_eret,
    output reg [4:0] 
    cp0_cause,
    output  [3:0] aluc,
    output reg [1:0] cal_sel,
    output reg cal_ena,
    output reg overflow,
    output reg dmem_write,
    output reg [1:0] dmemory_width,
    output reg [2:0] mem_sel,
    output reg [1:0] mux_Rdc,
    output reg [1:0] mux_Rd,
    output reg hi_wena,
    output reg lo_wena,
    output reg rf_wena,
    output reg cp0_wena
    );
    parameter Syscall=5'b01000,Break=5'b01001,Teq=5'b01101;
    assign aluc[3] =decoded_instr[8] ||decoded_instr[9] ||decoded_instr[10] ||decoded_instr[11] ||decoded_instr[12] ||decoded_instr[13] ||decoded_instr[14] ||decoded_instr[15] ||decoded_instr[26] ||decoded_instr[27] ||decoded_instr[28];
    assign aluc[2] =decoded_instr[4] ||decoded_instr[5] ||decoded_instr[6] ||decoded_instr[7] ||decoded_instr[10] ||decoded_instr[11] ||decoded_instr[12] ||decoded_instr[13] ||decoded_instr[14] ||decoded_instr[15] ||decoded_instr[19] ||decoded_instr[20] ||decoded_instr[21];
    assign aluc[1] =decoded_instr[0] ||decoded_instr[2] ||decoded_instr[6] ||decoded_instr[7] ||decoded_instr[8] ||decoded_instr[9] ||decoded_instr[10] ||decoded_instr[13] ||decoded_instr[17] ||decoded_instr[21] ||decoded_instr[24] ||decoded_instr[25] ||decoded_instr[26] ||decoded_instr[27] ||decoded_instr[52] ;
    assign aluc[0] =decoded_instr[2] ||decoded_instr[3] ||decoded_instr[5] ||decoded_instr[7] ||decoded_instr[8] ||decoded_instr[11] ||decoded_instr[14] ||decoded_instr[20] ||decoded_instr[24] ||decoded_instr[25] ||decoded_instr[26] ||decoded_instr[52];
    
    assign raddr1 =
            decoded_instr[30]?{2'b00,5'd31} : 
            (decoded_instr[44])?{2'b01,inst[15:11]}:
            (decoded_instr[46])?7'b100_0000:
            (decoded_instr[48])?7'b100_0001:
            (decoded_instr[50])?{2'b01,5'd14}:
            (decoded_instr[51]||decoded_instr[53])?{2'b01,5'd12}:
            (decoded_instr[10]||decoded_instr[11]||decoded_instr[12]||decoded_instr[28]||decoded_instr[29])?7'b110_0000:{2'b00,inst[25:21]}
            ;
    
    assign raddr2 = (decoded_instr[22:17]||decoded_instr[31:29]||decoded_instr[41:36]||decoded_instr[53:45]||decoded_instr[43:42])?7'b110_0000:{2'b00,inst[20:16]};
    
    // assign waddr = 
    //         (decoded_instr[22:17]||decoded_instr[28:26]||decoded_instr[41:38]||decoded_instr[44])?{2'b00,inst[20:16]}:
    //         (decoded_instr[45])?{2'b01,inst[15:11]}:
    //         (decoded_instr[47])?7'b100_0000:
    //         (decoded_instr[49])?7'b100_0001:
    //         (decoded_instr[33:32]||decoded_instr[35])?7'b100_0010:
    //         (decoded_instr[16]||decoded_instr[25:23]||decoded_instr[30:29]||decoded_instr[37]||decoded_instr[43:42]||decoded_instr[53:50])?7'b110_0000:
    //         {2'b00,inst[15:11]};
    always@(*)
    begin
        if( (decoded_instr[22:17]||decoded_instr[28:26]||decoded_instr[41:38]||decoded_instr[44]))
            waddr={2'b00,inst[20:16]};
        else if((decoded_instr[45]))
            waddr={2'b01,inst[15:11]};
        else if((decoded_instr[47]))
            waddr=7'b100_0000;
        else if((decoded_instr[49]))
            waddr= 7'b100_0001;
        else if((decoded_instr[33:32]||decoded_instr[35]))
            waddr=7'b100_0010;
        else if((decoded_instr[16]||decoded_instr[25:23]||decoded_instr[30:29]||decoded_instr[37]||decoded_instr[43:42]||decoded_instr[53:50]))
            waddr=7'b110_0000;
        else 
        begin
            waddr={2'b00,inst[15:11]};
        end
    end

    reg [6:0] raddr12,raddr21,waddr1;
    always @(*) 
    begin
             
            if(decoded_instr[0])
            begin    //add
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b1;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[1])
            begin    //addu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[2])
            begin    //sub
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b1;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[3])
            begin    //subu
                
               dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[4])
            begin    //and
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[5])
            begin    //or
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[6])
            begin    //xor
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[7])
            begin    //nor
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[8])
            begin    //slt
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[9])
            begin    //sltu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[10])
            begin    //sll
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_EXT;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[11])
            begin    //srl
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_EXT;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[12])
            begin    //sra
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_EXT;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
               cal_sel<=`MUL;
               
               cal_ena<=1'b0;
               overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[13])
            begin    //sllv
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[14])
            begin    //srlv
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[15])
            begin    //srav
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[16])
            begin    //jr
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_RS;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[17])
            begin    //addi
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b1;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[18])
            begin    //addiu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[19])
            begin    //andi
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[20])
            begin    //ori
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[21])
            begin    //xori
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[22])
            begin    //lw
                
                dmem_read<=1'b1;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_32;
                mem_sel<=`EXTEND32_NON;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[23])
            begin    //sw
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b1;
                dmemory_width<=`WIDTH_32;
                mem_sel<=`EXTEND32_NON;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[24])
            begin    //beq
                
                dmem_read<=1'b0;
                mux_pc_sel<=beq?`SELECT_PC_NPCEXT:`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_SL2_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[25])
            begin    //bne
                
                dmem_read<=1'b0;
                mux_pc_sel<=beq?`SELECT_PC_NPC:`SELECT_PC_NPCEXT;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND16_SL2_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[26])
            begin    //slti
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[27])
            begin    //sltiu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[28])
            begin    //lui
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end       
            else if(decoded_instr[29])
            begin    //j
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_CONNECT;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[30])
            begin    //jal
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_CONNECT;
                mux_ALUa<=`SELECT_ALUa_NPC;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[31])
            begin    //clz
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[32])
            begin    //divu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`DIVU;
                cal_ena<=1'b1;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_HI;
                hi_wena<=1'b1;
                lo_wena<=1'b1;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[33])
            begin    //div
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`DIV;
                cal_ena<=1'b1;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_HI;
                hi_wena<=1'b1;
                lo_wena<=1'b1;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[34])
            begin    //mul
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                cal_ena<=1'b1;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_LO;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[35])
            begin    //multu
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                cal_ena<=1'b1;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_HI;
                hi_wena<=1'b1;
                lo_wena<=1'b1;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[36])
            begin    //jarl
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_RS;
                mux_ALUa<=`SELECT_ALUa_NPC;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MUL;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[37])
            begin    //bgez
                
                dmem_read<=1'b0;
                mux_pc_sel<=bgez?`SELECT_PC_NPCEXT:`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_NPC;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND16_SL2_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[38])
            begin    //lh
                
                dmem_read<=1'b1;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND16_S;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[39])
            begin    //lb
                
                dmem_read<=1'b1;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_8;
                mem_sel<=`EXTEND8_S;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end        
            else if(decoded_instr[40])
            begin    //lbu
                
                dmem_read<=1'b1;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_8;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[41])
            begin    //lhu
                
                dmem_read<=1'b1;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND16_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end            
            else if(decoded_instr[42])
            begin    //sb
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b1;
                dmemory_width<=`WIDTH_8;
                mem_sel<=`EXTEND8_S;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[43])
            begin    //sh
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_EXT;
                ext_sel<=`EXTEND16_S;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b1;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND16_S;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_MEM;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end          
            else if(decoded_instr[44])
            begin     //mfc0
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_CP0;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_20_16;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[45])
            begin     //mtc0
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_IMM0;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b1;
            end
            else if(decoded_instr[46])
            begin    //mfhi
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_HI;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[47])
            begin    //mthi
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b1;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[48])
            begin    //mflo
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_LO;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IR_15_11;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b1;
                cp0_wena<=1'b0;
            end         
            else if(decoded_instr[49])
            begin    //mtlo
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_NPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_IMM0;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b1;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[50])
            begin     //eret
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_EPC;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b0;
                cp0_eret<=1'b1;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[51])
            begin    //syscall
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_INTR_ADDR;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b1;
                cp0_eret<=1'b0;
                cp0_cause<=Syscall;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[52])
            begin    //teq
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_INTR_ADDR;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=beq;
                cp0_eret<=1'b0;
                cp0_cause<=Teq;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end
            else if(decoded_instr[53])
            begin    //break
                
                dmem_read<=1'b0;
                mux_pc_sel<=`SELECT_PC_INTR_ADDR;
                mux_ALUa<=`SELECT_ALUa_RS;
                mux_ALUb<=`SELECT_ALUb_RT;
                ext_sel<=`EXTEND5_Z;
                cp0_exp<=1'b1;
                cp0_eret<=1'b0;
                cp0_cause<=Break;
                cal_sel<=`MULU;
                
                cal_ena<=1'b0;
                overflow<=1'b0;
                dmem_write<=1'b0;
                dmemory_width<=`WIDTH_16;
                mem_sel<=`EXTEND8_Z;
                mux_Rdc<=`SELECT_RDC_IMM31;
                mux_Rd<=`SELECT_RD_Z;
                hi_wena<=1'b0;
                lo_wena<=1'b0;
                rf_wena<=1'b0;
                cp0_wena<=1'b0;
            end

            else 
            begin  
                
                
                cal_ena<=1'b0;
            end         
    end
endmodule
