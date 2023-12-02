module fft_8
//implemented with real assembly line
#(parameter N='d28,
  parameter K='d16)
(
    input                         clk      ,
    input                         ifft     ,
    input      [55:0]          data0       ,
    input      [55:0]          data1       ,
    input      [55:0]          data2       ,
    input      [55:0]          data3       ,
    input      [55:0]          data4       ,
    input      [55:0]          data5       ,
    input      [55:0]          data6       ,
    input      [55:0]          data7       ,
    input      [31:0]             w1       ,
    input      [31:0]             w2       ,
    input      [31:0]             w3       ,
    input      [31:0]             w4       ,
    input      [31:0]             w5       ,
    input      [31:0]             w6       ,
    input      [31:0]             w7       ,
    input                         stall    ,
    output    reg[63:0]             x0       ,
    output    reg[63:0]             x1       ,
    output    reg[63:0]             x2       ,
    output    reg[63:0]             x3       ,
    output    reg[63:0]             x4       ,
    output    reg[63:0]             x5       ,
    output    reg[63:0]             x6       ,
    output    reg[63:0]             x7      
    //傅里叶系数,x0，x1,x2,x3,....与傅里叶展开的0，1，2，3次项依次对应
);

//定义乘积的wire
wire [91:0]crisp_0;
wire [91:0]crisp_1;
wire [91:0]crisp_2;
wire [91:0]crisp_3;
wire [91:0]crisp_4;
wire [91:0]crisp_5;
wire [91:0]crisp_6;
wire [91:0]crisp_7;

wire [45:0]crisp_0_re;
wire [45:0]crisp_1_re;
wire [45:0]crisp_2_re;
wire [45:0]crisp_3_re;
wire [45:0]crisp_4_re;
wire [45:0]crisp_5_re;
wire [45:0]crisp_6_re;
wire [45:0]crisp_7_re;
wire [45:0]crisp_0_im;
wire [45:0]crisp_1_im;
wire [45:0]crisp_2_im;
wire [45:0]crisp_3_im;
wire [45:0]crisp_4_im;
wire [45:0]crisp_5_im;
wire [45:0]crisp_6_im;
wire [45:0]crisp_7_im;

assign crisp_0_re = crisp_0[91:46];
assign crisp_1_re = crisp_1[91:46];
assign crisp_2_re = crisp_2[91:46];
assign crisp_3_re = crisp_3[91:46];
assign crisp_4_re = crisp_4[91:46];
assign crisp_5_re = crisp_5[91:46];
assign crisp_6_re = crisp_6[91:46];
assign crisp_7_re = crisp_7[91:46];
assign crisp_0_im = crisp_0[45:0];
assign crisp_1_im = crisp_1[45:0];
assign crisp_2_im = crisp_2[45:0];
assign crisp_3_im = crisp_3[45:0];
assign crisp_4_im = crisp_4[45:0];
assign crisp_5_im = crisp_5[45:0];
assign crisp_6_im = crisp_6[45:0];
assign crisp_7_im = crisp_7[45:0];

wire [31:0]w0;
assign w0=32'h40000000;
//第一级乘积 
TF t0(data0,w0,ifft,clk,crisp_0);
TF t1(data1,w1,ifft,clk,crisp_1);
TF t2(data2,w2,ifft,clk,crisp_2);
TF t3(data3,w3,ifft,clk,crisp_3);
TF t4(data4,w4,ifft,clk,crisp_4);
TF t5(data5,w5,ifft,clk,crisp_5);
TF t6(data6,w6,ifft,clk,crisp_6);
TF t7(data7,w7,ifft,clk,crisp_7);
//测试8点fft的时候没有考虑data0虚部较大时的情况（ifft要取data0共轭）



wire signed[27:0]          data_re0         ;
wire signed[27:0]          data_re1         ;
wire signed[27:0]          data_re2         ;
wire signed[27:0]          data_re3         ;
wire signed[27:0]          data_re4         ;
wire signed[27:0]          data_re5         ;
wire signed[27:0]          data_re6         ;
wire signed[27:0]          data_re7         ;
wire signed[27:0]          data_im0         ;
wire signed[27:0]          data_im1         ;
wire signed[27:0]          data_im2         ;
wire signed[27:0]          data_im3         ;
wire signed[27:0]          data_im4         ;
wire signed[27:0]          data_im5         ;
wire signed[27:0]          data_im6         ;
wire signed[27:0]          data_im7         ;
assign {data_re0,data_im0}= data0            ;
assign {data_re1,data_im1}= data1            ;
assign {data_re2,data_im2}= data2            ;
assign {data_re3,data_im3}= data3            ;
assign {data_re4,data_im4}= data4            ;
assign {data_re5,data_im5}= data5            ;
assign {data_re6,data_im6}= data6            ;
assign {data_re7,data_im7}= data7            ;




//----------------------stage 1------------------------------

