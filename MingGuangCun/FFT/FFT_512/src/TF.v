module TF
`define DATA_WIDTH 28
`define W_WIDTH 16
(
input [2*`DATA_WIDTH-1:0]data,
input [2*`W_WIDTH-1:0]w,
input       ifft,//reverse the imagnation part of data if ifft=1
input       clk,
output reg [2*`DATA_WIDTH+2*`W_WIDTH-1:0]ans
);


reg signed[`DATA_WIDTH-1:0]data1_re;
reg signed[`DATA_WIDTH-1:0]data1_im;
reg signed[`W_WIDTH-1:0]w1_re;
reg signed[`W_WIDTH-1:0]w1_im;


//stage 1
always @(posedge clk ) begin
    begin
        data1_re  <=  $signed(data[2*`DATA_WIDTH-1:`DATA_WIDTH]);
        data1_im  <=  ifft?-$signed(data[`DATA_WIDTH-1:0] ):$signed(data[`DATA_WIDTH-1:0] );
        w1_re     <=  $signed(w[2*`W_WIDTH-1:`W_WIDTH]   );
        w1_im     <=  $signed(w[`W_WIDTH-1:0]    );
    end
end

//stage 2
reg signed[`DATA_WIDTH-1:0]data2_re;
reg signed[`DATA_WIDTH-1:0]data2_im;
reg signed[`W_WIDTH-1:0]w2_re;
reg signed[`W_WIDTH-1:0]w2_im;

reg signed[`DATA_WIDTH:0]crisp_1;
reg signed[`W_WIDTH:0]meiko_1;
reg signed[`W_WIDTH:0]ming_1;
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
wire signed[`DATA_WIDTH+15:0]x1_1;
wire signed[`DATA_WIDTH+13:0]x2_1;
wire signed[`DATA_WIDTH+11:0]x3_1;
wire signed[`DATA_WIDTH+9:0] x4_1;
wire signed[`DATA_WIDTH+7:0] x5_1;
wire signed[`DATA_WIDTH+5:0] x6_1;
wire signed[`DATA_WIDTH+3:0] x7_1;
wire signed[`DATA_WIDTH+1:0] x8_1;

booth_crisp #(`DATA_WIDTH+1,4'd14)b1(w2_re[15:13],x1_1,crisp_1);//<<N-2
booth_crisp #(`DATA_WIDTH+1,4'd12)b2(w2_re[13:11],x2_1,crisp_1);//N-4
booth_crisp #(`DATA_WIDTH+1,4'd10)b3(w2_re[11:9],x3_1,crisp_1);//N-6
booth_crisp #(`DATA_WIDTH+1,4'd8)b4( w2_re[9:7],x4_1,crisp_1);//N-8
booth_crisp #(`DATA_WIDTH+1,3'd6)b5( w2_re[7:5],x5_1,crisp_1);//N-10
booth_crisp #(`DATA_WIDTH+1,3'd4)b6( w2_re[5:3],x6_1,crisp_1);//N-12
booth_crisp #(`DATA_WIDTH+1,2'd2)b7( w2_re[3:1],x7_1,crisp_1);//N-14
booth_crisp #(`DATA_WIDTH+1,1'd0)b8({w2_re[1:0],1'b0},x8_1,crisp_1);////0
//perform x1+x2+..+x8

wire signed[`DATA_WIDTH+14:0]x1_2;
wire signed[`DATA_WIDTH+12:0]x2_2;
wire signed[`DATA_WIDTH+10:0]x3_2;
wire signed[`DATA_WIDTH+8:0] x4_2;
wire signed[`DATA_WIDTH+6:0] x5_2;
wire signed[`DATA_WIDTH+4:0] x6_2;
wire signed[`DATA_WIDTH+2:0] x7_2;
wire signed[`DATA_WIDTH:0]   x8_2;
//13个存储运算结果的地方，这些后面会相加
booth_crisp #(`DATA_WIDTH,4'd14)b13(meiko_1[15:13],x1_2,data2_im);//<<N-2
booth_crisp #(`DATA_WIDTH,4'd12)b23(meiko_1[13:11],x2_2,data2_im);//N-4
booth_crisp #(`DATA_WIDTH,4'd10)b33(meiko_1[11:9],x3_2 ,data2_im);//N-6
booth_crisp #(`DATA_WIDTH,4'd8)b43( meiko_1[9:7],x4_2  ,data2_im);//N-8
booth_crisp #(`DATA_WIDTH,4'd6)b53( meiko_1[7:5],x5_2  ,data2_im);//N-10
booth_crisp #(`DATA_WIDTH,4'd4)b63( meiko_1[5:3],x6_2  ,data2_im);//N-12
booth_crisp #(`DATA_WIDTH,4'd2)b73( meiko_1[3:1],x7_2  ,data2_im);//N-14
booth_crisp #(`DATA_WIDTH,4'd0)b83({meiko_1[1:0],1'b0},x8_2,data2_im);////0



wire signed[`DATA_WIDTH+14:0]x1_3;
wire signed[`DATA_WIDTH+12:0]x2_3;
wire signed[`DATA_WIDTH+10:0]x3_3;
wire signed[`DATA_WIDTH+8:0] x4_3;
wire signed[`DATA_WIDTH+6:0] x5_3;
wire signed[`DATA_WIDTH+4:0] x6_3;
wire signed[`DATA_WIDTH+2:0] x7_3;
wire signed[`DATA_WIDTH:0]   x8_3;
//13个存储运算结果的地方，这些后面会相加
booth_crisp #(`DATA_WIDTH,4'd14)b12(ming_1[15:13]    ,x1_3,data2_re);//<<N-2
booth_crisp #(`DATA_WIDTH,4'd12)b22(ming_1[13:11]    ,x2_3,data2_re);//N-4
booth_crisp #(`DATA_WIDTH,4'd10)b32(ming_1[11:9]     ,x3_3,data2_re);//N-6
booth_crisp #(`DATA_WIDTH,4'd8)b42( ming_1[9:7]      ,x4_3,data2_re);//N-8
booth_crisp #(`DATA_WIDTH,4'd6)b52( ming_1[7:5]      ,x5_3,data2_re);//N-10
booth_crisp #(`DATA_WIDTH,4'd4)b62( ming_1[5:3]      ,x6_3,data2_re);//N-12
booth_crisp #(`DATA_WIDTH,4'd2)b72( ming_1[3:1]      ,x7_3,data2_re);//N-14
booth_crisp #(`DATA_WIDTH,4'd0)b82({ming_1[1:0],1'b0},x8_3,data2_re);////0
//stage 3
reg signed [`DATA_WIDTH+15+1:0]crisp1 ;
reg signed [`DATA_WIDTH+7+1: 0]crisp2 ;
reg signed [`DATA_WIDTH+14+1:0]meiko1 ;
reg signed [`DATA_WIDTH+6+1: 0]meiko2 ;
reg signed [`DATA_WIDTH+14+1:0]ming1  ;
reg signed [`DATA_WIDTH+6+1: 0]ming2  ;

always @(posedge clk ) begin
        crisp1       <=     x1_1+x2_1+x3_1+x4_1;  
        crisp2       <=     x5_1+x6_1+x7_1+x8_1;
        meiko1       <=     x1_2+x2_2+x3_2+x4_2;
        meiko2       <=     x5_2+x6_2+x7_2+x8_2;
        ming1        <=     x1_3+x2_3+x3_3+x4_3;
        ming2        <=     x5_3+x6_3+x7_3+x8_3;
end
//stage 4
wire signed[`DATA_WIDTH+`W_WIDTH-1:0] ans_re;
wire signed[`DATA_WIDTH+`W_WIDTH-1:0] ans_im;
assign ans_re=ans[2*`DATA_WIDTH+2*`W_WIDTH-1:`DATA_WIDTH+`W_WIDTH];
assign ans_im=ans[`DATA_WIDTH+`W_WIDTH-1:0] ;
always @(posedge clk ) begin
        ans[2*`DATA_WIDTH+2*`W_WIDTH-1:`DATA_WIDTH+`W_WIDTH] <= crisp1+crisp2-(meiko1+meiko2) ;
        ans[`DATA_WIDTH+`W_WIDTH-1:0]  <= crisp1+crisp2-(ming1+ming2  ) ;
end


endmodule
