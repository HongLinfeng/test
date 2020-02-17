`include "serial_crc.v"
module scrc_tb(
    
);
    reg clk;
    reg reset;
    reg enable;
    reg init;
    reg data_in;
    wire [15:0]crc_out;

serial_crc serial_crc(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .init(init),
    .data_in(data_in),
    .crc_out(crc_out)
);
parameter CLOCKPERIOD = 10;
always #(CLOCKPERIOD/2) clk = !clk;
reg [23:0]data;
integer i;
initial begin
    $dumpfile("scrc.vcd");
    $dumpvars;
    clk = 0;
    reset = 0;
    enable = 0;
    init = 0;
    #10 reset = 1;
    #10 reset = 0;
    init = 1;
    #10 init = 0;
    
    data = 24'h000080;
    for (i=0; i<25; i++) begin
        #10
            enable = 0;
        #10 data_in = data[i];
            enable = 1;     
    end
    enable=0;
    //gencrc(8'h01,data_in,enable);
    #2000 $finish;
end

task gencrc;
    input [7:0]data;
    output dout;
    output enable;
    reg d;
    integer i;
    for (i=0; i<8; i++) begin
        #10
            enable = 0;
        #10 dout = data[i];
            enable = 1;
        
    end
endtask
endmodule