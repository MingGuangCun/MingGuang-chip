module fft_top(
    input         clk_250M,
    input         rst_n   ,
    input [10:0]  addra_pc,
    input [255:0] dina_pc,
    input         wea_pc ,
    output        pc_select
);
        
        
 wire          ifft;
 wire          init_general;
 wire          fft_ing;
 
 wire [10 : 0] addra;
 wire [10 : 0] addra_fpga;
 wire [10 : 0] addrb;
 wire [10:0]   addrb_bram_ctrl;
 wire [10:0]   addrb_fpga;
 wire [255 : 0] dina;
 wire [255 : 0] dinb;
 wire [255 : 0] douta;
 wire [255 : 0] doutb;
 
 wire [0 : 0]   web;
 wire           web_fpga;
 wire           wea;
 wire [0 : 0]   wea_fpga;
 

//---------- instance list---------------
blk_mem b1(
  .clka(clk_250M),    // input   wire clka
  .wea(wea),      // input  wire [0 : 0] wea
  .addra(addra),  // input  wire [10 : 0] addra
  .dina(dina),    // input  wire [255 : 0] dina
  .douta(douta),  // output wire [255 : 0] douta
  .clkb(clk_250M),    // input  wire clkb
  .web(web),      // 0 when pc_select=1
  .addrb(addrb),  // input  wire [10 : 0] addrb
  .dinb(dinb),    // input  wire [255 : 0] dinb
  .doutb(doutb)  // output  wire [255 : 0] doutb
);

 assign addra=pc_select?addra_pc:addra_fpga;
 assign addrb=pc_select?addrb_bram_ctrl:addrb_fpga;
 assign wea=pc_select?wea_pc:0;// problem may exist
 assign dina=pc_select?dina_pc:1'd0;
 assign web=pc_select?0:web_fpga;
 wire [3:0]block_total;
 bram_ctrl bb1(
  clk_250M,
  rst_n,
  fft_ing,
  doutb,
  pc_select,
  addrb_bram_ctrl,
  ifft,
  init_general,
  block_total
 );
 

 fft_512 f1 (
         .clk          (clk_250M)
        ,.rst_n        (rst_n)      
        ,.init_general (init_general)
        ,.ifft         (ifft) 
        ,.douta        (douta) 
        ,.addra        (addra_fpga) 
        ,.web          (web_fpga ) 
        ,.addrb        (addrb_fpga) 
        ,.dinb         (dinb) 
        ,.fft_ing      (fft_ing) 
        ,.block_total   (block_total)
    );

endmodule
