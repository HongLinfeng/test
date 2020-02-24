`timescale 1ns/1ns
module STREAMLINEDDIVIDER(
    clk,
    rst_n,
    divisor,
    dividend,
    start_sig,

    done_sig,
    Quotient,
    Reminder
);
// input ports---------------
    input   clk;
    input   rst_n;
    input   start_sig;
    input   [7:0]divisor;
    input   [7:0]dividend;
// output ports---------------
    output  done_sig;
    output  [7:0]Quotient;//商
    output  [7:0]Reminder;//余数
// internal variables------------
    reg     [3:0]i;//步骤i
    reg     [8:0]s;//s为除数的负数补码表示
    reg     [15:0]Temp;//计算空间
    wire     [15:0]Diff;//每次用于计算差的结果
    reg     isNeg;
    reg     isDone;

    assign Diff = Temp + {s,7'd0};//减法
    assign done_sig = isDone;
    assign Quotient = isNeg?(~Temp[7:0]+1):Temp[7:0];
    assign Reminder = Temp[15:8];
    // codes start here--------------
    always@(posedge clk or negedge rst_n)
    if(!rst_n)//reset neg
    begin
        i <= 0;
        s <= 9'd0;
        Temp <= 16'd0;
        //Diff <= 16'd0;
        isNeg <= 0;
        isDone <= 0;
    end
    else if (start_sig) begin
        case (i)
            0:begin//初始化
                Temp <= dividend[7]?{8'd0,~dividend+1'b1}:{8'd0,dividend};//高8位全0，低八位被除数正数
                s <= divisor[7]?{divisor[7],divisor}:{1'b1,~divisor+1'b1};//s存放除数的负数补码值
                isNeg <= divisor[7]^dividend[7];//输出的符号
                //Diff <= 16'd0;
                i <= i+1'b1;
            end
            1,2,3,4,5,6,7,8:begin
                //Diff <= Temp + {s,7'd0};//减法
                if(Diff[15])    Temp <= {Temp[14:0],1'b0};//减法小于0 
                else    Temp <= {Diff[14:0],1'b1};//减法结果大于0
                i <= i+1'b1;
            end
            9:begin
                isDone <= 1'b1;
                i <= i+1'b1;
            end
            10:begin
                isDone <= 1'b0;
                i <= 0;
            end
            default: begin
                i <= 0;
            end
        endcase
    end

    
endmodule