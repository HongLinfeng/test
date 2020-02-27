
`include "test.v"
module test_tb(
    
);
    reg clk;
    reg rst_n;
    wire [2:0]C1;
    test U1(
    .clk(clk),
    .rst_n(rst_n),
    .C1(C1)
    );

    parameter CLOCKPERIOD = 10;
    initial begin
        $dumpfile("test.vcd");
        $dumpvars;
        clk = 0;
        rst_n = 0;
        #CLOCKPERIOD 
        rst_n = 1;

        #200 $finish;
    end
    always#5 clk = !clk;
endmodule