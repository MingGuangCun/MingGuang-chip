module fft_4
//implemented with real assembly line
#(parameter N=5'd28)(
    input                         clk   ,
    input                         ifft  ,
    input      [2*N-1:0]          data0 ,
    input      [2*N-1:0]          data1 ,
    input      [2*N-1:0]          data2 ,
    input      [2*N-1:0]          data3 ,
    input      [31:0]             w1    ,
    input      [31:0]             w2    ,
    input      [31:0]             w3    ,
    input                         stall ,
    output  reg[2*N+7:0]          x0       ,
    output  reg[2*N+7:0]          x1       ,
    output  reg[2*N+7:0]          x2       ,
    output  reg[2*N+7:0]          x3     
    //傅里叶系数,x0，x1,x2,x3,....与傅里叶展开的0，1，2，3次项依次对应
);
// 7 clk required 0->8 0->input_data asigned,8->output_data fetched
wire [91:0]crisp_0   ;
wire [91:0]crisp_1   ;
wire [91:0]crisp_2   ;
wire [91:0]crisp_3   ;
wire [31:0]w0;
assign w0=32'h40000000;
TF t0(data0,w0,ifft,clk,crisp_0);
TF t1(data1,w1,ifft,clk,crisp_1);
TF t2(data2,w2,ifft,clk,crisp_2);
TF t3(data3,w3,ifft,clk,crisp_3);


//these signals are designed to debug
wire signed[N-1:0]data_re0;
wire signed[N-1:0]data_re1;
wire signed[N-1:0]data_re2;
wire signed[N-1:0]data_re3;
wire signed[N-1:0]data_im0;
wire signed[N-1:0]data_im1;
wire signed[N-1:0]data_im2;
wire signed[N-1:0]data_im3;
assign {data_re0,data_im0}=data0;
assign {data_re1,data_im1}=data1;
assign {data_re2,data_im2}=data2;
assign {data_re3,data_im3}=data3;

//----------------------stage 1------------------------------

reg signed[46:0]          butterfly_out_re0_1;
reg signed[46:0]          butterfly_out_re1_1;
reg signed[46:0]          butterfly_out_re2_1;
reg signed[46:0]          butterfly_out_re3_1;
reg signed[46:0]          butterfly_out_im0_1;
reg signed[46:0]          butterfly_out_im1_1;
reg signed[46:0]          butterfly_out_im2_1;
reg signed[46:0]          butterfly_out_im3_1;

always @(posedge clk) begin
    butterfly_out_re0_1<=$signed(crisp_0       [91:46])  +    $signed(crisp_2  [91:46]);
    butterfly_out_re1_1<=$signed(crisp_1       [91:46])  +    $signed(crisp_3  [91:46]);
    butterfly_out_re2_1<=$signed(crisp_0       [91:46])  -    $signed(crisp_2  [91:46]);
    butterfly_out_re3_1<=$signed(crisp_1       [91:46])  -    $signed(crisp_3  [91:46]);
    butterfly_out_im0_1<=$signed(crisp_0       [45:0])        +    $signed(crisp_2    [45:0]);
    butterfly_out_im1_1<=$signed(crisp_1       [45:0])        +    $signed(crisp_3    [45:0]);
    butterfly_out_im2_1<=$signed(crisp_0       [45:0])        -    $signed(crisp_2    [45:0]);
    butterfly_out_im3_1<=$signed(crisp_1       [45:0])        -    $signed(crisp_3    [45:0]);
end
//----------------------stage 2------------------------------

reg [95:0]big_x0;
reg [95:0]big_x2;
reg [95:0]big_x1;
reg [95:0]big_x3;

wire signed [47:0]big_x0_re;
wire signed [47:0]big_x0_im;
wire signed [47:0]big_x1_re;
wire signed [47:0]big_x1_im;
wire signed [47:0]big_x2_re;
wire signed [47:0]big_x2_im;
wire signed [47:0]big_x3_re;
wire signed [47:0]big_x3_im;

assign big_x0_re=big_x0[95:48];
assign big_x2_re=big_x2[95:48];
assign big_x1_re=big_x1[95:48];
assign big_x3_re=big_x3[95:48];
assign big_x0_im=big_x0[47:0];      
assign big_x2_im=big_x2[47:0];    
assign big_x1_im=big_x1[47:0];    
assign big_x3_im=big_x3[47:0];   
always @(posedge clk) begin
   begin                          
        big_x0[95:48]  <=  butterfly_out_re0_1   +   butterfly_out_re1_1;
        big_x2[95:48]  <=  butterfly_out_re0_1   -   butterfly_out_re1_1;
        big_x1[95:48]  <=  butterfly_out_re2_1   +   butterfly_out_im3_1; 
        big_x3[95:48]  <=  butterfly_out_re2_1   -   butterfly_out_im3_1;  
        big_x0[47:0]  <=  ifft?-(butterfly_out_im0_1   +   butterfly_out_im1_1):(butterfly_out_im0_1   +   butterfly_out_im1_1);
        big_x2[47:0]  <=  ifft?-(butterfly_out_im0_1   -   butterfly_out_im1_1):(butterfly_out_im0_1   -   butterfly_out_im1_1);
        big_x1[47:0]  <=  ifft?-(butterfly_out_im2_1   -   butterfly_out_re3_1):(butterfly_out_im2_1   -   butterfly_out_re3_1);
        big_x3[47:0]  <=  ifft?-(butterfly_out_im2_1   +   butterfly_out_re3_1):(butterfly_out_im2_1   +   butterfly_out_re3_1);
    end
end

//----------------------stage 3------------------------------


always @(posedge clk ) 
    begin              
    if(stall)begin
        x0  <=  x0;
        x2  <=  x2;
        x1  <=  x1;
        x3  <=  x3;
    end
    else begin                          
        x0[63:32]     <=  big_x0_re>>>14;
        x2[63:32]     <=  big_x2_re>>>14;
        x1[63:32]     <=  big_x1_re>>>14;
        x3[63:32]     <=  big_x3_re>>>14;
        x0[31:0]      <=  big_x0_im>>>14;
        x2[31:0]      <=  big_x2_im>>>14;
        x1[31:0]      <=  big_x1_im>>>14;
        x3[31:0]      <=  big_x3_im>>>14;
    end
    end
endmodule
