//----------------------------------------------------
// A four level, round-robin arbiter. This was
// orginally coded by WD Peterson in VHDL.
//----------------------------------------------------
module arbiter (
  clk,    
  rst,    
  req3,   
  req2,   
  req1,   
  req0,   
  gnt3,   
  gnt2,   
  gnt1,   
  gnt0   
);
// --------------Port Declaration----------------------- 
input           clk;    
input           rst;    
input           req3;   
input           req2;   
input           req1;   
input           req0;   
output          gnt3;   
output          gnt2;   
output          gnt1;   
output          gnt0;   

//--------------Internal Registers----------------------
wire    [1:0]   gnt       ;   
wire            comreq    ; 
wire            beg       ;
wire   [1:0]    lgnt      ;//当前granted的master标号
wire            lcomreq   ;
reg             lgnt0     ;//grant的one-hot编码值
reg             lgnt1     ;//grant的one-hot编码值
reg             lgnt2     ;//grant的one-hot编码值
reg             lgnt3     ;//grant的one-hot编码值
reg             lasmask   ;//
reg             lmask0    ;//
reg             lmask1    ;//
reg             ledge     ;

//--------------Code Starts Here----------------------- 
always @ (posedge clk)
if (rst) begin
  lgnt0 <= 0;
  lgnt1 <= 0;
  lgnt2 <= 0;
  lgnt3 <= 0;
end else begin                                     
  lgnt0 <=(~lcomreq & ~lmask1 & ~lmask0 & ~req3 & ~req2 & ~req1 & req0)//当前0号优先级最低
        | (~lcomreq & ~lmask1 &  lmask0 & ~req3 & ~req2 &  req0)//当前1号优先级最低；没有连续申请总线；2号3号没有发起申请；0号发起申请
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req0)//当前2号优先级最低；没有连续申请总线；3号没有发起申请；0号发起申请
        | (~lcomreq &  lmask1 &  lmask0 & req0  )//lmask1和lmask0都为1：当前3号优先级最低；没有连续申请总线；0号发起申请
        | ( lcomreq & lgnt0 );//占总总线，且再次发起请求
  lgnt1 <=(~lcomreq & ~lmask1 & ~lmask0 &  req1)//当前1号优先级最低；没有连续申请总线；1号发起申请
        | (~lcomreq & ~lmask1 &  lmask0 & ~req3 & ~req2 &  req1 & ~req0)//当前2号优先级最低；没有连续申请总线；0，2，3没有发起申请；1号发起申请
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req1 & ~req0)
        | (~lcomreq &  lmask1 &  lmask0 &  req1 & ~req0)
        | ( lcomreq &  lgnt1);
  lgnt2 <=(~lcomreq & ~lmask1 & ~lmask0 &  req2  & ~req1)
        | (~lcomreq & ~lmask1 &  lmask0 &  req2)
        | (~lcomreq &  lmask1 & ~lmask0 & ~req3 &  req2  & ~req1 & ~req0)
        | (~lcomreq &  lmask1 &  lmask0 &  req2 & ~req1 & ~req0)
        | ( lcomreq &  lgnt2);
  lgnt3 <=(~lcomreq & ~lmask1 & ~lmask0 & req3  & ~req2 & ~req1)
        | (~lcomreq & ~lmask1 &  lmask0 & req3  & ~req2)
        | (~lcomreq &  lmask1 & ~lmask0 & req3)
        | (~lcomreq &  lmask1 &  lmask0 & req3  & ~req2 & ~req1 & ~req0)
        | ( lcomreq & lgnt3);
end 

//----------------------------------------------------
// lasmask state machine.
//----------------------------------------------------
assign beg = (req3 | req2 | req1 | req0) & ~lcomreq;//下一个时钟总线可用，且发起了请求
always @ (posedge clk)
begin                                     
  lasmask <= (beg & ~ledge & ~lasmask);//从空闲或者重复请求中进入新的忙时，有一个高脉冲，这个高脉冲用于定义接下来的优先级
  ledge   <= (beg & ~ledge &  lasmask) 
          |  (beg &  ledge & ~lasmask);
end 

//----------------------------------------------------
// comreq logic.当前某个master占用总线时，同一个master再次发生请求，则输出为1，否则为0；若为1则下一时钟的总线已经被占用；若为0则下一时钟的总线可以分配
//----------------------------------------------------
assign lcomreq = ( req3 & lgnt3 )
                | ( req2 & lgnt2 )
                | ( req1 & lgnt1 )
                | ( req0 & lgnt0 );

//----------------------------------------------------
// Encoder logic.将one-hot编码为BCD
//----------------------------------------------------
assign  lgnt =  {(lgnt3 | lgnt2),(lgnt3 | lgnt1)};

//----------------------------------------------------
// lmask register.
//----------------------------------------------------
always @ (posedge clk )
if( rst ) begin
  lmask1 <= 0;
  lmask0 <= 0;
end else if(lasmask) begin//若从空闲进入忙状态，更新lmask，lmask为最低的优先级
  lmask1 <= lgnt[1];
  lmask0 <= lgnt[0];
end else begin
  lmask1 <= lmask1;
  lmask0 <= lmask0;
end 

assign comreq = lcomreq;
assign gnt    = lgnt;
//----------------------------------------------------
// Drive the outputs
//----------------------------------------------------
assign gnt3   = lgnt3;
assign gnt2   = lgnt2;
assign gnt1   = lgnt1;
assign gnt0   = lgnt0;

endmodule