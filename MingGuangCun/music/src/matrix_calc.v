module matrix_calc #(
    parameter bram_width = 11
) (
    input                                        bramctrl_clk        ,
    input                                        bramctrl_rst        , 

    input                 [255:0]                bramctrl_data_out   ,
    input                                        calc_tx             ,


    output     reg        [bram_width-1:0]       bramctrl_addr       ,
    output     reg                               matr_calc_done      ,
    output     reg                               data_en             ,

    output     reg                               data_last           ,
    output     reg signed [63:0]                 matr_result         
);
////-----------------Definition of registers in this module-----------------////
  //----------------------Catch posedge data ready--------------------------//
reg                             calc_tx_d;
reg                             pos_calc_tx;
  //---------------------------State machine-------------------------------//
localparam                      S_IDLE              =   8'b0000_0000    ;
localparam                      S_MATRIX_DIAG       =   8'b0000_0001    ;
localparam                      S_DIAG_DONE         =   8'b0000_0010    ;
localparam                      S_MATRIX_CALC       =   8'b0000_0100    ;
localparam                      S_CALC_DONE         =   8'b0000_1000    ;
localparam                      S_DATA_OUT          =   8'b0001_0000    ;
reg         [ 7:0]              c_s                 =   8'b0            ;
reg         [ 7:0]              n_s                 =   8'b0            ; 
  //---------------------------Bram portb read-----------------------------//
reg		    [7:0]		        n_s_ff1	            = 'd0	            ;
reg		    [7:0]		        n_s_ff2	            = 'd0	            ;
reg		    [7:0]		        n_s_ff3	            = 'd0	            ;
(* max_fanout=100 *)reg		    [bram_width-1:0]	bramctrl_addr_ff1	= 'd0	            ;
(* max_fanout=100 *)reg		    [bram_width-1:0]	bramctrl_addr_ff2	= 'd0	            ;
(* max_fanout=100 *)reg		    [bram_width-1:0]	bramctrl_addr_ff3	= 'd0	            ;
reg signed  [255:0]             ram         [0:255]                     ;
  //------------------------------Booth_en---------------------------------//
reg                             booth_en                                ;
  //--------------------------Booth input module---------------------------//
wire        [bram_width-1:0]    booth_addr;
assign                          booth_addr         = bramctrl_addr_ff2  ;
wire        [63:0]              ans1                                    ;
wire        [63:0]              ans2                                    ;
wire        [63:0]              ans3                                    ;
wire        [63:0]              ans4                                    ;
wire        [63:0]              ans5                                    ;
wire        [63:0]              ans6                                    ;
wire        [63:0]              ans7                                    ;
wire        [63:0]              ans8                                    ;
wire                            booth_vld1                              ;
wire                            booth_vld2                              ;
wire                            booth_vld3                              ;
wire                            booth_vld4                              ;
wire                            booth_vld5                              ;
wire                            booth_vld6                              ;
wire                            booth_vld7                              ;
wire                            booth_vld8                              ;
wire                            booth_vld                               ;
assign booth_vld = booth_vld1&booth_vld2&booth_vld3&booth_vld4&booth_vld5&booth_vld6&booth_vld7&booth_vld8;
  //-------------------------Booth output module---------------------------//
reg         [15:0]              cnt_booth_addr                          ;
reg signed  [63:0]              diag_data       [0:3]                   ;
reg                             booth_vld_d                             ;
reg                             negbooth_vld                            ;
  //------------------------------Booth1_en--------------------------------//
(* max_fanout=100 *)reg                             booth_en1                               ;
  //--------------------------Booth1 input module--------------------------//
reg         [15:0]              matr_addr_col1                          ;
reg         [15:0]              matr_addr_col2                          ;
reg         [15:0]              matr_addr_col3                          ;
reg         [15:0]              matr_addr_col4                          ;
wire        [63:0]              ans12_1                                 ;
wire        [63:0]              ans12_2                                 ;
wire        [63:0]              ans12_3                                 ;
wire        [63:0]              ans12_4                                 ;
wire        [63:0]              ans12_5                                 ;
wire        [63:0]              ans12_6                                 ;
wire        [63:0]              ans12_7                                 ;
wire        [63:0]              ans12_8                                 ;
wire                            booth_vld12_1                           ;
wire                            booth_vld12_2                           ;
wire                            booth_vld12_3                           ;
wire                            booth_vld12_4                           ;
wire                            booth_vld12_5                           ;
wire                            booth_vld12_6                           ;
wire                            booth_vld12_7                           ;
wire                            booth_vld12_8                           ;
wire                            booth_vld12                             ;
assign booth_vld12 = booth_vld12_1&booth_vld12_2&booth_vld12_3&booth_vld12_4&booth_vld12_5&booth_vld12_6&booth_vld12_7&booth_vld12_8;
  //--------------------------Booth2 input module--------------------------//
wire                            booth_vld13_1                           ;
wire                            booth_vld13_2                           ;
wire                            booth_vld13_3                           ;
wire                            booth_vld13_4                           ;
wire                            booth_vld13_5                           ;
wire                            booth_vld13_6                           ;
wire                            booth_vld13_7                           ;
wire                            booth_vld13_8                           ;
wire        [63:0]              ans13_1                                 ;
wire        [63:0]              ans13_2                                 ;
wire        [63:0]              ans13_3                                 ;
wire        [63:0]              ans13_4                                 ;
wire        [63:0]              ans13_5                                 ;
wire        [63:0]              ans13_6                                 ;
wire        [63:0]              ans13_7                                 ;
wire        [63:0]              ans13_8                                 ;
wire                            booth_vld13                             ;
assign booth_vld13 = booth_vld13_1&booth_vld13_2&booth_vld13_3&booth_vld13_4&booth_vld13_5&booth_vld13_6&booth_vld13_7&booth_vld13_8;
  //--------------------------Booth3 input module--------------------------//
