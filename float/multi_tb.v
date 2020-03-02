`include "multiplyer.v"
`timescale 1ps/1ps
module multi_tb(
    
);

    reg clk;
    reg rst_n;
    reg [31:0]A;
    reg [31:0]B;
    wire [31:0]result;
    reg start_sig;
    wire [3:0]done_sig;

    multiplyer U1(
    .clk(clk),
    .rst_n(rst_n),
    .A(A),
    .B(B),
    .result(result),
    .start_sig(start_sig),
    .done_sig(done_sig)
);

initial begin
    $dumpfile("multi.vcd");
    $dumpvars;
    clk = 0;
    rst_n = 0;
    #10 rst_n = 1;

    #2000 $finish;
end
always #5 clk = !clk;
reg [5:0]i;
always@(posedge clk or negedge rst_n)
if(!rst_n)
begin
    A <= 32'd0;
    B <= 32'd0;
    i <= 6'd0;
    start_sig <= 1'b0;
end
else begin
    case (i)
        0:
            if(done_sig[0]==1'b1)
            begin
                start_sig <= 0;
                i <= i + 1'b1;
            end else begin
                A <= 32'b01000000001000000000000000000000;
                B <= 32'b01000000101000000000000000000000;
                start_sig <=1'b1;
            end 
        1:
            if(done_sig[0]==1'b1)
            begin
                start_sig <= 0;
                i <= i + 1'b1;
            end else begin
                A <= 32'b01000000010010010001011010000111;
                B <= 32'b01000000010010010001011010000111;
                start_sig <=1'b1;
            end 
        2:
            if(done_sig[0]==1'b1)
            begin
                start_sig <= 0;
                i <= i + 1'b1;
            end else begin
                A <= 32'b01000010100100111000100010110100;
                B <= 32'b01000010101001101000100000110001;
                start_sig <=1'b1;
            end
        3:
            if(done_sig[0]==1'b1)
            begin
                start_sig <= 0;
                i <= i + 1'b1;
            end else begin//3.1828*-0.0063=-0.0200516//404BB2FE*BBCE7000=BCA44340
                A <= 32'b01000000010010111011001011111111 ;
                B <= 32'b10111011110011100111000000111011
;
                start_sig <=1'b1;
            end
        default:i <= 0;
    endcase
end
endmodule