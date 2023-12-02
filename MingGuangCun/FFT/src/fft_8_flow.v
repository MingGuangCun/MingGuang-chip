module fft_8_flow
//implemented with real assembly line
#(parameter N=5'd28)
(
    input                         clk      ,
    input                         ifft     ,
    input      [2*N-1:0]          data0    ,
    input      [2*N-1:0]          data1    ,
    input      [2*N-1:0]          data2    ,
    input      [2*N-1:0]          data3    ,
    input      [2*N-1:0]          data4    ,
    input      [2*N-1:0]          data5    ,
    input      [2*N-1:0]          data6    ,
    input      [2*N-1:0]          data7    ,
    input      [31:0]             w1       ,
    input      [31:0]             w2       ,
    input      [31:0]             w3       ,
    input      [31:0]             w4       ,
    input      [31:0]             w5       ,
    input      [31:0]             w6       ,
    input      [31:0]             w7       ,
    input                         stall    ,
    output    reg [2*N+7:0]          x0    ,
    output    reg [2*N+7:0]          x1    ,
    output    reg [2*N+7:0]          x2    ,
    output    reg [2*N+7:0]          x3    ,
    output    reg [2*N+7:0]          x4    ,
    output    reg [2*N+7:0]          x5    ,
    output    reg [2*N+7:0]          x6    ,
    output    reg [2*N+7:0]          x7      
    //傅里叶系数,x0，x1,x2,x3,....与傅里叶展开的0，1，2，3次项依次对应
);

//定义乘积的wire
wire [2*N+1:0]crisp_0;
wire [2*N+1:0]crisp_1;
wire [2*N+1:0]crisp_2;
wire [2*N+1:0]crisp_3;
wire [2*N+1:0]crisp_4;
wire [2*N+1:0]crisp_5;
wire [2*N+1:0]crisp_6;
wire [2*N+1:0]crisp_7;
wire [31:0]w0;
assign w0=32'h40000000;
//第一级乘积 
TF_28 t0(data0,w0,ifft,clk,crisp_0);
TF_28 t1(data1,w1,ifft,clk,crisp_1);
TF_28 t2(data2,w2,ifft,clk,crisp_2);
TF_28 t3(data3,w3,ifft,clk,crisp_3);
TF_28 t4(data4,w4,ifft,clk,crisp_4);
TF_28 t5(data5,w5,ifft,clk,crisp_5);
TF_28 t6(data6,w6,ifft,clk,crisp_6);
TF_28 t7(data7,w7,ifft,clk,crisp_7);
//测试8点fft的时候没有考虑data0虚部较大时的情况（ifft要取data0共轭）



wire signed[N-1:0]          data_re0         ;
wire signed[N-1:0]          data_re1         ;
wire signed[N-1:0]          data_re2         ;
wire signed[N-1:0]          data_re3         ;
wire signed[N-1:0]          data_re4         ;
wire signed[N-1:0]          data_re5         ;
wire signed[N-1:0]          data_re6         ;
wire signed[N-1:0]          data_re7         ;
wire signed[N-1:0]          data_im0         ;
wire signed[N-1:0]          data_im1         ;
wire signed[N-1:0]          data_im2         ;
wire signed[N-1:0]          data_im3         ;
wire signed[N-1:0]          data_im4         ;
wire signed[N-1:0]          data_im5         ;
wire signed[N-1:0]          data_im6         ;
wire signed[N-1:0]          data_im7         ;
assign {data_re0,data_im0}= data0            ;
assign {data_re1,data_im1}= data1            ;
assign {data_re2,data_im2}= data2            ;
assign {data_re3,data_im3}= data3            ;
assign {data_re4,data_im4}= data4            ;
assign {data_re5,data_im5}= data5            ;
assign {data_re6,data_im6}= data6            ;
assign {data_re7,data_im7}= data7            ;




//----------------------stage 1------------------------------

reg signed[N+3:0]          butterfly_out_re0_1;
reg signed[N+3:0]          butterfly_out_re1_1;
reg signed[N+3:0]          butterfly_out_re2_1;
reg signed[N+3:0]          butterfly_out_re3_1;
reg signed[N+3:0]          butterfly_out_re4_1;
reg signed[N+3:0]          butterfly_out_re5_1;
reg signed[N+3:0]          butterfly_out_re6_1;
reg signed[N+3:0]          butterfly_out_re7_1;
reg signed[N+3:0]          butterfly_out_im0_1;
reg signed[N+3:0]          butterfly_out_im1_1;
reg signed[N+3:0]          butterfly_out_im2_1;
reg signed[N+3:0]          butterfly_out_im3_1;
reg signed[N+3:0]          butterfly_out_im4_1;
reg signed[N+3:0]          butterfly_out_im5_1;
reg signed[N+3:0]          butterfly_out_im6_1;
reg signed[N+3:0]          butterfly_out_im7_1;

