`timescale 1ns / 1ps

`include "define.vh"

module flow_control(
    input clk,
    input rst,
    input [6:0] waddr1,
    input [6:0] waddr2,
    input [6:0] waddr3,
    input [6:0] raddr1,
    input [6:0] raddr2,
    input overForcc,
    input stallForcc,
    input overstall,
    output [1:0] cond0,
    output [1:0] cond1,
    output [1:0] cond2,
    output [1:0] cond3,
    output [1:0] cond4,
    output [1:0] cond5,
    input ex_mem,
    input ex_mul,
    input [31:0] HI,
    input [31:0] LO,
    input [31:0] ex_Z,
   
    input me_mem,
    input me_mul,
    input [31:0] me_HI,
    input [31:0] me_LO,
    input [31:0] me_Z,
    input [31:0] me_MEM,
   
    input cpu_stall,

    output reg [31:0] ALUa,
    output reg [31:0] ALUb,
    output reg [31:0] id_Rt,
    output ALUa_w,
    output ALUb_w,
    output id_Rt_w
    
    );

    

    reg [1:0] cur_state,next_state;
    reg [4:0] count;
    reg vioForT;
    reg [1:0] Conds[0:5];
    wire vio;
    wire vio1=(waddr1!=7'b110_0000)
                    &&(raddr1==waddr1||raddr2==waddr1
                    ||(waddr1==7'b100_0010
                    &&(raddr1==7'b100_0000||raddr1==7'b100_0001||raddr2==7'b100_0000||raddr2==7'b100_0001)));
    wire vio2=(waddr2!=7'b110_0000)
                    &&(raddr1==waddr2||raddr2==waddr2
                    ||(waddr2==7'b100_0010
                    &&(raddr1==7'b100_0000||raddr1==7'b100_0001||raddr2==7'b100_0000||raddr2==7'b100_0001)));
    wire vio3=(waddr3!=7'b110_0000)
                    &&(raddr1==waddr3||raddr2==waddr3
                    ||(waddr3==7'b100_0010
                    &&(raddr1==7'b100_0000||raddr1==7'b100_0001||raddr2==7'b100_0000||raddr2==7'b100_0001)));
    
    assign vio=vio1|(vio2&ex_mem);
    assign cond0=Conds[0];
    assign cond1=Conds[1];
    assign cond2=Conds[2];
    assign cond3=Conds[3];
    assign cond4=Conds[4];
    assign cond5=Conds[5];
    always @(posedge clk or posedge rst) 
    begin
        if(rst)
            cur_state=`NORMAL;
        else
            cur_state=next_state;
    end

    assign ALUa_w=(!vio)
                    &&(raddr1!=7'b110_0000)
                    &&(raddr1==waddr2||raddr1==waddr3
                    ||(waddr2==7'b100_0010
                    &&(raddr1==7'b100_0000||raddr1==7'b100_0001))
                    ||(waddr3==7'b100_0010
                    &&(raddr1==7'b100_0000||raddr1==7'b100_0001)));
    assign ALUb_w=(!vio)&&(raddr2!=7'b110_0000)&&(raddr2==waddr2||raddr2==waddr3);
    assign id_Rt_w=ALUb_w;
    

    always @(*) 
    begin
        if(cpu_stall)
        begin
            next_state=cur_state;
            Conds[0]=`COND_STALL;  
            Conds[1]=`COND_STALL;  
            Conds[2]=`COND_STALL;  
            Conds[3]=`COND_STALL;  
            Conds[4]=`COND_STALL;
            Conds[5]=`COND_STALL;  
            
        end else 
        begin
            case (cur_state)
                `NORMAL: 
                begin
                    if (overstall) 
                    begin
                        if (vio) 
                        begin
                            next_state=`NORMAL;
                            Conds[0]=`COND_FLOW;  
                            Conds[1]=`COND_ZERO;  
                            Conds[2]=`COND_ZERO;  
                            Conds[3]=`COND_FLOW;  
                            Conds[4]=`COND_FLOW;
                            Conds[5]=`COND_FLOW;  
                            
                        end 
                        else 
                        begin
                            next_state=`NORMAL;
                            Conds[0]=`COND_FLOW;  
                            Conds[1]=`COND_FLOW;  
                            Conds[2]=`COND_ZERO;  
                            Conds[3]=`COND_FLOW;  
                            Conds[4]=`COND_FLOW;
                            Conds[5]=`COND_FLOW;  
                            
                        end
                    end
                    else if (!overForcc&stallForcc) 
                    begin
                        next_state=`MULDIV;
                        Conds[0]=`COND_STALL;  
                        Conds[1]=`COND_STALL;  
                        Conds[2]=`COND_STALL;  
                        Conds[3]=`COND_STALL;  
                        Conds[4]=`COND_STALL;
                        Conds[5]=`COND_STALL;  
                        
                    end
                    else if (vio) 
                    begin
                        next_state=`NORMAL;
                        Conds[0]=`COND_STALL;  
                        Conds[1]=`COND_ZERO;  
                        Conds[2]=`COND_FLOW;  
                        Conds[3]=`COND_FLOW;  
                        Conds[4]=`COND_FLOW;
                        Conds[5]=`COND_FLOW;  
                        
                    end 
                    else 
                    begin
                        next_state=`NORMAL;
                        Conds[0]=`COND_FLOW;  
                        Conds[1]=`COND_FLOW;  
                        Conds[2]=`COND_FLOW;  
                        Conds[3]=`COND_FLOW;  
                        Conds[4]=`COND_FLOW;
                        Conds[5]=`COND_FLOW;  
                        
                    end
                end
                `MULDIV: 
                begin
                    if (overForcc) 
                    begin
                        if (vio) 
                        begin
                            next_state=`NORMAL;
                            Conds[0]=`COND_STALL;  
                            Conds[1]=`COND_ZERO;  
                            Conds[2]=`COND_FLOW;  
                            Conds[3]=`COND_FLOW;  
                            Conds[4]=`COND_FLOW;
                            Conds[5]=`COND_FLOW;  
                            
                        end else 
                        begin
                            next_state=`NORMAL;
                            Conds[0]=`COND_FLOW;  
                            Conds[1]=`COND_FLOW;  
                            Conds[2]=`COND_FLOW;  
                            Conds[3]=`COND_FLOW;  
                            Conds[4]=`COND_FLOW;
                            Conds[5]=`COND_FLOW;  
                            
                        end
                    end 
                    else 
                    begin
                        Conds[0]=`COND_STALL;  
                        Conds[1]=`COND_STALL;  
                        Conds[2]=`COND_STALL;  
                        Conds[3]=`COND_STALL;  
                        Conds[4]=`COND_STALL;
                        Conds[5]=`COND_STALL;  
                        next_state=`MULDIV;
                    end
                end
                default: 
                begin
                    next_state=`NORMAL;
                    Conds[0]=`COND_FLOW;  
                    Conds[1]=`COND_FLOW;  
                    Conds[2]=`COND_FLOW;  
                    Conds[3]=`COND_FLOW;  
                    Conds[4]=`COND_FLOW;
                    Conds[5]=`COND_FLOW;  
                    
                end
            endcase
        end
    end
    always @(*) 
    begin
        if(!vio) 
        begin
            if(ALUa_w) 
            begin
                if(waddr2==raddr1||(waddr2==7'b100_0010&&(raddr1==7'b100_0000||raddr1==7'b100_0001))) 
                begin
                    case (waddr2)
                        7'b100_0000: ALUa=HI;
                        7'b100_0001: ALUa=LO;
                        7'b100_0010: 
                        begin
                            if (raddr1==7'b100_0000) begin
                                ALUa=HI;
                                vioForT =0;
                            end
                            else begin
                                vioForT =1;
                                ALUa=LO;
                            end
                        end
                        default: 
                        begin
                            case (waddr2[6:5])
                                2'b00: 
                                    ALUa=ex_Z;
                                2'b01: 
                                    ALUa=ex_Z;
                                default: 
                                begin 
                                    vioForT =0;
                                end
                            endcase
                        end
                    endcase
                end
                else 
                begin
                    if (me_mem) 
                    begin
                        ALUa=me_MEM;
                    end
                    case (waddr2)
                        7'b100_0000: ALUa=me_HI;
                        7'b100_0001: ALUa=me_LO;
                        7'b100_0010: 
                        begin
                            if (raddr1==7'b100_0000) 
                                ALUa=me_HI;
                            else
                                ALUa=me_LO;
                        end
                        default: 
                        begin
                            case (waddr2[6:5])
                                2'b00: ALUa=me_Z;
                                2'b01: ALUa=me_Z;
                                default: 
                                begin end
                            endcase
                        end
                    endcase
                end
            end

            if (id_Rt_w) 
            begin  
                if (raddr2==waddr2) begin
                    id_Rt=ex_mul?LO:ex_Z;
                end
                else 
                begin 
                    if (!me_mem) begin
                        id_Rt=me_mul?me_LO:me_Z;
                    end
                    else begin
                        id_Rt=me_MEM;
                        
                    end
                end
            end
            if (ALUb_w) 
            begin  
                if (raddr2==waddr2) begin
                    ALUb=ex_mul?LO:ex_Z;
                end
                else 
                begin  
                    if (!me_mem) begin
                        ALUb=me_mul?me_LO:me_Z;
                    end
                    else begin
                        ALUb=me_MEM;
                        
                    end
                end
            end

            
        end
    end
endmodule
