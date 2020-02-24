`include "streamlineddivider.v"
`timescale 1ns/1ns
module divider_tb(
    
);
    reg clk;
    reg rst_n;
    reg [7:0]divisor;
    reg [7:0]dividend;
    reg start_sig;

    wire done_sig;
    wire [7:0]Quotient;
    wire [7:0]Reminder;

STREAMLINEDDIVIDER u1_divider(
    .clk(clk),
    .rst_n(rst_n),
    .divisor(divisor),
    .dividend(dividend),
    .start_sig(start_sig),

    .done_sig(done_sig),
    .Quotient(Quotient),
    .Reminder(Reminder)
);
    
    initial begin
        $dumpfile("divider.vcd");
        $dumpvars;
        clk = 0;
        rst_n = 0;
        divisor = 8'd10;
        dividend = 8'd243;
        start_sig = 0;
        #10 rst_n = 1;
        //start_sig = 1;
        #10
        cal_divider(8'd10,8'd243,divisor,dividend,start_sig);

        #200 $finish;
    end
    
    always#5 clk = !clk;
    always@(done_sig)
    if(done_sig)
        start_sig = 0;

    task cal_divider;
        input   [7:0] A;
        input   [7:0] B;
        output  [7:0]divisor;
        output  [7:0]dividend;
        output  start_sig;
        begin
            divisor = A;
            dividend = B;
            start_sig = 1'b1;
        end
    endtask
endmodule