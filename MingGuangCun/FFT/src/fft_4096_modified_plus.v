module                fft_4096_modified_plus
(//when mode=11 do 4096 ,mode=10 do 1024 ,mode=01 do 2048 ,mode=00 do 4096
    input             clk                  ,
    input             rst_n                ,
    input             init_general         ,
    input             ifft                 ,//when ifft=1 do ifft
    input        [1:0]mode                 ,
    input      [255:0]douta                ,
    output  reg[10:0]addra                 ,
    output  reg       web                  ,
    output  reg[10:0]addrb                 ,
    output  reg[255:0]dinb                 ,
    output  reg       fft_ing              ,
    input             usr_irq_ack          ,
    output  reg       usr_irq_req
);
// optimize the distribution of always block 
//0,512,...,512*7,64,64+512,....,64+512*7
//...,64*7,64*7+512,.....,64*7+512*7,
//8,8+512,...,8+512*7,8+64,8+64+512,....,8+64+512*7

//------------interrupt settings------------- 
reg usr_irq_ack_1;//异步信号，缓存一拍
reg syn          ;
wire ack         ;

//---------------------------------------
//set for state machine
localparam state0  =  6'b000001;
localparam state1  =  6'b000010;
localparam state2  =  6'b000100;
localparam state3  =  6'b001000;
localparam state4  =  6'b010000;
localparam state5  =  6'b100000;
//-------------------------------------------
reg [2:0]stage;
reg [3:0]stall;
 reg [55:0]f1_data0;
 reg [55:0]f1_data1;
 reg [55:0]f1_data2;
 reg [55:0]f1_data3;
 reg [55:0]f1_data4;
 reg [55:0]f1_data5;
 reg [55:0]f1_data6;
 reg [55:0]f1_data7;
 reg [31:0]f1_w1   ;
 reg [31:0]f1_w2   ;
 reg [31:0]f1_w3   ;
 reg [31:0]f1_w4   ;
 reg [31:0]f1_w5   ;
 reg [31:0]f1_w6   ;
 reg [31:0]f1_w7   ;
wire [63:0]f1_x0   ;
wire [63:0]f1_x1   ;
wire [63:0]f1_x2   ;
wire [63:0]f1_x3   ;
wire [63:0]f1_x4   ;
wire [63:0]f1_x5   ;
wire [63:0]f1_x6   ;
wire [63:0]f1_x7   ;
 //----------------------instantiation --------------------------
 

 fft_8 f1(
clk      ,
ifft     ,
f1_data0 ,
f1_data1 ,
f1_data2 ,
f1_data3 ,
f1_data4 ,
f1_data5 ,
f1_data6 ,
f1_data7 ,
f1_w1    ,
f1_w2    ,
f1_w3    ,
f1_w4    ,
f1_w5    ,
f1_w6    ,
f1_w7    ,
stall[0] ,
f1_x0    ,
f1_x1    ,
f1_x2    ,
f1_x3    ,
f1_x4    ,
f1_x5    ,
f1_x6    ,
f1_x7      
);
 reg [55:0]f2_data0;
 reg [55:0]f2_data1;
 reg [55:0]f2_data2;
 reg [55:0]f2_data3;
 reg [55:0]f2_data4;
 reg [55:0]f2_data5;
 reg [55:0]f2_data6;
 reg [55:0]f2_data7;
 reg [31:0]f2_w1   ;
 reg [31:0]f2_w2   ;
 reg [31:0]f2_w3   ;
 reg [31:0]f2_w4   ;
 reg [31:0]f2_w5   ;
 reg [31:0]f2_w6   ;
 reg [31:0]f2_w7   ;
 wire [63:0]f2_x0   ;
 wire [63:0]f2_x1   ;
 wire [63:0]f2_x2   ;
 wire [63:0]f2_x3   ;
 wire [63:0]f2_x4   ;
 wire [63:0]f2_x5   ;
 wire [63:0]f2_x6   ;
 wire [63:0]f2_x7   ;
 
 fft_8 f2(
clk   ,
ifft  ,
f2_data0 ,
f2_data1 ,
f2_data2 ,
f2_data3 ,
f2_data4 ,
f2_data5 ,
f2_data6 ,
f2_data7 ,
f2_w1    ,
f2_w2    ,
f2_w3    ,
f2_w4    ,
f2_w5    ,
f2_w6    ,
f2_w7    ,
stall[1]   ,
f2_x0    ,
f2_x1    ,
f2_x2    ,
f2_x3    ,
f2_x4    ,
f2_x5    ,
f2_x6    ,
f2_x7      
);
 reg [55:0]f3_data0;
 reg [55:0]f3_data1;
 reg [55:0]f3_data2;
 reg [55:0]f3_data3;
 reg [55:0]f3_data4;
 reg [55:0]f3_data5;
 reg [55:0]f3_data6;
 reg [55:0]f3_data7;
 reg [31:0]f3_w1   ;
 reg [31:0]f3_w2   ;
 reg [31:0]f3_w3   ;
 reg [31:0]f3_w4   ;
 reg [31:0]f3_w5   ;
 reg [31:0]f3_w6   ;
 reg [31:0]f3_w7   ;
 wire [63:0]f3_x0   ;
 wire [63:0]f3_x1   ;
 wire [63:0]f3_x2   ;
 wire [63:0]f3_x3   ;
 wire [63:0]f3_x4   ;
 wire [63:0]f3_x5   ;
 wire [63:0]f3_x6   ;
 wire [63:0]f3_x7   ;
 
 fft_8 f3(
clk   ,
ifft  ,
f3_data0 ,
f3_data1 ,
f3_data2 ,
f3_data3 ,
f3_data4 ,
f3_data5 ,
f3_data6 ,
f3_data7 ,
f3_w1    ,
f3_w2    ,
f3_w3    ,
f3_w4    ,
f3_w5    ,
f3_w6    ,
f3_w7    ,
stall[2]   ,
f3_x0    ,
f3_x1    ,
f3_x2    ,
f3_x3    ,
f3_x4    ,
f3_x5    ,
f3_x6    ,
f3_x7      
);
 reg [55:0]f4_data0;
 reg [55:0]f4_data1;
 reg [55:0]f4_data2;
 reg [55:0]f4_data3;
 reg [55:0]f4_data4;
 reg [55:0]f4_data5;
 reg [55:0]f4_data6;
 reg [55:0]f4_data7;
 reg [31:0]f4_w1   ;
 reg [31:0]f4_w2   ;
 reg [31:0]f4_w3   ;
 reg [31:0]f4_w4   ;
 reg [31:0]f4_w5   ;
 reg [31:0]f4_w6   ;
 reg [31:0]f4_w7   ;
 wire [63:0]f4_x0   ;
 wire [63:0]f4_x1   ;
 wire [63:0]f4_x2   ;
 wire [63:0]f4_x3   ;
 wire [63:0]f4_x4   ;
 wire [63:0]f4_x5   ;
 wire [63:0]f4_x6   ;
 wire [63:0]f4_x7   ;
 
 fft_8 f4(
clk   ,
ifft  ,
f4_data0 ,
f4_data1 ,
f4_data2 ,
f4_data3 ,
f4_data4 ,
f4_data5 ,
f4_data6 ,
f4_data7 ,
f4_w1    ,
f4_w2    ,
f4_w3    ,
f4_w4    ,
f4_w5    ,
f4_w6    ,
f4_w7    ,
stall[3] ,
f4_x0    ,
f4_x1    ,
f4_x2    ,
f4_x3    ,
f4_x4    ,
f4_x5    ,
f4_x6    ,
f4_x7      
);
//-------------------1 fft_4 flow instance--------------------------------
 wire [63:0]f1_x0_4   ;
 wire [63:0]f1_x1_4   ;
 wire [63:0]f1_x2_4   ;
 wire [63:0]f1_x3_4   ;

