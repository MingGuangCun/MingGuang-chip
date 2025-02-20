module fft_8
//implemented with real assembly line
//16 -> 19 -> 22 -> 25 -> 28 -> 32
`define DATA_WIDTH 28
`define W_WIDTH 16
`define TF_ANS_WIDTH (`DATA_WIDTH+`W_WIDTH)
`define X_WIDTH 32

//TF_ANS_WIDTH 影响什么？
//影响倒数三位的值：误差在正负8以内
#(parameter N='d28,
  parameter K='d16)
(
    input                                   clk      ,
    input                                   ifft     ,
    input      [2*`DATA_WIDTH-1:0]          data0    ,
    input      [2*`DATA_WIDTH-1:0]          data1    ,
    input      [2*`DATA_WIDTH-1:0]          data2    ,
    input      [2*`DATA_WIDTH-1:0]          data3    ,
    input      [2*`DATA_WIDTH-1:0]          data4    ,
    input      [2*`DATA_WIDTH-1:0]          data5    ,
    input      [2*`DATA_WIDTH-1:0]          data6    ,
    input      [2*`DATA_WIDTH-1:0]          data7    ,
    input      [2*`W_WIDTH-1:0]             w1       ,
    input      [2*`W_WIDTH-1:0]             w2       ,
    input      [2*`W_WIDTH-1:0]             w3       ,
    input      [2*`W_WIDTH-1:0]             w4       ,
    input      [2*`W_WIDTH-1:0]             w5       ,
    input      [2*`W_WIDTH-1:0]             w6       ,
    input      [2*`W_WIDTH-1:0]             w7       ,
    output    reg[2*`X_WIDTH-1:0]              x0       ,
    output    reg[2*`X_WIDTH-1:0]              x1       ,
    output    reg[2*`X_WIDTH-1:0]              x2       ,
    output    reg[2*`X_WIDTH-1:0]              x3       ,
    output    reg[2*`X_WIDTH-1:0]              x4       ,
    output    reg[2*`X_WIDTH-1:0]              x5       ,
    output    reg[2*`X_WIDTH-1:0]              x6       ,
    output    reg[2*`X_WIDTH-1:0]              x7       ,
    input                                      stall
    //傅里叶系数,x0，x1,x2,x3,....与傅里叶展开的0，1，2，3次项依次对应
);

//定义乘积的wire
wire [2*`TF_ANS_WIDTH-1:0]crisp_0;
wire [2*`TF_ANS_WIDTH-1:0]crisp_1;
wire [2*`TF_ANS_WIDTH-1:0]crisp_2;
wire [2*`TF_ANS_WIDTH-1:0]crisp_3;
wire [2*`TF_ANS_WIDTH-1:0]crisp_4;
wire [2*`TF_ANS_WIDTH-1:0]crisp_5;
wire [2*`TF_ANS_WIDTH-1:0]crisp_6;
wire [2*`TF_ANS_WIDTH-1:0]crisp_7;

wire [`TF_ANS_WIDTH-1:0]crisp_0_re;
wire [`TF_ANS_WIDTH-1:0]crisp_1_re;
wire [`TF_ANS_WIDTH-1:0]crisp_2_re;
wire [`TF_ANS_WIDTH-1:0]crisp_3_re;
wire [`TF_ANS_WIDTH-1:0]crisp_4_re;
wire [`TF_ANS_WIDTH-1:0]crisp_5_re;
wire [`TF_ANS_WIDTH-1:0]crisp_6_re;
wire [`TF_ANS_WIDTH-1:0]crisp_7_re;
wire [`TF_ANS_WIDTH-1:0]crisp_0_im;
wire [`TF_ANS_WIDTH-1:0]crisp_1_im;
wire [`TF_ANS_WIDTH-1:0]crisp_2_im;
wire [`TF_ANS_WIDTH-1:0]crisp_3_im;
wire [`TF_ANS_WIDTH-1:0]crisp_4_im;
wire [`TF_ANS_WIDTH-1:0]crisp_5_im;
wire [`TF_ANS_WIDTH-1:0]crisp_6_im;
wire [`TF_ANS_WIDTH-1:0]crisp_7_im;

assign crisp_0_re = crisp_0[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_1_re = crisp_1[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_2_re = crisp_2[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_3_re = crisp_3[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_4_re = crisp_4[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_5_re = crisp_5[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_6_re = crisp_6[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_7_re = crisp_7[2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH];
assign crisp_0_im = crisp_0[`TF_ANS_WIDTH-1:0];
assign crisp_1_im = crisp_1[`TF_ANS_WIDTH-1:0];
assign crisp_2_im = crisp_2[`TF_ANS_WIDTH-1:0];
assign crisp_3_im = crisp_3[`TF_ANS_WIDTH-1:0];
assign crisp_4_im = crisp_4[`TF_ANS_WIDTH-1:0];
assign crisp_5_im = crisp_5[`TF_ANS_WIDTH-1:0];
assign crisp_6_im = crisp_6[`TF_ANS_WIDTH-1:0];
assign crisp_7_im = crisp_7[`TF_ANS_WIDTH-1:0];

wire [31:0]w0;
assign w0=32'h40000000;
//第一级乘积 takes 4 cycles
TF t0(data0,w0,ifft,clk,crisp_0);
TF t1(data1,w1,ifft,clk,crisp_1);
TF t2(data2,w2,ifft,clk,crisp_2);
TF t3(data3,w3,ifft,clk,crisp_3);
TF t4(data4,w4,ifft,clk,crisp_4);
TF t5(data5,w5,ifft,clk,crisp_5);
TF t6(data6,w6,ifft,clk,crisp_6);
TF t7(data7,w7,ifft,clk,crisp_7);
//测试8点fft的时候没有考虑data0虚部较大时的情况（ifft要取data0共轭）



wire signed[`DATA_WIDTH-1:0]          data_re0         ;
wire signed[`DATA_WIDTH-1:0]          data_re1         ;
wire signed[`DATA_WIDTH-1:0]          data_re2         ;
wire signed[`DATA_WIDTH-1:0]          data_re3         ;
wire signed[`DATA_WIDTH-1:0]          data_re4         ;
wire signed[`DATA_WIDTH-1:0]          data_re5         ;
wire signed[`DATA_WIDTH-1:0]          data_re6         ;
wire signed[`DATA_WIDTH-1:0]          data_re7         ;
wire signed[`DATA_WIDTH-1:0]          data_im0         ;
wire signed[`DATA_WIDTH-1:0]          data_im1         ;
wire signed[`DATA_WIDTH-1:0]          data_im2         ;
wire signed[`DATA_WIDTH-1:0]          data_im3         ;
wire signed[`DATA_WIDTH-1:0]          data_im4         ;
wire signed[`DATA_WIDTH-1:0]          data_im5         ;
wire signed[`DATA_WIDTH-1:0]          data_im6         ;
wire signed[`DATA_WIDTH-1:0]          data_im7         ;
assign {data_re0,data_im0}= data0            ;
assign {data_re1,data_im1}= data1            ;
assign {data_re2,data_im2}= data2            ;
assign {data_re3,data_im3}= data3            ;
assign {data_re4,data_im4}= data4            ;
assign {data_re5,data_im5}= data5            ;
assign {data_re6,data_im6}= data6            ;
assign {data_re7,data_im7}= data7            ;




//----------------------stage 1------------------------------

reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re0_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re1_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re2_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re3_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re4_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re5_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re6_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_re7_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im0_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im1_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im2_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im3_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im4_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im5_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im6_1;
reg signed[`TF_ANS_WIDTH:0]          butterfly_out_im7_1;

always @(posedge clk ) begin
        butterfly_out_re0_1<=$signed(crisp_0       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  +    $signed(crisp_4  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re1_1<=$signed(crisp_0       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  -    $signed(crisp_4  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re2_1<=$signed(crisp_1       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  +    $signed(crisp_5  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re3_1<=$signed(crisp_1       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  -    $signed(crisp_5  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re4_1<=$signed(crisp_2       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  +    $signed(crisp_6  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re5_1<=$signed(crisp_2       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  -    $signed(crisp_6  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re6_1<=$signed(crisp_3       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  +    $signed(crisp_7  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_re7_1<=$signed(crisp_3       [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH])  -    $signed(crisp_7  [2*`TF_ANS_WIDTH-1:`TF_ANS_WIDTH]);
        butterfly_out_im0_1<=$signed(crisp_0       [`TF_ANS_WIDTH-1:0])   +    $signed(crisp_4    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im1_1<=$signed(crisp_0       [`TF_ANS_WIDTH-1:0])   -    $signed(crisp_4    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im2_1<=$signed(crisp_1       [`TF_ANS_WIDTH-1:0])   +    $signed(crisp_5    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im3_1<=$signed(crisp_1       [`TF_ANS_WIDTH-1:0])   -    $signed(crisp_5    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im4_1<=$signed(crisp_2       [`TF_ANS_WIDTH-1:0])   +    $signed(crisp_6    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im5_1<=$signed(crisp_2       [`TF_ANS_WIDTH-1:0])   -    $signed(crisp_6    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im6_1<=$signed(crisp_3       [`TF_ANS_WIDTH-1:0])   +    $signed(crisp_7    [`TF_ANS_WIDTH-1:0]);
        butterfly_out_im7_1<=$signed(crisp_3       [`TF_ANS_WIDTH-1:0])   -    $signed(crisp_7    [`TF_ANS_WIDTH-1:0]);
end
//----------------------stage 2------------------------------

reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re0_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re1_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re2_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re3_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re4_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_re5_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im0_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im1_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im2_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im3_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im4_2;
reg signed[`TF_ANS_WIDTH+1:0]          butterfly_out_im5_2;
reg signed[`TF_ANS_WIDTH+1+1:0]          a3_re_plus         ;
reg signed[`TF_ANS_WIDTH+1+1:0]          a3_im_plus         ;
reg signed[`TF_ANS_WIDTH+1+1:0]          a4_re_plus         ;
reg signed[`TF_ANS_WIDTH+1+1:0]          a4_im_plus         ;

always @(posedge clk ) begin
        butterfly_out_re0_2  <=  butterfly_out_re0_1   +   butterfly_out_re4_1;
        butterfly_out_re1_2  <=  butterfly_out_re0_1   -   butterfly_out_re4_1;
        butterfly_out_re2_2  <=  butterfly_out_re2_1   +   butterfly_out_re6_1;
        butterfly_out_re3_2  <=  butterfly_out_re2_1   -   butterfly_out_re6_1;
        butterfly_out_re4_2  <=  butterfly_out_re1_1   +   butterfly_out_im5_1;
        butterfly_out_re5_2  <=  butterfly_out_re1_1   -   butterfly_out_im5_1;
        butterfly_out_im0_2  <=  butterfly_out_im0_1   +   butterfly_out_im4_1;
        butterfly_out_im1_2  <=  butterfly_out_im0_1   -   butterfly_out_im4_1;
        butterfly_out_im2_2  <=  butterfly_out_im2_1   +   butterfly_out_im6_1;
        butterfly_out_im3_2  <=  butterfly_out_im2_1   -   butterfly_out_im6_1;
        butterfly_out_im4_2  <=  butterfly_out_im1_1   -   butterfly_out_re5_1;
        butterfly_out_im5_2  <=  butterfly_out_im1_1   +   butterfly_out_re5_1;
        a3_re_plus           <=  butterfly_out_re3_1   +   butterfly_out_im7_1+butterfly_out_im3_1    -   butterfly_out_re7_1 ;
        a3_im_plus           <=  butterfly_out_im3_1   -   butterfly_out_re7_1-(butterfly_out_re3_1   +   butterfly_out_im7_1);
        a4_re_plus           <=  butterfly_out_im3_1   +   butterfly_out_re7_1-(butterfly_out_re3_1   -   butterfly_out_im7_1);
        a4_im_plus           <=  -butterfly_out_im3_1  -   butterfly_out_re7_1-butterfly_out_re3_1    +   butterfly_out_im7_1 ;
end
//----------------------stage 3------------------------------

reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re0_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re1_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re2_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re3_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re4_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_re5_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im0_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im1_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im2_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im3_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im4_3;
reg signed[`TF_ANS_WIDTH+1-14:0]          butterfly_out_im5_3;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a3_re_plus_1     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a3_im_plus_1     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a4_re_plus_1     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a4_im_plus_1     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a3_re_plus_2     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a3_im_plus_2     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a4_re_plus_2     ;
reg signed[`TF_ANS_WIDTH+1+1-14:0]          a4_im_plus_2     ;

always @(posedge clk ) begin
        butterfly_out_re0_3  <=  butterfly_out_re0_2>>>14;
        butterfly_out_re1_3  <=  butterfly_out_re1_2>>>14;
        butterfly_out_re2_3  <=  butterfly_out_re2_2>>>14;
        butterfly_out_re3_3  <=  butterfly_out_re3_2>>>14;
        butterfly_out_re4_3  <=  butterfly_out_re4_2>>>14;
        butterfly_out_re5_3  <=  butterfly_out_re5_2>>>14;
        butterfly_out_im0_3  <=  butterfly_out_im0_2>>>14;
        butterfly_out_im1_3  <=  butterfly_out_im1_2>>>14;
        butterfly_out_im2_3  <=  butterfly_out_im2_2>>>14;
        butterfly_out_im3_3  <=  butterfly_out_im3_2>>>14;
        butterfly_out_im4_3  <=  butterfly_out_im4_2>>>14;
        butterfly_out_im5_3  <=  butterfly_out_im5_2>>>14;
        a3_re_plus_1         <=  (a3_re_plus>>>15)+(a3_re_plus>>>17)+(a3_re_plus>>>18)              ;
        a3_re_plus_2         <=  (a3_re_plus>>>(6+14))+(a3_re_plus>>>(8+14))                        ;
        a4_re_plus_1         <=  (a4_re_plus>>>(1+14))+(a4_re_plus>>>(3+14))+(a4_re_plus>>>(4+14))  ;
        a4_re_plus_2         <=  (a4_re_plus>>>(6+14))+(a4_re_plus>>>(8+14))                        ;
        a3_im_plus_1         <=  (a3_im_plus>>>(1+14))+(a3_im_plus>>>(3+14))+(a3_im_plus>>>(4+14))  ;
        a3_im_plus_2         <=  (a3_im_plus>>>(6+14))+(a3_im_plus>>>(8+14))                        ;
        a4_im_plus_1         <=  (a4_im_plus>>>(1+14))+(a4_im_plus>>>(3+14))+(a4_im_plus>>>(4+14))  ;
        a4_im_plus_2         <=  (a4_im_plus>>>(6+14))+(a4_im_plus>>>(8+14))                        ;
end



//----------------------stage 4------------------------------



wire signed[`X_WIDTH-1:0]x0_re; 
wire signed[`X_WIDTH-1:0]x4_re; 
wire signed[`X_WIDTH-1:0]x2_re; 
wire signed[`X_WIDTH-1:0]x6_re; 
wire signed[`X_WIDTH-1:0]x1_re; 
wire signed[`X_WIDTH-1:0]x5_re; 
wire signed[`X_WIDTH-1:0]x3_re; 
wire signed[`X_WIDTH-1:0]x7_re; 
wire signed[`X_WIDTH-1:0]x0_im; 
wire signed[`X_WIDTH-1:0]x4_im; 
wire signed[`X_WIDTH-1:0]x2_im; 
wire signed[`X_WIDTH-1:0]x6_im; 
wire signed[`X_WIDTH-1:0]x1_im; 
wire signed[`X_WIDTH-1:0]x5_im; 
wire signed[`X_WIDTH-1:0]x3_im; 
wire signed[`X_WIDTH-1:0]x7_im; 

assign x0_re=x0[2*`X_WIDTH-1:`X_WIDTH];
assign x4_re=x4[2*`X_WIDTH-1:`X_WIDTH];
assign x2_re=x2[2*`X_WIDTH-1:`X_WIDTH];
assign x6_re=x6[2*`X_WIDTH-1:`X_WIDTH];
assign x1_re=x1[2*`X_WIDTH-1:`X_WIDTH];
assign x5_re=x5[2*`X_WIDTH-1:`X_WIDTH];
assign x3_re=x3[2*`X_WIDTH-1:`X_WIDTH];
assign x7_re=x7[2*`X_WIDTH-1:`X_WIDTH];
assign x0_im=x0[`X_WIDTH-1:0];   
assign x4_im=x4[`X_WIDTH-1:0];   
assign x2_im=x2[`X_WIDTH-1:0];   
assign x6_im=x6[`X_WIDTH-1:0];   
assign x1_im=x1[`X_WIDTH-1:0];   
assign x5_im=x5[`X_WIDTH-1:0];   
assign x3_im=x3[`X_WIDTH-1:0];   
assign x7_im=x7[`X_WIDTH-1:0];  

always @(posedge clk ) 
    begin              
    if(stall)begin
        x0  <=  x0;
        x4  <=  x4;
        x2  <=  x2;
        x6  <=  x6;
        x1  <=  x1;
        x5  <=  x5;
        x3  <=  x3;
        x7  <=  x7;
    end
    else begin                          
        x0[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re0_3   +   butterfly_out_re2_3;
        x4[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re0_3   -   butterfly_out_re2_3;
        x2[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re1_3   +   butterfly_out_im3_3;
        x6[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re1_3   -   butterfly_out_im3_3;
        x1[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re4_3   +  (a3_re_plus_1 +a3_re_plus_2)  ;  
        x5[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re4_3   -  (a3_re_plus_1 +a3_re_plus_2)  ;  
        x3[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re5_3   +  (a4_re_plus_1 +a4_re_plus_2)  ;  
        x7[2*`X_WIDTH-1:`X_WIDTH]     <=  butterfly_out_re5_3   -  (a4_re_plus_1 +a4_re_plus_2)  ;  
        x0[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im0_3   +   butterfly_out_im2_3):butterfly_out_im0_3   +   butterfly_out_im2_3;
        x4[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im0_3   -   butterfly_out_im2_3):butterfly_out_im0_3   -   butterfly_out_im2_3;
        x2[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im1_3   -   butterfly_out_re3_3):butterfly_out_im1_3   -   butterfly_out_re3_3;
        x6[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im1_3   +   butterfly_out_re3_3):butterfly_out_im1_3   +   butterfly_out_re3_3;
        x1[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im4_3   +    (a3_im_plus_1 +a3_im_plus_2)) :butterfly_out_im4_3   + (a3_im_plus_1 +a3_im_plus_2) ;
        x5[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im4_3   -    (a3_im_plus_1 +a3_im_plus_2)) :butterfly_out_im4_3   - (a3_im_plus_1 +a3_im_plus_2) ;
        x3[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im5_3   +    (a4_im_plus_1 +a4_im_plus_2)) :butterfly_out_im5_3   + (a4_im_plus_1 +a4_im_plus_2) ;
        x7[`X_WIDTH-1:0]              <=  ifft?-(butterfly_out_im5_3   -    (a4_im_plus_1 +a4_im_plus_2)) :butterfly_out_im5_3   - (a4_im_plus_1 +a4_im_plus_2) ;
    end
    end

endmodule
 