wire                            booth_vld14_1                           ;
wire                            booth_vld14_2                           ;
wire                            booth_vld14_3                           ;
wire                            booth_vld14_4                           ;
wire                            booth_vld14_5                           ;
wire                            booth_vld14_6                           ;
wire                            booth_vld14_7                           ;
wire                            booth_vld14_8                           ;
wire        [63:0]              ans14_1                                 ;
wire        [63:0]              ans14_2                                 ;
wire        [63:0]              ans14_3                                 ;
wire        [63:0]              ans14_4                                 ;
wire        [63:0]              ans14_5                                 ;
wire        [63:0]              ans14_6                                 ;
wire        [63:0]              ans14_7                                 ;
wire        [63:0]              ans14_8                                 ;
wire                            booth_vld14                             ;
assign booth_vld14 = booth_vld14_1&booth_vld14_2&booth_vld14_3&booth_vld14_4&booth_vld14_5&booth_vld14_6&booth_vld14_7&booth_vld14_8;
  //--------------------------Booth4 input module--------------------------//
wire                            booth_vld21_1                           ;
wire                            booth_vld21_2                           ;
wire                            booth_vld21_3                           ;
wire                            booth_vld21_4                           ;
wire                            booth_vld21_5                           ;
wire                            booth_vld21_6                           ;
wire                            booth_vld21_7                           ;
wire                            booth_vld21_8                           ;
wire        [63:0]              ans21_1                                 ;
wire        [63:0]              ans21_2                                 ;
wire        [63:0]              ans21_3                                 ;
wire        [63:0]              ans21_4                                 ;
wire        [63:0]              ans21_5                                 ;
wire        [63:0]              ans21_6                                 ;
wire        [63:0]              ans21_7                                 ;
wire        [63:0]              ans21_8                                 ;
wire                            booth_vld21                             ;
assign booth_vld21 = booth_vld21_1&booth_vld21_2&booth_vld21_3&booth_vld21_4&booth_vld21_5&booth_vld21_6&booth_vld21_7&booth_vld21_8;
  //--------------------------Booth5 input module--------------------------//
wire                            booth_vld23_1                           ;
wire                            booth_vld23_2                           ;
wire                            booth_vld23_3                           ;
wire                            booth_vld23_4                           ;
wire                            booth_vld23_5                           ;
wire                            booth_vld23_6                           ;
wire                            booth_vld23_7                           ;
wire                            booth_vld23_8                           ;
wire        [63:0]              ans23_1                                 ;
wire        [63:0]              ans23_2                                 ;
wire        [63:0]              ans23_3                                 ;
wire        [63:0]              ans23_4                                 ;
wire        [63:0]              ans23_5                                 ;
wire        [63:0]              ans23_6                                 ;
wire        [63:0]              ans23_7                                 ;
wire        [63:0]              ans23_8                                 ;
wire                            booth_vld23                             ;
assign booth_vld23 = booth_vld23_1&booth_vld23_2&booth_vld23_3&booth_vld23_4&booth_vld23_5&booth_vld23_6&booth_vld23_7&booth_vld23_8;
  //--------------------------Booth6 input module--------------------------//
wire                            booth_vld24_1                           ;
wire                            booth_vld24_2                           ;
wire                            booth_vld24_3                           ;
wire                            booth_vld24_4                           ;
wire                            booth_vld24_5                           ;
wire                            booth_vld24_6                           ;
wire                            booth_vld24_7                           ;
wire                            booth_vld24_8                           ;
wire        [63:0]              ans24_1                                 ;
wire        [63:0]              ans24_2                                 ;
wire        [63:0]              ans24_3                                 ;
wire        [63:0]              ans24_4                                 ;
wire        [63:0]              ans24_5                                 ;
wire        [63:0]              ans24_6                                 ;
wire        [63:0]              ans24_7                                 ;
wire        [63:0]              ans24_8                                 ;
wire                            booth_vld24                             ;
assign booth_vld24 = booth_vld24_1&booth_vld24_2&booth_vld24_3&booth_vld24_4&booth_vld24_5&booth_vld24_6&booth_vld24_7&booth_vld24_8;
  //--------------------------Booth7 input module--------------------------//
wire                            booth_vld31_1                           ;
wire                            booth_vld31_2                           ;
wire                            booth_vld31_3                           ;
wire                            booth_vld31_4                           ;
wire                            booth_vld31_5                           ;
wire                            booth_vld31_6                           ;
wire                            booth_vld31_7                           ;
wire                            booth_vld31_8                           ;
wire        [63:0]              ans31_1                                 ;
wire        [63:0]              ans31_2                                 ;
wire        [63:0]              ans31_3                                 ;
wire        [63:0]              ans31_4                                 ;
wire        [63:0]              ans31_5                                 ;
wire        [63:0]              ans31_6                                 ;
wire        [63:0]              ans31_7                                 ;
wire        [63:0]              ans31_8                                 ;
wire                            booth_vld31                             ;
assign booth_vld31 = booth_vld31_1&booth_vld31_2&booth_vld31_3&booth_vld31_4&booth_vld31_5&booth_vld31_6&booth_vld31_7&booth_vld31_8;
  //--------------------------Booth8 input module--------------------------//
wire                            booth_vld32_1                           ;
wire                            booth_vld32_2                           ;
wire                            booth_vld32_3                           ;
wire                            booth_vld32_4                           ;
wire                            booth_vld32_5                           ;
wire                            booth_vld32_6                           ;
wire                            booth_vld32_7                           ;
wire                            booth_vld32_8                           ;
wire        [63:0]              ans32_1                                 ;
wire        [63:0]              ans32_2                                 ;
wire        [63:0]              ans32_3                                 ;
wire        [63:0]              ans32_4                                 ;
wire        [63:0]              ans32_5                                 ;
wire        [63:0]              ans32_6                                 ;
wire        [63:0]              ans32_7                                 ;
wire        [63:0]              ans32_8                                 ;
wire                            booth_vld32                             ;
assign booth_vld32 = booth_vld32_1&booth_vld32_2&booth_vld32_3&booth_vld32_4&booth_vld32_5&booth_vld32_6&booth_vld32_7&booth_vld32_8;
  //--------------------------Booth9 input module--------------------------//
