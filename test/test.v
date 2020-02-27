module test(
    clk,
    rst_n,
    C1
);
    input clk;
    input rst_n;
    output [2:0]C1;
    reg [2:0]C1;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        C1<= 0;
    else if(C1 ==4)
        C1<=0;
    else C1 <=C1+1'b1;
endmodule