reg signed[46:0]          butterfly_out_re0_1;
reg signed[46:0]          butterfly_out_re1_1;
reg signed[46:0]          butterfly_out_re2_1;
reg signed[46:0]          butterfly_out_re3_1;
reg signed[46:0]          butterfly_out_re4_1;
reg signed[46:0]          butterfly_out_re5_1;
reg signed[46:0]          butterfly_out_re6_1;
reg signed[46:0]          butterfly_out_re7_1;
reg signed[46:0]          butterfly_out_im0_1;
reg signed[46:0]          butterfly_out_im1_1;
reg signed[46:0]          butterfly_out_im2_1;
reg signed[46:0]          butterfly_out_im3_1;
reg signed[46:0]          butterfly_out_im4_1;
reg signed[46:0]          butterfly_out_im5_1;
reg signed[46:0]          butterfly_out_im6_1;
reg signed[46:0]          butterfly_out_im7_1;

always @(posedge clk ) begin
        butterfly_out_re0_1<=$signed(crisp_0       [91:46])  +    $signed(crisp_4  [91:46]);
        butterfly_out_re1_1<=$signed(crisp_0       [91:46])  -    $signed(crisp_4  [91:46]);
        butterfly_out_re2_1<=$signed(crisp_1       [91:46])  +    $signed(crisp_5  [91:46]);
        butterfly_out_re3_1<=$signed(crisp_1       [91:46])  -    $signed(crisp_5  [91:46]);
        butterfly_out_re4_1<=$signed(crisp_2       [91:46])  +    $signed(crisp_6  [91:46]);
        butterfly_out_re5_1<=$signed(crisp_2       [91:46])  -    $signed(crisp_6  [91:46]);
        butterfly_out_re6_1<=$signed(crisp_3       [91:46])  +    $signed(crisp_7  [91:46]);
        butterfly_out_re7_1<=$signed(crisp_3       [91:46])  -    $signed(crisp_7  [91:46]);
        butterfly_out_im0_1<=$signed(crisp_0       [45:0])   +    $signed(crisp_4    [45:0]);
        butterfly_out_im1_1<=$signed(crisp_0       [45:0])   -    $signed(crisp_4    [45:0]);
        butterfly_out_im2_1<=$signed(crisp_1       [45:0])   +    $signed(crisp_5    [45:0]);
        butterfly_out_im3_1<=$signed(crisp_1       [45:0])   -    $signed(crisp_5    [45:0]);
        butterfly_out_im4_1<=$signed(crisp_2       [45:0])   +    $signed(crisp_6    [45:0]);
        butterfly_out_im5_1<=$signed(crisp_2       [45:0])   -    $signed(crisp_6    [45:0]);
        butterfly_out_im6_1<=$signed(crisp_3       [45:0])   +    $signed(crisp_7    [45:0]);
        butterfly_out_im7_1<=$signed(crisp_3       [45:0])   -    $signed(crisp_7    [45:0]);
end
//----------------------stage 2------------------------------

reg signed[47:0]          butterfly_out_re0_2;
reg signed[47:0]          butterfly_out_re1_2;
reg signed[47:0]          butterfly_out_re2_2;
reg signed[47:0]          butterfly_out_re3_2;
reg signed[47:0]          butterfly_out_re4_2;
reg signed[47:0]          butterfly_out_re5_2;
reg signed[47:0]          butterfly_out_im0_2;
reg signed[47:0]          butterfly_out_im1_2;
reg signed[47:0]          butterfly_out_im2_2;
reg signed[47:0]          butterfly_out_im3_2;
reg signed[47:0]          butterfly_out_im4_2;
reg signed[47:0]          butterfly_out_im5_2;
reg signed[48:0]          a3_re_plus         ;
reg signed[48:0]          a3_im_plus         ;
reg signed[48:0]          a4_re_plus         ;
reg signed[48:0]          a4_im_plus         ;

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
reg [99:0]big_x0;
reg [99:0]big_x4;
reg [99:0]big_x2;
reg [99:0]big_x6;
reg [99:0]big_x1;
reg [99:0]big_x5;
reg [99:0]big_x3;
reg [99:0]big_x7;

wire signed [49:0]big_x0_re;
wire signed [49:0]big_x0_im;
wire signed [49:0]big_x1_re;
wire signed [49:0]big_x1_im;
wire signed [49:0]big_x2_re;
wire signed [49:0]big_x2_im;
wire signed [49:0]big_x3_re;
wire signed [49:0]big_x3_im;
wire signed [49:0]big_x4_re;
wire signed [49:0]big_x4_im;
wire signed [49:0]big_x5_re;
wire signed [49:0]big_x5_im;
wire signed [49:0]big_x6_re;
wire signed [49:0]big_x6_im;
wire signed [49:0]big_x7_re;
wire signed [49:0]big_x7_im;

