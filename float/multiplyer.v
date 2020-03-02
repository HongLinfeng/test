module multiplyer(
    clk,
    rst_n,
    A,
    B,
    result,
    start_sig,
    done_sig
);
    input   clk;
    input   rst_n;
    input   [31:0]A;
    input   [31:0]B;
    input   start_sig;

    output  [31:0]result;
    output  [3:0]done_sig;

    reg     [32:0]rA;//{A[31:23],1'b1,A[22:0]}
    reg     [32:0]rB;//{B[31:23],1'b1,B[22:0]}

    reg     rSign;
    reg     [9:0]rExp;//[9:8]overflow or underflow [7:0]
    reg     [47:0]rM;
    reg     [31:0]rResult;
    reg     isOver;
    reg     isUnder;
    reg     isZero;
    reg     isDone;
    

    reg     [4:0]i;

    assign  done_sig = {isOver,isUnder,isZero,isDone};
    assign  result = rResult;
    always@(posedge clk or negedge rst_n)
    if(!rst_n)
    begin
        rA <= 0;//{A[31:23],1'b1,A[22:0]}
        rB <= 0;//{B[31:23],1'b1,B[22:0]}

        rSign <= 0;
        rExp <= 0;//[9:8]overflow or underflow [7:0]
        rM <= 0;
        rResult <= 0;
        isOver <= 0;
        isUnder <= 0;
        isZero <= 0;
        isDone <= 0;
    end
    else if(start_sig)
    begin
        case (i)
            0://初始化待处理数据
            begin
                rA <= {A[31:23],1'b1,A[22:0]};
                rB <= {B[31:23],1'b1,B[22:0]};

                rSign <= A[31]^B[31];
                //rExp <= A[30:23]+B[30:23]-8'd127+1'b1;
                //rM <= {1'b1,A[22:0]}*{1'b1,B[22:0]};
                isOver <= 1'b0;
                isUnder <= 1'b0;
                isZero <= 1'b0;
                i <= i + 1'b1;
            end
            1:
            begin
                if(rA[31:24]==rB[31:24]&&(rA[22:0]!=23'd0 && rB[22:0]!=23'd0)||rA[32]^rB[32])
                begin
                    // rB[31:24]<= rB[31:24]+1'b1;
                    // rB[23:0]<=rB[23:0]>>1;
                end
                i <= i+ 1'b1;

            end
            2:
            begin
                rExp <= rA[31:24]+rB[31:24]-8'd127;
                rM <= rA[23:0]*rB[23:0];
                i <= i+1'b1;
            end
            3:
            begin
                if(rM[47] ==  1'b1) 
                begin
                    rM <= rM;
                    rExp <= rExp + 1'b1;
                end
                else if(rM[46] ==  1'b1)
                begin
                    rM <= rM << 1;
                    //rExp <= rExp -1'b1;
                end else if(rM[45]==1'b1)
                begin
                    rM <= rM << 2;
                    rExp <= rExp - 1'b1;
                end
                i <= i+1'b1;
            end
            4:
            begin
                if(rExp[9:8]==2'b01)
                begin
                    isOver <= 1'b1;
                    rResult <= {1'b0,8'd127,23'd0};
                end else if(rExp==2'b11)
                begin
                    isUnder <= 1'b1;
                    rResult <= {1'b0,8'd127,23'd0};
                end else if(rM[47:24]==24'd0)
                begin
                    isZero <= 1'b1;
                    rResult <= {1'b0,8'd127,23'd0};
                end else if(rM[23]== 1'b1)//四舍五入
                    rResult <= {rSign,rExp[7:0],rM[46:24]};//+1'b1};
                else
                    rResult <= {rSign,rExp[7:0],rM[46:24]};
                i <= i+1'b1;
            end
            5:
            begin
                isDone <= 1'b1;
                i <= i+1'b1;
            end
            6:
            begin
                isDone <= 1'b0;
                i <= 0;
            end
            default:i <= 0;
        endcase
    end
endmodule