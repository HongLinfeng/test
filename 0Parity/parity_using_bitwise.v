module parity_using_bitwise(
    data_in,
    parity_out
);
    input [7:0]data_in;
    output  parity_out;

    assign  parity_out= ^data_in;
endmodule