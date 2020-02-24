`include "boothu.v"
module booth_tb;

    reg clk;
    reg rst_n;
    reg Start_sig;
    reg [7:0]Avalue;
    reg [7:0]Bvalue;
    wire Done_sig;
    wire [15:0]Product;

BOOTHU #(8)booth_u1(
    .clk(clk),
    .rst_n(rst_n),
    .Start_sig(Start_sig),
    .A(Avalue),
    .B(Bvalue),
    .Done_sig(Done_sig),
    .Product(Product)
);

initial begin
    $dumpfile("booth.vcd");
    $dumpvars;
    clk = 0;
    rst_n = 0;
    Start_sig = 0;
    Avalue = 8'b00010000;
    Bvalue = 8'b00000100;
    #CLOCKPERIOD rst_n = 1;
    #CLOCKPERIOD Start_sig = 1;

    
    #400 $finish;
end
parameter CLOCKPERIOD = 10;
always #(CLOCKPERIOD/2) clk = !clk;
always @(posedge clk)
if(Done_sig == 1)
    Start_sig <=0;
endmodule