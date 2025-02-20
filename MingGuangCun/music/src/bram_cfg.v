`timescale 1ns / 1ps

module bram_cfg(
    input                                   bramcfg_clk,
    input                                   bramcfg_rst,
    input                       [31:0]      bramcfg_we,
    input                                   bramcfg_en,
    input                       [16:0]      bramcfg_addr,
    input                       [255:0]     bramcfg_data_out,
    output                      [255:0]     bramcfg_data_in,

    output        reg           [15:0]      antenna_rx      ,
    output        reg           [15:0]      antenna_tx      ,
    output        reg           [15:0]      matrix_row      ,
    output        reg           [15:0]      matrix_col      ,
    output        reg           [15:0]      antenna_d       ,
    output        reg                       calc_tx         ,
    
    input                                   calc_done       
);

//-------------------------calc_done_clc_siganl------------------------------//
reg                         done_irq;
//--------------------------bram_cfg_read_ctrl-------------------------------//
always @(posedge bramcfg_clk) begin
    if(bramcfg_rst) begin
        antenna_rx          <= 16'd0;
        antenna_tx          <= 16'd0;
        matrix_row          <= 16'd0;
        matrix_col          <= 16'd0;
        antenna_d           <= 16'd0;
        calc_tx             <= 1'd0;
        done_irq            <= 1'd0;
    end
    else begin
        if((&bramcfg_we[13:0])&bramcfg_en&(bramcfg_addr == {1'b1,16'h0000})) begin
            antenna_rx          <= bramcfg_data_out[15:0];                      //Number of receiving antennas
            antenna_tx          <= bramcfg_data_out[31:16];                     //Number of transmit antennas
            matrix_row          <= bramcfg_data_out[47:32];                     //The number of rows of the input matrix
            matrix_col          <= bramcfg_data_out[63:48];                     //The number of columns of the input matrix
            antenna_d           <= bramcfg_data_out[79:64];                     //Distance between antennas
            calc_tx             <= bramcfg_data_out[80:80];                     //End of received data flag
            done_irq            <= bramcfg_data_out[96:96];                     //Interrupt clear flag
        end
        else begin
            antenna_rx          <= antenna_rx;
            antenna_tx          <= antenna_tx;
            matrix_row          <= matrix_row;
            matrix_col          <= matrix_col;
            antenna_d           <= antenna_d ;
            calc_tx             <= calc_tx   ;
            done_irq            <= done_irq  ;
        end
    end
end
//-------------------------bram_cfg_write_ctrl------------------------------//
reg                         calc_done_d;
reg                         pos_calc_done;
reg                         fpga_done;
reg [256:0]                bramcfg_rddata;
always @(posedge bramcfg_clk) begin
    if(bramcfg_rst) begin
        calc_done_d       <=      1'b0;
        fpga_done         <=      1'b0;
        pos_calc_done     <=      1'b0;
    end
    else begin
        pos_calc_done     <=      ~calc_done_d&calc_done;
        calc_done_d       <=      calc_done;
        case({done_irq,pos_calc_done})
        2'b01:       fpga_done <= 1'b1;
        2'b10,2'b11: fpga_done <= 1'b0;
        2'b00:       fpga_done <= fpga_done;
        endcase
    end
end

always @(posedge bramcfg_clk) begin
    if(bramcfg_rst) begin
        bramcfg_rddata              <= 256'd0;
    end
    else
    begin
        case({(bramcfg_we==32'b0)&bramcfg_en,bramcfg_addr == {1'b1,16'h0100}})
        2'b11: begin
            bramcfg_rddata 	        <= {255'b0,fpga_done};
        end
        default: begin
            bramcfg_rddata          <= bramcfg_rddata;
        end
        endcase
    end
end
assign bramcfg_data_in = bramcfg_rddata;
endmodule
