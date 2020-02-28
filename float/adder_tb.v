`include "adder.v"
`timescale 1ps/1ps 
module float_add_module_simulation();
reg CLK;
reg RSTn;
reg Start_Sig; 
reg [31:0]A;
reg [31:0] B; 
wire [3:0] Done_Sig; 
wire [31:0] Result;
/*******************/ 
// wire [56:0]SQ_rA,SQ_rB;
// wire [48:0]SQ_Temp,SQ_TempA,SQ_TempB;
// wire [9:0]SQ_rExp; 
// wire [7:0]SQ_rExpDiff;
 /**********************************/ 
adder U1 ( 
    .clk(CLK ),
    .rst_n( RSTn), 
    .A(A),
    .B(B ),
    .Result(Result ), 
    .Start_Sig( Start_Sig), 
    .Done_Sig(Done_Sig) 
    // .SQ_rA(SQ_rA), 
    // .SQ_rB(SQ_rB)

// .SQ_Temp( SQ_Temp),
// .SQ_TempA(SQ_TempA), 
// .SQ_TempB(SQ_TempB), 
// .SQ_rExp( SQ_rExp ),
// .SQ_rExpDiff( SQ_rExpDiff) 
);
/***********************************/ 
initial begin 
    $dumpfile("adder.vcd");
    $dumpvars;
    RSTn= 0;CLK = 0;  #10 RSTn= 1; 
    //forever #5 CLK = ~CLK;
    #2000 $finish;

end 
always #5 CLK = !CLK;
/***********************************/ 
reg [3:0]i; 
always @ ( posedge CLK or negedge RSTn )
if(!RSTn) 
begin 
    A<= 32'd0; 
    B <= 32'd0; 
    Start_Sig<= 1'b0; 
    i <= 4'd0;
end 
else
case( i )
    0: //A=3.65, B= -7.4,A+B = ? 
    if(Done_Sig[0]) 
    begin 
        Start_Sig <= 1'b0; 
        i <= i + 1'b1; 
        $display("%b",Result); 
    end 
    else begin
        A<= 32'b0_10000000_11010011001100110011010; 
        B <= 32'b1_10000001_11011001100110011001101; 
        Start_Sig <= 1'b1; 
    end 
    1: //Exp undeflow check 
    if(Done_Sig[0]) begin 
        Start_Sig <= 1'b0; 
        i <= i + 1'b1; 
    end 
    else begin
        A<= 32'b0_00000000_01010000101101000101101; 
        B <= 32'b1_00000000_00010000101100001000111;
        Start_Sig <= 1'b1; 
    end
    2://A=1.9999997, B=-1.9999998,A+B=?
    if(Done_Sig[0] )begin 
        Start_Sig<= 1'b0; 
        i <= i + 1'b1; 
        $display("%b",Result); 
    end 
    else begin
        A<= 32'b0_01111111_11111111111111111111110;
        B <= 32'b1_01111111_11111111111111111111111; 
        Start_Sig <= 1'b1;
    end 
    3: //Exp Overflow 
    if(Done_Sig[0]) begin 
        Start_Sig <= 1'b0; 
        i <= i + 1'b1; end 
    else begin
        A<= 32'b0_11111111_11111111111111111111111; 
        B <= 32'b0_11111111_11111111111111111111111;
        Start_Sig <= 1'b1; 
    end

    4://A= -12.558, B= -7.309 ,A+B =? 
    if(Done_Sig[0] )begin 
        Start_Sig<= 1'b0; 
        i <= i + 1'b1; 
        $display("%b",Result);
    end 
    else begin
        A<= 32'b11000001010010001110110110010001; 
        B <= 32'b11000000111010011110001101010100; 
        Start_Sig <= 1'b1; end
    5://A= 111.7762, B= 302.4409 ,A+B =? 
    if(Done_Sig[0] )begin 
        Start_Sig<= 1'b0;
        i <= i + 1'b1; 
        $display("%b",Result); 
    end 
    else begin
        A<= 32'b01000010110111111000110101101010; 
        B <= 32'b01000011100101110011100001101111; 
        Start_Sig <= 1'b1; 
    end 
    6://A= 2112.2012, B= -2002.2012,A+B=? 
    if(Done_Sig[0] )begin 
        Start_Sig<= 1'b0; 
        i <= i + 1'b1; 
        $display("%b",Result); end 
    else begin
        A<= 32'b01000101000001000000001100111000; 
        B <= 32'b11000100111110100100011001110000; 
        Start_Sig <= 1'b1; end 
    7:
        i <= i;
    endcase
        
endmodule