wire                            booth_vld34_1                           ;
wire                            booth_vld34_2                           ;
wire                            booth_vld34_3                           ;
wire                            booth_vld34_4                           ;
wire                            booth_vld34_5                           ;
wire                            booth_vld34_6                           ;
wire                            booth_vld34_7                           ;
wire                            booth_vld34_8                           ;
wire        [63:0]              ans34_1                                 ;
wire        [63:0]              ans34_2                                 ;
wire        [63:0]              ans34_3                                 ;
wire        [63:0]              ans34_4                                 ;
wire        [63:0]              ans34_5                                 ;
wire        [63:0]              ans34_6                                 ;
wire        [63:0]              ans34_7                                 ;
wire        [63:0]              ans34_8                                 ;
wire                            booth_vld34                             ;
assign booth_vld34 = booth_vld34_1&booth_vld34_2&booth_vld34_3&booth_vld34_4&booth_vld34_5&booth_vld34_6&booth_vld34_7&booth_vld34_8;
  //-------------------------Booth10 input module--------------------------//
wire                            booth_vld41_1                           ;
wire                            booth_vld41_2                           ;
wire                            booth_vld41_3                           ;
wire                            booth_vld41_4                           ;
wire                            booth_vld41_5                           ;
wire                            booth_vld41_6                           ;
wire                            booth_vld41_7                           ;
wire                            booth_vld41_8                           ;
wire        [63:0]              ans41_1                                 ;
wire        [63:0]              ans41_2                                 ;
wire        [63:0]              ans41_3                                 ;
wire        [63:0]              ans41_4                                 ;
wire        [63:0]              ans41_5                                 ;
wire        [63:0]              ans41_6                                 ;
wire        [63:0]              ans41_7                                 ;
wire        [63:0]              ans41_8                                 ;
wire                            booth_vld41                             ;
assign booth_vld41 = booth_vld41_1&booth_vld41_2&booth_vld41_3&booth_vld41_4&booth_vld41_5&booth_vld41_6&booth_vld41_7&booth_vld41_8;
  //-------------------------Booth11 input module--------------------------//
wire                            booth_vld42_1                           ;
wire                            booth_vld42_2                           ;
wire                            booth_vld42_3                           ;
wire                            booth_vld42_4                           ;
wire                            booth_vld42_5                           ;
wire                            booth_vld42_6                           ;
wire                            booth_vld42_7                           ;
wire                            booth_vld42_8                           ;
wire        [63:0]              ans42_1                                 ;
wire        [63:0]              ans42_2                                 ;
wire        [63:0]              ans42_3                                 ;
wire        [63:0]              ans42_4                                 ;
wire        [63:0]              ans42_5                                 ;
wire        [63:0]              ans42_6                                 ;
wire        [63:0]              ans42_7                                 ;
wire        [63:0]              ans42_8                                 ;
wire                            booth_vld42                             ;
assign booth_vld42 = booth_vld42_1&booth_vld42_2&booth_vld42_3&booth_vld42_4&booth_vld42_5&booth_vld42_6&booth_vld42_7&booth_vld42_8;
  //-------------------------Booth11 input module--------------------------//
wire                            booth_vld43_1                           ;
wire                            booth_vld43_2                           ;
wire                            booth_vld43_3                           ;
wire                            booth_vld43_4                           ;
wire                            booth_vld43_5                           ;
wire                            booth_vld43_6                           ;
wire                            booth_vld43_7                           ;
wire                            booth_vld43_8                           ;
wire        [63:0]              ans43_1                                 ;
wire        [63:0]              ans43_2                                 ;
wire        [63:0]              ans43_3                                 ;
wire        [63:0]              ans43_4                                 ;
wire        [63:0]              ans43_5                                 ;
wire        [63:0]              ans43_6                                 ;
wire        [63:0]              ans43_7                                 ;
wire        [63:0]              ans43_8                                 ;
wire                            booth_vld43                             ;
assign booth_vld43 = booth_vld43_1&booth_vld43_2&booth_vld43_3&booth_vld43_4&booth_vld43_5&booth_vld43_6&booth_vld43_7&booth_vld43_8;
  //-------------------------Booth output module---------------------------//
reg         [15:0]              cnt_booth1_addr                         ;
reg signed  [63:0]              nodiag_data       [0:11]                ;
(* max_fanout=100 *)reg signed  [63:0]              matr_resu_out     [0:15]                ;
reg                             booth_vld12_d                           ;
reg                             negbooth_vld12                          ;

  //--------------------------Data output module---------------------------//
reg         [15:0]              cnt_data_out                            ;
reg                             data_en_ff1                             ;
reg                             neg_data_en                             ;


////---------------------------Functional module--------------------------////
  //---------------------Catch posedge data ready------------------------//
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        calc_tx_d       <=      1'b0;
        pos_calc_tx     <=      1'b0;
    end
    else begin
        pos_calc_tx     <=      ~calc_tx_d&calc_tx;
        calc_tx_d       <=      calc_tx;
    end
end
  //---------------------------State machine-------------------------------//
always @(posedge bramctrl_clk) begin
	if(bramctrl_rst) 
		c_s <= S_IDLE;
	else
		c_s <= n_s;
end 

