`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV
`include "uvm_macros.svh"
import uvm_pkg::*;
class my_transaction extends uvm_sequence_item;

   rand int a1_re;
   rand int a1_im;
   rand int a2_re;
   rand int a2_im;
   rand int a3_re;
   rand int a3_im;
   rand int a4_re;
   rand int a4_im;
   rand bit[10:0] addra;
   rand bit wea_pc;
   constraint value_max{
       soft a1_re inside {[-1000:1000]};
       soft a1_im inside {[-1000:1000]};
       soft a2_re inside {[-1000:1000]};
       soft a2_im inside {[-1000:1000]};
       soft a3_re inside {[-1000:1000]};
       soft a3_im inside {[-1000:1000]};
       soft a4_re inside {[-1000:1000]};
       soft a4_im inside {[-1000:1000]};
   }

   `uvm_object_utils(my_transaction)

   function new(string name = "my_transaction");
      super.new();
   endfunction
endclass
`endif