assign big_x0_re=big_x0[99:50];
assign big_x4_re=big_x4[99:50];
assign big_x2_re=big_x2[99:50];
assign big_x6_re=big_x6[99:50];
assign big_x1_re=big_x1[99:50];
assign big_x5_re=big_x5[99:50];
assign big_x3_re=big_x3[99:50];
assign big_x7_re=big_x7[99:50];
assign big_x0_im=big_x0[49:0];   
assign big_x4_im=big_x4[49:0];   
assign big_x2_im=big_x2[49:0];   
assign big_x6_im=big_x6[49:0];   
assign big_x1_im=big_x1[49:0];   
assign big_x5_im=big_x5[49:0];   
assign big_x3_im=big_x3[49:0];   
assign big_x7_im=big_x7[49:0];  


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

always @(posedge clk ) 
    begin                                           
        big_x0[99:50]        <=  butterfly_out_re0_2   +   butterfly_out_re2_2;
        big_x4[99:50]        <=  butterfly_out_re0_2   -   butterfly_out_re2_2;
        big_x2[99:50]        <=  butterfly_out_re1_2   +   butterfly_out_im3_2;
        big_x6[99:50]        <=  butterfly_out_re1_2   -   butterfly_out_im3_2;
        big_x1[99:50]        <=  butterfly_out_re4_2   +   (a3_re_plus>>>1)+(a3_re_plus>>>3) +(a3_re_plus>>>4) +(a3_re_plus>>>6) +(a3_re_plus>>>8) +(a3_re_plus>>> 14)   ;  
        big_x5[99:50]        <=  butterfly_out_re4_2   -   ((a3_re_plus>>>1)+(a3_re_plus>>>3) +(a3_re_plus>>>4) +(a3_re_plus>>>6) +(a3_re_plus>>>8) +(a3_re_plus>>>14))  ;  
        big_x3[99:50]        <=  butterfly_out_re5_2   +   (a4_re_plus>>>1)+(a4_re_plus>>>3) +(a4_re_plus>>>4) +(a4_re_plus>>>6) +(a4_re_plus>>>8) +(a4_re_plus>>> 14)   ;  
        big_x7[99:50]        <=  butterfly_out_re5_2   -   ((a4_re_plus>>>1)+(a4_re_plus>>>3) +(a4_re_plus>>>4) +(a4_re_plus>>>6) +(a4_re_plus>>>8) +(a4_re_plus>>>14))  ;  
        big_x0[49:0]         <=  ifft?-(butterfly_out_im0_2   +   butterfly_out_im2_2):butterfly_out_im0_2   +   butterfly_out_im2_2;
        big_x4[49:0]         <=  ifft?-(butterfly_out_im0_2   -   butterfly_out_im2_2):butterfly_out_im0_2   -   butterfly_out_im2_2;
        big_x2[49:0]         <=  ifft?-(butterfly_out_im1_2   -   butterfly_out_re3_2):butterfly_out_im1_2   -   butterfly_out_re3_2;
        big_x6[49:0]         <=  ifft?-(butterfly_out_im1_2   +   butterfly_out_re3_2):butterfly_out_im1_2   +   butterfly_out_re3_2;
        big_x1[49:0]         <=  ifft?-(butterfly_out_im4_2   +   (a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>> 14))  :butterfly_out_im4_2   +   (a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>   14) ;
        big_x5[49:0]         <=  ifft?-(butterfly_out_im4_2   -   ((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>14) )):butterfly_out_im4_2   -   ((a3_im_plus>>>1)+(a3_im_plus>>>3) +(a3_im_plus>>>4) +(a3_im_plus>>>6) +(a3_im_plus>>>8) +(a3_im_plus>>>14) ) ;
        big_x3[49:0]         <=  ifft?-(butterfly_out_im5_2   +   (a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>> 14))  :butterfly_out_im5_2   +   (a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>>   14) ;
        big_x7[49:0]         <=  ifft?-(butterfly_out_im5_2   -   ((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>>14))) :butterfly_out_im5_2   -   ((a4_im_plus>>>1)+(a4_im_plus>>>3) +(a4_im_plus>>>4) +(a4_im_plus>>>6) +(a4_im_plus>>>8) +(a4_im_plus>>> 14)) ;
    end

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
        x0[63:32]     <=  big_x0_re>>>14;
        x4[63:32]     <=  big_x4_re>>>14;
        x2[63:32]     <=  big_x2_re>>>14;
        x6[63:32]     <=  big_x6_re>>>14;
        x1[63:32]     <=  big_x1_re>>>14;
        x5[63:32]     <=  big_x5_re>>>14;
        x3[63:32]     <=  big_x3_re>>>14;
        x7[63:32]     <=  big_x7_re>>>14;
        x0[31:0]      <=  big_x0_im>>>14;
        x4[31:0]      <=  big_x4_im>>>14;
        x2[31:0]      <=  big_x2_im>>>14;
        x6[31:0]      <=  big_x6_im>>>14;
        x1[31:0]      <=  big_x1_im>>>14;
        x5[31:0]      <=  big_x5_im>>>14;
        x3[31:0]      <=  big_x3_im>>>14;
        x7[31:0]      <=  big_x7_im>>>14;
    end
    end

endmodule
 