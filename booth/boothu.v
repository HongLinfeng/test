module BOOTHU(
    clk,
    rst_n,
    Start_sig,
    A,
    B,
    Done_sig,
    Product
);
    parameter DATAWIDTH = 8;
    // paramter for state
    parameter   INIT = 4'b0001;
    parameter   OPER = 4'b0010;
    parameter   RSHIFT = 4'b0100;
    parameter   OUT = 4'b1000;
    parameter   OUT2 = 4'b1100;
    // input port------------------
    input   clk;
    input   rst_n;
    input   Start_sig;
    input   [DATAWIDTH-1:0]     A;//被乘数
    input   [DATAWIDTH-1:0]     B;//乘数
    // output ports------------------
    output  Done_sig;
    output  [2*DATAWIDTH-1:0]   Product;   
    // internal variables-------------
    reg     [DATAWIDTH-1:0]     A_n;
    reg     [2*DATAWIDTH:0]     booth_p;
    reg     [10:0]  counter;//counter for state count
    reg     [3:0]   state;
    reg     Done;
    reg     Start_sig_reg;
    // code starts here---------------
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)begin
            booth_p <= 0;
            Done <= 0;
            A_n <= 0;
            counter <= 0;
            state <= INIT;
        end
        else begin   
            if(Start_sig)//可以计算         
                case (state)
                INIT:begin
                    Done <= 1'b0;
                    A_n <= (~A+1'b1);
                    booth_p <= {{(DATAWIDTH-1){1'b0}},B,2'b00};
                    state <= OPER;
                    //counter <=  1'b1;
                end
                OPER:begin
                    //counter <= counter + 1'b1;
                    case(booth_p[2:1])
                        2'b01:begin
                            booth_p <= {{booth_p[2*DATAWIDTH],booth_p[2*DATAWIDTH:DATAWIDTH+2]}+A,booth_p[DATAWIDTH+1:1]};
                        end
                        2'b10:begin
                            booth_p <= {{booth_p[2*DATAWIDTH],booth_p[2*DATAWIDTH:DATAWIDTH+2]}+A_n,booth_p[DATAWIDTH+1:1]};
                        end
                        default: begin
                            booth_p <= {booth_p[2*DATAWIDTH],booth_p[2*DATAWIDTH:1]};;
                        end
                    endcase
                    //state <= RSHIFT;
                //end
                //RSHIFT:begin
                    counter <= counter + 1'b1;
                    
                //    booth_p <= {booth_p[2*DATAWIDTH],booth_p[2*DATAWIDTH:1]};
                    if(counter == DATAWIDTH-1)
                        state <= OUT;
                    else    state <= OPER;
                end
                OUT:begin
                    booth_p <= {booth_p[2*DATAWIDTH],booth_p[2*DATAWIDTH:1]};;
                    Done <= 1'b1;
                    state <= OUT2;
                    //counter <= counter + 1'b1;
                end
                OUT2:begin
                    Done <= 1'b0;
                    state <= INIT;
                end
                default: begin
                    booth_p <= 0;
                    Done <= 0;
                    A_n <= 0;
                    counter <= 0;
                    state <= INIT;
                end
            endcase
        end
    end

    // always @(posedge clk or negedge rst_n)
    // if(!rst_n)begin
    //     state <= INIT;
    //     Start_sig_reg <= 0;
    // end
    // else begin
    //     Start_sig_reg <= Start_sig;
    //     if(counter==0 && Start_sig_reg==1'b0 && Start_sig==1'b1) state <= OPER;//
    //     else if (counter == 2*DATAWIDTH)    state <= OUT;
    //     else if(counter[0] == 1'b0) state <= OPER;
    //     else if(counter[0] == 1'b1 && counter != 1) state <= RSHIFT; 
    //     else state<= INIT;
    // end

    assign Done_sig = Done;
    assign Product = booth_p[2*DATAWIDTH:1];
endmodule