`timescale 1ns / 1ps

module tb_music();

parameter bram_width = 11;

  //---------------------------Clk & rst-------------------------------//
reg         clk;
reg         rst;
  //---------------------------Matr signal-------------------------------//
reg         [15:0]              n                                           ;
reg signed  [255:0]             ram           [0:255]                       ;
reg signed  [255:0]             bramctrl_data_out                           ;
wire        [bram_width-1:0]    bramctrl_addr                               ;
wire signed [63:0]              matr_result                                 ; 
wire                            matr_calc_done                              ;
wire                            data_last                                   ;
  //---------------------------jacobi signal-------------------------------//
wire                            jacbi_data_vld                              ;
wire                            jacobi_done                                 ;
wire                            jacobi_datavld                              ;
wire signed  [31:0]             calc_resut_matr                             ;
wire signed  [31:0]             calc_resut_vetc                             ;
  //---------------------------endmodule signal-----------------------------//
reg                             calc_tx                                     ;
reg                             calc_tx_d                                   ;
reg                             pos_calc_tx                                 ;
  //-----------------------------test signal-------------------------------//
// wire [31:0]                 test1 ;
// wire [31:0]                 test2 ;
// wire [63:0]                 test3 ;
// wire [63:0]                 test4 ;
// wire [63:0]                 test5 ;
// wire [63:0]                 test6 ;
// wire [63:0]                 test7 ;
// wire [63:0]                 test8 ;
// wire [63:0]                 test9 ;
// wire [63:0]                 test10;
// wire [63:0]                 test11;
// wire [63:0]                 test12;
// wire [63:0]                 test13;
// wire [63:0]                 test14;
// wire [63:0]                 test15;
// wire [63:0]                 test16;
initial begin
    clk         = 1'b0;
    rst         = 1'b1;
    calc_tx     = 1'b0;
//    $readmemb("dec2bin.txt",ram);
    $readmemb("C:/Users/Administrator.DESKTOP-9COUHVN/Desktop/music4/music.srcs/sources_1/new/bin.txt",ram);
    #20 rst     =1'b0;
    #20 calc_tx =1'b1;
    for(n=0; n<=255; n=n+1)
    $display("%h",ram[n]);
end

always #2 clk   = ~clk;

// task open_file;
//     input string      file_dir_name ;
//     input string      rw ;
//     output int        fd ;

//     fd = $fopen(file_dir_name, rw);
//     if (! fd) begin
//         $display("--- iii --- Failed to open file: %s", file_dir_name);
//     end
//     else begin
//         $display("--- iii --- %s has been opened successfully.", file_dir_name);
//     end
// endtask


always@(posedge clk) begin
    if(rst) 
        bramctrl_data_out               <= 256'd0;
    else 
        bramctrl_data_out               <= ram[bramctrl_addr];
end     

always @(posedge clk) begin
    if(rst) begin
        calc_tx_d       <=      1'b0;
        pos_calc_tx     <=      1'b0;
    end
    else begin
        pos_calc_tx     <=      ~calc_tx_d&jacobi_done;
        calc_tx_d       <=      jacobi_done;
    end
end
always @(posedge clk) begin
    if(pos_calc_tx)
        $stop;    
end

matrix_calc tb_matrix_calc(
.bramctrl_clk        (clk),
.bramctrl_rst        (rst),
.bramctrl_data_out   (bramctrl_data_out),
.calc_tx             (calc_tx),
.bramctrl_addr       (bramctrl_addr),
.matr_calc_done      (matr_calc_done),
.data_en             (jacbi_data_vld),
.data_last           (data_last),
.matr_result         (matr_result)
);

jacobi u_jacobi(
.jacobi_clk(clk),
.jacobi_rst(rst),
.data_en   (jacbi_data_vld),
.data_first(data_last),
.data_in   (matr_result),
.calc_resut_matr(calc_resut_matr),
.calc_resut_vetc(calc_resut_vetc),
.jacobi_datavld(jacobi_datavld),
.jacobi_done(jacobi_done)
);
endmodule