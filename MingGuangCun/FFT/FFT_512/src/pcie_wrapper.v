//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
//Date        : Tue Oct 11 21:46:22 2022
//Host        : DESKTOP-9COUHVN running 64-bit major release  (build 9200)
//Command     : generate_target pcie_wrapper.bd
//Design      : pcie_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module pcie_wrapper
   (BRAM_PORTA_0_addr,
    BRAM_PORTA_0_clk,
    BRAM_PORTA_0_din,
    BRAM_PORTA_0_dout,
    BRAM_PORTA_0_en,
    BRAM_PORTA_0_rst,
    BRAM_PORTA_0_we,
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
    usr_irq_req);
  output [15:0]BRAM_PORTA_0_addr;
  output BRAM_PORTA_0_clk;
  output [255:0]BRAM_PORTA_0_din;
  input [255:0]BRAM_PORTA_0_dout;
  output BRAM_PORTA_0_en;
  output BRAM_PORTA_0_rst;
  output [31:0]BRAM_PORTA_0_we;
  output axi_clk;
  output msi_enable;
  output [2:0]msi_vector_width;
  input [7:0]pcie_mgt_rxn;
  input [7:0]pcie_mgt_rxp;
  output [7:0]pcie_mgt_txn;
  output [7:0]pcie_mgt_txp;
  input [0:0]pcie_ref_clk_n;
  input [0:0]pcie_ref_clk_p;
  input pcie_rstn;
  output [0:0]usr_irq_ack;
  input [0:0]usr_irq_req;

  wire [15:0]BRAM_PORTA_0_addr;
  wire BRAM_PORTA_0_clk;
  wire [255:0]BRAM_PORTA_0_din;
  wire [255:0]BRAM_PORTA_0_dout;
  wire BRAM_PORTA_0_en;
  wire BRAM_PORTA_0_rst;
  wire [31:0]BRAM_PORTA_0_we;
  wire axi_aclk;
  wire msi_enable;
  wire [2:0]msi_vector_width;
  wire [7:0]pcie_mgt_rxn;
  wire [7:0]pcie_mgt_rxp;
  wire [7:0]pcie_mgt_txn;
  wire [7:0]pcie_mgt_txp;
  wire [0:0]pcie_ref_clk_n;
  wire [0:0]pcie_ref_clk_p;
  wire pcie_rstn;
  wire [0:0]usr_irq_ack;
  wire [0:0]usr_irq_req;

  design_1 pcie_i
       (.BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
        .BRAM_PORTA_0_clk(BRAM_PORTA_0_clk),
        .BRAM_PORTA_0_din(BRAM_PORTA_0_din),
        .BRAM_PORTA_0_dout(BRAM_PORTA_0_dout),
        .BRAM_PORTA_0_en(BRAM_PORTA_0_en),
        .BRAM_PORTA_0_rst(BRAM_PORTA_0_rst),
        .BRAM_PORTA_0_we(BRAM_PORTA_0_we),
        .axi_clk(axi_clk),
        .msi_enable(msi_enable),
        .msi_vector_width(msi_vector_width),
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_ref_clk_n(pcie_ref_clk_n),
        .pcie_ref_clk_p(pcie_ref_clk_p),
        .pcie_rstn(pcie_rstn),
        .usr_irq_ack(usr_irq_ack),
        .usr_irq_req(usr_irq_req));
endmodule
