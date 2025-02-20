module TF
(//不装了，28位实部28位虚部,参数N没用，就做个形式
input [55:0]data,//data28位实部28位虚部
input [31:0]w,//16位虚部16位实部,旋转因子在相乘之后要移位
input       ifft,//reverse the imagnation part of data if ifft=1
input       clk,
output reg [91:0]ans
);
//最后右移K-2位，因为是K-2位量化
//5 clk required
//极致的流水线，连开始都没有，一直流就完事儿了
//乘旋转因子

reg signed[27:0]data1_re;
reg signed[27:0]data1_im;
reg signed[15:0]w1_re;
reg signed[15:0]w1_im;
 

//stage 1
always @(posedge clk ) begin
    begin
        data1_re  <=  $signed(data[55:28]);
        data1_im  <=  ifft?-$signed(data[27:0] ):$signed(data[27:0] );
        w1_re     <=  $signed(w[31:16]   );
        w1_im     <=  $signed(w[15:0]    );
    end
end

//stage 2
reg signed[27:0]data2_re;
reg signed[27:0]data2_im;
reg signed[15:0]w2_re;
reg signed[15:0]w2_im;
reg signed[28:0]crisp_1;
reg signed[16:0]meiko_1;
reg signed[16:0]ming_1;
always @(posedge clk ) begin
    begin
        crisp_1                       <=        data1_re +  data1_im     ;
        meiko_1                       <=        w1_im    +    w1_re      ;
        ming_1                        <=        w1_re    -    w1_im      ;
    end
end
always @(posedge clk ) begin
    begin
        data2_re  <=  data1_re;
        data2_im  <=  data1_im;
        w2_re     <=  w1_re   ;
        w2_im     <=  w1_im   ;
    end
end
//stage 3
wire signed[43:0]x1_1;
wire signed[41:0]x2_1;
wire signed[39:0]x3_1;
wire signed[37:0] x4_1;
wire signed[35:0] x5_1;
wire signed[33:0] x6_1;
wire signed[31:0] x7_1;
wire signed[29:0] x8_1;
//由于crisp_1的位宽与data多一位，所以不完全一样
//13个存储运算结果的地方，这些后面会相加
booth_crisp #('d29,'d14)b1(w2_re[15:13],x1_1,crisp_1);//<<N-2
booth_crisp #('d29,'d12)b2(w2_re[13:11],x2_1,crisp_1);//N-4
booth_crisp #('d29,'d10)b3(w2_re[11:9],x3_1,crisp_1);//N-6
booth_crisp #('d29,'d8)b4( w2_re[9:7],x4_1,crisp_1);//N-8
booth_crisp #('d29,'d6)b5( w2_re[7:5],x5_1,crisp_1);//N-10
booth_crisp #('d29,'d4)b6( w2_re[5:3],x6_1,crisp_1);//N-12
booth_crisp #('d29,'d2)b7( w2_re[3:1],x7_1,crisp_1);//N-14
booth_crisp #('d29,'d0)b8({w2_re[1:0],1'b0},x8_1,crisp_1);////0
//perform x1+x2+..+x8

wire signed[42:0]x1_2;
wire signed[40:0]x2_2;
wire signed[38:0]x3_2;
wire signed[36:0]x4_2;
wire signed[34:0]x5_2;
wire signed[32:0]x6_2;
wire signed[30:0]x7_2;
wire signed[28:0]x8_2;
//13个存储运算结果的地方，这些后面会相加
booth_crisp #('d28,4'd14)b13(meiko_1[15:13],x1_2,data2_im);//<<N-2
booth_crisp #('d28,4'd12)b23(meiko_1[13:11],x2_2,data2_im);//N-4
booth_crisp #('d28,4'd10)b33(meiko_1[11:9],x3_2 ,data2_im);//N-6
booth_crisp #('d28,4'd8)b43( meiko_1[9:7],x4_2  ,data2_im);//N-8
booth_crisp #('d28,4'd6)b53( meiko_1[7:5],x5_2  ,data2_im);//N-10
booth_crisp #('d28,4'd4)b63( meiko_1[5:3],x6_2  ,data2_im);//N-12
booth_crisp #('d28,4'd2)b73( meiko_1[3:1],x7_2  ,data2_im);//N-14
booth_crisp #('d28,4'd0)b83({meiko_1[1:0],1'b0},x8_2,data2_im);////0



wire signed[42:0]x1_3;
wire signed[40:0]x2_3;
wire signed[38:0]x3_3;
wire signed[36:0]x4_3;
wire signed[34:0]x5_3;
wire signed[32:0]x6_3;
wire signed[30:0]x7_3;
wire signed[28:0]x8_3;
//13个存储运算结果的地方，这些后面会相加
booth_crisp #('d28,4'd14)b12(ming_1[15:13]    ,x1_3,data2_re);//<<N-2
booth_crisp #('d28,4'd12)b22(ming_1[13:11]    ,x2_3,data2_re);//N-4
booth_crisp #('d28,4'd10)b32(ming_1[11:9]     ,x3_3,data2_re);//N-6
booth_crisp #('d28,4'd8)b42( ming_1[9:7]      ,x4_3,data2_re);//N-8
booth_crisp #('d28,4'd6)b52( ming_1[7:5]      ,x5_3,data2_re);//N-10
booth_crisp #('d28,4'd4)b62( ming_1[5:3]      ,x6_3,data2_re);//N-12
booth_crisp #('d28,4'd2)b72( ming_1[3:1]      ,x7_3,data2_re);//N-14
booth_crisp #('d28,4'd0)b82({ming_1[1:0],1'b0},x8_3,data2_re);////0
//stage 3
reg signed [44:0]crisp1 ;
reg signed [36:0]crisp2 ;
reg signed [43:0]meiko1 ;
reg signed [35:0]meiko2 ;
reg signed [43:0]ming1  ;
reg signed [35:0]ming2  ;

always @(posedge clk ) begin
        crisp1       <=     x1_1+x2_1+x3_1+x4_1;  
        crisp2       <=     x5_1+x6_1+x7_1+x8_1;
        meiko1       <=     x1_2+x2_2+x3_2+x4_2;
        meiko2       <=     x5_2+x6_2+x7_2+x8_2;
        ming1        <=     x1_3+x2_3+x3_3+x4_3;
        ming2        <=     x5_3+x6_3+x7_3+x8_3;
end
//stage 4
wire signed[45:0] ans_re;
wire signed[45:0] ans_im;
assign ans_re=ans[91:46];
assign ans_im=ans[45:0] ;
always @(posedge clk ) begin
        ans[91:46] <= crisp1+crisp2-(meiko1+meiko2) ;
        ans[45:0]  <= crisp1+crisp2-(ming1+ming2  ) ;
end


endmodule