fft_4 f14(
clk   ,
ifft     ,
f1_data0 ,
f1_data1 ,
f1_data2 ,
f1_data3 ,
f1_w2    ,
f1_w4    ,
f1_w6    ,
stall[0] ,
f1_x0_4    ,
f1_x1_4    ,
f1_x2_4    ,
f1_x3_4     
);

//-----------------2 fft_2_flow instance
 wire [63:0]f1_x0_2   ;
 wire [63:0]f1_x1_2   ;

fft_2 f12(
clk      ,
ifft     ,
f1_data0 ,
f1_data1 ,
f1_w4    ,
f1_x0_2  ,
f1_x1_2    
);

 wire [63:0]f1_x2_2   ;
 wire [63:0]f1_x3_2   ;

fft_2 f22(
clk      ,
ifft     ,
f2_data0 ,
f2_data1 ,
f2_w4    ,
f1_x2_2  ,
f1_x3_2    
);
//--------------------------------------
reg [9:0]k;
 wire[15:0]w1_re;
 wire[15:0]w2_re;
 wire[15:0]w3_re;
 wire[15:0]w4_re;
 wire[15:0]w5_re;
 wire[15:0]w6_re;
 wire[15:0]w7_re;
 wire[15:0]w1_im;
 wire[15:0]w2_im;
 wire[15:0]w3_im;
 wire[15:0]w4_im;
 wire[15:0]w5_im;
 wire[15:0]w6_im;
 wire[15:0]w7_im;
rotation_factor_4096 r2(
clk,
k,
stage,
w1_re,
w1_im,
w2_re,
w2_im,
w3_re,
w3_im,
w4_re,
w4_im,
w5_re,
w5_im,
w6_re,
w6_im,
w7_re,
w7_im
);
reg [5:0]state;
reg [6:0]cnt;//mod 128 cntmod16 +cntmod8 is better
reg [3:0]cnt1;
reg [3:0]cnt2;
reg cnt3;
reg rd_en;
reg on;
/*
----------brief introduction to these cnts----------
clk_num is set to determine the clk it needs ||for simulate
recommend remove clk_num when using it on fpga pratically 
cnt is set to control when  address_wr and stall begin to change .
cnt1 is set to control the read process ,mainly about address_rd cnt2
and set the input for fft modules.
cnt2 is the same like cnt1,just replace the read with write.you can 
even delay cnt1 for some particular clks to maintain the output.

*/
//---------always block---------------------------------
//count to enable address transform 
//count block
//because  verilog doesn't allow operations like vector[9-mode:6-mode]
//and every mode takes the same time
//so we just need to count on the clk

