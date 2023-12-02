module fft_2
#(parameter N=5'd28)(
    input                         clk   ,
    input                         ifft  ,
    input      [2*N-1:0]          data0 ,
    input      [2*N-1:0]          data1 ,
    input      [31:0]             w1    ,
    output     reg[2*N+7:0]          x0    ,
    output     reg[2*N+7:0]          x1    
    //傅里叶系数,x0，x1,x2,x3,....与傅里叶展开的0，1，2，3次项依次对应
);
// 6 clk required 0->8 0->input_data asigned,8->output_data fetched
wire [91:0]crisp_0   ;
wire [91:0]crisp_1   ;
wire [31:0]w0;
assign w0=32'h40000000;

TF t0(data0,w0,ifft,clk,crisp_0);
TF t1(data1,w1,ifft,clk,crisp_1);


wire signed[N-1:0]data_re0;
wire signed[N-1:0]data_re1;
wire signed[N-1:0]data_im0;
wire signed[N-1:0]data_im1;

assign {data_re0,data_im0}=data0;
assign {data_re1,data_im1}=data1;

//------stage  1---------------------
reg [93:0]big_x0;
reg [93:0]big_x2;
reg [93:0]big_x1;
reg [93:0]big_x3;

wire signed [46:0]big_x0_re;
wire signed [46:0]big_x0_im;
wire signed [46:0]big_x1_re;
wire signed [46:0]big_x1_im;

assign big_x0_re=big_x0[93:47];
assign big_x1_re=big_x1[93:47];
assign big_x0_im=big_x0[46:0];       
assign big_x1_im=big_x1[46:0];    
always @(posedge clk ) begin
        big_x0[93:47]  <=  $signed(crisp_0       [91:46])  +    $signed(crisp_1  [91:46]);
        big_x1[93:47]  <=  $signed(crisp_0       [91:46])  -    $signed(crisp_1  [91:46]);
        big_x0[46:0]   <=  ifft?-($signed(crisp_0       [45:0])        +    $signed(crisp_1    [45:0])):($signed(crisp_0       [45:0])        +    $signed(crisp_1    [45:0]));
        big_x1[46:0]   <=  ifft?-($signed(crisp_0       [45:0])        -    $signed(crisp_1    [45:0])):($signed(crisp_0       [45:0])        -    $signed(crisp_1    [45:0]));
end
//----------------------stage 2------------------------------
always @(posedge clk ) 
     begin                          
        x0[63:32]     <=  big_x0_re>>>14;
        x1[63:32]     <=  big_x1_re>>>14;
        x0[31:0]      <=  big_x0_im>>>14;
        x1[31:0]      <=  big_x1_im>>>14;
    end

/*
flow line template
//----------------------stage 1  after TF output the result------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        
    end
    else if(vld_s2)begin
        
    end
    else begin
        
    end
end
*/

endmodule