always @(*) begin
	case(c_s)
	S_IDLE: begin
		if(pos_calc_tx)
			n_s = S_MATRIX_DIAG;
		else
			n_s = S_IDLE;
	end
	S_MATRIX_DIAG: begin
        if(bramctrl_addr_ff1 < 'd255)
            n_s = S_MATRIX_DIAG;
        else
            n_s = S_DIAG_DONE;
	end
    S_DIAG_DONE: begin
        if(negbooth_vld)
            n_s = S_MATRIX_CALC;
        else
            n_s = S_DIAG_DONE;
    end
    S_MATRIX_CALC: begin
        if(matr_addr_col1 < 'd63)
            n_s = S_MATRIX_CALC;
        else
            n_s = S_CALC_DONE;
    end
    S_CALC_DONE: begin
        if(negbooth_vld12)
            n_s = S_DATA_OUT;
        else        
            n_s = S_CALC_DONE;
    end
    S_DATA_OUT: begin
        if(cnt_data_out < 'd16)
            n_s = S_DATA_OUT;
        else
            n_s = S_IDLE;
    end
    default:n_s = S_IDLE;
	endcase
end
//---------------------------Bram portb read-----------------------------//
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        n_s_ff1             <= 'd0	;
        n_s_ff2             <= 'd0	;
        n_s_ff3             <= 'd0	;
        bramctrl_addr_ff1   <= 'd0	;
        bramctrl_addr_ff2   <= 'd0	;
        bramctrl_addr_ff3   <= 'd0	;
    end
    else begin
        n_s_ff1             <= n_s              ;
        n_s_ff2             <= n_s_ff1           ;
        n_s_ff3             <= n_s_ff2           ;
        bramctrl_addr_ff1   <= bramctrl_addr    ;
        bramctrl_addr_ff2   <= bramctrl_addr_ff1 ;
        bramctrl_addr_ff3   <= bramctrl_addr_ff2 ;
    end
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) 
        bramctrl_addr       <= 11'd0;
    else if(n_s == S_MATRIX_DIAG) begin
        if(bramctrl_addr < 'd255)
            bramctrl_addr       <= bramctrl_addr + 1'b1;
        else
            bramctrl_addr       <= bramctrl_addr;
    end
    else 
        bramctrl_addr       <= 11'd0;
end

always @(posedge bramctrl_clk) begin
    if(n_s_ff1 == S_MATRIX_DIAG)
        ram[bramctrl_addr_ff1] <= bramctrl_data_out;
    else 
        ram[bramctrl_addr_ff1] <=  ram[bramctrl_addr_ff1];
end
//-------------------------Matrix diag multiplication-----------------------------//
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) 
        booth_en            <= 1'b0;    
    else if(n_s_ff1 == S_MATRIX_DIAG) 
        booth_en            <= 1'b1;
    else
        booth_en            <= 1'b0;
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        cnt_booth_addr       <= 16'd0;
    end
    else if(booth_vld) begin
        cnt_booth_addr       <= cnt_booth_addr + 1'b1;
    end
    else begin
        cnt_booth_addr       <= 16'd0;
    end
end
// assign tb_cnt_booth_addr = cnt_booth_addr;
plural_booth u1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][31 :  0], ram[booth_addr][31 :  0], ans1, booth_vld1);
plural_booth u2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][63 : 32], ram[booth_addr][63 : 32], ans2, booth_vld2);
plural_booth u3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][95 : 64], ram[booth_addr][95 : 64], ans3, booth_vld3);
plural_booth u4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][127: 96], ram[booth_addr][127: 96], ans4, booth_vld4);
plural_booth u5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][159:128], ram[booth_addr][159:128], ans5, booth_vld5);
plural_booth u6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][191:160], ram[booth_addr][191:160], ans6, booth_vld6);
plural_booth u7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][223:192], ram[booth_addr][223:192], ans7, booth_vld7);
plural_booth u8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en, ram[booth_addr][255:224], ram[booth_addr][255:224], ans8, booth_vld8);
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        diag_data[0]                <= 64'd0;
        diag_data[1]                <= 64'd0;
        diag_data[2]                <= 64'd0;
        diag_data[3]                <= 64'd0;
    end
    else if(booth_vld) begin
        if(cnt_booth_addr < 'd64)
            diag_data[0]            <= {diag_data[0][63:32] + ans1[63:32] + ans2[63:32] + ans3[63:32] + ans4[63:32] + ans5[63:32] + ans6[63:32] + ans7[63:32] + ans8[63:32],diag_data[0][31: 0] + ans1[31: 0] + ans2[31: 0] + ans3[31: 0] + ans4[31: 0] + ans5[31: 0] + ans6[31: 0] + ans7[31: 0] + ans8[31: 0]};        
        else if(cnt_booth_addr < 'd128)   
            diag_data[1]            <= {diag_data[1][63:32] + ans1[63:32] + ans2[63:32] + ans3[63:32] + ans4[63:32] + ans5[63:32] + ans6[63:32] + ans7[63:32] + ans8[63:32],diag_data[1][31: 0] + ans1[31: 0] + ans2[31: 0] + ans3[31: 0] + ans4[31: 0] + ans5[31: 0] + ans6[31: 0] + ans7[31: 0] + ans8[31: 0]}; 
        else if(cnt_booth_addr < 'd192) 
            diag_data[2]            <= {diag_data[2][63:32] + ans1[63:32] + ans2[63:32] + ans3[63:32] + ans4[63:32] + ans5[63:32] + ans6[63:32] + ans7[63:32] + ans8[63:32],diag_data[2][31: 0] + ans1[31: 0] + ans2[31: 0] + ans3[31: 0] + ans4[31: 0] + ans5[31: 0] + ans6[31: 0] + ans7[31: 0] + ans8[31: 0]};
        else
            diag_data[3]            <= {diag_data[3][63:32] + ans1[63:32] + ans2[63:32] + ans3[63:32] + ans4[63:32] + ans5[63:32] + ans6[63:32] + ans7[63:32] + ans8[63:32],diag_data[3][31: 0] + ans1[31: 0] + ans2[31: 0] + ans3[31: 0] + ans4[31: 0] + ans5[31: 0] + ans6[31: 0] + ans7[31: 0] + ans8[31: 0]};        
    end
    else begin
        diag_data[0]                <= 64'd0;
        diag_data[1]                <= 64'd0;
        diag_data[2]                <= 64'd0;
        diag_data[3]                <= 64'd0;        
    end
end
// catch negedge booth_vld_ff1
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        booth_vld_d       <=      1'b0;
        negbooth_vld      <=      1'b0;
    end
    else begin
        negbooth_vld      <=      booth_vld_d&~booth_vld;
        booth_vld_d       <=      booth_vld;
    end
end

//-------------------------Matrix element multiplication-----------------------------//
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) 
        booth_en1           <= 1'b0;
    else if(n_s == S_MATRIX_CALC)
        booth_en1           <= 1'b1;
    else
        booth_en1           <= 1'b0;
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        matr_addr_col1      <= 16'd0;
        matr_addr_col2      <= 16'd64;
        matr_addr_col3      <= 16'd128;
        matr_addr_col4      <= 16'd192;
    end
    else if(n_s_ff1 == S_MATRIX_CALC) begin
        matr_addr_col1      <= matr_addr_col1 + 1'b1;
        matr_addr_col2      <= matr_addr_col2 + 1'b1;
        matr_addr_col3      <= matr_addr_col3 + 1'b1;
        matr_addr_col4      <= matr_addr_col4 + 1'b1;
    end
    else begin
        matr_addr_col1      <= 16'd0;
        matr_addr_col2      <= 16'd64;
        matr_addr_col3      <= 16'd128;
        matr_addr_col4      <= 16'd192;
    end
end
// 1
plural_booth a1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][31 :  0], ram[matr_addr_col2][31 :  0], ans12_1, booth_vld12_1);
plural_booth a2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][63 : 32], ram[matr_addr_col2][63 : 32], ans12_2, booth_vld12_2);
plural_booth a3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][95 : 64], ram[matr_addr_col2][95 : 64], ans12_3, booth_vld12_3);
plural_booth a4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][127: 96], ram[matr_addr_col2][127: 96], ans12_4, booth_vld12_4);
plural_booth a5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][159:128], ram[matr_addr_col2][159:128], ans12_5, booth_vld12_5);
plural_booth a6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][191:160], ram[matr_addr_col2][191:160], ans12_6, booth_vld12_6);
plural_booth a7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][223:192], ram[matr_addr_col2][223:192], ans12_7, booth_vld12_7);
plural_booth a8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][255:224], ram[matr_addr_col2][255:224], ans12_8, booth_vld12_8);
// 2
plural_booth b1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][31 :  0], ram[matr_addr_col3][31 :  0], ans13_1, booth_vld13_1);
plural_booth b2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][63 : 32], ram[matr_addr_col3][63 : 32], ans13_2, booth_vld13_2);
plural_booth b3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][95 : 64], ram[matr_addr_col3][95 : 64], ans13_3, booth_vld13_3);
plural_booth b4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][127: 96], ram[matr_addr_col3][127: 96], ans13_4, booth_vld13_4);
plural_booth b5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][159:128], ram[matr_addr_col3][159:128], ans13_5, booth_vld13_5);
plural_booth b6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][191:160], ram[matr_addr_col3][191:160], ans13_6, booth_vld13_6);
plural_booth b7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][223:192], ram[matr_addr_col3][223:192], ans13_7, booth_vld13_7);
plural_booth b8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][255:224], ram[matr_addr_col3][255:224], ans13_8, booth_vld13_8);
// 3
plural_booth c1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][31 :  0], ram[matr_addr_col4][31 :  0], ans14_1, booth_vld14_1);
plural_booth c2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][63 : 32], ram[matr_addr_col4][63 : 32], ans14_2, booth_vld14_2);
plural_booth c3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][95 : 64], ram[matr_addr_col4][95 : 64], ans14_3, booth_vld14_3);
plural_booth c4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][127: 96], ram[matr_addr_col4][127: 96], ans14_4, booth_vld14_4);
plural_booth c5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][159:128], ram[matr_addr_col4][159:128], ans14_5, booth_vld14_5);
plural_booth c6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][191:160], ram[matr_addr_col4][191:160], ans14_6, booth_vld14_6);
plural_booth c7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][223:192], ram[matr_addr_col4][223:192], ans14_7, booth_vld14_7);
plural_booth c8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col1][255:224], ram[matr_addr_col4][255:224], ans14_8, booth_vld14_8);
// 4
plural_booth d1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][31 :  0], ram[matr_addr_col1][31 :  0], ans21_1, booth_vld21_1);
plural_booth d2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][63 : 32], ram[matr_addr_col1][63 : 32], ans21_2, booth_vld21_2);
plural_booth d3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][95 : 64], ram[matr_addr_col1][95 : 64], ans21_3, booth_vld21_3);
plural_booth d4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][127: 96], ram[matr_addr_col1][127: 96], ans21_4, booth_vld21_4);
plural_booth d5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][159:128], ram[matr_addr_col1][159:128], ans21_5, booth_vld21_5);
plural_booth d6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][191:160], ram[matr_addr_col1][191:160], ans21_6, booth_vld21_6);
plural_booth d7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][223:192], ram[matr_addr_col1][223:192], ans21_7, booth_vld21_7);
plural_booth d8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][255:224], ram[matr_addr_col1][255:224], ans21_8, booth_vld21_8);
// 5
plural_booth e1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][31 :  0], ram[matr_addr_col3][31 :  0], ans23_1, booth_vld23_1);
plural_booth e2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][63 : 32], ram[matr_addr_col3][63 : 32], ans23_2, booth_vld23_2);
plural_booth e3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][95 : 64], ram[matr_addr_col3][95 : 64], ans23_3, booth_vld23_3);
plural_booth e4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][127: 96], ram[matr_addr_col3][127: 96], ans23_4, booth_vld23_4);
plural_booth e5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][159:128], ram[matr_addr_col3][159:128], ans23_5, booth_vld23_5);
plural_booth e6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][191:160], ram[matr_addr_col3][191:160], ans23_6, booth_vld23_6);
plural_booth e7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][223:192], ram[matr_addr_col3][223:192], ans23_7, booth_vld23_7);
plural_booth e8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][255:224], ram[matr_addr_col3][255:224], ans23_8, booth_vld23_8);
// 6
plural_booth f1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][31 :  0], ram[matr_addr_col4][31 :  0], ans24_1, booth_vld24_1);
plural_booth f2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][63 : 32], ram[matr_addr_col4][63 : 32], ans24_2, booth_vld24_2);
plural_booth f3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][95 : 64], ram[matr_addr_col4][95 : 64], ans24_3, booth_vld24_3);
plural_booth f4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][127: 96], ram[matr_addr_col4][127: 96], ans24_4, booth_vld24_4);
plural_booth f5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][159:128], ram[matr_addr_col4][159:128], ans24_5, booth_vld24_5);
plural_booth f6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][191:160], ram[matr_addr_col4][191:160], ans24_6, booth_vld24_6);
plural_booth f7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][223:192], ram[matr_addr_col4][223:192], ans24_7, booth_vld24_7);
plural_booth f8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col2][255:224], ram[matr_addr_col4][255:224], ans24_8, booth_vld24_8);
// 7
plural_booth g1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][31 :  0], ram[matr_addr_col1][31 :  0], ans31_1, booth_vld31_1);
plural_booth g2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][63 : 32], ram[matr_addr_col1][63 : 32], ans31_2, booth_vld31_2);
plural_booth g3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][95 : 64], ram[matr_addr_col1][95 : 64], ans31_3, booth_vld31_3);
plural_booth g4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][127: 96], ram[matr_addr_col1][127: 96], ans31_4, booth_vld31_4);
plural_booth g5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][159:128], ram[matr_addr_col1][159:128], ans31_5, booth_vld31_5);
plural_booth g6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][191:160], ram[matr_addr_col1][191:160], ans31_6, booth_vld31_6);
plural_booth g7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][223:192], ram[matr_addr_col1][223:192], ans31_7, booth_vld31_7);
plural_booth g8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][255:224], ram[matr_addr_col1][255:224], ans31_8, booth_vld31_8);
// 8
plural_booth h1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][31 :  0], ram[matr_addr_col2][31 :  0], ans32_1, booth_vld32_1);
plural_booth h2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][63 : 32], ram[matr_addr_col2][63 : 32], ans32_2, booth_vld32_2);
plural_booth h3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][95 : 64], ram[matr_addr_col2][95 : 64], ans32_3, booth_vld32_3);
plural_booth h4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][127: 96], ram[matr_addr_col2][127: 96], ans32_4, booth_vld32_4);
plural_booth h5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][159:128], ram[matr_addr_col2][159:128], ans32_5, booth_vld32_5);
plural_booth h6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][191:160], ram[matr_addr_col2][191:160], ans32_6, booth_vld32_6);
plural_booth h7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][223:192], ram[matr_addr_col2][223:192], ans32_7, booth_vld32_7);
plural_booth h8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][255:224], ram[matr_addr_col2][255:224], ans32_8, booth_vld32_8);
// 9
plural_booth i1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][31 :  0], ram[matr_addr_col4][31 :  0], ans34_1, booth_vld34_1);
plural_booth i2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][63 : 32], ram[matr_addr_col4][63 : 32], ans34_2, booth_vld34_2);
plural_booth i3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][95 : 64], ram[matr_addr_col4][95 : 64], ans34_3, booth_vld34_3);
plural_booth i4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][127: 96], ram[matr_addr_col4][127: 96], ans34_4, booth_vld34_4);
plural_booth i5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][159:128], ram[matr_addr_col4][159:128], ans34_5, booth_vld34_5);
plural_booth i6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][191:160], ram[matr_addr_col4][191:160], ans34_6, booth_vld34_6);
plural_booth i7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][223:192], ram[matr_addr_col4][223:192], ans34_7, booth_vld34_7);
plural_booth i8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col3][255:224], ram[matr_addr_col4][255:224], ans34_8, booth_vld34_8);
// 10
plural_booth j1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][31 :  0], ram[matr_addr_col1][31 :  0], ans41_1, booth_vld41_1);
plural_booth j2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][63 : 32], ram[matr_addr_col1][63 : 32], ans41_2, booth_vld41_2);
plural_booth j3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][95 : 64], ram[matr_addr_col1][95 : 64], ans41_3, booth_vld41_3);
plural_booth j4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][127: 96], ram[matr_addr_col1][127: 96], ans41_4, booth_vld41_4);
plural_booth j5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][159:128], ram[matr_addr_col1][159:128], ans41_5, booth_vld41_5);
plural_booth j6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][191:160], ram[matr_addr_col1][191:160], ans41_6, booth_vld41_6);
plural_booth j7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][223:192], ram[matr_addr_col1][223:192], ans41_7, booth_vld41_7);
plural_booth j8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][255:224], ram[matr_addr_col1][255:224], ans41_8, booth_vld41_8);
// 11
plural_booth k1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][31 :  0], ram[matr_addr_col2][31 :  0], ans42_1, booth_vld42_1);
plural_booth k2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][63 : 32], ram[matr_addr_col2][63 : 32], ans42_2, booth_vld42_2);
plural_booth k3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][95 : 64], ram[matr_addr_col2][95 : 64], ans42_3, booth_vld42_3);
plural_booth k4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][127: 96], ram[matr_addr_col2][127: 96], ans42_4, booth_vld42_4);
plural_booth k5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][159:128], ram[matr_addr_col2][159:128], ans42_5, booth_vld42_5);
plural_booth k6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][191:160], ram[matr_addr_col2][191:160], ans42_6, booth_vld42_6);
plural_booth k7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][223:192], ram[matr_addr_col2][223:192], ans42_7, booth_vld42_7);
plural_booth k8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][255:224], ram[matr_addr_col2][255:224], ans42_8, booth_vld42_8);
// 12
plural_booth l1_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][31 :  0], ram[matr_addr_col3][31 :  0], ans43_1, booth_vld43_1);
plural_booth l2_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][63 : 32], ram[matr_addr_col3][63 : 32], ans43_2, booth_vld43_2);
plural_booth l3_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][95 : 64], ram[matr_addr_col3][95 : 64], ans43_3, booth_vld43_3);
plural_booth l4_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][127: 96], ram[matr_addr_col3][127: 96], ans43_4, booth_vld43_4);
plural_booth l5_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][159:128], ram[matr_addr_col3][159:128], ans43_5, booth_vld43_5);
plural_booth l6_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][191:160], ram[matr_addr_col3][191:160], ans43_6, booth_vld43_6);
plural_booth l7_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][223:192], ram[matr_addr_col3][223:192], ans43_7, booth_vld43_7);
plural_booth l8_plural_booth(bramctrl_clk, bramctrl_rst, booth_en1, ram[matr_addr_col4][255:224], ram[matr_addr_col3][255:224], ans43_8, booth_vld43_8);

