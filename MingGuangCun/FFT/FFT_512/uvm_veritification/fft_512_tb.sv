`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
//时间单位/时间精度
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_driver.sv"
module fft_512_tb;

    reg rst_n;
    reg clk_250M;
    // reg addra_pc;
    // reg dina_pc;
    // reg wea_pc;

    my_if if1(clk_250M,rst_n);
    fft_top dut(
        .clk_250M(clk_250M) ,
        .rst_n   (rst_n) ,
        .addra_pc(if1.addra_pc) ,
        .dina_pc (if1.dina_pc) ,
        .wea_pc(if1.wea_pc),
        .pc_select(if1.pc_select)
    );
    //clk generation 
    //250M 1000/(250*10^9) = 4*10^-9 s = 4ns ,one cycle takes 4ns
    initial begin
        clk_250M = 0;
    forever begin
        #2 clk_250M = ~clk_250M;
    end
    end
    initial begin
        rst_n = 1'b0;
        #1000;
        rst_n = 1'b1;
    end
    initial begin
        run_test("my_driver");
    end
    initial begin
       uvm_config_db#(virtual my_if)::set(null, "uvm_test_top", "vif", if1); 
    end
endmodule