//state transform
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        state       <= state0;
        stage       <= 0     ;
        fft_ing     <= 0     ;
        syn         <= 0     ;
    end
    else begin
        case (state)
            state0: begin
            syn         <= 0     ;
                if(init_general)begin
                     state   <= state1;
                     fft_ing <= 1     ;
                 end 
                 else begin
                    state        <= state0;
                    stage        <= 1'd0  ;
                    fft_ing      <= 0     ;
                 end
            end
            state1:begin
                syn         <= 0     ;
                if(addrb==(11'd1024>>>mode)-1)
                     begin
                        state <= state2;
                        stage <= 1'd1  ;
                    end
                else begin
                        state <= state;
                        stage <= stage;
                end
            end
            state2:begin
                syn         <= 0     ;
                if(addrb==(11'd1024>>>mode)-1)
                     begin
                        state <= state3;
                        stage <= 2'd2;
                    end
                else begin
                        state <= state;
                        stage <= stage;
                end 
            end
            state3:begin
                syn         <= 0     ;
                if(addrb==(11'd1024>>>mode)-1)
                     begin
                        state <= state4;
                        stage <= 2'd3;
                    end
                else begin
                        state <= state;
                        stage <= stage;
                end 
            end
            state4:begin
               syn         <= 0     ;
               if(addrb==(11'd1024>>>mode)-1)       begin
                if(mode==2)begin
                    if(cnt[0])begin
                            state<=state;     
                    end
                    else begin
                        state <= state5;
                    end
                    end
                else begin
                    state <= state5;
                end
                end
                else    state <= state ;
            end
            state5:begin
                syn         <= 1               ;
                if(cnt==2'd2) fft_ing <= 0     ;
                else fft_ing = fft_ing;
                if(cnt==2'd3) state   <= state0;
                else state <= state;
            end
            default:state <= state0; 
        endcase
    end
end

//address transform
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt    <= 0;
        cnt1   <= 0;
        cnt2   <= 0;
        cnt3   <= 0;
        addra  <= 0;
        addrb  <= 0;
        web    <= 0;
        rd_en  <= 0;
    end
    else begin
        case (state)
            state0:begin
                cnt    <=  0 ;
                cnt1   <=  0 ;
                cnt2   <=  0 ;
                cnt3   <=  0 ;
                addra  <=  0 ;
                addrb  <=  0 ;
                rd_en  <=  0 ;
                web    <=  0 ;
            end 
            state1:begin
                if (addrb==(11'd1024>>>mode)-1) begin
                        cnt <= 1'd0;
                     end
                     else begin
                        cnt <= cnt + 1'd1;
                     end
                if (addra==(11'd1024>>>mode)-1) begin
                    if(cnt1=='d6) 
                        cnt1  <= 'd7;
                    else if(cnt1=='d7)begin
                        rd_en <= 0;
                        cnt1  <= 0;
                    end
                    else begin
                        rd_en <= rd_en;
                        cnt1  <= cnt1;
                    end
                     if (addrb==(11'd1024>>>mode)-1) begin
                        addra <= 0;
                     end
                     else 
                        addra <= addra;
                 end
                 else begin 
                     rd_en <= 1;
                     if(cnt[2:0]==3'd7)      addra <= addra - (10'd896>>>mode) + 'd1;
                     else                    addra <= addra + (8'd128>>>mode)      ;
                     // to optimize the timing ,
                     //we need to insert two register
                     //thus lengthen the time to wait
                     if(rd_en)begin
                        if (cnt1 == 3'd7)  cnt1 <= 0;
                        else               cnt1 <= cnt1+1;
                        end
                 end
                 if(on||web)begin//
                     if(addrb==(11'd1024>>>mode)-1)
                     begin 
                        web   <= 0;
                        addrb <= 0;
                        cnt2  <= 0;
                    end
					else begin
                        web   <= 1'd1;
                        if (cnt2 == 'd7)    cnt2 <= 1'd0     ; 
                        else                cnt2 <= cnt2+1'd1;
                        if(web)begin
                            if(cnt[2:0]==1'd1) addrb <= addrb - (10'd896>>>mode) + 'd1;
                            else             addrb <= addrb + (8'd128>>>mode);
                        end
                     end
             end
            end
            state2:begin
                if (addrb==(11'd1024>>>mode)-1) begin
                        cnt <= 1'd0;
                     end
                     else begin
                        cnt <= cnt + 1'd1;
                     end
                 if (addra==(11'd1024>>>mode)-1) begin
                    if     (cnt1 == 'd6)  cnt1 <= 'd7;
                    else if(cnt1 == 7)begin
                        rd_en <= 0;
                        cnt1  <= 0;
                     end
                     else begin
                        rd_en <= rd_en;
                        cnt1  <= cnt1 ;
                     end
                     if (addrb==(11'd1024>>>mode)-1) begin
                        addra <= 0;
                     end
                     else addra <= addra;
                 end
                 else begin 
                     rd_en <= 1;
                     case(mode)
                            1'd0:begin
                            if     (cnt==7'd127)              addra <= addra+'d1;
                            else if(cnt[2:0]==3'd7)          addra <= addra-(7'd112>>>mode)+'d1;
                            else                             addra <= addra+(5'd16>>>mode);
                            end
                            1'd1: begin
                                if     (cnt[5:0]==6'd63)         addra <= addra+'d1;
                                else if(cnt[2:0]==3'd7)          addra <= addra-(7'd112>>>mode)+'d1;
                                else                             addra <= addra+(5'd16>>>mode);
                            end
                            2'd2:begin
                                if     (cnt[4:0]==5'd31)         addra <= addra+'d1;
                                else if(cnt[2:0]==3'd7)          addra <= addra-(7'd112>>>mode)+'d1;
                                else                             addra <= addra+(5'd16>>>mode);
                            end
                            default:begin
                                addra  <=  1'd0;
                            end
                            endcase
                    if(rd_en)begin
                        if  (cnt1==3'd7)    cnt1 <= 0;
                        else                cnt1 <= cnt1+1;
                        end
                 end
                 if(on||web)begin
                     if(addrb==(11'd1024>>>mode)-1)
                     begin
                        web   <= 0;
                        addrb <= 0;
                        cnt2  <= 0;
                    end
					else begin
                        web  <=  1'd1;
                        if (cnt2==3'd7)   cnt2 <= 'd0;
                        else              cnt2 <= cnt2 + 1;
                        if (web) begin
                            case(mode)
                            1'd0:begin
                            if     (cnt==5'd17)              addrb <= addrb+'d1;
                            else if(cnt[2:0]==3'd1)          addrb <= addrb-(7'd112>>>mode)+'d1;
                            else                             addrb <= addrb+(5'd16>>>mode);
                            end
                            1'd1: begin
                                if     (cnt[5:0]==5'd17)         addrb <= addrb+'d1;
                                else if(cnt[2:0]==3'd1)          addrb <= addrb-(7'd112>>>mode)+'d1;
                                else                             addrb <= addrb+(5'd16>>>mode);
                            end
                            2'd2:begin
                                if     (cnt[4:0]==5'd17)         addrb <= addrb+'d1;
                                else if(cnt[2:0]==3'd1)          addrb <= addrb-(7'd112>>>mode)+'d1;
                                else                             addrb <= addrb+(5'd16>>>mode);
                            end
                            default:begin
                                addrb  <=  1'd0;
                            end
                            endcase
                            end
                            end
                     end
            end
            state3:begin
                if (addrb==(11'd1024>>>mode)-1) begin
                        cnt <= 1'd0;
                     end
                     else begin
                        cnt <= cnt + 1'd1;
                     end
                if (addra==(11'd1024>>>mode)-1) begin
                    if      (cnt1 == 6)   cnt1 <= 'd7;
                    else if (cnt1 == 7)begin
                        rd_en <= 0;
                        cnt1  <= 0;
                     end
                     else begin
                        rd_en <= rd_en;
                        cnt1  <= cnt1;
                     end
                     if (addrb==(11'd1024>>>mode)-1) begin
                        addra <= 0;
                     end
                     else addra <= addra;
                 end
                 else begin 
                     rd_en <= 1;
                     case(mode)
                            1'd0:begin
                            if      (cnt[3:0]==4'd15)   addra<=addra + 1             ;
                            else if (cnt[2:0]==3'd7 )   addra<=addra - (4'd14) +1'd1 ;
                            else                        addra<=addra + (2'd2 )       ;
                            end
                            1'd1: begin
                                //for 2048 ,the else is not for more modes
                                //use two instances of fft_8 because of one dout contains 4 data,two of which needs to be in the same computation process 
                                //the other two instances need to be idle
                                addra <= addra + 1'd1;
                            end
                            2'd2:begin
                                //for 1024
                                addra <= addra + 1'd1;
                            end
                            default:begin
                                if      (cnt[3:0]==4'd15)   addra<=addra + 1                   ;
                                else if (cnt[2:0]==3'd7 )   addra<=addra - (4'd14) +1'd1 ;
                                else                        addra<=addra + (2'd2 )       ;
                            end
                            endcase
                     if(rd_en)begin
                            if(cnt1 == 3'd7)   cnt1 <= 'd0;
                            else               cnt1 <= cnt1 + 1'd1;
                        end
                 end
                 if(on||web)begin
                     if(addrb==(11'd1024>>>mode)-1)
                     begin
                        web   <= 0;
                        addrb <= 0;
                        cnt2  <= 0;
                        case(mode)
                        1'd0:    cnt3  <= 0;
                        default: cnt3  <= 1;
                        endcase
                    end
					else begin
                        web <= 1'd1;
                        if(cnt2 == 3'd7)   cnt2 <= 'd0;
                        else               cnt2 <= cnt2 + 1'd1;
                        if (web) begin
                            case(mode)
                            1'd0:begin
                            if      (cnt[3:0]==1'd1)   addrb<=addrb + 1                   ;
                            else if (cnt[2:0]==1'd1)   addrb<=addrb - (4'd14) +1'd1 ;
                            else                       addrb<=addrb + (2'd2 )       ;
                            end
                            1'd1: begin
                                //for 2048 ,the else is not for more modes
                                //use two instances of fft_8 because of one dout contains 4 data,two of which needs to be in the same computation process 
                                //the other two instances need to be idle
                                addrb <= addrb + 1'd1;
                            end
                            2'd2:begin
                                //for 1024
                                addrb <= addrb + 1'd1;
                            end
                            2'd3:begin
                                if      (&addrb[3:0])   addrb<=addrb + 1                   ;
                                else if (&addrb[3:1])   addrb<=addrb - (4'd14) +1'd1 ;
                                else                    addrb<=addrb + (2'd2 )       ;
                            end
                            endcase
                            end
                            end
                     end
            end
            state4:begin
                if (addrb==(11'd1024>>>mode)-1) begin
                        cnt <= 1'd0;
                     end
                     else begin
                        cnt <= cnt + 1'd1;
                     end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                 if(mode==0)cnt3 <= ~cnt3;
                 else       cnt3 <=  cnt3;//except 4096,all change without halt
                 if (addra==(11'd1024>>>mode)-1) begin
                    if(cnt1==3'd6)  cnt1 <= 3'd7;
                     else if(cnt1==3'd7)begin
                        rd_en <= 0;
                        cnt1  <= 0;
                     end
                     else begin
                        rd_en <= rd_en;
                        cnt1  <= cnt1 ;
                     end
                 end
                 else begin 
                     rd_en <= 1;
                     if(mode==2'd2)  begin 
                        if(cnt[0])addra <= addra+1;//for 1024
                     end
                     else begin
                        addra <= addra+1;
                     end
                     if(rd_en)begin
                        if(cnt1==(4'd8>>>mode)-1)  cnt1   <= 0;
                        else                       cnt1   <= cnt1+1;
                        end
                 end
                 if(on||web)begin
                    if(addrb==(11'd1024>>>mode)-1)
                     begin
                        if(mode==2)begin
                            if(cnt[0])begin
                               addrb <= addrb; 
                            end
                            else begin
                                addrb <= 11'd1024;
                            end
                        end
                        else begin
                        addrb <= 11'd1024;
                        end
                        //whatever the mode
                        //choose 1024 as the control place
                    end
					else begin
                        web <= 1'd1;
                        if (cnt2==(4'd8>>>mode)-1) cnt2 <= 0     ;
                        else                       cnt2 <= cnt2+1;
                        if (web) begin
                         if(mode==2'd2)  begin 
                            if(cnt2[0])  addrb <= addrb  ;//for 1024
                            else         addrb <= addrb+1;
                            end
                         else begin
                                    addrb <= addrb+1;
                           end
                            end
                     end
                     end
            end
            state5:begin
                cnt <= cnt + 1'd1;
            end
            default: begin
                cnt    <=  0   ;
                cnt1   <=  0;
                cnt2   <=  0;
                cnt3   <=  0;
                addra  <=  0;
                addrb  <=  0;
                web    <=  0;
                rd_en  <=  0;
            end
        endcase
    end
end

//rotary factor transform
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        k <= 0;
    end
    else begin
        case (state)
            state0:begin
                k  <=  0   ;
            end
            state1:begin
                k  <=  0;
            end
            state2:begin
                if(addra==(11'd1024>>>mode)-1) k  <= 1'd0;
                else begin
                case (mode)
                    1'd0: k  <=  addra[9:7];//4096
                    1'd1: k  <=  addra[8:6];//2048
                    2'd2: k  <=  addra[7:5];//1024
                    default: k  <=  addra[9:7];
                endcase
                end
            end
            state3:begin
                case (mode)
                    1'd0: begin
                        if(&addrb[9:0])     
                            k  <=  0;
                        else                
                            k  <=  addra[9:7]+(addra[6:4]<<3);
                    end//4096
                    1'd1: begin
                        if(&addrb[8:0])     
                            k  <=  0;
                        else                
                            k  <=  addra[8:6]+(addra[5:3]<<3);
                    end//2048
                    2'd2: begin
                        if(&addrb[7:0])     
                            k  <=  0;
                        else if(cnt[1:0]==2'd3)                
                            begin
                                if(&k[5:3]) k  <=  k - 55;
                                else        k  <=  k + 8 ;
                            end
                        else begin
                            k <= k;
                        end 
                    end//1024
                    default: k  <=  0;
                endcase
            end
            state4:begin
                if (cnt3)begin
                     if(&k[8:3])        
                        k  <=  k - 'd503;
                     else if(&k[8:6])
                        k  <=  k - 'd440;
                     else 
                        k  <=  k + 'd64;                     
                 end
                 else begin
                    k  <=  k;
                 end
            end
            default: k  <=  1'd0;
        endcase
    end
end
 
 always @(posedge clk ) begin
         if(rd_en)begin
             if(stage==1||stage==0)begin
                 f1_w1[31:16]<=w1_re;   
                 f1_w2[31:16]<=w2_re;   
                 f1_w3[31:16]<=w3_re;   
                 f1_w4[31:16]<=w4_re;   
                 f1_w5[31:16]<=w5_re;   
                 f1_w6[31:16]<=w6_re;   
                 f1_w7[31:16]<=w7_re;
                 f1_w1[15:0]<=w1_im;   
                 f1_w2[15:0]<=w2_im;   
                 f1_w3[15:0]<=w3_im;   
                 f1_w4[15:0]<=w4_im;   
                 f1_w5[15:0]<=w5_im;   
                 f1_w6[15:0]<=w6_im;   
                 f1_w7[15:0]<=w7_im;

                 f2_w1[31:16]<=w1_re;   
                 f2_w2[31:16]<=w2_re;   
                 f2_w3[31:16]<=w3_re;   
                 f2_w4[31:16]<=w4_re;   
                 f2_w5[31:16]<=w5_re;   
                 f2_w6[31:16]<=w6_re;   
                 f2_w7[31:16]<=w7_re;
                 f2_w1[15:0]<=w1_im;   
                 f2_w2[15:0]<=w2_im;   
                 f2_w3[15:0]<=w3_im;   
                 f2_w4[15:0]<=w4_im;   
                 f2_w5[15:0]<=w5_im;   
                 f2_w6[15:0]<=w6_im;   
                 f2_w7[15:0]<=w7_im;

                 f3_w1[31:16]<=w1_re;   
                 f3_w2[31:16]<=w2_re;   
                 f3_w3[31:16]<=w3_re;   
                 f3_w4[31:16]<=w4_re;   
                 f3_w5[31:16]<=w5_re;   
                 f3_w6[31:16]<=w6_re;   
                 f3_w7[31:16]<=w7_re;
                 f3_w1[15:0]<=w1_im;   
                 f3_w2[15:0]<=w2_im;   
                 f3_w3[15:0]<=w3_im;   
                 f3_w4[15:0]<=w4_im;   
                 f3_w5[15:0]<=w5_im;   
                 f3_w6[15:0]<=w6_im;   
                 f3_w7[15:0]<=w7_im;

                 f4_w1[31:16]<=w1_re;   
                 f4_w2[31:16]<=w2_re;   
                 f4_w3[31:16]<=w3_re;   
                 f4_w4[31:16]<=w4_re;   
                 f4_w5[31:16]<=w5_re;   
                 f4_w6[31:16]<=w6_re;   
                 f4_w7[31:16]<=w7_re;
                 f4_w1[15:0]<=w1_im;   
                 f4_w2[15:0]<=w2_im;   
                 f4_w3[15:0]<=w3_im;   
                 f4_w4[15:0]<=w4_im;   
                 f4_w5[15:0]<=w5_im;   
                 f4_w6[15:0]<=w6_im;   
                 f4_w7[15:0]<=w7_im;
             case (cnt1)
                    1'd0:begin
                        f1_data0[55:28]<=$signed(douta[59:32]);
                        f1_data0[27:0] <=$signed(douta[27:0] );
                        f2_data0[55:28]<=$signed(douta[123:96]);
                        f2_data0[27:0] <=$signed(douta[91:64] );
                        f3_data0[55:28]<=$signed(douta[187:160]);
                        f3_data0[27:0] <=$signed(douta[155:128] );
                        f4_data0[55:28]<=$signed(douta[251:224]);
                        f4_data0[27:0] <=$signed(douta[219:192] );
                    end
                    2'd1:begin
                        f1_data1[55:28]<=$signed(douta[59:32]);
                        f1_data1[27:0] <=$signed(douta[27:0] );
                        f2_data1[55:28]<=$signed(douta[123:96]);
                        f2_data1[27:0] <=$signed(douta[91:64] );
                        f3_data1[55:28]<=$signed(douta[187:160]);
                        f3_data1[27:0] <=$signed(douta[155:128] );
                        f4_data1[55:28]<=$signed(douta[251:224]);
                        f4_data1[27:0] <=$signed(douta[219:192] ); 
                    end
                    2'd2:begin
                        f1_data2[55:28]<=$signed(douta[59:32]);
                        f1_data2[27:0] <=$signed(douta[27:0] );
                        f2_data2[55:28]<=$signed(douta[123:96]);
                        f2_data2[27:0] <=$signed(douta[91:64] );
                        f3_data2[55:28]<=$signed(douta[187:160]);
                        f3_data2[27:0] <=$signed(douta[155:128] );
                        f4_data2[55:28]<=$signed(douta[251:224]);
                        f4_data2[27:0] <=$signed(douta[219:192] );
                    end
                    2'd3:begin
                        f1_data3[55:28]<=$signed(douta[59:32]);
                        f1_data3[27:0] <=$signed(douta[27:0] );
                        f2_data3[55:28]<=$signed(douta[123:96]);
                        f2_data3[27:0] <=$signed(douta[91:64] );
                        f3_data3[55:28]<=$signed(douta[187:160]);
                        f3_data3[27:0] <=$signed(douta[155:128] );
                        f4_data3[55:28]<=$signed(douta[251:224]);
                        f4_data3[27:0] <=$signed(douta[219:192] );
                    end
                    'd4:begin
                        f1_data4[55:28]<=$signed(douta[59:32]);
                        f1_data4[27:0] <=$signed(douta[27:0] );
                        f2_data4[55:28]<=$signed(douta[123:96]);
                        f2_data4[27:0] <=$signed(douta[91:64] );
                        f3_data4[55:28]<=$signed(douta[187:160]);
                        f3_data4[27:0] <=$signed(douta[155:128] );
                        f4_data4[55:28]<=$signed(douta[251:224]);
                        f4_data4[27:0] <=$signed(douta[219:192] );
                    end
                    'd5:begin
                        f1_data5[55:28]<=$signed(douta[59:32]);
                        f1_data5[27:0] <=$signed(douta[27:0] );
                        f2_data5[55:28]<=$signed(douta[123:96]);
                        f2_data5[27:0] <=$signed(douta[91:64] );
                        f3_data5[55:28]<=$signed(douta[187:160]);
                        f3_data5[27:0] <=$signed(douta[155:128] );
                        f4_data5[55:28]<=$signed(douta[251:224]);
                        f4_data5[27:0] <=$signed(douta[219:192] );
                    end
                    'd6:begin
                        f1_data6[55:28]<=$signed(douta[59:32]);
                        f1_data6[27:0] <=$signed(douta[27:0] );
                        f2_data6[55:28]<=$signed(douta[123:96]);
                        f2_data6[27:0] <=$signed(douta[91:64] );
                        f3_data6[55:28]<=$signed(douta[187:160]);
                        f3_data6[27:0] <=$signed(douta[155:128] );
                        f4_data6[55:28]<=$signed(douta[251:224]);
                        f4_data6[27:0] <=$signed(douta[219:192] );
                    end
                    'd7:begin
                        f1_data7[55:28]<=$signed(douta[59:32]);
                        f1_data7[27:0] <=$signed(douta[27:0] );
                        f2_data7[55:28]<=$signed(douta[123:96]);
                        f2_data7[27:0] <=$signed(douta[91:64] );
                        f3_data7[55:28]<=$signed(douta[187:160]);
                        f3_data7[27:0] <=$signed(douta[155:128] );
                        f4_data7[55:28]<=$signed(douta[251:224]);
                        f4_data7[27:0] <=$signed(douta[219:192] );
                    end 
                     default:; 
                 endcase
             end
             else if(stage==2)begin
                case (mode)
                    2'd2:begin
                        //roation factor may affect
                        f1_w1[31:16]<=w1_re;   
                        f1_w2[31:16]<=w2_re;   
                        f1_w3[31:16]<=w3_re;   
                        f1_w4[31:16]<=w4_re;   
                        f1_w5[31:16]<=w5_re;   
                        f1_w6[31:16]<=w6_re;   
                        f1_w7[31:16]<=w7_re;
                        f1_w1[15:0]<=w1_im;   
                        f1_w2[15:0]<=w2_im;   
                        f1_w3[15:0]<=w3_im;   
                        f1_w4[15:0]<=w4_im;   
                        f1_w5[15:0]<=w5_im;   
                        f1_w6[15:0]<=w6_im;   
                        f1_w7[15:0]<=w7_im;

                        f2_w1[31:16]<=w1_re;   
                        f2_w2[31:16]<=w2_re;   
                        f2_w3[31:16]<=w3_re;   
                        f2_w4[31:16]<=w4_re;   
                        f2_w5[31:16]<=w5_re;   
                        f2_w6[31:16]<=w6_re;   
                        f2_w7[31:16]<=w7_re;
                        f2_w1[15:0]<=w1_im;   
                        f2_w2[15:0]<=w2_im;   
                        f2_w3[15:0]<=w3_im;   
                        f2_w4[15:0]<=w4_im;   
                        f2_w5[15:0]<=w5_im;   
                        f2_w6[15:0]<=w6_im;   
                        f2_w7[15:0]<=w7_im;
                        case (cnt1[1:0])
                    1'd0:begin
                        f1_data0[55:28]<=$signed(douta[59:32]);
                        f1_data0[27:0] <=$signed(douta[27:0] );
                        f2_data0[55:28]<=$signed(douta[123:96]);
                        f2_data0[27:0] <=$signed(douta[91:64] );
                        f1_data1[55:28]<=$signed(douta[187:160]);
                        f1_data1[27:0] <=$signed(douta[155:128] );
                        f2_data1[55:28]<=$signed(douta[251:224]);
                        f2_data1[27:0] <=$signed(douta[219:192] );
                    end
                    2'd1:begin
                        f1_data2[55:28]<=$signed(douta[59:32]);
                        f1_data2[27:0] <=$signed(douta[27:0] );
                        f2_data2[55:28]<=$signed(douta[123:96]);
                        f2_data2[27:0] <=$signed(douta[91:64] );
                        f1_data3[55:28]<=$signed(douta[187:160]);
                        f1_data3[27:0] <=$signed(douta[155:128] );
                        f2_data3[55:28]<=$signed(douta[251:224]);
                        f2_data3[27:0] <=$signed(douta[219:192] ); 
                    end
                    2'd2:begin
                        f1_data4[55:28]<=$signed(douta[59:32]);
                        f1_data4[27:0] <=$signed(douta[27:0] );
                        f2_data4[55:28]<=$signed(douta[123:96]);
                        f2_data4[27:0] <=$signed(douta[91:64] );
                        f1_data5[55:28]<=$signed(douta[187:160]);
                        f1_data5[27:0] <=$signed(douta[155:128] );
                        f2_data5[55:28]<=$signed(douta[251:224]);
                        f2_data5[27:0] <=$signed(douta[219:192] );
                    end
                    2'd3:begin
                        f1_data6[55:28]<=$signed(douta[59:32]);
                        f1_data6[27:0] <=$signed(douta[27:0] );
                        f2_data6[55:28]<=$signed(douta[123:96]);
                        f2_data6[27:0] <=$signed(douta[91:64] );
                        f1_data7[55:28]<=$signed(douta[187:160]);
                        f1_data7[27:0] <=$signed(douta[155:128] );
                        f2_data7[55:28]<=$signed(douta[251:224]);
                        f2_data7[27:0] <=$signed(douta[219:192] );
                    end
                 endcase
                    end
                    default:begin
                 f1_w1[31:16]<=w1_re;   
                 f1_w2[31:16]<=w2_re;   
                 f1_w3[31:16]<=w3_re;   
                 f1_w4[31:16]<=w4_re;   
                 f1_w5[31:16]<=w5_re;   
                 f1_w6[31:16]<=w6_re;   
                 f1_w7[31:16]<=w7_re;
                 f1_w1[15:0]<=w1_im;   
                 f1_w2[15:0]<=w2_im;   
                 f1_w3[15:0]<=w3_im;   
                 f1_w4[15:0]<=w4_im;   
                 f1_w5[15:0]<=w5_im;   
                 f1_w6[15:0]<=w6_im;   
                 f1_w7[15:0]<=w7_im;

                 f2_w1[31:16]<=w1_re;   
                 f2_w2[31:16]<=w2_re;   
                 f2_w3[31:16]<=w3_re;   
                 f2_w4[31:16]<=w4_re;   
                 f2_w5[31:16]<=w5_re;   
                 f2_w6[31:16]<=w6_re;   
                 f2_w7[31:16]<=w7_re;
                 f2_w1[15:0]<=w1_im;   
                 f2_w2[15:0]<=w2_im;   
                 f2_w3[15:0]<=w3_im;   
                 f2_w4[15:0]<=w4_im;   
                 f2_w5[15:0]<=w5_im;   
                 f2_w6[15:0]<=w6_im;   
                 f2_w7[15:0]<=w7_im;

                 f3_w1[31:16]<=w1_re;   
                 f3_w2[31:16]<=w2_re;   
                 f3_w3[31:16]<=w3_re;   
                 f3_w4[31:16]<=w4_re;   
                 f3_w5[31:16]<=w5_re;   
                 f3_w6[31:16]<=w6_re;   
                 f3_w7[31:16]<=w7_re;
                 f3_w1[15:0]<=w1_im;   
                 f3_w2[15:0]<=w2_im;   
                 f3_w3[15:0]<=w3_im;   
                 f3_w4[15:0]<=w4_im;   
                 f3_w5[15:0]<=w5_im;   
                 f3_w6[15:0]<=w6_im;   
                 f3_w7[15:0]<=w7_im;

                 f4_w1[31:16]<=w1_re;   
                 f4_w2[31:16]<=w2_re;   
                 f4_w3[31:16]<=w3_re;   
                 f4_w4[31:16]<=w4_re;   
                 f4_w5[31:16]<=w5_re;   
                 f4_w6[31:16]<=w6_re;   
                 f4_w7[31:16]<=w7_re;
                 f4_w1[15:0]<=w1_im;   
                 f4_w2[15:0]<=w2_im;   
                 f4_w3[15:0]<=w3_im;   
                 f4_w4[15:0]<=w4_im;   
                 f4_w5[15:0]<=w5_im;   
                 f4_w6[15:0]<=w6_im;   
                 f4_w7[15:0]<=w7_im;
             case (cnt1)
                    1'd0:begin
                        f1_data0[55:28]<=$signed(douta[59:32]);
                        f1_data0[27:0] <=$signed(douta[27:0] );
                        f2_data0[55:28]<=$signed(douta[123:96]);
                        f2_data0[27:0] <=$signed(douta[91:64] );
                        f3_data0[55:28]<=$signed(douta[187:160]);
                        f3_data0[27:0] <=$signed(douta[155:128] );
                        f4_data0[55:28]<=$signed(douta[251:224]);
                        f4_data0[27:0] <=$signed(douta[219:192] );
                    end
                    2'd1:begin
                        f1_data1[55:28]<=$signed(douta[59:32]);
                        f1_data1[27:0] <=$signed(douta[27:0] );
                        f2_data1[55:28]<=$signed(douta[123:96]);
                        f2_data1[27:0] <=$signed(douta[91:64] );
                        f3_data1[55:28]<=$signed(douta[187:160]);
                        f3_data1[27:0] <=$signed(douta[155:128] );
                        f4_data1[55:28]<=$signed(douta[251:224]);
                        f4_data1[27:0] <=$signed(douta[219:192] ); 
                    end
                    2'd2:begin
                        f1_data2[55:28]<=$signed(douta[59:32]);
                        f1_data2[27:0] <=$signed(douta[27:0] );
                        f2_data2[55:28]<=$signed(douta[123:96]);
                        f2_data2[27:0] <=$signed(douta[91:64] );
                        f3_data2[55:28]<=$signed(douta[187:160]);
                        f3_data2[27:0] <=$signed(douta[155:128] );
                        f4_data2[55:28]<=$signed(douta[251:224]);
                        f4_data2[27:0] <=$signed(douta[219:192] );
                    end
                    2'd3:begin
                        f1_data3[55:28]<=$signed(douta[59:32]);
                        f1_data3[27:0] <=$signed(douta[27:0] );
                        f2_data3[55:28]<=$signed(douta[123:96]);
                        f2_data3[27:0] <=$signed(douta[91:64] );
                        f3_data3[55:28]<=$signed(douta[187:160]);
                        f3_data3[27:0] <=$signed(douta[155:128] );
                        f4_data3[55:28]<=$signed(douta[251:224]);
                        f4_data3[27:0] <=$signed(douta[219:192] );
                    end
                    'd4:begin
                        f1_data4[55:28]<=$signed(douta[59:32]);
                        f1_data4[27:0] <=$signed(douta[27:0] );
                        f2_data4[55:28]<=$signed(douta[123:96]);
                        f2_data4[27:0] <=$signed(douta[91:64] );
                        f3_data4[55:28]<=$signed(douta[187:160]);
                        f3_data4[27:0] <=$signed(douta[155:128] );
                        f4_data4[55:28]<=$signed(douta[251:224]);
                        f4_data4[27:0] <=$signed(douta[219:192] );
                    end
                    'd5:begin
                        f1_data5[55:28]<=$signed(douta[59:32]);
                        f1_data5[27:0] <=$signed(douta[27:0] );
                        f2_data5[55:28]<=$signed(douta[123:96]);
                        f2_data5[27:0] <=$signed(douta[91:64] );
                        f3_data5[55:28]<=$signed(douta[187:160]);
                        f3_data5[27:0] <=$signed(douta[155:128] );
                        f4_data5[55:28]<=$signed(douta[251:224]);
                        f4_data5[27:0] <=$signed(douta[219:192] );
                    end
                    'd6:begin
                        f1_data6[55:28]<=$signed(douta[59:32]);
                        f1_data6[27:0] <=$signed(douta[27:0] );
                        f2_data6[55:28]<=$signed(douta[123:96]);
                        f2_data6[27:0] <=$signed(douta[91:64] );
                        f3_data6[55:28]<=$signed(douta[187:160]);
                        f3_data6[27:0] <=$signed(douta[155:128] );
                        f4_data6[55:28]<=$signed(douta[251:224]);
                        f4_data6[27:0] <=$signed(douta[219:192] );
                    end
                    'd7:begin
                        f1_data7[55:28]<=$signed(douta[59:32]);
                        f1_data7[27:0] <=$signed(douta[27:0] );
                        f2_data7[55:28]<=$signed(douta[123:96]);
                        f2_data7[27:0] <=$signed(douta[91:64] );
                        f3_data7[55:28]<=$signed(douta[187:160]);
                        f3_data7[27:0] <=$signed(douta[155:128] );
                        f4_data7[55:28]<=$signed(douta[251:224]);
                        f4_data7[27:0] <=$signed(douta[219:192] );
                    end 
                     default:; 
                 endcase
                    end
                endcase
             end
             else  begin
                 case (mode)
                    1'd0:begin//4096
                        case (cnt1)
                     'd0:begin
                         f1_data0[55:28]<=$signed(douta[59:32]);
                         f1_data0[27:0] <=$signed(douta[27:0] );
                         f1_data1[55:28]<=$signed(douta[123:96]);
                         f1_data1[27:0] <=$signed(douta[91:64] );
                         f1_data2[55:28]<=$signed(douta[187:160]);
                         f1_data2[27:0] <=$signed(douta[155:128] );
                         f1_data3[55:28]<=$signed(douta[251:224]);
                         f1_data3[27:0] <=$signed(douta[219:192] );
                     end
                      'd1:begin
                         f1_data4[55:28]<=$signed(douta[59:32]);
                         f1_data4[27:0] <=$signed(douta[27:0] );
                         f1_data5[55:28]<=$signed(douta[123:96]);
                         f1_data5[27:0] <=$signed(douta[91:64] );
                         f1_data6[55:28]<=$signed(douta[187:160]);
                         f1_data6[27:0] <=$signed(douta[155:128] );
                         f1_data7[55:28]<=$signed(douta[251:224]);
                         f1_data7[27:0] <=$signed(douta[219:192] );

                         f1_w1[31:16]<=w1_re;   
                         f1_w2[31:16]<=w2_re;   
                         f1_w3[31:16]<=w3_re;   
                         f1_w4[31:16]<=w4_re;   
                         f1_w5[31:16]<=w5_re;   
                         f1_w6[31:16]<=w6_re;   
                         f1_w7[31:16]<=w7_re;
                         f1_w1[15:0]<=w1_im;   
                         f1_w2[15:0]<=w2_im;   
                         f1_w3[15:0]<=w3_im;   
                         f1_w4[15:0]<=w4_im;   
                         f1_w5[15:0]<=w5_im;   
                         f1_w6[15:0]<=w6_im;   
                         f1_w7[15:0]<=w7_im;
                     end
                     'd2:begin
                         f2_data0[55:28]<=$signed(douta[59:32]);
                         f2_data0[27:0] <=$signed(douta[27:0] );
                         f2_data1[55:28]<=$signed(douta[123:96]);
                         f2_data1[27:0] <=$signed(douta[91:64] );
                         f2_data2[55:28]<=$signed(douta[187:160]);
                         f2_data2[27:0] <=$signed(douta[155:128] );
                         f2_data3[55:28]<=$signed(douta[251:224]);
                         f2_data3[27:0] <=$signed(douta[219:192] );
                     end
                      'd3:begin
                         f2_data4[55:28]<=$signed(douta[59:32]);
                         f2_data4[27:0] <=$signed(douta[27:0] );
                         f2_data5[55:28]<=$signed(douta[123:96]);
                         f2_data5[27:0] <=$signed(douta[91:64] );
                         f2_data6[55:28]<=$signed(douta[187:160]);
                         f2_data6[27:0] <=$signed(douta[155:128] );
                         f2_data7[55:28]<=$signed(douta[251:224]);
                         f2_data7[27:0] <=$signed(douta[219:192] );

                         f2_w1[31:16]<=w1_re;   
                         f2_w2[31:16]<=w2_re;   
                         f2_w3[31:16]<=w3_re;   
                         f2_w4[31:16]<=w4_re;   
                         f2_w5[31:16]<=w5_re;   
                         f2_w6[31:16]<=w6_re;   
                         f2_w7[31:16]<=w7_re;
                         f2_w1[15:0]<=w1_im;   
                         f2_w2[15:0]<=w2_im;   
                         f2_w3[15:0]<=w3_im;   
                         f2_w4[15:0]<=w4_im;   
                         f2_w5[15:0]<=w5_im;   
                         f2_w6[15:0]<=w6_im;   
                         f2_w7[15:0]<=w7_im;
                     end
                     'd4:begin
                         f3_data0[55:28]<=$signed(douta[59:32]);
                         f3_data0[27:0] <=$signed(douta[27:0] );
                         f3_data1[55:28]<=$signed(douta[123:96]);
                         f3_data1[27:0] <=$signed(douta[91:64] );
                         f3_data2[55:28]<=$signed(douta[187:160]);
                         f3_data2[27:0] <=$signed(douta[155:128] );
                         f3_data3[55:28]<=$signed(douta[251:224]);
                         f3_data3[27:0] <=$signed(douta[219:192] );
                     end
                      'd5:begin
                         f3_data4[55:28]<=$signed(douta[59:32]);
                         f3_data4[27:0] <=$signed(douta[27:0] );
                         f3_data5[55:28]<=$signed(douta[123:96]);
                         f3_data5[27:0] <=$signed(douta[91:64] );
                         f3_data6[55:28]<=$signed(douta[187:160]);
                         f3_data6[27:0] <=$signed(douta[155:128] );
                         f3_data7[55:28]<=$signed(douta[251:224]);
                         f3_data7[27:0] <=$signed(douta[219:192] );

                         f3_w1[31:16]<=w1_re;   
                         f3_w2[31:16]<=w2_re;   
                         f3_w3[31:16]<=w3_re;   
                         f3_w4[31:16]<=w4_re;   
                         f3_w5[31:16]<=w5_re;   
                         f3_w6[31:16]<=w6_re;   
                         f3_w7[31:16]<=w7_re;
                         f3_w1[15:0]<=w1_im;   
                         f3_w2[15:0]<=w2_im;   
                         f3_w3[15:0]<=w3_im;   
                         f3_w4[15:0]<=w4_im;   
                         f3_w5[15:0]<=w5_im;   
                         f3_w6[15:0]<=w6_im;   
                         f3_w7[15:0]<=w7_im;
                     end
                     'd6:begin
                         f4_data0[55:28]<=$signed(douta[59:32]);
                         f4_data0[27:0] <=$signed(douta[27:0] );
                         f4_data1[55:28]<=$signed(douta[123:96]);
                         f4_data1[27:0] <=$signed(douta[91:64] );
                         f4_data2[55:28]<=$signed(douta[187:160]);
                         f4_data2[27:0] <=$signed(douta[155:128] );
                         f4_data3[55:28]<=$signed(douta[251:224]);
                         f4_data3[27:0] <=$signed(douta[219:192] );
                     end
                      'd7:begin
                         f4_data4[55:28]<=$signed(douta[59:32]);
                         f4_data4[27:0] <=$signed(douta[27:0] );
                         f4_data5[55:28]<=$signed(douta[123:96]);
                         f4_data5[27:0] <=$signed(douta[91:64] );
                         f4_data6[55:28]<=$signed(douta[187:160]);
                         f4_data6[27:0] <=$signed(douta[155:128] );
                         f4_data7[55:28]<=$signed(douta[251:224]);
                         f4_data7[27:0] <=$signed(douta[219:192] );
                         
                         f4_w1[31:16]<=w1_re;   
                         f4_w2[31:16]<=w2_re;   
                         f4_w3[31:16]<=w3_re;   
                         f4_w4[31:16]<=w4_re;   
                         f4_w5[31:16]<=w5_re;   
                         f4_w6[31:16]<=w6_re;   
                         f4_w7[31:16]<=w7_re;
                         f4_w1[15:0]<=w1_im;   
                         f4_w2[15:0]<=w2_im;   
                         f4_w3[15:0]<=w3_im;   
                         f4_w4[15:0]<=w4_im;   
                         f4_w5[15:0]<=w5_im;   
                         f4_w6[15:0]<=w6_im;   
                         f4_w7[15:0]<=w7_im;
                     end
                     default: ;
                 endcase
                    end
                    1'd1:begin
                         f1_data0[55:28]<=$signed(douta[59:32]);
                         f1_data0[27:0] <=$signed(douta[27:0] );
                         f1_data1[55:28]<=$signed(douta[123:96]);
                         f1_data1[27:0] <=$signed(douta[91:64] );
                         f1_data2[55:28]<=$signed(douta[187:160]);
                         f1_data2[27:0] <=$signed(douta[155:128] );
                         f1_data3[55:28]<=$signed(douta[251:224]);
                         f1_data3[27:0] <=$signed(douta[219:192] );
                         f1_w2[31:16]<=w2_re;    
                         f1_w4[31:16]<=w4_re;    
                         f1_w6[31:16]<=w6_re;    
                         f1_w2[15:0] <=w2_im;     
                         f1_w4[15:0] <=w4_im;      
                         f1_w6[15:0] <=w6_im; 
                     end
                     2'd2:begin
                        if(!cnt[0])
                        begin
                            f2_data0[55:28]<=$signed(douta[187:160]);
                            f2_data0[27:0] <=$signed(douta[155:128] );
                            f2_data1[55:28]<=$signed(douta[251:224]);
                            f2_data1[27:0] <=$signed(douta[219:192] );
                            f2_w4[31:16]<=w4_re;
                            f2_w4[15:0] <=w4_im;   
                        end
                        else begin
                            f1_data0[55:28]<=$signed(douta[59:32]);
                            f1_data0[27:0] <=$signed(douta[27:0] );
                            f1_data1[55:28]<=$signed(douta[123:96]);
                            f1_data1[27:0] <=$signed(douta[91:64] );
                            f1_w4[31:16]<=w4_re;
                            f1_w4[15:0] <=w4_im;  
                        end   
                     end
                    default:;//?
                 endcase
             end  
         end
     end
 always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
         dinb<=0;
     end
     else begin
        if (state==state5)dinb<=0;//stored in the last 255
        else if(on||web)begin
             if(stage==0||stage==1)begin
                 case (cnt2)
                     'd0:begin
                         dinb<={f4_x0,f3_x0,f2_x0,f1_x0};
                     end
                     'd1:begin
                         dinb<={f4_x1,f3_x1,f2_x1,f1_x1};
                     end
                     'd2:begin
                         dinb<={f4_x2,f3_x2,f2_x2,f1_x2};
                     end
                     'd3:begin
                         dinb<={f4_x3,f3_x3,f2_x3,f1_x3};
                     end
                     'd4:begin
                         dinb<={f4_x4,f3_x4,f2_x4,f1_x4};
                     end
                     'd5:begin
                         dinb<={f4_x5,f3_x5,f2_x5,f1_x5};
                     end
                     'd6:begin
                         dinb<={f4_x6,f3_x6,f2_x6,f1_x6};
                     end
                     'd7:begin
                         dinb<={f4_x7,f3_x7,f2_x7,f1_x7};
                     end 
                     default: ;
                 endcase
             end
             else if(stage==2)begin
                case (mode)
                    2'd2:begin
                        case (cnt2)
                            'd0:begin
                                dinb<={f2_x1,f1_x1,f2_x0,f1_x0};
                            end
                            'd1:begin
                                dinb<={f2_x3,f1_x3,f2_x2,f1_x2};
                            end
                            'd2:begin
                                dinb<={f2_x5,f1_x5,f2_x4,f1_x4};
                            end
                            'd3:begin
                                dinb<={f2_x7,f1_x7,f2_x6,f1_x6};
                            end
                            'd4:begin
                                dinb<={f2_x1,f1_x1,f2_x0,f1_x0};
                            end
                            'd5:begin
                                dinb<={f2_x3,f1_x3,f2_x2,f1_x2};
                            end
                            'd6:begin
                                dinb<={f2_x5,f1_x5,f2_x4,f1_x4};
                            end
                            'd7:begin
                                dinb<={f2_x7,f1_x7,f2_x6,f1_x6};
                            end 
                            default: ;
                        endcase
                    end 
                    default:begin
                        case (cnt2)
                            'd0:begin
                                dinb<={f4_x0,f3_x0,f2_x0,f1_x0};
                            end
                            'd1:begin
                                dinb<={f4_x1,f3_x1,f2_x1,f1_x1};
                            end
                            'd2:begin
                                dinb<={f4_x2,f3_x2,f2_x2,f1_x2};
                            end
                            'd3:begin
                                dinb<={f4_x3,f3_x3,f2_x3,f1_x3};
                            end
                            'd4:begin
                                dinb<={f4_x4,f3_x4,f2_x4,f1_x4};
                            end
                            'd5:begin
                                dinb<={f4_x5,f3_x5,f2_x5,f1_x5};
                            end
                            'd6:begin
                                dinb<={f4_x6,f3_x6,f2_x6,f1_x6};
                            end
                            'd7:begin
                                dinb<={f4_x7,f3_x7,f2_x7,f1_x7};
                            end 
                            default: ;
                        endcase
                    end 
                endcase
             end
             else begin
                //there should be case(mode)
               if(mode==0)begin
                 case (cnt2)
                     'd0:dinb<={f1_x3,f1_x2,f1_x1,f1_x0};
                     'd1:dinb<={f1_x7,f1_x6,f1_x5,f1_x4};
                     'd2:dinb<={f2_x3,f2_x2,f2_x1,f2_x0};
                     'd3:dinb<={f2_x7,f2_x6,f2_x5,f2_x4};
                     'd4:dinb<={f3_x3,f3_x2,f3_x1,f3_x0};
                     'd5:dinb<={f3_x7,f3_x6,f3_x5,f3_x4};
                     'd6:dinb<={f4_x3,f4_x2,f4_x1,f4_x0};
                     'd7:dinb<={f4_x7,f4_x6,f4_x5,f4_x4};  
                     default: ;
                 endcase
               end
               else if(mode==1)begin
                dinb <= {f1_x3_4,f1_x2_4,f1_x1_4,f1_x0_4};
               end
               else if(mode==2)begin
                dinb<= {f1_x3_2,f1_x2_2,f1_x1_2,f1_x0_2};
               end
               else begin
                dinb<=0;
               end
             end
         end
         else dinb<=dinb; 
     end
 end


 //set a cnt to control the "on" variable
// on is set to process the address_wr
reg ready;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)      on  <=  1'd0;
    else if(ready)  on  <=  1'd1;
    else            on  <=  1'd0;
end
//based on time 
//so different base leads to different time ,same base leads to same time
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        ready  <=  1'd0;
    end
    else begin
        if(stage < 2'd2)begin//for base 8
            if(cnt[3:0]==15)ready  <=  1'd1;
            else       ready  <=  1'd0;
        end
        else if(stage ==2'd2)begin
            if(mode[1])begin
                if(cnt[3:0]==11)ready  <=  1'd1;
                else            ready  <=  1'd0;
            end
            else begin
                if(cnt[3:0]==15)ready  <=  1'd1;
                else            ready  <=  1'd0;
            end
        end
        else if(stage == 2'd3)begin
            if(mode==1'd0)begin//for base 8
            //it's like the upper case,do it with base 8
            //but 8 just means the opration time alike
            // the trigger condition should be cnt==8
                if(cnt[3:0]==4'd9) ready  <=  1'd1;
                else               ready  <=  1'd0;
            end
            else if(mode==1'd1)begin
                //9-7=2,1 for the fft ,1 for the 1 clk delay of state6
                if(cnt[3:0]==3'd7) ready  <=  1'd1;
                else               ready  <=  1'd0;
            end
            else if(mode==2'd2)begin
                //7-6=1 1 for the fft
                if(cnt[3:0]==3'd6) ready  <=  1'd1;
                else               ready  <=  1'd0;
            end
            else begin
                ready <= 1'd0;
            end
        end
        else begin
            ready  <=  1'd0;
        end
    end
end
//the reason of stall is we can't assign 8 items in one clk , so we need to maintain the value for one clk 
//so we don't need to set stall for base 4 ans 2,just for base 8
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        stall<=4'b0000;
    end
    else begin
        if(stage < 2'd3)begin
            if(mode==2'd2&&stage==2'd2)begin
                if(cnt[1:0]==2'd3)begin
                    stall <= 4'b0000;
                end
                else begin
                    stall <= 4'b1111;
                end
            end
            else begin
            if (cnt[2:0]==0) begin
                stall <= 4'b1111;//stay
            end
            else if(cnt[2:0]==7)begin
                stall <= 4'b0000;//change   
            end
            else begin
                stall <= stall;
            end
            end
        end
        else begin
            if(mode==1'd0)begin
            if (cnt[2:0]==2) begin
                stall[0] <= 1;
            end
            else if(cnt[2:0]==1)begin
                stall[0] <= 0;   
            end
            else begin
                stall[0] <= stall[0];
            end

            if (cnt[2:0]==4) begin
                stall[1] <= 1;
            end
            else if(cnt[2:0]==3)begin
                stall[1] <= 0;   
            end
            else begin
                stall[1] <= stall[1];
            end

            if (cnt[2:0]==6) begin
                stall[2] <= 1;
            end
            else if(cnt[2:0]==5)begin
                stall[2] <= 0;   
            end
            else begin
                stall[2] <= stall[2];
            end

            if (cnt[2:0]==0) begin
                stall[3] <= 1;
            end
            else if(cnt[2:0]==7)begin
                stall[3] <= 0;   
            end
            else begin
                stall[3] <= stall[3];
            end
        end
        else if(mode==1'd1)begin
            stall <= 1'd0;
        end
        else if(mode==2'd2)begin
            stall <= 1'd0;
        end
        else begin
            stall <= 1'd0;
        end
        end
            end
end

//-------interrupt setting ---------------------
//delay one cycle for usr_ack

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      usr_irq_ack_1 <= 1'd0;
    end
    else begin
      usr_irq_ack_1 <= usr_irq_ack;
    end
end

// using state machine 
reg [1:0]irq_state;
localparam Waiting_for_syn = 2'b01;
localparam Waiting_for_ack = 2'b10;
assign ack = usr_irq_ack_1;

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    irq_state <= Waiting_for_syn;
  end
  else begin
    case(irq_state)
      Waiting_for_syn:begin
        if(syn) irq_state <= Waiting_for_ack;
        else    irq_state <= irq_state      ;
      end
      Waiting_for_ack:begin
        if(ack) irq_state <= Waiting_for_syn;
        else    irq_state <= irq_state      ;
      end
      default: irq_state <= Waiting_for_syn;
      endcase
  end
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    usr_irq_req <= 1'b0   ;
  end
  else begin
    case(irq_state)
    Waiting_for_syn:begin
      usr_irq_req <= 1'd0;
    end
    Waiting_for_ack:begin
      usr_irq_req <= 1'd1;
    end
    default: usr_irq_req <= 1'd0;
    endcase
  end
end



endmodule