always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        cnt_booth1_addr       <= 16'd0;
    end
    else if(booth_vld12) begin
        cnt_booth1_addr       <= cnt_booth1_addr + 1'b1;
    end
    else begin
        cnt_booth1_addr       <= 16'd0;
    end
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        nodiag_data[0]               <= 64'd0; 
        nodiag_data[1]               <= 64'd0; 
        nodiag_data[2]               <= 64'd0; 
        nodiag_data[3]               <= 64'd0; 
        nodiag_data[4]               <= 64'd0; 
        nodiag_data[5]               <= 64'd0; 
        nodiag_data[6]               <= 64'd0;
        nodiag_data[7]               <= 64'd0;
        nodiag_data[8]               <= 64'd0;
        nodiag_data[9]               <= 64'd0;
        nodiag_data[10]              <= 64'd0;
        nodiag_data[11]              <= 64'd0;

    end
    else if(booth_vld12) begin
        nodiag_data[0]               <= {nodiag_data[0][63:32] + ans12_1[63:32] + ans12_2[63:32] + ans12_3[63:32] + ans12_4[63:32] + ans12_5[63:32] + ans12_6[63:32] + ans12_7[63:32] + ans12_8[63:32],nodiag_data[0][31: 0] + ans12_1[31: 0] + ans12_2[31: 0] + ans12_3[31: 0] + ans12_4[31: 0] + ans12_5[31: 0] + ans12_6[31: 0] + ans12_7[31: 0] + ans12_8[31: 0]};        
        nodiag_data[1]               <= {nodiag_data[1][63:32] + ans13_1[63:32] + ans13_2[63:32] + ans13_3[63:32] + ans13_4[63:32] + ans13_5[63:32] + ans13_6[63:32] + ans13_7[63:32] + ans13_8[63:32],nodiag_data[1][31: 0] + ans13_1[31: 0] + ans13_2[31: 0] + ans13_3[31: 0] + ans13_4[31: 0] + ans13_5[31: 0] + ans13_6[31: 0] + ans13_7[31: 0] + ans13_8[31: 0]};
        nodiag_data[2]               <= {nodiag_data[2][63:32] + ans14_1[63:32] + ans14_2[63:32] + ans14_3[63:32] + ans14_4[63:32] + ans14_5[63:32] + ans14_6[63:32] + ans14_7[63:32] + ans14_8[63:32],nodiag_data[2][31: 0] + ans14_1[31: 0] + ans14_2[31: 0] + ans14_3[31: 0] + ans14_4[31: 0] + ans14_5[31: 0] + ans14_6[31: 0] + ans14_7[31: 0] + ans14_8[31: 0]};
        nodiag_data[3]               <= {nodiag_data[3][63:32] + ans21_1[63:32] + ans21_2[63:32] + ans21_3[63:32] + ans21_4[63:32] + ans21_5[63:32] + ans21_6[63:32] + ans21_7[63:32] + ans21_8[63:32],nodiag_data[3][31: 0] + ans21_1[31: 0] + ans21_2[31: 0] + ans21_3[31: 0] + ans21_4[31: 0] + ans21_5[31: 0] + ans21_6[31: 0] + ans21_7[31: 0] + ans21_8[31: 0]};
        nodiag_data[4]               <= {nodiag_data[4][63:32] + ans23_1[63:32] + ans23_2[63:32] + ans23_3[63:32] + ans23_4[63:32] + ans23_5[63:32] + ans23_6[63:32] + ans23_7[63:32] + ans23_8[63:32],nodiag_data[4][31: 0] + ans23_1[31: 0] + ans23_2[31: 0] + ans23_3[31: 0] + ans23_4[31: 0] + ans23_5[31: 0] + ans23_6[31: 0] + ans23_7[31: 0] + ans23_8[31: 0]};
        nodiag_data[5]               <= {nodiag_data[5][63:32] + ans24_1[63:32] + ans24_2[63:32] + ans24_3[63:32] + ans24_4[63:32] + ans24_5[63:32] + ans24_6[63:32] + ans24_7[63:32] + ans24_8[63:32],nodiag_data[5][31: 0] + ans24_1[31: 0] + ans24_2[31: 0] + ans24_3[31: 0] + ans24_4[31: 0] + ans24_5[31: 0] + ans24_6[31: 0] + ans24_7[31: 0] + ans24_8[31: 0]};
        nodiag_data[6]               <= {nodiag_data[6][63:32] + ans31_1[63:32] + ans31_2[63:32] + ans31_3[63:32] + ans31_4[63:32] + ans31_5[63:32] + ans31_6[63:32] + ans31_7[63:32] + ans31_8[63:32],nodiag_data[6][31: 0] + ans31_1[31: 0] + ans31_2[31: 0] + ans31_3[31: 0] + ans31_4[31: 0] + ans31_5[31: 0] + ans31_6[31: 0] + ans31_7[31: 0] + ans31_8[31: 0]};
        nodiag_data[7]               <= {nodiag_data[7][63:32] + ans32_1[63:32] + ans32_2[63:32] + ans32_3[63:32] + ans32_4[63:32] + ans32_5[63:32] + ans32_6[63:32] + ans32_7[63:32] + ans32_8[63:32],nodiag_data[7][31: 0] + ans32_1[31: 0] + ans32_2[31: 0] + ans32_3[31: 0] + ans32_4[31: 0] + ans32_5[31: 0] + ans32_6[31: 0] + ans32_7[31: 0] + ans32_8[31: 0]};
        nodiag_data[8]               <= {nodiag_data[8][63:32] + ans34_1[63:32] + ans34_2[63:32] + ans34_3[63:32] + ans34_4[63:32] + ans34_5[63:32] + ans34_6[63:32] + ans34_7[63:32] + ans34_8[63:32],nodiag_data[8][31: 0] + ans34_1[31: 0] + ans34_2[31: 0] + ans34_3[31: 0] + ans34_4[31: 0] + ans34_5[31: 0] + ans34_6[31: 0] + ans34_7[31: 0] + ans34_8[31: 0]};
        nodiag_data[9]               <= {nodiag_data[9][63:32] + ans41_1[63:32] + ans41_2[63:32] + ans41_3[63:32] + ans41_4[63:32] + ans41_5[63:32] + ans41_6[63:32] + ans41_7[63:32] + ans41_8[63:32],nodiag_data[9][31: 0] + ans41_1[31: 0] + ans41_2[31: 0] + ans41_3[31: 0] + ans41_4[31: 0] + ans41_5[31: 0] + ans41_6[31: 0] + ans41_7[31: 0] + ans41_8[31: 0]};
        nodiag_data[10]              <= {nodiag_data[10][63:32] + ans42_1[63:32] + ans42_2[63:32] + ans42_3[63:32] + ans42_4[63:32] + ans42_5[63:32] + ans42_6[63:32] + ans42_7[63:32] + ans42_8[63:32],nodiag_data[10][31: 0] + ans42_1[31: 0] + ans42_2[31: 0] + ans42_3[31: 0] + ans42_4[31: 0] + ans42_5[31: 0] + ans42_6[31: 0] + ans42_7[31: 0] + ans42_8[31: 0]};
        nodiag_data[11]              <= {nodiag_data[11][63:32] + ans43_1[63:32] + ans43_2[63:32] + ans43_3[63:32] + ans43_4[63:32] + ans43_5[63:32] + ans43_6[63:32] + ans43_7[63:32] + ans43_8[63:32],nodiag_data[11][31: 0] + ans43_1[31: 0] + ans43_2[31: 0] + ans43_3[31: 0] + ans43_4[31: 0] + ans43_5[31: 0] + ans43_6[31: 0] + ans43_7[31: 0] + ans43_8[31: 0]};
    end  
    else begin   
        nodiag_data[0]               <= 64'd0;
        nodiag_data[1]               <= 64'd0;
        nodiag_data[2]               <= 64'd0; 
        nodiag_data[3]               <= 64'd0; 
        nodiag_data[4]               <= 64'd0; 
        nodiag_data[5]               <= 64'd0; 
        nodiag_data[6 ]              <= 64'd0;
        nodiag_data[7 ]              <= 64'd0;
        nodiag_data[8 ]              <= 64'd0;
        nodiag_data[9 ]              <= 64'd0;
        nodiag_data[10]              <= 64'd0;
        nodiag_data[11]              <= 64'd0;        
    end
