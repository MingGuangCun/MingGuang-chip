module jacobi(
    input                                        jacobi_clk        ,
    input                                        jacobi_rst        ,
    
    input                                        data_en           ,
    input                                        data_first        ,
    input       signed        [63:0]             data_in           ,
    output  reg signed        [31:0]             calc_resut_matr   ,
    output  reg signed        [31:0]             calc_resut_vetc   ,
    output  reg                                  jacobi_datavld    ,
    output  reg                                  jacobi_done          
);
  //-------Capture input to enable signal rising edges signal--------//
reg                             pos_data_en                             ;
reg                             data_en_ff1                             ;
  //---------------Data quantization bit width signal----------------//
parameter                       quantify            =   16384           ;
  //----------------------pi for cordic signal-----------------------//
parameter                       pi                  =   2147483648      ;// 180*2^29/45
  //----------------------STATE MACHINE signal-----------------------//
localparam                      S_IDLE              =   8'b0000_0000    ;
localparam                      S_DATA_IN           =   8'b0000_0001    ;
localparam                      S_INDEX             =   8'b0000_0010    ;
localparam                      S_INDEX1            =   8'b0000_0100    ;
localparam                      S_THETA             =   8'b0000_1000    ;
localparam                      S_SINCOS            =   8'b0001_0000    ;
localparam                      S_ROWCOL_1          =   8'b0010_0000    ;
localparam                      S_ROWCOL_2          =   8'b0100_0000    ;
localparam                      S_FEA_VET           =   8'b1000_0000    ;
localparam                      S_LOOP_FOR          =   8'b1000_0001    ;
localparam                      S_DATA_OUT          =   8'b1000_0010    ;
reg         [07:00]             c_s                 =   8'b0            ;
reg         [07:00]             n_s                 =   8'b0            ; 
reg		    [07:00]		        n_s_ff1	            =   8'd0	        ;
reg		    [07:00]		        n_s_ff2	            =   8'd0	        ;
reg		    [07:00]		        n_s_ff3	            =   8'd0	        ;
  //-----Matrix multiplication calculation result conversion signal---//
reg         [04:00]             cnt_data_in                             ;
reg         [05:00]             cnt_data_in1                            ;
reg         [05:00]             cnt_data_in2                            ;
reg         [05:00]             cnt_data_in3                            ;
reg         [05:00]             cnt_data_in4                            ;
reg         [05:00]             cnt_data_addr                           ;
reg signed  [63:0]              data_in_ff1                             ;
reg signed  [63:0]              data_in_ff2                             ;
  //-----Iterating over the control counter of the for loop signal----//
reg         [07:00]             cnt_ite                                 ;
reg         [07:00]             cnt_ite_ff1                             ;
reg         [07:00]             cnt_ite_ff2                             ;
reg         [07:00]             cnt_for                                 ;
reg         [07:00]             for_row                                 ;
reg         [07:00]             for_col                                 ;
  //-----------------------STATE : S_THETA signal---------------------//
reg         [07:00]             cnt_theta                               ;
reg  signed [31:00]             theta                                   ;
reg  signed [31:00]             x_start                                 ;
reg  signed [31:00]             y_start                                 ;
wire signed [31:00]             angle                                   ;
reg         [00:00]             theta_i_vld                             ;
wire                            theta_o_vld                             ;
  //----------------------STATE : S_SINCOS signal---------------------//
reg         [07:00]             cnt_sincos                              ;
reg         [15:00]             an                                      ;
reg         [00:00]             scos1_i_vld                             ;
wire                            scos1_o_vld                             ;
reg         [00:00]             scos2_i_vld                             ;
wire                            scos2_o_vld                             ;
reg  signed [31:00]             theta1                                  ;
reg  signed [31:00]             theta2                                  ;
wire signed [15:00]             sin1                                    ;
wire signed [15:00]             cos1                                    ;
wire signed [15:00]             sin2                                    ;
wire signed [15:00]             cos2                                    ;
reg  signed [15:00]             sin1_the                                ;
reg  signed [15:00]             cos1_the                                ;
reg  signed [15:00]             sin2_the                                ;
reg  signed [15:00]             cos2_the                                ;
  //----------------------STATE : S_SINCOS signal---------------------//
reg         [07:00]             index_rr                                ;
reg         [07:00]             index_rc                                ;
reg         [07:00]             index_cr                                ;
reg         [07:00]             index_cc                                ;

  //---------------------STATE : S_ROWCOL_1 signal-------------------//
reg         [07:00]             cnt_rc1                                 ;
reg         [00:00]             booth_rcvld1                            ;
wire                            booth_rcovld1                           ;
wire                            booth_rcovld2                           ;
wire                            booth_rcovld3                           ;
wire                            booth_rcovld4                           ;
wire                            booth_rcovld5                           ;
wire                            booth_rcovld6                           ;
wire                            booth_rcovld7                           ;
wire                            booth_rcovld8                           ;
wire signed [31:00]             alu_rr1                                 ;
wire signed [31:00]             alu_rr2                                 ;
wire signed [31:00]             alu_rr3                                 ;
wire signed [31:00]             alu_cc1                                 ;
wire signed [31:00]             alu_cc2                                 ;
wire signed [31:00]             alu_cc3                                 ;
wire signed [31:00]             alu_rc1                                 ;
wire signed [31:00]             alu_rc2                                 ;
reg  signed [31:00]             booth_a1                                ;
reg  signed [31:00]             booth_a2                                ;
reg  signed [31:00]             booth_a3                                ;
reg  signed [31:00]             booth_b1                                ;
reg  signed [31:00]             booth_b2                                ;
reg  signed [31:00]             booth_b3                                ;
reg  signed [31:00]             booth_c1                                ;
reg  signed [31:00]             booth_c2                                ;
reg  signed [31:00]             booth_d1                                ;
reg  signed [31:00]             booth_d2                                ;
reg  signed [31:00]             booth_d3                                ;
reg  signed [31:00]             booth_e1                                ;
reg  signed [31:00]             booth_e2                                ;
reg  signed [31:00]             booth_e3                                ;
reg  signed [31:00]             booth_f1                                ;
reg  signed [31:00]             booth_f2                                ;
reg  signed [31:00]             booth_g1                                ;
reg  signed [31:00]             booth_g2                                ;
reg  signed [31:00]             booth_h1                                ;
reg  signed [31:00]             booth_h2                                ;
  //---------------------STATE : S_ROWCOL_2 signal-------------------//
