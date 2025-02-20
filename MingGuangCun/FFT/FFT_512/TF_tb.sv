`timescale 1ns/1ps
`define DATA_WIDTH 16
`define W_WIDTH 16
module TF_tb;
reg                         clk ;
reg                         rstn;
reg      [2*`DATA_WIDTH-1:0]data;
reg      [2*`W_WIDTH-1:0]   w   ;
reg                         ifft;
wire    [2*`DATA_WIDTH+2*`W_WIDTH-1:0]ans;

TF dut(
   .data(data)
  ,.w(w)
  ,.ifft(ifft)
  ,.clk(clk)
  ,.ans(ans)
);

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

// data test
initial begin 
  @(posedge rstn);
  repeat(5) @(posedge clk);
  process_fft();
  data[`DATA_WIDTH-1:0] = `DATA_WIDTH'd340;
  data[2*`DATA_WIDTH-1:`DATA_WIDTH] = `DATA_WIDTH'd340;
  w[`W_WIDTH-1:0] = `W_WIDTH'd340;
  w[2*`W_WIDTH-1:`W_WIDTH] = `W_WIDTH'd340;
  @(posedge clk)
  data[`DATA_WIDTH-1:0] = `DATA_WIDTH'd340;
  data[2*`DATA_WIDTH-1:`DATA_WIDTH] = `DATA_WIDTH'd340;
  w[`W_WIDTH-1:0] = `W_WIDTH'd340;
  w[2*`W_WIDTH-1:`W_WIDTH] = -`W_WIDTH'd340;
  repeat(20)@(posedge clk);
  $finish();
end
task process_fft();
  @(posedge clk)ifft = 0;
endtask
task process_ifft();
  @(posedge clk)ifft = 1;
endtask



endmodule
