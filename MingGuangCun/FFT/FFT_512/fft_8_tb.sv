`timescale 1ns/1ps
`define DATA_WIDTH 28
`define W_WIDTH 16
`define FFT_ANS_WIDTH 32  
module fft_8_tb;
reg  clk;
reg rstn;
reg ifft;
reg [2*`DATA_WIDTH-1:0]data0;
reg [2*`DATA_WIDTH-1:0]data1;
reg [2*`DATA_WIDTH-1:0]data2;
reg [2*`DATA_WIDTH-1:0]data3;
reg [2*`DATA_WIDTH-1:0]data4;
reg [2*`DATA_WIDTH-1:0]data5;
reg [2*`DATA_WIDTH-1:0]data6;
reg [2*`DATA_WIDTH-1:0]data7;

reg [2*`W_WIDTH-1:0]w1   ;
reg [2*`W_WIDTH-1:0]w2   ;
reg [2*`W_WIDTH-1:0]w3   ;
reg [2*`W_WIDTH-1:0]w4   ;
reg [2*`W_WIDTH-1:0]w5   ;
reg [2*`W_WIDTH-1:0]w6   ;
reg [2*`W_WIDTH-1:0]w7   ;

wire [2*`FFT_ANS_WIDTH-1:0]x0   ;
wire [2*`FFT_ANS_WIDTH-1:0]x1   ;
wire [2*`FFT_ANS_WIDTH-1:0]x2   ;
wire [2*`FFT_ANS_WIDTH-1:0]x3   ;
wire [2*`FFT_ANS_WIDTH-1:0]x4   ;
wire [2*`FFT_ANS_WIDTH-1:0]x5   ;
wire [2*`FFT_ANS_WIDTH-1:0]x6   ;
wire [2*`FFT_ANS_WIDTH-1:0]x7   ;
reg stall;
reg [31:0]cnt;
 //----------------------instantiation --------------------------
 
//-------------- fft_8 dut -----------------------
 fft_8 f1(
.clk   (clk     ) ,
.ifft  (ifft    ) ,
.data0 (data0) ,
.data1 (data1) ,
.data2 (data2) ,
.data3 (data3) ,
.data4 (data4) ,
.data5 (data5) ,
.data6 (data6) ,
.data7 (data7) ,
.w1    (w1   ) ,
.w2    (w2   ) ,
.w3    (w3   ) ,
.w4    (w4   ) ,
.w5    (w5   ) ,
.w6    (w6   ) ,
.w7    (w7   ) ,
.x0    (x0   ) ,
.x1    (x1   ) ,
.x2    (x2   ) ,
.x3    (x3   ) ,
.x4    (x4   ) ,
.x5    (x5   ) ,
.x6    (x6   ) ,
.x7    (x7   ) ,
.stall (stall)
);

reg signed[15:0]packed_data[4096:0];
initial begin 
  $readmemb("E:/fft/simulations/fft_8_data.txt",packed_data);
end
// clock generation
initial begin 
  clk <= 0;
  forever begin
    #5 clk <= !clk;
  end
end

// reset trigger
initial begin 
  #10 rstn <= 0;
  repeat(10) @(posedge clk);
  rstn <= 1;
end
integer fid;
// data test
initial begin 
  fid = $fopen("E:/fft/simulations/result.txt");
  cnt = 0;
  @(posedge rstn);
  repeat(5) @(posedge clk);
  $display("there");
  $display("cnt=%d",cnt);
  while(cnt<256)begin
    process_fft();
    assign_w();
    assign_data(cnt);
    write_data2file();
    stall = 0;
    cnt = cnt + 1;
  end
  repeat(20)@(posedge clk);
  $finish();
end
task process_fft();
  @(posedge clk)ifft = 0;
endtask
task process_ifft();
  @(posedge clk)ifft = 1;
endtask
task assign_w();
  w1[`W_WIDTH-1:0] = 0;
  w1[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w2[`W_WIDTH-1:0] = 0;
  w2[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w3[`W_WIDTH-1:0] = 0;
  w3[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w4[`W_WIDTH-1:0] = 0;
  w4[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w5[`W_WIDTH-1:0] = 0;
  w5[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w6[`W_WIDTH-1:0] = 0;
  w6[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
  w7[`W_WIDTH-1:0] = 0;
  w7[2*`W_WIDTH-1:`W_WIDTH] = 16'h4000;
endtask
task assign_data(
  input [31:0]id
  );
  data0[`DATA_WIDTH-1:0]                   = packed_data[16*id-16];
  data0[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-15];
  data1[`DATA_WIDTH-1:0]                   = packed_data[16*id-14];
  data1[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-13];
  data2[`DATA_WIDTH-1:0]                   = packed_data[16*id-12];
  data2[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-11];
  data3[`DATA_WIDTH-1:0]                   = packed_data[16*id-10];
  data3[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-9];
  data4[`DATA_WIDTH-1:0]                   = packed_data[16*id-8];
  data4[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-7];
  data5[`DATA_WIDTH-1:0]                   = packed_data[16*id-6];
  data5[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-5];
  data6[`DATA_WIDTH-1:0]                   = packed_data[16*id-4];
  data6[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-3];
  data7[`DATA_WIDTH-1:0]                   = packed_data[16*id-2];
  data7[2*`DATA_WIDTH-1:`DATA_WIDTH]       = packed_data[16*id-1];
endtask
function void write_data2file(); 
  $display("here");
  // $fwrite(fid,"%d\n",$signed(x0[`FFT_ANS_WIDTH-1:0]));
  $fwrite(fid,"%d\n",f1.x0_im);
  $fwrite(fid,"%d\n",f1.x0_re);
  $fwrite(fid,"%d\n",f1.x1_im);
  $fwrite(fid,"%d\n",f1.x1_re);
  $fwrite(fid,"%d\n",f1.x2_im);
  $fwrite(fid,"%d\n",f1.x2_re);
  $fwrite(fid,"%d\n",f1.x3_im);
  $fwrite(fid,"%d\n",f1.x3_re);
  $fwrite(fid,"%d\n",f1.x4_im);
  $fwrite(fid,"%d\n",f1.x4_re);
  $fwrite(fid,"%d\n",f1.x5_im);
  $fwrite(fid,"%d\n",f1.x5_re);
  $fwrite(fid,"%d\n",f1.x6_im);
  $fwrite(fid,"%d\n",f1.x6_re);
  $fwrite(fid,"%d\n",f1.x7_im);
  $fwrite(fid,"%d\n",f1.x7_re);
  // signed(x0[`FFT_ANS_WIDTH-1:0])
endfunction


endmodule
