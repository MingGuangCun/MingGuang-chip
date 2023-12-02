module fft_top(
    input           pcie_ref_clk_n,
    input           pcie_ref_clk_p,
    input           pcie_rstn,
    input [7:0]     pcie_mgt_rxn,
    input [7:0]     pcie_mgt_rxp,
    output [7:0]    pcie_mgt_txn,
    output [7:0]    pcie_mgt_txp
);
wire          axi_clk;
wire          clk_250M;
       
wire          rst;
wire          rst_n;
assign        rst_n=!rst;
       
wire          ifft;
wire          [1:0]mode;
wire          init_general;
wire          pc_select;
wire          fft_ing;

wire [10 : 0] addra;
wire [15 : 0] addra_pc  ;
wire [10 : 0] addra_fpga;
wire [10 : 0] addrb;
wire [10:0]   addrb_bram_ctrl;
wire [10:0]   addrb_fpga;
wire [255 : 0] dina;
wire [255 : 0] dina_pc ;
wire [255 : 0] dinb;
wire [255 : 0] douta;
wire [255 : 0] doutb;

wire           ena;
wire           ena_pc;
wire [0 : 0]   web;
wire           web_fpga;
wire           wea;
wire [31 : 0]  wea_pc    ;
wire [0 : 0]   wea_fpga;

//-------for interrupt signnal ------
wire msi_enable;
wire [2:0]msi_vector_width;
wire usr_irq_ack;
wire usr_irq_req;

assign msi_enable       = 1'b1;
assign msi_vector_width = 1'd1;

//---------- instance list---------------
blk_mem_gen_0 b1(
  .clka(clk_250M),    // input   wire clka
  .ena(ena),      // input  wire ena
  .wea(wea),      // input  wire [0 : 0] wea
  .addra(addra),  // input  wire [10 : 0] addra
  .dina(dina),    // input  wire [255 : 0] dina
  .douta(douta),  // output wire [255 : 0] douta
  .clkb(clk_250M),    // input  wire clkb
  .enb(1'b1),      // input  wire enb
  .web(web),      // 0 when pc_select=1
  .addrb(addrb),  // input  wire [10 : 0] addrb
  .dinb(dinb),    // input  wire [255 : 0] dinb
  .doutb(doutb)  // output  wire [255 : 0] doutb
);

assign addra=pc_select?addra_pc[15:5]:addra_fpga;
assign addrb=pc_select?addrb_bram_ctrl:addrb_fpga;
assign wea=pc_select?wea_pc[0]:0;// problem may exist
assign dina=pc_select?dina_pc:1'd0;
assign web=pc_select?0:web_fpga;
assign ena=pc_select?ena_pc:1'b1;
bram_ctrl bb1(
  clk_250M,
  rst_n,
  fft_ing,
  doutb,
  pc_select,
  addrb_bram_ctrl,
  ifft,
  mode,
  init_general
);
 pcie_wrapper p1
   (addra_pc,
    clk_250M,
    dina_pc,
    douta,
    ena_pc,
    rst,
    wea_pc,
    axi_clk,
    msi_enable,
    msi_vector_width,
    pcie_mgt_rxn,
    pcie_mgt_rxp,
    pcie_mgt_txn,
    pcie_mgt_txp,
    pcie_ref_clk_n,
    pcie_ref_clk_p,
    pcie_rstn,
    usr_irq_ack,
    usr_irq_req
    );
 fft_4096_modified_plus f1(
     clk_250M             ,
     rst_n                ,
     init_general         ,
     ifft                 ,
     mode                 ,         
     douta                ,
     addra_fpga           ,
     web_fpga             ,
     addrb_fpga           ,
     dinb                 ,
     fft_ing              ,
     usr_irq_ack          ,
     usr_irq_req
);

endmodule
