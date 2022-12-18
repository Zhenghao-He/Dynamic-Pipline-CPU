`timescale 1ns / 1ps
module cpu_tb();
    reg clk;
    reg rst;
    wire [31:0] inst,pc;
    reg [31:0] pc_2[0:4],inst_2[0:4];
    wire [31:0] reg_28;
    reg stall;
    wire [53:0] decoded_instr;
    wire [6:0] waddr;
    wire [6:0] waddr1;
    wire [6:0] t_wa;
    assign waddr=uut.ID.con_id.waddr;
    assign waddr1=uut.ID.con_id.waddr1;
    assign t_wa=waddr-waddr1;
    assign decoded_instr=uut.ID.con_id.decoded_instr;
        integer file_output;
    integer counter=0;
    initial begin
        file_output=$fopen("output.txt");
        pc_2[0]=32'h0000_0000;
        clk=0;
        rst=1;
        stall=0;
        #274;
        rst=0;
    end
    sccomp_dataflow uut(
        clk,  
        rst,    
        stall,
        pc,
        inst,
        reg_28
        
    );
    always begin
        #1;
        clk=~clk;
        #1;
        if(clk==1'b0&&rst==0) begin
            if(counter==5000) begin
                $fclose(file_output);
                $finish;
            end 
            else if(pc_2[0]!=pc) begin
                pc_2[4]=pc_2[3];
                pc_2[3]=pc_2[2];
                pc_2[2]=pc_2[1];
                pc_2[1]=pc_2[0];
                pc_2[0]=pc;

                inst_2[4]=inst_2[3];
                inst_2[3]=inst_2[2];
                inst_2[2]=inst_2[1];
                inst_2[1]=inst_2[0];
                inst_2[0]=inst;
                
                if (pc_2[4]!=32'h0000_0000) begin
                    counter=counter+1;
                    $fdisplay(file_output,"pc: %h",pc_2[4]);
                    $fdisplay(file_output,"instr: %h",inst_2[4]);
                    $fdisplay(file_output,"regfile0: %h",cpu_tb.uut.ID.rf.array_reg[0]);
                    $fdisplay(file_output,"regfile1: %h",cpu_tb.uut.ID.rf.array_reg[1]);
                    $fdisplay(file_output,"regfile2: %h",cpu_tb.uut.ID.rf.array_reg[2]);
                    $fdisplay(file_output,"regfile3: %h",cpu_tb.uut.ID.rf.array_reg[3]);
                    $fdisplay(file_output,"regfile4: %h",cpu_tb.uut.ID.rf.array_reg[4]);
                    $fdisplay(file_output,"regfile5: %h",cpu_tb.uut.ID.rf.array_reg[5]);
                    $fdisplay(file_output,"regfile6: %h",cpu_tb.uut.ID.rf.array_reg[6]);
                    $fdisplay(file_output,"regfile7: %h",cpu_tb.uut.ID.rf.array_reg[7]);
                    $fdisplay(file_output,"regfile8: %h",cpu_tb.uut.ID.rf.array_reg[8]);
                    $fdisplay(file_output,"regfile9: %h",cpu_tb.uut.ID.rf.array_reg[9]);
                    $fdisplay(file_output,"regfile10: %h",cpu_tb.uut.ID.rf.array_reg[10]);
                    $fdisplay(file_output,"regfile11: %h",cpu_tb.uut.ID.rf.array_reg[11]);
                    $fdisplay(file_output,"regfile12: %h",cpu_tb.uut.ID.rf.array_reg[12]);
                    $fdisplay(file_output,"regfile13: %h",cpu_tb.uut.ID.rf.array_reg[13]);
                    $fdisplay(file_output,"regfile14: %h",cpu_tb.uut.ID.rf.array_reg[14]);
                    $fdisplay(file_output,"regfile15: %h",cpu_tb.uut.ID.rf.array_reg[15]);
                    $fdisplay(file_output,"regfile16: %h",cpu_tb.uut.ID.rf.array_reg[16]);
                    $fdisplay(file_output,"regfile17: %h",cpu_tb.uut.ID.rf.array_reg[17]);
                    $fdisplay(file_output,"regfile18: %h",cpu_tb.uut.ID.rf.array_reg[18]);
                    $fdisplay(file_output,"regfile19: %h",cpu_tb.uut.ID.rf.array_reg[19]);
                    $fdisplay(file_output,"regfile20: %h",cpu_tb.uut.ID.rf.array_reg[20]);
                    $fdisplay(file_output,"regfile21: %h",cpu_tb.uut.ID.rf.array_reg[21]);
                    $fdisplay(file_output,"regfile22: %h",cpu_tb.uut.ID.rf.array_reg[22]);
                    $fdisplay(file_output,"regfile23: %h",cpu_tb.uut.ID.rf.array_reg[23]);
                    $fdisplay(file_output,"regfile24: %h",cpu_tb.uut.ID.rf.array_reg[24]);
                    $fdisplay(file_output,"regfile25: %h",cpu_tb.uut.ID.rf.array_reg[25]);
                    $fdisplay(file_output,"regfile26: %h",cpu_tb.uut.ID.rf.array_reg[26]);
                    $fdisplay(file_output,"regfile27: %h",cpu_tb.uut.ID.rf.array_reg[27]);
                    $fdisplay(file_output,"regfile28: %h",cpu_tb.uut.ID.rf.array_reg[28]);
                    $fdisplay(file_output,"regfile29: %h",cpu_tb.uut.ID.rf.array_reg[29]);
                    $fdisplay(file_output,"regfile30: %h",cpu_tb.uut.ID.rf.array_reg[30]);
                    $fdisplay(file_output,"regfile31: %h",cpu_tb.uut.ID.rf.array_reg[31]);
                end
            end
        end
    end
endmodule

