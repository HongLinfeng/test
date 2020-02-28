module adder(
    clk,
    rst_n,
    Start_Sig,
    A,
    B,
    Result,
    Done_Sig
);
    input   clk;
    input   rst_n;
    input   Start_Sig;
    input   [31:0]A;
    input   [31:0]B;

    output  [31:0]Result;
    output  [3:0]Done_Sig;//isOver,isUnder,isZero,isDone

    reg     [3:0]  i;
    reg     [56:0]rA,rB;//[56]Sign,[55:48]Exponent,[47:46]Hidden Bit,[45:23]Mantissa,[22:0]M'Backup
    reg     [48:0]Temp;//[48]M'Sign,[47:46]Hidden Bit,[45:23]M,[22:0]M'Backup
    reg     [48:0]TempA,TempB;
    reg     [31:0]rResult;
    wire     [9:0]rExp;//[9:8]Overflow or underflow check,[7;0]usual exp
    reg     [9:0]rExpValue;
    reg     [7:0]rExpDiff;//different between A.EXP and B.EXP
    reg     isSign;
    reg     isOver;
    reg     isUnder;
    reg     isZero;
    reg     isDone;

    assign rExp = A[30:23]-B[30:23];//价码差值
    always@(posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        i <= 0;
        rA <= 0;
        rB <= 0;
        Temp <= 0;
        TempA <= 0;
        TempB <= 0;
        rResult <= 0;
        //rExp <= 0;
        rExpDiff <= 0;
        isSign <= 0;
        isOver <= 0;
        isUnder <= 0;
        isZero <= 0;
        isDone <= 0;
        rExpValue <= 0;
    end
    else if(Start_Sig)//使能控制，后面可以改为触发控制
    begin
        case(i)
            0:begin//initial A,B and other reg
                rA <= {A[31],A[30:23],2'b01,A[22:0],23'd0};
                rB <= {B[31],B[30:23],2'b01,B[22:0],23'd0};

                isOver <= 1'b0;
                isUnder <= 1'b0;
                isZero <= 1'b0;
                i <= i+1'b1;
            end
            1://价码对齐,可以和第一步合并
            begin
                if(rExp[8] == 1)//A<B
                    rExpDiff <= ~rExp[7:0] + 1'b1;//价码差值
                else 
                    rExpDiff <= rExp[7:0];
                i <= i+1; 
            end
            2://,可以和上一步合并
            begin
                if(rExp[8]==1)//A<B
                begin   
                    rA[47:0] <= rA[47:0]>>(rExpDiff);
                    rA[55:48] <= rB[55:48];
                end else begin
                    rB[47:0] <= rB[47:0]>>(rExpDiff);
                    rB[55:48] <= rA[55:48];
                end
                i <= i+1'b1;
            end
            3://补码转换
            begin   
                TempA <= rA[56]?{rA[56],(~rA[47:0]+1'b1)}:{rA[56],rA[47:0]};
                TempB <= rB[56]?{rB[56],(~rB[47:0]+1'b1)}:{rB[56],rB[47:0]};
                i <= i+1'b1;
            end
            4://加减运算
            begin
                Temp <= TempA + TempB;
                i <= i+1'b1;
            end
            5://补码转换为原码
            begin
                isSign <= Temp[48];
                if(Temp[48]== 1'b1)//结果<0
                    Temp <= ~Temp+1'b1;
                rExpValue <= {2'b00,rA[55:48]};//价码缓存
                i <= i+1'b1;
            end
            6://移位
            begin
                if(Temp[47:46]==2'b10||Temp[47:46]==2'b11)
                begin
                    Temp <= Temp>>1;//尾数
                    rExpValue <= rExpValue+1'b1;//指数
                end 
                else if (Temp[47:46] ==2'b00 && Temp[45] == 1'b1) begin
                    Temp <= Temp << 1;
                    rExpValue <= rExpValue-5'd1;
                end
                else if(Temp[47:46] ==2'b00 && Temp[44] == 1'b1)begin
                    Temp <= Temp << 2;
                    rExpValue <= rExpValue-5'd2;
                end
                else if(Temp[47:46] ==2'b00 && Temp[43] == 1'b1)begin
                    Temp <= Temp << 3;
                    rExpValue <= rExpValue-5'd3;
                end
                else if(Temp[47:46] ==2'b00 && Temp[42] == 1'b1)begin
                    Temp <= Temp << 4;
                    rExpValue <= rExpValue-5'd4;
                end
                else if(Temp[47:46] ==2'b00 && Temp[41] == 1'b1)begin
                    Temp <= Temp << 5;
                    rExpValue <= rExpValue-5'd5;
                end
                else if(Temp[47:46] ==2'b00 && Temp[40] == 1'b1)begin
                    Temp <= Temp << 6;
                    rExpValue <= rExpValue-5'd6;
                end
                else if(Temp[47:46] ==2'b00 && Temp[39] == 1'b1)begin
                    Temp <= Temp << 7;
                    rExpValue <= rExpValue-5'd7;
                end
                else if(Temp[47:46] ==2'b00 && Temp[38] == 1'b1)begin
                    Temp <= Temp << 8;
                    rExpValue <= rExpValue-5'd8;
                end
                else if(Temp[47:46] ==2'b00 && Temp[37] == 1'b1)begin
                    Temp <= Temp << 9;
                    rExpValue <= rExpValue-5'd9;
                end
                else if(Temp[47:46] ==2'b00 && Temp[36] == 1'b1)begin
                    Temp <= Temp << 10;
                    rExpValue <= rExpValue-5'd10;
                end
                else if(Temp[47:46] ==2'b00 && Temp[35] == 1'b1)begin
                    Temp <= Temp << 11;
                    rExpValue <= rExpValue-5'd11;
                end
                else if(Temp[47:46] ==2'b00 && Temp[34] == 1'b1)begin
                    Temp <= Temp << 12;
                    rExpValue <= rExpValue-5'd12;
                end
                else if(Temp[47:46] ==2'b00 && Temp[33] == 1'b1)begin
                    Temp <= Temp << 13;
                    rExpValue <= rExpValue-5'd13;
                end
                else if(Temp[47:46] ==2'b00 && Temp[32] == 1'b1)begin
                    Temp <= Temp << 14;
                    rExpValue <= rExpValue-5'd14;
                end
                else if(Temp[47:46] ==2'b00 && Temp[31] == 1'b1)begin
                    Temp <= Temp << 15;
                    rExpValue <= rExpValue-5'd15;
                end
                else if(Temp[47:46] ==2'b00 && Temp[30] == 1'b1)begin
                    Temp <= Temp << 16;
                    rExpValue <= rExpValue-5'd16;
                end
                else if(Temp[47:46] ==2'b00 && Temp[29] == 1'b1)begin
                    Temp <= Temp << 17;
                    rExpValue <= rExpValue-5'd17;
                end
                else if(Temp[47:46] ==2'b00 && Temp[28] == 1'b1)begin
                    Temp <= Temp << 18;
                    rExpValue <= rExpValue-5'd18;
                end
                else if(Temp[47:46] ==2'b00 && Temp[27] == 1'b1)begin
                    Temp <= Temp << 19;
                    rExpValue <= rExpValue-5'd19;
                end
                else if(Temp[47:46] ==2'b00 && Temp[26] == 1'b1)begin
                    Temp <= Temp << 20;
                    rExpValue <= rExpValue-5'd20;
                end
                else if(Temp[47:46] ==2'b00 && Temp[25] == 1'b1)begin
                    Temp <= Temp << 21;
                    rExpValue <= rExpValue-5'd21;
                end
                else if(Temp[47:46] ==2'b00 && Temp[24] == 1'b1)begin
                    Temp <= Temp << 22;
                    rExpValue <= rExpValue-5'd22;
                end
                else if(Temp[47:46] ==2'b00 && Temp[23] == 1'b1)begin
                    Temp <= Temp << 23;
                    rExpValue <= rExpValue-5'd23;
                end
                else if(Temp[47:46] ==2'b00 && Temp[22] == 1'b1)begin
                    Temp <= Temp << 24;
                    rExpValue <= rExpValue-5'd24;
                end
                else if(Temp[47:46] ==2'b00 && Temp[24] == 1'b1)begin
                    Temp <= Temp << 25;
                    rExpValue <= rExpValue-5'd25;
                end
                i <= i+1'b1;
            end
            7://溢出校验
            begin
                if(rExpValue[9:8] == 2'b01)//overflow
                begin
                    isOver <= 0;
                    rResult <= {1'b0,8'd127,23'd0};
                end
                else if(rExpValue[9:8] == 2'b11)//underflow
                begin
                    isUnder <= 0;
                    rResult <= {1'b0,8'd127,23'd0};
                end
                else if(Temp[46:23] == 24'd0)//zero
                begin
                    isZero <= 0;
                    rResult <= {1'b0,8'd127,23'd0};
                end
                else if(Temp[22]==1'b1)
                    rResult <= {isSign,rExpValue[7:0],Temp[45:23],1'b1};
                else    
                    rResult <= {isSign,rExpValue[7:0],Temp[45:23]};
                i <= i+1'b1;
            end
            8:
            begin
                isDone <= 1'b1;
                i <= i+1'b1;
            end
            9:
            begin
                isDone <= 1'b0;
                i <= i+1'b1;
            end

            default:i <= 0;

        endcase
    end
   
   assign Done_Sig = {isOver,isUnder,isZero,isDone};
   assign Result = rResult;

   
endmodule