quit -sim
 
set UVM_DPI_HOME  C:/modelsim/modelsim/uvm-1.1d/win64
set WORK_HOME    "E:/study stuff/riscv_coprocessor/MingGuangCun-baseband_chip/MingGuangCun/FFT/FFT_512/uvm_veritification"
 
if [file exists work] {
    vdel -all
}
 
vlib work
vlog  -L mtiAvm -L mtiOvm -L mtiUvm -L mtiUPF   $WORK_HOME/my_driver.sv
vlog  -L mtiAvm -L mtiOvm -L mtiUvm -L mtiUPF   $WORK_HOME/my_if.sv
vlog  -L mtiAvm -L mtiOvm -L mtiUvm -L mtiUPF   $WORK_HOME/my_transaction.sv
vlog     $WORK_HOME/blk_mem.v
vlog     $WORK_HOME/fft_header.v
vlog     $WORK_HOME/booth_crisp.v  
vlog     $WORK_HOME/bram_ctrl.v +cover=bcesf 
vlog     $WORK_HOME/TF.v +cover=bcesf 
vlog     $WORK_HOME/fft_8.v +cover=bcesf 
vlog     $WORK_HOME/rotator_factor_512.v +cover=bcesf 
vlog     $WORK_HOME/fft_top.v
vlog     $WORK_HOME/fft_512.v +cover=bcesf 
vlog     $WORK_HOME/fft_512_tb.sv

vsim  -c -sv_lib $UVM_DPI_HOME/uvm_dpi   -coverage work.fft_512_tb
run 100