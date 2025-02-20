//CORDIC implementation for sine and cosine for Final Project 
//Claire Barnes
module cordic_angle
#(
	parameter width = 32          ,
    parameter loop  = 16          ,
    parameter pi    = 2147483648  // 180*2^29/45
)
(
    input                                      clk        ,
    input                                      rst_n      ,
    input                                      in_vld     ,
    input  signed [width-1:0]                  x_start    ,
    input  signed [width-1:0]                  y_start    ,
    output signed [31:0]                       angle      ,
    output          reg                        out_vld    
);
// Generate table of atan values

reg  signed [width:0] x [0:width-1];
reg  signed [width:0] y [0:width-1];
reg  signed    [31:0] z [0:width-1];  

reg  signed [width:0]         x_shr;
reg  signed [width:0]         y_shr;
reg                           y_sign;

reg vld_s1, vld_s2, vld_s3, vld_s4, vld_s5, vld_s6, vld_s7, vld_s8, vld_s9, vld_s10, vld_s11, vld_s12, vld_s13, vld_s14, vld_s15;

wire signed [31:0] atan_table [0:30];                        
assign atan_table[00] = 'b00100000000000000000000000000000; // 45.000 degrees -> atan(2^0)
assign atan_table[01] = 'b00010010111001000000010100011101; // 26.565 degrees -> atan(2^-1)  vpa(atand(1/2),10) 26.56505118   2^29*26.56505118/45
assign atan_table[02] = 'b00001001111110110011100001011011; // 14.036 degrees -> atan(2^-2)
assign atan_table[03] = 'b00000101000100010001000111010100; // atan(2^-3)
assign atan_table[04] = 'b00000010100010110000110101000011;
assign atan_table[05] = 'b00000001010001011101011111100001;
assign atan_table[06] = 'b00000000101000101111011000011110;
assign atan_table[07] = 'b00000000010100010111110001010101;
assign atan_table[08] = 'b00000000001010001011111001010011;
assign atan_table[09] = 'b00000000000101000101111100101110;
assign atan_table[10] = 'b00000000000010100010111110011000;
assign atan_table[11] = 'b00000000000001010001011111001100;
assign atan_table[12] = 'b00000000000000101000101111100110;
assign atan_table[13] = 'b00000000000000010100010111110011;
assign atan_table[14] = 'b00000000000000001010001011111001;
assign atan_table[15] = 'b00000000000000000101000101111100;
assign atan_table[16] = 'b00000000000000000010100010111110;
assign atan_table[17] = 'b00000000000000000001010001011111;
assign atan_table[18] = 'b00000000000000000000101000101111;
assign atan_table[19] = 'b00000000000000000000010100010111;
assign atan_table[20] = 'b00000000000000000000001010001011;
assign atan_table[21] = 'b00000000000000000000000101000101;
assign atan_table[22] = 'b00000000000000000000000010100010;
assign atan_table[23] = 'b00000000000000000000000001010001;
assign atan_table[24] = 'b00000000000000000000000000101000;
assign atan_table[25] = 'b00000000000000000000000000010100;
assign atan_table[26] = 'b00000000000000000000000000001010;
assign atan_table[27] = 'b00000000000000000000000000000101;
assign atan_table[28] = 'b00000000000000000000000000000010;
assign atan_table[29] = 'b00000000000000000000000000000001;
assign atan_table[30] = 'b00000000000000000000000000000000;

// control path
always @(posedge clk) begin
    if(rst_n) begin
        vld_s1                        <= 1'b0;                       
        vld_s2                        <= 1'b0;              
        vld_s3                        <= 1'b0;              
        vld_s4                        <= 1'b0;              
        vld_s5                        <= 1'b0;              
        vld_s6                        <= 1'b0;              
        vld_s7                        <= 1'b0;              
        vld_s8                        <= 1'b0;
        vld_s9                        <= 1'b0;
        vld_s10                       <= 1'b0;
        vld_s11                       <= 1'b0;
        vld_s12                       <= 1'b0;
        vld_s13                       <= 1'b0;
        vld_s14                       <= 1'b0;
        vld_s15                       <= 1'b0;
        out_vld                       <= 1'b0;                      
    end
    else begin
        vld_s1                        <= in_vld ;
        vld_s2                        <= vld_s1 ;
        vld_s3                        <= vld_s2 ;
        vld_s4                        <= vld_s3 ;
        vld_s5                        <= vld_s4 ;
        vld_s6                        <= vld_s5 ;
        vld_s7                        <= vld_s6 ;
        vld_s8                        <= vld_s7 ;
        vld_s9                        <= vld_s8 ;
        vld_s10                       <= vld_s9 ;
        vld_s11                       <= vld_s10;
        vld_s12                       <= vld_s11;
        vld_s13                       <= vld_s12;
        vld_s14                       <= vld_s13;
        vld_s15                       <= vld_s14;
        out_vld                       <= vld_s15;
    end
