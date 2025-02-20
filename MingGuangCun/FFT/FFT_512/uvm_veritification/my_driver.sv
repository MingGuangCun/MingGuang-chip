`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
`include "uvm_macros.svh"
`include "my_if.sv"
`include "my_transaction.sv"
import uvm_pkg::*;
class my_driver extends uvm_driver;

   virtual my_if vif;

   `uvm_component_utils(my_driver)
   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(my_transaction tr);
endclass

task my_driver::main_phase(uvm_phase phase);
    my_transaction tr;
    phase.raise_objection(this);
    `uvm_info("my_driver", "main phase", UVM_LOW);
    while(!vif.rst_n)
    @(posedge vif.clk);
    while(1)begin
    for(int i = 0; i < 128*7; i++) begin 
    //每次更新所有的地址的数据
      tr = new("tr");
      assert(tr.randomize() with {addra == i;wea_pc==1;});
      drive_one_pkt(tr);
    end
    tr = new("tr");
    assert(tr.randomize() with {addra == 128*7;wea_pc==1;a1_im inside {65535,196607,327679,458751,589823,720895,851967,131071,262143,393215,524287,655359,786431,917503};});
    drive_one_pkt(tr);
    //等待FFT结束
    @(posedge vif.pc_select)
    repeat(5) @(posedge vif.clk);
    end
   phase.drop_objection(this);
endtask

task my_driver::drive_one_pkt(my_transaction tr);
   bit [255:0]dina;
   dina = {tr.a4_re, tr.a4_im, tr.a3_re, tr.a3_im, tr.a2_re, tr.a2_im, tr.a1_re, tr.a1_im};
   @(posedge vif.clk);
   vif.dina_pc = dina;
   vif.addra_pc = tr.addra;
   vif.wea_pc = tr.wea_pc;
   `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
endtask


`endif