always @(posedge clk ) begin
        butterfly_out_re0_1<=$signed(crisp_0       [2*N+1:N+1])  +    $signed(crisp_4  [2*N+1:N+1]);
        butterfly_out_re1_1<=$signed(crisp_0       [2*N+1:N+1])  -    $signed(crisp_4  [2*N+1:N+1]);
        butterfly_out_re2_1<=$signed(crisp_1       [2*N+1:N+1])  +    $signed(crisp_5  [2*N+1:N+1]);
        butterfly_out_re3_1<=$signed(crisp_1       [2*N+1:N+1])  -    $signed(crisp_5  [2*N+1:N+1]);
        butterfly_out_re4_1<=$signed(crisp_2       [2*N+1:N+1])  +    $signed(crisp_6  [2*N+1:N+1]);
        butterfly_out_re5_1<=$signed(crisp_2       [2*N+1:N+1])  -    $signed(crisp_6  [2*N+1:N+1]);
        butterfly_out_re6_1<=$signed(crisp_3       [2*N+1:N+1])  +    $signed(crisp_7  [2*N+1:N+1]);
        butterfly_out_re7_1<=$signed(crisp_3       [2*N+1:N+1])  -    $signed(crisp_7  [2*N+1:N+1]);
        butterfly_out_im0_1<=$signed(crisp_0       [N:0])        +    $signed(crisp_4    [N:0]);
        butterfly_out_im1_1<=$signed(crisp_0       [N:0])        -    $signed(crisp_4    [N:0]);
        butterfly_out_im2_1<=$signed(crisp_1       [N:0])        +    $signed(crisp_5    [N:0]);
        butterfly_out_im3_1<=$signed(crisp_1       [N:0])        -    $signed(crisp_5    [N:0]);
        butterfly_out_im4_1<=$signed(crisp_2       [N:0])        +    $signed(crisp_6    [N:0]);
        butterfly_out_im5_1<=$signed(crisp_2       [N:0])        -    $signed(crisp_6    [N:0]);
        butterfly_out_im6_1<=$signed(crisp_3       [N:0])        +    $signed(crisp_7    [N:0]);
        butterfly_out_im7_1<=$signed(crisp_3       [N:0])        -    $signed(crisp_7    [N:0]);
end
//----------------------stage 2------------------------------

reg signed[N+3:0]          butterfly_out_re0_2;
reg signed[N+3:0]          butterfly_out_re1_2;
reg signed[N+3:0]          butterfly_out_re2_2;
reg signed[N+3:0]          butterfly_out_re3_2;
reg signed[N+3:0]          butterfly_out_re4_2;
reg signed[N+3:0]          butterfly_out_re5_2;
reg signed[N+3:0]          butterfly_out_im0_2;
reg signed[N+3:0]          butterfly_out_im1_2;
reg signed[N+3:0]          butterfly_out_im2_2;
reg signed[N+3:0]          butterfly_out_im3_2;
reg signed[N+3:0]          butterfly_out_im4_2;
reg signed[N+3:0]          butterfly_out_im5_2;
reg signed[N+3:0]          a3_re         ;
reg signed[N+3:0]          a3_im         ;
reg signed[N+3:0]          a4_re         ;
reg signed[N+3:0]          a4_im         ;

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
        a3_re           <=  butterfly_out_re3_1   +   butterfly_out_im7_1+butterfly_out_im3_1    -   butterfly_out_re7_1 ;
        a3_im           <=  butterfly_out_im3_1   -   butterfly_out_re7_1-(butterfly_out_re3_1   +   butterfly_out_im7_1);
        a4_re           <=  butterfly_out_im3_1   +   butterfly_out_re7_1-(butterfly_out_re3_1   -   butterfly_out_im7_1);
        a4_im           <=  -butterfly_out_im3_1  -   butterfly_out_re7_1-butterfly_out_re3_1    +   butterfly_out_im7_1 ;
