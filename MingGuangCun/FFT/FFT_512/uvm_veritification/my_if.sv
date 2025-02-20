`ifndef MY_IF__SV
`define MY_IF__SV
`include "uvm_macros.svh"
import uvm_pkg::*;
interface my_if(input clk, input rst_n);

   logic [255:0] dina_pc ;
   logic [10:0]  addra_pc;
   logic         wea_pc  ;     
   logic pc_select       ;   
endinterface

`endif