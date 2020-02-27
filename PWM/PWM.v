module PWM(
    clk,
    rst_n,
    option_key,
    pwmout
);

    parameter   SEGMENT = 8'd195;//3.9us

    input   clk;//50MHz
    input   rst_n;
    input   [4:0]option_key;

    output  pwmout;

    reg [7:0]C1;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        C1 <= 0;
    else if(C1 == SEGMENT)
        C1 <= 0;
    else C1 <= C1 + 1'b1;

    reg [7:0]System_Seg;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        System_Seg <= 0;
    else if (System_Seg == 8'd255)
        System_Seg <= 0;
    else if(C1== SEGMENT) System_Seg <= System_Seg + 1'b1;

    reg [7:0] Option_Seg;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)begin
        Option_Seg <= 0;

    end
    else if (option_key[4]) begin//+10
        if(Option_Seg < 8'd245) Option_Seg <= Option_Seg + 8'd10;
        else Option_Seg <= 8'd255;
    end 
    else if(option_key[3])begin//-10
        if(Option_Seg > 8'd10) Option_Seg <= Option_Seg - 8'd10;
        else    Option_Seg <= 8'd0;
    end
    else if(option_key[2])begin//+1
        if(Option_Seg <8'd255) Option_Seg <= Option_Seg+8'd1;
        else Option_Seg <= 8'd255;
    end
    else if(option_key[1])begin//-1
        if(Option_Seg > 8'd0) Option_Seg <= Option_Seg - 8'd1;
        else Option_Seg <= 8'd0;
    end
    else if(option_key[0])begin//half
        Option_Seg <= 8'd127;
    end


    assign pwmout = (System_Seg < Option_Seg)?1'b1:1'b0;
    endmodule