end

always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        matr_resu_out[0 ]              <= 64'd0;
        matr_resu_out[1 ]              <= 64'd0;
        matr_resu_out[2 ]              <= 64'd0;
        matr_resu_out[3 ]              <= 64'd0;
        matr_resu_out[4 ]              <= 64'd0;
        matr_resu_out[5 ]              <= 64'd0;
        matr_resu_out[6 ]              <= 64'd0;
        matr_resu_out[7 ]              <= 64'd0;
        matr_resu_out[8 ]              <= 64'd0;  
        matr_resu_out[9 ]              <= 64'd0;  
        matr_resu_out[10]              <= 64'd0;
        matr_resu_out[11]              <= 64'd0;
        matr_resu_out[12]              <= 64'd0;
        matr_resu_out[13]              <= 64'd0;
        matr_resu_out[14]              <= 64'd0;  
        matr_resu_out[15]              <= 64'd0;  
    end
    else if(cnt_booth_addr == 'd256) begin
        matr_resu_out[0 ]               <= diag_data[0];
        matr_resu_out[5 ]               <= diag_data[1];
        matr_resu_out[10]               <= diag_data[2];
        matr_resu_out[15]               <= diag_data[3];
    end
    else if(cnt_booth1_addr == 'd64) begin
        matr_resu_out[1 ]              <= nodiag_data[0];
        matr_resu_out[2 ]              <= nodiag_data[1];
        matr_resu_out[3 ]              <= nodiag_data[2];
        matr_resu_out[4 ]              <= nodiag_data[3];
        matr_resu_out[6 ]              <= nodiag_data[4];
        matr_resu_out[7 ]              <= nodiag_data[5];
        matr_resu_out[8 ]              <= nodiag_data[6 ];
        matr_resu_out[9 ]              <= nodiag_data[7 ];
        matr_resu_out[11]              <= nodiag_data[8 ];
        matr_resu_out[12]              <= nodiag_data[9 ];
        matr_resu_out[13]              <= nodiag_data[10];
        matr_resu_out[14]              <= nodiag_data[11];
    end
    else begin
        matr_resu_out[0 ]              <= matr_resu_out[0 ];
        matr_resu_out[5 ]              <= matr_resu_out[5 ];
        matr_resu_out[10]              <= matr_resu_out[10];
        matr_resu_out[15]              <= matr_resu_out[15];
        matr_resu_out[1 ]              <= matr_resu_out[1 ];
        matr_resu_out[2 ]              <= matr_resu_out[2 ];
        matr_resu_out[3 ]              <= matr_resu_out[3 ];
        matr_resu_out[4 ]              <= matr_resu_out[4 ];
        matr_resu_out[6 ]              <= matr_resu_out[6 ];
        matr_resu_out[7 ]              <= matr_resu_out[7 ];
        matr_resu_out[8 ]              <= matr_resu_out[8 ];
        matr_resu_out[9 ]              <= matr_resu_out[9 ];
        matr_resu_out[11]              <= matr_resu_out[11];
        matr_resu_out[12]              <= matr_resu_out[12];
        matr_resu_out[13]              <= matr_resu_out[13];
        matr_resu_out[14]              <= matr_resu_out[14];
    end
end

//catch negedge booth_vld_ff1
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        booth_vld12_d      <=      1'b0;
        negbooth_vld12     <=      1'b0;
    end
    else begin
        negbooth_vld12     <=      booth_vld12_d&~booth_vld12;
        booth_vld12_d      <=      booth_vld12;
    end
end
  //---------------------------Data out-------------------------------//
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst)
        cnt_data_out                <= 16'd0;
    else if(n_s == S_DATA_OUT)
        cnt_data_out                <= cnt_data_out + 1'b1;
    else 
        cnt_data_out                <= 16'd0;
end

always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        data_en                     <= 1'b0;
        data_last                   <= 1'b0;         
    end
    else if(n_s == S_DATA_OUT && cnt_data_out == 'd15) begin
        data_en                     <= 1'b1;
        data_last                   <= 1'b1;              
    end
    else if(n_s == S_DATA_OUT) begin
        data_en                     <= 1'b1;
        data_last                   <= 1'b0;   
    end
    else begin
        data_en                     <= 1'b0;
        data_last                   <= 1'b0;                
    end
end

always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) 
        matr_result                 <= 64'd0;
    else if(n_s == S_DATA_OUT)
        matr_result                 <= matr_resu_out[cnt_data_out];
    else 
        matr_result                 <= 64'd0;   
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) begin
        data_en_ff1       <=      1'b0;
        neg_data_en       <=      1'b0;
    end
    else begin
        neg_data_en       <=      data_en_ff1&~data_en;
        data_en_ff1       <=      data_en;
    end
end
always @(posedge bramctrl_clk) begin
    if(bramctrl_rst) 
        matr_calc_done             <=      1'b0;
    else if(neg_data_en)
        matr_calc_done             <=      1'b1;
    else
        matr_calc_done             <=      1'b0;
end
endmodule


