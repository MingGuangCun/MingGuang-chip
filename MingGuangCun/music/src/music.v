module music(
    input                       pcie_ref_clk_n          ,
    input                       pcie_ref_clk_p          ,
    input                       pcie_rstn               ,
    input   [7:0]               pcie_mgt_rxn            ,
    input   [7:0]               pcie_mgt_rxp            ,
    output  [7:0]               pcie_mgt_txn            ,
    output  [7:0]               pcie_mgt_txp
);
wire                   bramctrl_clk;
wire                   bramctrl_rst;
wire                   clk_150m;
reg                    rst_150m;
wire                   locked_150m;
//-------------------------bram_interface_from_pcie------------------------------//
wire                   bram_en;
wire        [31:0]     bram_we;
wire        [16:0]     bram_addr;
wire        [255:0]    bram_data_out;
wire        [255:0]    bram_data_in;
//------------------------bram_interface_from_bram_portb-------------------------//
// wire                   bramctrl_we;
wire        [10:0]     bramctrl_addr;
wire        [255:0]    bramctrl_data_out;
// wire        [255:0]    bramctrl_data_in;
//------------------------bram_interface_from_bram_porta-------------------------//
wire        [31:0]     brama_we;
wire        [16:0]     brama_addr;
wire        [255:0]    brama_data_out;
wire        [255:0]    brama_data_in;
//-------------------------bram_interface_from_bram_cfg--------------------------//
wire        [31:0]     bramcfg_we;
wire        [16:0]     bramcfg_addr;
wire        [255:0]    bramcfg_data_out;
wire        [255:0]    bramcfg_data_in;
//-------------------------bram_slect_porta_or_bram_cfg--------------------------//
wire                   bramslect_flag;
assign bramslect_flag   = bram_addr[16];
assign bramcfg_we       = (bramslect_flag==1'b1)?bram_we:0;
assign brama_we         = (bramslect_flag==1'b0)?bram_we:0;
assign bramcfg_addr     = (bramslect_flag==1'b1)?bram_addr:0;
assign brama_addr       = (bramslect_flag==1'b0)?bram_addr:0;
assign bramcfg_data_out = (bramslect_flag==1'b1)?bram_data_out:0;
assign brama_data_out   = (bramslect_flag==1'b0)?bram_data_out:0;
assign bram_data_in     = (bramslect_flag==1'b1)?bramcfg_data_in:brama_data_in;
//-------------------------------------------------------------------------------//
wire        [15:0]     antenna_rx      ;
wire        [15:0]     antenna_tx      ;
wire        [15:0]     matrix_row      ;
wire        [15:0]     matrix_col      ;
wire        [15:0]     antenna_d       ;
wire                   calc_tx         ;
wire                   calc_done       ;
//-------------------------matrix_signal--------------------------//
wire        [63:0]     matr_result     ;
wire                   matrix_data_en  ;
wire                   matrix_data_last;
wire                   matr_calc_done  ;
wire                   jacbi_data_vld  ;

wire                   jacobi_datavld  ;
wire signed        [31:0]             calc_resut_matr   ;
wire signed        [31:0]             calc_resut_vetc   ;

// clk_150M u_clk_150M
// (
//     // Clock out ports
//     .clk_out1(clk_150m),     // output clk_out1
//     // Status and control signals
//     .reset(bramctrl_rst), // input reset
//     .locked(locked_150m),       // output locked
//     // Clock in ports
//     .clk_in1(bramctrl_clk)   // input clk_in1
// );    
always @(posedge clk_150m) begin
	if(locked_150m)
		rst_150m <= 0;
	else
		rst_150m <= 1;
end
bram_cfg u_bram_cfg(
    .bramcfg_clk        (bramctrl_clk)    ,
    .bramcfg_rst        (bramctrl_rst)    ,
    .bramcfg_we         (bramcfg_we)    ,
    .bramcfg_en         (bram_en),
    .bramcfg_addr       (bramcfg_addr)    ,
    .bramcfg_data_out   (bramcfg_data_out)    ,
    .bramcfg_data_in    (bramcfg_data_in)     ,
    .antenna_rx         (antenna_rx),
    .antenna_tx         (antenna_tx),
    .matrix_row         (matrix_row),
    .matrix_col         (matrix_col),
    .antenna_d          (antenna_d),
    .calc_tx            (calc_tx),
    .calc_done          (calc_done)

);

matrix_calc u_matrix_calc(
    .bramctrl_clk        (bramctrl_clk),
    .bramctrl_rst        (bramctrl_rst), 
    .bramctrl_data_out   (bramctrl_data_out),
    .calc_tx             (calc_tx),
    .bramctrl_addr       (bramctrl_addr),
    .matr_calc_done      (matr_calc_done),
    .data_en             (jacbi_data_vld),
    .data_last           (matrix_data_last),
    .matr_result         (matr_result)
);
ila_0 ila_joc_result (
	.clk(bramctrl_clk), // input wire clk

	.probe0(calc_resut_matr), // input wire [63:0] probe0
    .probe1(calc_resut_vetc)  // input wire [31:0]  probe1 
);
ila_1 ila_matr_result (
	.clk(bramctrl_clk), // input wire clk

	.probe0(matr_result) // input wire [63:0] probe0
);
jacobi u_jacobi(
    .jacobi_clk        (bramctrl_clk),
    .jacobi_rst        (bramctrl_rst),
    .data_en           (jacbi_data_vld),
    .data_first        (matrix_data_last),
    .data_in           (matr_result),
    .calc_resut_matr   (calc_resut_matr),
    .calc_resut_vetc   (calc_resut_vetc),
    .jacobi_datavld    (jacobi_datavld),
    .jacobi_done       (calc_done)     
);

blk_mem_gen_0 u_blk_mem_gen_0(
    .clka(bramctrl_clk),    // input wire clka
    .wea(brama_we[0]),      // input wire [0 : 0] wea
    .addra(brama_addr[15:5]),  // input wire [10 : 0] addra
    .dina(brama_data_out),    // input wire [255 : 0] dina
    .douta(brama_data_in),  // output wire [255 : 0] douta
    .clkb(bramctrl_clk),    // input wire clkb
    .web(1'b0),      // input wire [0 : 0] web
    .addrb(bramctrl_addr),  // input wire [10 : 0] addrb
    .dinb('d0),    // input wire [255 : 0] dinb
    .doutb(bramctrl_data_out)  // output wire [255 : 0] doutb
);


pcie_wrapper u_pcie_wrapper(
    //BRAM
	.BRAM_PORTA_addr    (bram_addr),
    .BRAM_PORTA_clk     (bramctrl_clk),
    .BRAM_PORTA_din     (bram_data_out),//input bram
    .BRAM_PORTA_dout    (bram_data_in), //output bram
    .BRAM_PORTA_en      (bram_en),
    .BRAM_PORTA_rst     (bramctrl_rst),
    .BRAM_PORTA_we      (bram_we),

    //pcie
    .pcie_mgt_rxn       (pcie_mgt_rxn),
    .pcie_mgt_rxp       (pcie_mgt_rxp),
    .pcie_mgt_txn       (pcie_mgt_txn),
    .pcie_mgt_txp       (pcie_mgt_txp),
    .pcie_ref_clk_n     (pcie_ref_clk_n),
    .pcie_ref_clk_p     (pcie_ref_clk_p),
    .pcie_rstn          (pcie_rstn)
);
  
// ila_2 matrix_ila (
// 	.clk(bramctrl_clk), // input wire clk

// 	.probe0(test9), // input wire [63:0] probe0
//     .probe1(test10),
//     .probe2(test11),
//     .probe3(test12),
//     .probe4(calc_done),
//     .probe5(calc_tx),
//     .probe6(bram_en),
//     .probe7(test13),
//     .probe8(test14),
//     .probe9(test15),
//     .probe10(test16)
// );
//-------------------------bram_porta_ila--------------------------//
// ila_0 bram_porta_ila (
// 	.clk(bramctrl_clk), // input wire clk
// 	.probe0(bram_addr), // input wire [16:0]  probe0  
//  .probe1(bramcfg_addr),// input wire [16:0]  probe1 
// 	.probe2(bram_we), // input wire [0:0]  probe2
// 	.probe3(bram_data_out), // input wire [256:0]  probe3
// 	.probe4(bram_data_in), // input wire [256:0]  probe4 
// 	.probe5(bram_en), // input wire [0:0]  probe5
// 	.probe6(antenna_rx), // input wire [15:0]  probe6 
// 	.probe7(antenna_tx) ,// input wire [15:0]  probe7
// 	.probe8(matrix_row), // input wire [15:0]  probe8
// 	.probe9(matrix_col), // input wire [15:0]  probe9
// 	.probe10(antenna_d), // input wire [15:0]  probe10
// 	.probe11(calc_tx) // input wire [0:0]  probe11
// );
//-------------------------bram_portb_ila--------------------------//
// ila_1 bram_portb_ila (
// 	.clk(bramctrl_clk), // input wire clk
// 	.probe0(wi_pos_calc_tx), // input wire [0:0]  probe0  
// 	.probe1(bramctrl_addr), // input wire [10:0]  probe1 
// 	.probe2(test1), // input wire [255:0]  probe2 
// 	.probe3(test2), // input wire [255:0]  probe3 
// 	.probe4(calc_done), // input wire [0:0]  probe4 
// 	.probe5(bramctrl_data_out), // input wire [255:0]  probe5
//     .probe6({5'd0,calc_tx,wi_done_irq,wi_pos_calc_done}),
//     .probe7(wi_bramctrl_addr_1d),
//     .probe8(wi_fpga_done),
//     .probe9(bramcfg_addr)
// );
endmodule