reg         [07:00]             cnt_rc2                                 ;
reg         [07:00]             cnt_rc3                                 ;
reg         [07:00]             cnt_loop                                ;
reg         [00:00]             booth_rcvld2                            ;
wire                            rcovld1                                 ;
wire                            rcovld2                                 ;
wire                            rcovld3                                 ;
wire                            rcovld4                                 ;
reg  signed [31:00]             booth_i1                                ;
reg  signed [31:00]             booth_i2                                ;
reg  signed [31:00]             booth_j1                                ;
reg  signed [31:00]             booth_j2                                ;
reg  signed [31:00]             booth_k1                                ;
reg  signed [31:00]             booth_k2                                ;
reg  signed [31:00]             booth_l1                                ;
reg  signed [31:00]             booth_l2                                ;
wire signed [31:00]             alu_rk                                  ;
wire signed [31:00]             alu_kr                                  ;
wire signed [31:00]             alu_ck                                  ;
wire signed [31:00]             alu_kc                                  ;
reg         [07:00]             index_rk                                ;
reg         [07:00]             index_kr                                ;
reg         [07:00]             index_ck                                ;
reg         [07:00]             index_kc                                ;
  //---------------------STATE : S_FEA_VET signal-------------------//
reg         [07:00]             cnt_vet                                 ;
reg         [07:00]             cnt_vet1                                ;
reg         [07:00]             loop_vet                                ;
reg         [00:00]             booth_rcvld3                            ;
wire                            pkrovld1                                ;
wire                            pkcovld2                                ;
wire                            pkrovld3                                ;
wire                            pkcovld4                                ;
reg  signed [31:00]             booth_m1                                ;
reg  signed [31:00]             booth_m2                                ;
reg  signed [31:00]             booth_n1                                ;
reg  signed [31:00]             booth_n2                                ;
reg  signed [31:00]             booth_o1                                ;
reg  signed [31:00]             booth_o2                                ;
reg  signed [31:00]             booth_p1                                ;
reg  signed [31:00]             booth_p2                                ;
wire signed [31:00]             alu_pkrc                                ;
wire signed [31:00]             alu_pkcs                                ;
wire signed [31:00]             alu_pkcc                                ;
wire signed [31:00]             alu_pkrs                                ;
wire        [07:00]             index1_kr                               ;
wire        [07:00]             index1_kc                               ;
assign      index1_kr = (loop_vet << 3)+for_row;
assign      index1_kc = (loop_vet << 3)+for_col;
// reg         [07:00]             index1_kr                               ;
// reg         [07:00]             index1_kc                               ;
  //---------------------STATE : S_DATA_OUT signal-----------------//
reg         [7:0]               cnt_calc_result                         ;
  //-------Compute eigenvalues and eigenvector result storage------//
reg signed  [31:0]              matr_data       [0:63]                  ;
reg signed  [31:0]              feature_vet     [0:63]                  ;

  //--------Capture the rising edge of the input enable signal-----//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        pos_data_en         <=      1'b0;
        data_en_ff1         <=      1'b0;
    end
    else begin
        pos_data_en         <=      ~data_en_ff1&data_en;
        data_en_ff1         <=      data_en;
    end
end
  //---------------------------data beat----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        data_in_ff1         <= 64'd0;
        data_in_ff2         <= 64'd0;
    end
    else begin
        if(n_s == S_ROWCOL_2) begin
            data_in_ff1         <= 64'd0;
            data_in_ff2         <= 64'd0;   
        end
        else begin
            data_in_ff1         <= data_in;
            data_in_ff2         <= data_in_ff1;
        end
    end
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        n_s_ff1             <= 'd0	;
        n_s_ff2             <= 'd0	;
        n_s_ff3             <= 'd0	;
    end
    else begin
        n_s_ff1             <= n_s              ;
        n_s_ff2             <= n_s_ff1           ;
        n_s_ff3             <= n_s_ff2           ;
    end
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        cnt_ite_ff1         <= 63'd0;
        cnt_ite_ff2         <= 63'd0;
    end
    else begin
        cnt_ite_ff1         <= cnt_ite;
        cnt_ite_ff2         <= cnt_ite_ff1;        
    end
end

  //---------------------------State machine-------------------------------//
always @(posedge jacobi_clk) begin
	if(jacobi_rst) 
		c_s <= S_IDLE;
	else
		c_s <= n_s;
end 