end
//----------------------stage 3------------------------------
wire signed[N+3:0]x0_re; 
wire signed[N+3:0]x4_re; 
wire signed[N+3:0]x2_re; 
wire signed[N+3:0]x6_re; 
wire signed[N+3:0]x1_re; 
wire signed[N+3:0]x5_re; 
wire signed[N+3:0]x3_re; 
wire signed[N+3:0]x7_re; 
wire signed[N+3:0]x0_im; 
wire signed[N+3:0]x4_im; 
wire signed[N+3:0]x2_im; 
wire signed[N+3:0]x6_im; 
wire signed[N+3:0]x1_im; 
wire signed[N+3:0]x5_im; 
wire signed[N+3:0]x3_im; 
wire signed[N+3:0]x7_im; 
assign x0_re=x0[2*N+7:N+4];
assign x4_re=x4[2*N+7:N+4];
assign x2_re=x2[2*N+7:N+4];
assign x6_re=x6[2*N+7:N+4];
assign x1_re=x1[2*N+7:N+4];
assign x5_re=x5[2*N+7:N+4];
assign x3_re=x3[2*N+7:N+4];
assign x7_re=x7[2*N+7:N+4];
assign x0_im=x0[N+3:0];   
assign x4_im=x4[N+3:0];   
assign x2_im=x2[N+3:0];   
assign x6_im=x6[N+3:0];   
assign x1_im=x1[N+3:0];   
assign x5_im=x5[N+3:0];   
assign x3_im=x3[N+3:0];   
assign x7_im=x7[N+3:0];   

wire signed[N+17:0]a3_re_plus;
wire signed[N+17:0]a3_im_plus;
wire signed[N+17:0]a4_re_plus;
wire signed[N+17:0]a4_im_plus;
assign a3_re_plus = (a3_re <<< 14);
assign a3_im_plus = (a3_im <<< 14);
assign a4_re_plus = (a4_re <<< 14);
assign a4_im_plus = (a4_im <<< 14);

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
        x0[2*N+7:N+4]  <=  butterfly_out_re0_2   +   butterfly_out_re2_2;
        x4[2*N+7:N+4]  <=  butterfly_out_re0_2   -   butterfly_out_re2_2;
        x2[2*N+7:N+4]  <=  butterfly_out_re1_2   +   butterfly_out_im3_2;
        x6[2*N+7:N+4]  <=  butterfly_out_re1_2   -   butterfly_out_im3_2;
        x1[2*N+7:N+4]  <=  butterfly_out_re4_2   +   ((a3_re_plus>>>1)+(a3_re_plus>>>3) +(a3_re_plus>>>4) +(a3_re_plus>>>6) +(a3_re_plus>>>8) +(a3_re_plus>>> 14) >>>14)  ;  
        x5[2*N+7:N+4]  <=  butterfly_out_re4_2   -   (((a3_re_plus>>>1)+(a3_re_plus>>>3) +(a3_re_plus>>>4) +(a3_re_plus>>>6) +(a3_re_plus>>>8) +(a3_re_plus>>>14))>>>14)  ;  
        x3[2*N+7:N+4]  <=  butterfly_out_re5_2   +   ((a4_re_plus>>>1)+(a4_re_plus>>>3) +(a4_re_plus>>>4) +(a4_re_plus>>>6) +(a4_re_plus>>>8) +(a4_re_plus>>> 14) >>>14)  ;  
        x7[2*N+7:N+4]  <=  butterfly_out_re5_2   -   (((a4_re_plus>>>1)+(a4_re_plus>>>3) +(a4_re_plus>>>4) +(a4_re_plus>>>6) +(a4_re_plus>>>8) +(a4_re_plus>>>14))>>>14)  ;  
        x0[N+3:0]      <=  ifft?-(butterfly_out_im0_2   +   butterfly_out_im2_2):butterfly_out_im0_2   +   butterfly_out_im2_2;
        x4[N+3:0]      <=  ifft?-(butterfly_out_im0_2   -   butterfly_out_im2_2):butterfly_out_im0_2   -   butterfly_out_im2_2;
        x2[N+3:0]      <=  ifft?-(butterfly_out_im1_2   -   butterfly_out_re3_2):butterfly_out_im1_2   -   butterfly_out_re3_2;
        x6[N+3:0]      <=  ifft?-(butterfly_out_im1_2   +   butterfly_out_re3_2):butterfly_out_im1_2   +   butterfly_out_re3_2;
        x1[N+3:0]      <=  ifft?-(butterfly_out_im4_2   +   ((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>> 14))  >>>14):butterfly_out_im4_2   +   ((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>   14) >>>14);   
        x5[N+3:0]      <=  ifft?-(butterfly_out_im4_2   -   (((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>14) ))>>>14):butterfly_out_im4_2   -   (((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>14) ) >>>14);  
        x3[N+3:0]      <=  ifft?-(butterfly_out_im5_2   +   ((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>> 14))  >>>14):butterfly_out_im5_2   +   ((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>>   14) >>>14);   
        x7[N+3:0]      <=  ifft?-(butterfly_out_im5_2   -   (((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>>14))) >>>14):butterfly_out_im5_2   -   (((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>> 14)) >>>14);   
    end
    end
endmodule
 