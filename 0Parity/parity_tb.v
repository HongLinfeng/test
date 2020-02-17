`include "parity_assign.v"
`include "parity_fun1.v"
`include "parity_using_bitwise.v"
module parity_tb;
    reg [7:0]data_in;
    wire parity_out_assign;
    wire parity_out_fun1;
    wire parity_out_bitwise;
parity_assign parity_assign(
    .data_in(data_in),
    .parity_out(parity_out_assign)
);
parity_fun1 parity_fun1(
    .data_in(data_in),
    .parity_out(parity_out_fun1)
);
parity_using_bitwise parity_using_bitwise(
    .data_in(data_in),
    .parity_out(parity_out_bitwise)
);

initial begin
    $dumpfile("parity.vcd");
    $dumpvars;
    data_in = 0;
    #50 data_in = 8'h03;
    #50 data_in = 8'h10;
    #50 $finish;
end
    
endmodule