always @(*) begin
	case(c_s)
	S_IDLE: begin
		if(pos_data_en)
			n_s = S_DATA_IN;
		else
			n_s = S_IDLE;
	end
	S_DATA_IN: begin
        if(cnt_data_in < 'd16)
            n_s = S_DATA_IN;
        else
            n_s = S_INDEX;
	end
    S_INDEX: begin
        n_s = S_INDEX1;
    end
    S_INDEX1: begin
        n_s = S_THETA;
    end
    S_THETA: begin
        if(cnt_theta < 'd19)
            n_s = S_THETA;
        else 
            n_s = S_SINCOS;
    end
    S_SINCOS: begin
        if(cnt_sincos < 'd19)
            n_s = S_SINCOS;
        else
            n_s = S_ROWCOL_1;
    end    
    S_ROWCOL_1: begin
        if(cnt_rc1 < 'd7) 
            n_s = S_ROWCOL_1;
        else 
            n_s = S_ROWCOL_2;
    end
    S_ROWCOL_2: begin
        if(cnt_rc3 < 'd49)
            n_s = S_ROWCOL_2;
        else    
            n_s = S_FEA_VET;
    end
    S_FEA_VET: begin
        if(cnt_vet < 'd48)
            n_s = S_FEA_VET;
        else begin
            if(cnt_vet == 'd48 && cnt_for < 'd56)
                n_s = S_INDEX;
            else 
                n_s = S_LOOP_FOR;
        end        
        // if(cnt_vet < 'd49)
        //     n_s = S_FEA_VET;
        // else begin
        //     if(cnt_vet == 'd49 && cnt_for < 'd56)
        //         n_s = S_INDEX;
        //     else 
        //         n_s = S_LOOP_FOR;
        // end
    end
    S_LOOP_FOR: begin
        if(cnt_ite  < 'd2)
            n_s = S_INDEX;
        else
            n_s = S_DATA_OUT;
    end
    S_DATA_OUT: begin
        if(cnt_calc_result == 'd64)
            n_s = S_IDLE;
        else
            n_s = S_DATA_OUT;
    end
    default:n_s = S_IDLE;
	endcase
end

  //--------------------------STATE : S_DATA_IN----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        cnt_data_in             <= 16'd0;
    else if(n_s == S_DATA_IN) begin
        if(cnt_data_in < 'd16)
            cnt_data_in         <= cnt_data_in + 1'b1;
        else
            cnt_data_in         <= 16'd0;
    end
    else 
        cnt_data_in             <= 16'd0;
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        cnt_data_in1            <= 6'd0;
        cnt_data_in2            <= 6'd4;
        cnt_data_in3            <= 6'd8;
        cnt_data_in4            <= 6'd12;
    end
    else if(n_s == S_DATA_IN) begin
        cnt_data_in1            <= cnt_data_in1 + 1'b1;
        cnt_data_in2            <= cnt_data_in2 + 1'b1;
        cnt_data_in3            <= cnt_data_in3 + 1'b1;
        cnt_data_in4            <= cnt_data_in4 + 1'b1;
    end
    else begin
        cnt_data_in1            <= 6'd0;
        cnt_data_in2            <= 6'd4;
        cnt_data_in3            <= 6'd8;
        cnt_data_in4            <= 6'd12; 
    end
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        cnt_data_addr           <= 6'd0;
    else if(cnt_data_in < 'd4)
        cnt_data_addr           <= cnt_data_in1;
    else if(cnt_data_in < 'd8)
        cnt_data_addr           <= cnt_data_in2;
    else if(cnt_data_in < 'd12)
        cnt_data_addr           <= cnt_data_in3;
    else 
        cnt_data_addr           <= cnt_data_in4;
end

// always @(posedge jacobi_clk) begin
//     if(jacobi_rst) 
//         matr_data[0]                    <= 32'd0;
//     else if(n_s_ff1 == S_DATA_IN) begin
//         matr_data[cnt_data_addr       ]  <=  data_in_ff2[63:32];//re
//         matr_data[cnt_data_addr + 'd4 ]  <=  data_in_ff2[31:00];//im
//         matr_data[cnt_data_addr + 'd32]  <= -data_in_ff2[31:00];//re
//         matr_data[cnt_data_addr + 'd36]  <=  data_in_ff2[63:32];//im
//     end
//     else
//         matr_data[0]          <= matr_data[0];
// end

  //---------------------------STATE : S_INDEX-----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        for_row             <= 'd0;
        for_col             <= 'd0;
        cnt_for             <= 'd0;
    end
    else if(n_s == S_INDEX) begin
        if(cnt_for < 'd56)
            cnt_for         <= cnt_for + 1'b1;
        else 
            cnt_for         <= 'd0;

        if(cnt_for == 8'd0) begin
            for_row         <= 'd0;
            for_col         <= 'd1;
        end
        else if(for_col == 5'd7) begin
            for_row         <= for_row + 1'b1;
            for_col         <= 'd0;            
        end
        else if(for_row == (for_col+1)) begin
            for_row         <= for_row;
            for_col         <= for_col + 'd2;
        end
        else begin
            for_col         <= for_col + 1'b1;
            for_row         <= for_row;
        end
    end
    else if(n_s == S_LOOP_FOR) begin
        cnt_for         <= 'd0;
    end
    else begin
        for_col             <= for_col; 
        for_row             <= for_row;
    end
end
  //---------------------------STATE : S_INDEX1----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        index_rr            <= 'd0;
        index_rc            <= 'd0;
        index_cr            <= 'd0;
        index_cc            <= 'd0;
    end
    else if(n_s == S_INDEX1) begin
        index_rr            <= (for_row << 3)+for_row;
        index_rc            <= (for_row << 3)+for_col;
        index_cr            <= (for_col << 3)+for_row;
        index_cc            <= (for_col << 3)+for_col;        
    end
    else begin
        index_rr            <= index_rr;
        index_rc            <= index_rc;
        index_cr            <= index_cr;
        index_cc            <= index_cc;
    end
end

  //---------------------------STATE : S_THETA-----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        cnt_theta           <= 8'd0;
        theta               <= 32'd0;
        theta_i_vld         <= 1'b0;
        x_start             <= 32'd0;
        y_start             <= 32'd0;
    end
    else if(n_s == S_THETA) begin  
        cnt_theta           <= cnt_theta + 1'b1;      
        if(matr_data[index_rr] == matr_data[index_cc]) 
            theta           <= pi >>> 2; 
        else if(cnt_theta == 1'b0) begin
            x_start         <= matr_data[index_rr] - matr_data[index_cc];
            y_start         <= matr_data[index_rc] <<< 1;
            theta_i_vld     <= 1'b1;
        end
        else if(theta_o_vld == 1'b1) 
            theta           <= angle >>> 1;
        else
            theta_i_vld     <= 1'b0;
    end
    else begin
        cnt_theta           <= 8'd0;
        theta_i_vld         <= 1'b0;
        theta               <= theta;
    end
end
  //---------------------------STATE : S_SINCOS----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        cnt_sincos          <= 'd0;
        scos1_i_vld         <= 1'b0;
        scos2_i_vld         <= 1'b0;     
        theta1              <= 32'd0;
        theta2              <= 32'd0;  
        sin1_the            <= 16'd0;
        cos1_the            <= 16'd0;
        sin2_the            <= 16'd0;
        cos2_the            <= 16'd0; 
        an                  <= 'd9948;//4096*4/1.647;
    end
    else if(n_s == S_SINCOS) begin
        cnt_sincos          <= cnt_sincos + 1'b1;
        if(cnt_sincos == 'd0) begin
            scos1_i_vld     <= 1'b1;
            scos2_i_vld     <= 1'b1;
            theta1          <= theta;
            theta2          <= theta << 1;
        end
        else if(scos1_o_vld&scos2_o_vld) begin
            sin1_the        <= sin1;
            cos1_the        <= cos1;
            sin2_the        <= sin2;
            cos2_the        <= cos2;
        end
        else begin
            scos1_i_vld     <= 1'b0;
            scos2_i_vld     <= 1'b0;
        end
    end
    else begin
        cnt_sincos          <= 'd0;
        sin1_the            <= sin1_the;
        cos1_the            <= cos1_the;
        sin2_the            <= sin2_the;
        cos2_the            <= cos2_the;
        theta1              <= theta1;
        theta2              <= theta2;            
    end
end
  //-------------STATE : S_DATA_IN & S_ROWCOL_1 & S_ROWCOL_2------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        cnt_rc1                 <= 'd0;
        booth_rcvld1            <= 1'd0;
        booth_a1                <= 32'd0;
        booth_a2                <= 32'd0;
        booth_a3                <= 32'd0;
        booth_b1                <= 32'd0;
        booth_b2                <= 32'd0;
        booth_b3                <= 32'd0;
        booth_c1                <= 32'd0;
        booth_c2                <= 32'd0;
        booth_d1                <= 32'd0;
        booth_d2                <= 32'd0;
        booth_d3                <= 32'd0;
        booth_e1                <= 32'd0;
        booth_e2                <= 32'd0;
        booth_e3                <= 32'd0;
        booth_f1                <= 32'd0;
        booth_f2                <= 32'd0;
        booth_g1                <= 32'd0;
        booth_g2                <= 32'd0;
        booth_h1                <= 32'd0;
        booth_h2                <= 32'd0;

        cnt_rc2                 <= 'd0;
        cnt_rc3                 <= 'd0;
        cnt_loop                <= 'd0;
        booth_rcvld2            <= 1'b0;
        booth_i1                <= 32'd0;
        booth_i2                <= 32'd0;
        booth_j1                <= 32'd0;
        booth_j2                <= 32'd0;
        booth_k1                <= 32'd0;
        booth_k2                <= 32'd0;
        booth_l1                <= 32'd0;
        booth_l2                <= 32'd0;

        index_rk                <= 'd0;
        index_kr                <= 'd0;
        index_ck                <= 'd0;
        index_kc                <= 'd0;     
    end
    else if(n_s_ff1 == S_DATA_IN) begin
        matr_data[cnt_data_addr       ]  <=  data_in_ff2[63:32];//re
        matr_data[cnt_data_addr + 'd4 ]  <=  data_in_ff2[31:00];//im
        matr_data[cnt_data_addr + 'd32]  <= -data_in_ff2[31:00];//re
        matr_data[cnt_data_addr + 'd36]  <=  data_in_ff2[63:32];//im
    end    
    else if(n_s == S_ROWCOL_1) begin
        cnt_rc1                 <= cnt_rc1 + 1'b1;
        if(cnt_rc1 == 'd0) begin
            booth_rcvld1            <= 1'b1;
            booth_a1                <= matr_data[index_rr];
            booth_a2                <= cos1_the;
            booth_a3                <= cos1_the;
            booth_b1                <= matr_data[index_cc];
            booth_b2                <= sin1_the;
            booth_b3                <= sin1_the;
            booth_c1                <= matr_data[index_rc];
            booth_c2                <= sin2_the;
            booth_d1                <= matr_data[index_rr];
            booth_d2                <= sin1_the;
            booth_d3                <= sin1_the;
            booth_e1                <= matr_data[index_cc];
            booth_e2                <= cos1_the;
            booth_e3                <= cos1_the;
            booth_f1                <= matr_data[index_rc];
            booth_f2                <= sin2_the;
            booth_g1                <= (matr_data[index_cc]-matr_data[index_rr]) >>> 1;
            booth_g2                <= sin2_the;
            booth_h1                <= matr_data[index_rc];
            booth_h2                <= cos2_the;
        end
        else if(booth_rcovld1 & booth_rcovld2 & !booth_rcovld3 & booth_rcovld4 & booth_rcovld5 & !booth_rcovld6 & !booth_rcovld7 & !booth_rcovld8) begin
            matr_data[index_rr]     <= alu_rr1 + alu_rr2 + alu_rr3;
            matr_data[index_cc]     <= alu_cc1 + alu_cc2 - alu_cc3;
            matr_data[index_rc]     <= alu_rc1 + alu_rc2;
            matr_data[index_cr]     <= alu_rc1 + alu_rc2;
        end
        else begin
            booth_rcvld1            <= 1'b0;
            matr_data[index_rr]     <= matr_data[index_rr];
            matr_data[index_cc]     <= matr_data[index_cc];
            matr_data[index_rc]     <= matr_data[index_rc];
            matr_data[index_cr]     <= matr_data[index_cr];
        end
    end
    else if(n_s == S_ROWCOL_2) begin
        cnt_rc3             <= cnt_rc3 + 1'b1;
        if(cnt_rc2 < 'd5)
            cnt_rc2         <= cnt_rc2 + 1'b1;
        else
            cnt_rc2         <= 'd0;

        if(cnt_rc2 == 'd5 && cnt_loop < 'd7)
            cnt_loop            <= cnt_loop + 1'b1;
        else 
            cnt_loop            <= cnt_loop;

        if(cnt_rc2 == 'd0) begin
            index_rk            <= (for_row << 3)+cnt_loop;
            index_kr            <= (cnt_loop << 3)+for_row;
            index_ck            <= (for_col << 3)+cnt_loop;
            index_kc            <= (cnt_loop << 3)+for_col;
        end
        else begin
            index_rk            <= index_rk;
            index_kr            <= index_kr;
            index_ck            <= index_ck;
            index_kc            <= index_kc;
        end
    
        if(cnt_rc2 == 'd1 && cnt_loop != for_row && cnt_loop != for_col && cnt_loop < 'd8) begin
            booth_rcvld2        <= 1'b1;      
            booth_i1            <= matr_data[index_rk];
            booth_i2            <= cos1_the;
            booth_j1            <= matr_data[index_ck];
            booth_j2            <= sin1_the;
            booth_k1            <= matr_data[index_ck];
            booth_k2            <= cos1_the;
            booth_l1            <= matr_data[index_rk];
            booth_l2            <= sin1_the;
        end  
        else 
            booth_rcvld2        <= 1'b0;

        if(rcovld1 & rcovld2 & rcovld3 & rcovld4) begin
            matr_data[index_rk] <= alu_rk + alu_kr;
            matr_data[index_kr] <= alu_rk + alu_kr;
            matr_data[index_ck] <= alu_ck - alu_kc;
            matr_data[index_kc] <= alu_ck - alu_kc;
        end
        else begin
            matr_data[index_rk] <= matr_data[index_rk];
            matr_data[index_kr] <= matr_data[index_kr];
            matr_data[index_ck] <= matr_data[index_ck];
            matr_data[index_kc] <= matr_data[index_kc];       
        end
    end    
    else begin
        cnt_rc1                 <= 'd0;
        matr_data[index_rr]     <= matr_data[index_rr];
        matr_data[index_cc]     <= matr_data[index_cc];
        matr_data[index_rc]     <= matr_data[index_rc];
        matr_data[index_cr]     <= matr_data[index_cr];

        cnt_rc2                 <= 'd0;
        cnt_rc3                 <= 'd0;
        cnt_loop                <= 'd0;     
        booth_rcvld2            <= 1'b0;           
    end
end



// always @(posedge jacobi_clk) begin
//     if(jacobi_rst) begin
//         cnt_rc2                 <= 'd0;
//         cnt_rc3                 <= 'd0;
//         cnt_loop                <= 'd0;
//         booth_rcvld2            <= 1'b0;
//         booth_i1                <= 32'd0;
//         booth_i2                <= 32'd0;
//         booth_j1                <= 32'd0;
//         booth_j2                <= 32'd0;
//         booth_k1                <= 32'd0;
//         booth_k2                <= 32'd0;
//         booth_l1                <= 32'd0;
//         booth_l2                <= 32'd0;
//     end
//     else if(n_s == S_ROWCOL_2) begin
//         cnt_rc3             <= cnt_rc3 + 1'b1;
//         if(cnt_rc2 < 'd5)
//             cnt_rc2         <= cnt_rc2 + 1'b1;
//         else
//             cnt_rc2         <= 'd0;

//         if(cnt_rc2 == 'd5 && cnt_loop < 'd7)
//             cnt_loop            <= cnt_loop + 1'b1;
//         else 
//             cnt_loop            <= cnt_loop;

//         if(cnt_rc2 == 'd0 && cnt_loop != for_row && cnt_loop != for_col && cnt_loop < 'd8) begin
//             booth_rcvld2        <= 1'b1;      
//             booth_i1            <= matr_data[index_rk];
//             booth_i2            <= cos1_the;
//             booth_j1            <= matr_data[index_ck];
//             booth_j2            <= sin1_the;
//             booth_k1            <= matr_data[index_ck];
//             booth_k2            <= cos1_the;
//             booth_l1            <= matr_data[index_rk];
//             booth_l2            <= sin1_the;
//         end  
//         else 
//             booth_rcvld2        <= 1'b0;

//         if(rcovld1) begin
//             matr_data[index_rk] <= alu_rk + alu_kr;
//             matr_data[index_kr] <= alu_rk + alu_kr;
//             matr_data[index_ck] <= alu_ck - alu_kc;
//             matr_data[index_kc] <= alu_ck - alu_kc;
//         end
//         else begin
//             matr_data[index_rk] <= matr_data[index_rk];
//             matr_data[index_kr] <= matr_data[index_kr];
//             matr_data[index_ck] <= matr_data[index_ck];
//             matr_data[index_kc] <= matr_data[index_kc];       
//         end
//     end
//     else begin
//         cnt_rc2                 <= 'd0;
//         cnt_rc3                 <= 'd0;
//         cnt_loop                <= 'd0;     
//         booth_rcvld2            <= 1'b0;   
//     end
// end
  //------------------------STATE : S_FEA_VET----------------------------//
always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
                                                        feature_vet[20]                  <= 'd0      ;feature_vet[40]                  <= 'd0      ;feature_vet[60]                  <= 'd0      ;     
        cnt_vet                         <= 'd0      ;   feature_vet[21]                  <= 'd0      ;feature_vet[41]                  <= 'd0      ;feature_vet[61]                  <= 'd0      ;     
        cnt_vet1                        <= 'd0      ;   feature_vet[22]                  <= 'd0      ;feature_vet[42]                  <= 'd0      ;feature_vet[62]                  <= 'd0      ;     
        loop_vet                        <= 'd0      ;   feature_vet[23]                  <= 'd0      ;feature_vet[43]                  <= 'd0      ;feature_vet[63]                  <= quantify ;     
        booth_rcvld3                    <= 1'b0     ;   feature_vet[24]                  <= 'd0      ;feature_vet[44]                  <= 'd0      ; 
        feature_vet[0]                  <= quantify ;   feature_vet[25]                  <= 'd0      ;feature_vet[45]                  <= quantify ;
        feature_vet[1]                  <= 'd0      ;   feature_vet[26]                  <= 'd0      ;feature_vet[46]                  <= 'd0      ;
        feature_vet[2]                  <= 'd0      ;   feature_vet[27]                  <= quantify ;feature_vet[47]                  <= 'd0      ;
        feature_vet[3]                  <= 'd0      ;   feature_vet[28]                  <= 'd0      ;feature_vet[48]                  <= 'd0      ;
        feature_vet[4]                  <= 'd0      ;   feature_vet[29]                  <= 'd0      ;feature_vet[49]                  <= 'd0      ;   
        feature_vet[5]                  <= 'd0      ;   feature_vet[30]                  <= 'd0      ;feature_vet[50]                  <= 'd0      ;
        feature_vet[6]                  <= 'd0      ;   feature_vet[31]                  <= 'd0      ;feature_vet[51]                  <= 'd0      ;
        feature_vet[7]                  <= 'd0      ;   feature_vet[32]                  <= 'd0      ;feature_vet[52]                  <= 'd0      ;
        feature_vet[8]                  <= 'd0      ;   feature_vet[33]                  <= 'd0      ;feature_vet[53]                  <= 'd0      ;
        feature_vet[9]                  <= quantify ;   feature_vet[34]                  <= 'd0      ;feature_vet[54]                  <= quantify ;   
        feature_vet[10]                 <= 'd0      ;   feature_vet[35]                  <= 'd0      ;feature_vet[55]                  <= 'd0      ;
        feature_vet[11]                 <= 'd0      ;   feature_vet[36]                  <= quantify ;feature_vet[56]                  <= 'd0      ;
        feature_vet[12]                 <= 'd0      ;   feature_vet[37]                  <= 'd0      ;feature_vet[57]                  <= 'd0      ;
        feature_vet[13]                 <= 'd0      ;   feature_vet[38]                  <= 'd0      ;feature_vet[58]                  <= 'd0      ;
        feature_vet[14]                 <= 'd0      ;   feature_vet[39]                  <= 'd0      ;feature_vet[59]                  <= 'd0      ;   
        feature_vet[15]                 <= 'd0      ;
        feature_vet[16]                 <= 'd0      ;
        feature_vet[17]                 <= 'd0      ;
        feature_vet[18]                 <= quantify ;
        feature_vet[19]                 <= 'd0      ;  

        // index1_kr                       <= 'd0;
        // index1_kc                       <= 'd0;                         
    end
    else if(n_s == S_IDLE) begin
        feature_vet[0]                  <= quantify ;feature_vet[20]                  <= 'd0      ;feature_vet[40]                  <= 'd0      ;feature_vet[60]                  <= 'd0      ;
        feature_vet[1]                  <= 'd0      ;feature_vet[21]                  <= 'd0      ;feature_vet[41]                  <= 'd0      ;feature_vet[61]                  <= 'd0      ;
        feature_vet[2]                  <= 'd0      ;feature_vet[22]                  <= 'd0      ;feature_vet[42]                  <= 'd0      ;feature_vet[62]                  <= 'd0      ;
        feature_vet[3]                  <= 'd0      ;feature_vet[23]                  <= 'd0      ;feature_vet[43]                  <= 'd0      ;feature_vet[63]                  <= quantify ;
        feature_vet[4]                  <= 'd0      ;feature_vet[24]                  <= 'd0      ;feature_vet[44]                  <= 'd0      ;
        feature_vet[5]                  <= 'd0      ;feature_vet[25]                  <= 'd0      ;feature_vet[45]                  <= quantify ;
        feature_vet[6]                  <= 'd0      ;feature_vet[26]                  <= 'd0      ;feature_vet[46]                  <= 'd0      ;
        feature_vet[7]                  <= 'd0      ;feature_vet[27]                  <= quantify ;feature_vet[47]                  <= 'd0      ;
        feature_vet[8]                  <= 'd0      ;feature_vet[28]                  <= 'd0      ;feature_vet[48]                  <= 'd0      ;
        feature_vet[9]                  <= quantify ;feature_vet[29]                  <= 'd0      ;feature_vet[49]                  <= 'd0      ;
        feature_vet[10]                 <= 'd0      ;feature_vet[30]                  <= 'd0      ;feature_vet[50]                  <= 'd0      ;
        feature_vet[11]                 <= 'd0      ;feature_vet[31]                  <= 'd0      ;feature_vet[51]                  <= 'd0      ;
        feature_vet[12]                 <= 'd0      ;feature_vet[32]                  <= 'd0      ;feature_vet[52]                  <= 'd0      ;
        feature_vet[13]                 <= 'd0      ;feature_vet[33]                  <= 'd0      ;feature_vet[53]                  <= 'd0      ;
        feature_vet[14]                 <= 'd0      ;feature_vet[34]                  <= 'd0      ;feature_vet[54]                  <= quantify ;
        feature_vet[15]                 <= 'd0      ;feature_vet[35]                  <= 'd0      ;feature_vet[55]                  <= 'd0      ;
        feature_vet[16]                 <= 'd0      ;feature_vet[36]                  <= quantify ;feature_vet[56]                  <= 'd0      ;
        feature_vet[17]                 <= 'd0      ;feature_vet[37]                  <= 'd0      ;feature_vet[57]                  <= 'd0      ;
        feature_vet[18]                 <= quantify ;feature_vet[38]                  <= 'd0      ;feature_vet[58]                  <= 'd0      ;
        feature_vet[19]                 <= 'd0      ;feature_vet[39]                  <= 'd0      ;feature_vet[59]                  <= 'd0      ;
    end
    else if(n_s == S_FEA_VET) begin        
        cnt_vet                         <= cnt_vet + 'd1;
        if(cnt_vet1 < 'd5)
            cnt_vet1                    <= cnt_vet1 + 1'b1;
        else
            cnt_vet1                    <= 'd0;

        if(cnt_vet1 == 'd5)
            loop_vet                    <= loop_vet + 1'b1;
        else 
            loop_vet                    <= loop_vet;

        if(cnt_ite == 'd0 && for_row == 'd0 && for_col == 'd1) begin
            feature_vet[index_rr]       <= cos1_the;
            feature_vet[index_rc]       <= -sin1_the;
            feature_vet[index_cr]       <= sin1_the;
            feature_vet[index_cc]       <= cos1_the;
        end
        else begin
            if(cnt_vet1 == 'd0) begin
                booth_rcvld3            <= 1'b1;
                booth_m1                <= feature_vet[index1_kr];
                booth_m2                <= cos1_the;
                booth_n1                <= feature_vet[index1_kc];
                booth_n2                <= sin1_the;
                booth_o1                <= feature_vet[index1_kc];
                booth_o2                <= cos1_the;
                booth_p1                <= feature_vet[index1_kr];
                booth_p2                <= sin1_the;
            end
            else begin
                booth_rcvld3            <= 1'b0;
            end
        end

        if (pkrovld1) begin
            feature_vet[index1_kr]  <= alu_pkrc + alu_pkcs;
            feature_vet[index1_kc]  <= alu_pkcc - alu_pkrs;
        end
        else begin
            feature_vet[index1_kr]  <= feature_vet[index1_kr];
            feature_vet[index1_kc]  <= feature_vet[index1_kc];
        end

    end    
    // else if(n_s == S_FEA_VET) begin        
    //     cnt_vet                         <= cnt_vet + 'd1;
    //     if(cnt_vet1 < 'd5)
    //         cnt_vet1                    <= cnt_vet1 + 1'b1;
    //     else
    //         cnt_vet1                    <= 'd0;

    //     if(cnt_vet1 == 'd5)
    //         loop_vet                    <= loop_vet + 1'b1;
    //     else 
    //         loop_vet                    <= loop_vet;

    //     if(cnt_ite == 'd0 && for_row == 'd0 && for_col == 'd1) begin
    //         feature_vet[index_rr]       <= cos1_the;
    //         feature_vet[index_rc]       <= -sin1_the;
    //         feature_vet[index_cr]       <= sin1_the;
    //         feature_vet[index_cc]       <= cos1_the;
    //     end
    //     else begin
    //         if(cnt_vet1 == 'd0) begin
    //             index1_kr               <= (loop_vet << 3)+for_row;
    //             index1_kc               <= (loop_vet << 3)+for_col;
    //         end
    //         else begin
    //             index1_kr               <= index1_kr;
    //             index1_kc               <= index1_kc;               
    //         end
    //         if(cnt_vet1 == 'd1) begin
    //             booth_rcvld3            <= 1'b1;
    //             booth_m1                <= feature_vet[index1_kr];
    //             booth_m2                <= cos1_the;
    //             booth_n1                <= feature_vet[index1_kc];
    //             booth_n2                <= sin1_the;
    //             booth_o1                <= feature_vet[index1_kc];
    //             booth_o2                <= cos1_the;
    //             booth_p1                <= feature_vet[index1_kr];
    //             booth_p2                <= sin1_the;
    //         end
    //         else begin
    //             booth_rcvld3            <= 1'b0;
    //         end
    //     end

    //     if (pkrovld1 & pkcovld2 & pkrovld3 & pkcovld4) begin
    //         feature_vet[index1_kr]  <= alu_pkrc + alu_pkcs;
    //         feature_vet[index1_kc]  <= alu_pkcc - alu_pkrs;
    //     end
    //     else begin
    //         feature_vet[index1_kr]  <= feature_vet[index1_kr];
    //         feature_vet[index1_kc]  <= feature_vet[index1_kc];
    //     end

    // end
    else begin
        cnt_vet                         <= 'd0;
        cnt_vet1                        <= 'd0;
        loop_vet                        <= 'd0;
        booth_rcvld3                    <= 1'b0;
    end
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        cnt_ite             <= 'd0;
    else if(n_s == S_LOOP_FOR) begin
        if(cnt_ite == 'd2)
            cnt_ite         <= 'd0;
        else 
            cnt_ite         <= cnt_ite + 1'b1;
    end
    else 
        cnt_ite             <= cnt_ite;
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        cnt_calc_result             <= 'd0;
    else if(n_s == S_DATA_OUT) 
        cnt_calc_result             <= cnt_calc_result + 1'b1;
    else
        cnt_calc_result             <= 'd0;   
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) begin
        calc_resut_matr             <= 'd0;
        calc_resut_vetc             <= 'd0;
    end
    else if(n_s == S_DATA_OUT) begin
        calc_resut_matr             <= matr_data[cnt_calc_result];
        calc_resut_vetc             <= feature_vet[cnt_calc_result];    
    end
    else begin
        calc_resut_matr             <= 'd0;
        calc_resut_vetc             <= 'd0;        
    end
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        jacobi_datavld              <= 1'd0;
    else if(n_s == S_DATA_OUT) 
        jacobi_datavld              <= 1'b1;
    else
        jacobi_datavld              <= 1'b0;
end

always @(posedge jacobi_clk) begin
    if(jacobi_rst) 
        jacobi_done             <= 1'b0;
    else if(cnt_calc_result == 'd63)
        jacobi_done             <= 1'b1;
    else 
        jacobi_done             <= 1'b0;
end

  //-------------------------Instantiate : S_THETA--------------------------//
cordic_angle u1_cordic_angle(
    .clk        (jacobi_clk),
    .rst_n      (jacobi_rst),
    .in_vld     (theta_i_vld),
    .x_start    (x_start),
    .y_start    (y_start),
    .angle      (angle),
    .out_vld    (theta_o_vld)    
);
  //-------------------------Instantiate : S_SINCOS-------------------------//
music_cordic u1_cordic(
    .clk        (jacobi_clk),
    .rst_n      (jacobi_rst),
    .in_vld     (scos1_i_vld),
    .x_start    (an),
    .y_start    (16'd0),
    .angle      (theta1),
    .sine       (sin1),
    .cosine     (cos1),
    .out_vld    (scos1_o_vld)
);
music_cordic u2_cordic(
    .clk        (jacobi_clk),
    .rst_n      (jacobi_rst),
    .in_vld     (scos2_i_vld),
    .x_start    (an),
    .y_start    (16'd0),
    .angle      (theta2),
    .sine       (sin2),
    .cosine     (cos2),
    .out_vld    (scos2_o_vld)
);
  //------------------------Instantiate : S_ROWCOL_1-----------------------//
booth_3 u1_booth_3(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_a1),
    .b      (booth_a2),
    .c      (booth_a3),
    .ans    (alu_rr1),
    .out_vld(booth_rcovld1)    
);
booth_3 u2_booth_3(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_b1),
    .b      (booth_b2),
    .c      (booth_b3),
    .ans    (alu_rr2),
    .out_vld(booth_rcovld2)    
);
booth_2 u3_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_c1),
    .b      (booth_c2),
    .ans    (alu_rr3),
    .out_vld(booth_rcovld3)  
);
booth_3 u4_booth_3(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_d1),
    .b      (booth_d2),
    .c      (booth_d3),
    .ans    (alu_cc1),
    .out_vld(booth_rcovld4)    
);
booth_3 u5_booth_3(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_e1),
    .b      (booth_e2),
    .c      (booth_e3),
    .ans    (alu_cc2),
    .out_vld(booth_rcovld5)    
);
booth_2 u6_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_f1),
    .b      (booth_f2),
    .ans    (alu_cc3),
    .out_vld(booth_rcovld6)  
);
booth_2 u7_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_g1),
    .b      (booth_g2),
    .ans    (alu_rc1),
    .out_vld(booth_rcovld7)  
);
booth_2 u8_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld1),
    .a      (booth_h1),
    .b      (booth_h2),
    .ans    (alu_rc2),
    .out_vld(booth_rcovld8)  
);
  //------------------------Instantiate : S_ROWCOL_2-----------------------//
booth_2 m1_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld2),
    .a      (booth_i1),
    .b      (booth_i2),
    .ans    (alu_rk),
    .out_vld(rcovld1)  
);
booth_2 m2_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld2),
    .a      (booth_j1),
    .b      (booth_j2),
    .ans    (alu_kr),
    .out_vld(rcovld2)  
);
booth_2 m3_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld2),
    .a      (booth_k1),
    .b      (booth_k2),
    .ans    (alu_ck),
    .out_vld(rcovld3)  
);
booth_2 m4_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld2),
    .a      (booth_l1),
    .b      (booth_l2),
    .ans    (alu_kc),
    .out_vld(rcovld4)  
);
  //-------------------------Instantiate : S_FEA_VET------------------------//
booth_2 h1_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld3),
    .a      (booth_m1),
    .b      (booth_m2),
    .ans    (alu_pkrc),
    .out_vld(pkrovld1)  
);
booth_2 h2_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld3),
    .a      (booth_n1),
    .b      (booth_n2),
    .ans    (alu_pkcs),
    .out_vld(pkcovld2)  
);
booth_2 h3_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld3),
    .a      (booth_o1),
    .b      (booth_o2),
    .ans    (alu_pkcc),
    .out_vld(pkrovld3)  
);
booth_2 h4_booth_2(
    .clk    (jacobi_clk),
    .rst_n  (jacobi_rst),
    .in_vld (booth_rcvld3),
    .a      (booth_p1),
    .b      (booth_p2),
    .ans    (alu_pkrs),
    .out_vld(pkcovld4)  
);

endmodule