end
// make sure the rotation angle is in the -pi/2 to pi/2 range
// 1  no changes needed for these quadrants
// 2  subtract pi/2 for angle in this quadrant
// 3  add pi/2 to angles in this quadrant
always @(posedge clk) begin
    if(rst_n) begin
        x[0]          <= 'd0;
        y[0]          <= 'd0;
        z[0]          <= 'd0;
    end
    else if(in_vld) begin
        if(y_start[width-1] == 1'b0)
            y[0]        <= {y_start[31],y_start};
        else
            y[0]        <= -{y_start[31],y_start};      
        if(x_start[width-1] == 1'b0)
            x[0]        <= {x_start[31],x_start};
        else
            x[0]        <= -{x_start[31],x_start};
        end
    else begin
        x[0] <= x[0];
        y[0] <= y[0];
        z[0] <= z[0];
    end
end

always @(posedge clk) begin
    if(rst_n) begin
        x_shr         <= 'd0;
        y_shr         <= 'd0;  
        y_sign        <= 1'd0;  
    end
    else if(vld_s1) begin
        x[1]          <= (y[0][width] == 1'b0) ? x[0] + y[0] :  x[0] - y[0]                            ;
        y[1]          <= (y[0][width] == 1'b0) ? y[0] - x[0] :  y[0] + x[0]                            ;
        z[1]          <= (y[0][width] == 1'b0) ? z[0] + atan_table[0] : z[0] - atan_table[0]           ;   
        x_shr         <= ((y[0][width] == 1'b0) ? x[0] + y[0] :  x[0] - y[0]                  ) >>>1   ;
        y_shr         <= ((y[0][width] == 1'b0) ? y[0] - x[0] :  y[0] + x[0]                  ) >>>1   ;
        y_sign        <= ((y[0][width] == 1'b0) ? y[0] - x[0] :  y[0] + x[0] ) >>>width  ;
    end
    else if(vld_s2) begin
        x[2]          <= (y_sign  == 1'b0)? x[1] + y_shr :  x[1] - y_shr                            ;
        y[2]          <= (y_sign  == 1'b0)? y[1] - x_shr :  y[1] + x_shr                            ;
        z[2]          <= (y_sign  == 1'b0)? z[1] + atan_table[1] : z[1] - atan_table[1]             ;  
        x_shr         <= ((y_sign == 1'b0)? x[1] + y_shr :  x[1] - y_shr                ) >>>2   ;
        y_shr         <= ((y_sign == 1'b0)? y[1] - x_shr :  y[1] + x_shr                ) >>>2   ;
        y_sign        <= ((y_sign == 1'b0)? y[1] - x_shr :  y[1] + x_shr ) >>>width   ;         
    end
    else if(vld_s3) begin
        x[3]          <= (y_sign  == 1'b0)? x[2] + y_shr :  x[2] - y_shr                ;
        y[3]          <= (y_sign  == 1'b0)? y[2] - x_shr :  y[2] + x_shr                ;
        z[3]          <= (y_sign  == 1'b0)? z[2] + atan_table[2] : z[2] - atan_table[2] ;  
        x_shr         <= ((y_sign == 1'b0)? x[2] + y_shr :  x[2] - y_shr                ) >>>3   ;
        y_shr         <= ((y_sign == 1'b0)? y[2] - x_shr :  y[2] + x_shr                ) >>>3   ;
        y_sign        <= ((y_sign == 1'b0)? y[2] - x_shr :  y[2] + x_shr ) >>>width   ;                
    end
    else if(vld_s4) begin
        x[4]          <= (y_sign  == 1'b0)? x[3] + y_shr :  x[3] - y_shr                ;
        y[4]          <= (y_sign  == 1'b0)? y[3] - x_shr :  y[3] + x_shr                ;
        z[4]          <= (y_sign  == 1'b0)? z[3] + atan_table[3] : z[3] - atan_table[3] ;  
        x_shr         <= ((y_sign == 1'b0)? x[3] + y_shr :  x[3] - y_shr                ) >>>4   ;
        y_shr         <= ((y_sign == 1'b0)? y[3] - x_shr :  y[3] + x_shr                ) >>>4   ;
        y_sign        <= ((y_sign == 1'b0)? y[3] - x_shr :  y[3] + x_shr ) >>>width   ;          
    end
    else if(vld_s5) begin
        x[5]          <= (y_sign  == 1'b0)? x[4] + y_shr :  x[4] - y_shr                ;
        y[5]          <= (y_sign  == 1'b0)? y[4] - x_shr :  y[4] + x_shr                ;
        z[5]          <= (y_sign  == 1'b0)? z[4] + atan_table[4] : z[4] - atan_table[4] ;  
        x_shr         <= ((y_sign == 1'b0)? x[4] + y_shr :  x[4] - y_shr                ) >>>5   ;
        y_shr         <= ((y_sign == 1'b0)? y[4] - x_shr :  y[4] + x_shr                ) >>>5   ;
        y_sign        <= ((y_sign == 1'b0)? y[4] - x_shr :  y[4] + x_shr ) >>>width   ;        
    end
    else if(vld_s6) begin
        x[6]          <= (y_sign  == 1'b0)? x[5] + y_shr :  x[5] - y_shr                ;
        y[6]          <= (y_sign  == 1'b0)? y[5] - x_shr :  y[5] + x_shr                ;
        z[6]          <= (y_sign  == 1'b0)? z[5] + atan_table[5] : z[5] - atan_table[5] ; 
        x_shr         <= ((y_sign == 1'b0)? x[5] + y_shr :  x[5] - y_shr                ) >>>6   ;
        y_shr         <= ((y_sign == 1'b0)? y[5] - x_shr :  y[5] + x_shr                ) >>>6   ;
        y_sign        <= ((y_sign == 1'b0)? y[5] - x_shr :  y[5] + x_shr ) >>>width   ;           
    end
    else if(vld_s7) begin
        x[7]          <= (y_sign  == 1'b0)? x[6] + y_shr :  x[6] - y_shr                ;
        y[7]          <= (y_sign  == 1'b0)? y[6] - x_shr :  y[6] + x_shr                ;
        z[7]          <= (y_sign  == 1'b0)? z[6] + atan_table[6] : z[6] - atan_table[6] ;  
        x_shr         <= ((y_sign == 1'b0)? x[6] + y_shr :  x[6] - y_shr                ) >>>7   ;
        y_shr         <= ((y_sign == 1'b0)? y[6] - x_shr :  y[6] + x_shr                ) >>>7   ;
        y_sign        <= ((y_sign == 1'b0)? y[6] - x_shr :  y[6] + x_shr ) >>>width   ;          
    end
    else if(vld_s8) begin
        x[8]          <= (y_sign  == 1'b0)? x[7] + y_shr :  x[7] - y_shr                ;
        y[8]          <= (y_sign  == 1'b0)? y[7] - x_shr :  y[7] + x_shr                ;
        z[8]          <= (y_sign  == 1'b0)? z[7] + atan_table[7] : z[7] - atan_table[7] ;  
        x_shr         <= ((y_sign == 1'b0)? x[7] + y_shr :  x[7] - y_shr                ) >>>8   ;
        y_shr         <= ((y_sign == 1'b0)? y[7] - x_shr :  y[7] + x_shr                ) >>>8   ;
        y_sign        <= ((y_sign == 1'b0)? y[7] - x_shr :  y[7] + x_shr ) >>>width   ;          
    end
    else if(vld_s9) begin
        x[9]          <= (y_sign  == 1'b0)? x[8] + y_shr :  x[8] - y_shr                ;
        y[9]          <= (y_sign  == 1'b0)? y[8] - x_shr :  y[8] + x_shr                ;
        z[9]          <= (y_sign  == 1'b0)? z[8] + atan_table[8] : z[8] - atan_table[8] ;  
        x_shr         <= ((y_sign == 1'b0)? x[8] + y_shr :  x[8] - y_shr                ) >>>9   ;
        y_shr         <= ((y_sign == 1'b0)? y[8] - x_shr :  y[8] + x_shr                ) >>>9   ;
        y_sign        <= ((y_sign == 1'b0)? y[8] - x_shr :  y[8] + x_shr ) >>>width   ;          
    end   
    else if(vld_s10) begin
        x[10]          <= (y_sign == 1'b0)? x[9] + y_shr :  x[9] - y_shr                     ;
        y[10]          <= (y_sign == 1'b0)? y[9] - x_shr :  y[9] + x_shr                     ;
        z[10]          <= (y_sign == 1'b0)? z[9] + atan_table[9] : z[9] - atan_table[9]      ;  
        x_shr         <= ((y_sign == 1'b0)? x[9] + y_shr :  x[9] - y_shr                ) >>>10   ;
        y_shr         <= ((y_sign == 1'b0)? y[9] - x_shr :  y[9] + x_shr                ) >>>10   ;
        y_sign        <= ((y_sign == 1'b0)? y[9] - x_shr :  y[9] + x_shr ) >>>width   ;          
    end    
    else if(vld_s11) begin
        x[11]          <= (y_sign == 1'b0)? x[10] + y_shr :  x[10] - y_shr                   ;
        y[11]          <= (y_sign == 1'b0)? y[10] - x_shr :  y[10] + x_shr                   ;
        z[11]          <= (y_sign == 1'b0)? z[10] + atan_table[10] : z[10] - atan_table[10]  ;  
        x_shr         <= ((y_sign == 1'b0)? x[10] + y_shr :  x[10] - y_shr                  ) >>>11   ;
        y_shr         <= ((y_sign == 1'b0)? y[10] - x_shr :  y[10] + x_shr                  ) >>>11   ;
        y_sign        <= ((y_sign == 1'b0)? y[10] - x_shr :  y[10] + x_shr ) >>>width   ;          
    end           
    else if(vld_s12) begin
        x[12]          <= (y_sign  == 1'b0)? x[11] + y_shr :  x[11] - y_shr                   ;
        y[12]          <= (y_sign  == 1'b0)? y[11] - x_shr :  y[11] + x_shr                   ;
        z[12]          <= (y_sign  == 1'b0)? z[11] + atan_table[11] : z[11] - atan_table[11]  ;  
        x_shr          <= ((y_sign == 1'b0)? x[11] + y_shr :  x[11] - y_shr                  ) >>>12   ;
        y_shr          <= ((y_sign == 1'b0)? y[11] - x_shr :  y[11] + x_shr                  ) >>>12   ;
        y_sign         <= ((y_sign == 1'b0)? y[11] - x_shr :  y[11] + x_shr ) >>>width   ;          
    end        
    else if(vld_s13) begin
        x[13]          <= (y_sign  == 1'b0)? x[12] + y_shr :  x[12] - y_shr                   ;
        y[13]          <= (y_sign  == 1'b0)? y[12] - x_shr :  y[12] + x_shr                   ;
        z[13]          <= (y_sign  == 1'b0)? z[12] + atan_table[12] : z[12] - atan_table[12]  ; 
        x_shr          <= ((y_sign == 1'b0)? x[12] + y_shr :  x[12] - y_shr                  ) >>>13   ;
        y_shr          <= ((y_sign == 1'b0)? y[12] - x_shr :  y[12] + x_shr                  ) >>>13   ;
        y_sign         <= ((y_sign == 1'b0)? y[12] - x_shr :  y[12] + x_shr ) >>>width   ;             
    end  
    else if(vld_s14) begin
        x[14]          <= (y_sign  == 1'b0)? x[13] + y_shr :  x[13] - y_shr                   ;
        y[14]          <= (y_sign  == 1'b0)? y[13] - x_shr :  y[13] + x_shr                   ;
        z[14]          <= (y_sign  == 1'b0)? z[13] + atan_table[13] : z[13] - atan_table[13]  ;  
        x_shr          <= ((y_sign == 1'b0)? x[13] + y_shr :  x[13] - y_shr                  ) >>>14   ;
        y_shr          <= ((y_sign == 1'b0)? y[13] - x_shr :  y[13] + x_shr                  ) >>>14   ;
        y_sign         <= ((y_sign == 1'b0)? y[13] - x_shr :  y[13] + x_shr ) >>>width   ;          
    end   
    else if(vld_s15) begin
        x[15]          <= (y_sign  == 1'b0)? x[14] + y_shr :  x[14] - y_shr                   ;
        y[15]          <= (y_sign  == 1'b0)? y[14] - x_shr :  y[14] + x_shr                   ;
        z[15]          <= (y_sign  == 1'b0)? z[14] + atan_table[14] : z[14] - atan_table[14]  ;  
        x_shr          <= ((y_sign == 1'b0)? x[14] + y_shr :  x[14] - y_shr                  ) >>>15   ;
        y_shr          <= ((y_sign == 1'b0)? y[14] - x_shr :  y[14] + x_shr                  ) >>>15   ;
        y_sign         <= ((y_sign == 1'b0)? y[14] - x_shr :  y[14] + x_shr ) >>>width   ;            
    end   
    else begin
        x[15]          <= x[15];
        y[15]          <= y[15];
        z[15]          <= z[15];
    end
end

// assign output
assign angle = (x_start[width-1] == 1'b0 && y_start[width-1] == 1'b0)?z[loop-1]:
                (x_start[width-1] == 1'b1 && y_start[width-1] == 1'b0)?(-z[loop-1]):
                (x_start[width-1] == 1'b1 && y_start[width-1] == 1'b1)?(z[loop-1])://this fit the jacobi, but false
                (-z[loop-1]);

endmodule





