module                fft_512
// `define RAM_DATA_WIDTH 256
// `define RAM_ADDR_WIDTH 11
// `define DATA_WIDTH 28 
// `define W_WIDTH 16
// `define FFT_ANS_WIDTH 32 
// `define BORDER_ADDR 8'd128
`include "fft_header.v"
(//when mode=11 do 4096 ,mode=10 do 1024 ,mode=01 do 2048 ,mode=00 do 4096
    input                           clk                  ,
    input                           rst_n                ,
    input                           init_general         ,
    input                           ifft                 ,//when ifft=1 do ifft
    input      [3:0]                block_total          ,
    input      [`RAM_DATA_WIDTH-1:0]douta                ,
    output  reg[`RAM_ADDR_WIDTH-1:0]addra                ,
    output  reg                     web                  ,
    output  reg[`RAM_ADDR_WIDTH-1:0]addrb                ,
    output  reg[`RAM_DATA_WIDTH-1:0]dinb                 ,
    output  reg                     fft_ing  
    `ifdef MSI_ENABLE            
    ,input                           usr_irq_ack          
    ,output  reg                     usr_irq_req       
    `endif    
);
// optimize the distribution of always block 
//0,512,...,512*7,64,64+512,....,64+512*7
//...,64*7,64*7+512,.....,64*7+512*7,
//8,8+512,...,8+512*7,8+64,8+64+512,....,8+64+512*7

//------------interrupt settings------------- 
`ifdef MSI_ENABLE
reg usr_irq_ack_1;//异步信号，缓存一拍
reg usr_irq_ack_2;//异步信号，缓存一拍
reg usr_irq_ack_3;//异步信号，缓存一拍
reg syn          ;
wire ack         ;
`endif
//-----------normal settings -------------------
reg [3:0]stall;
reg ifft_reg;//default : enable fft
//---------------------------------------
//set for state machine
localparam state0  =  5'b00001;
localparam state1  =  5'b00010;
localparam state2  =  5'b00100;
localparam state3  =  5'b01000;
localparam state4  =  5'b10000;
//-------------------------------------------
reg [2:0]stage;
reg [2*`DATA_WIDTH-1:0]f1_data0;
reg [2*`DATA_WIDTH-1:0]f1_data1;
reg [2*`DATA_WIDTH-1:0]f1_data2;
reg [2*`DATA_WIDTH-1:0]f1_data3;
reg [2*`DATA_WIDTH-1:0]f1_data4;
reg [2*`DATA_WIDTH-1:0]f1_data5;
reg [2*`DATA_WIDTH-1:0]f1_data6;
reg [2*`DATA_WIDTH-1:0]f1_data7;
reg [2*`W_WIDTH-1:0]f1_w1   ;
reg [2*`W_WIDTH-1:0]f1_w2   ;
reg [2*`W_WIDTH-1:0]f1_w3   ;
reg [2*`W_WIDTH-1:0]f1_w4   ;
reg [2*`W_WIDTH-1:0]f1_w5   ;
reg [2*`W_WIDTH-1:0]f1_w6   ;
reg [2*`W_WIDTH-1:0]f1_w7   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x0   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x1   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x2   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x3   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x4   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x5   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x6   ;
wire [2*`FFT_ANS_WIDTH-1:0]f1_x7   ;
 //----------------------instantiation --------------------------
 
//-------------- fft_8 dut -----------------------
 fft_8 f1(
.clk   (clk     ) ,
.ifft  (ifft_reg) ,
.data0 (f1_data0) ,
.data1 (f1_data1) ,
.data2 (f1_data2) ,
.data3 (f1_data3) ,
.data4 (f1_data4) ,
.data5 (f1_data5) ,
.data6 (f1_data6) ,
.data7 (f1_data7) ,
.w1    (f1_w1   ) ,
.w2    (f1_w2   ) ,
.w3    (f1_w3   ) ,
.w4    (f1_w4   ) ,
.w5    (f1_w5   ) ,
.w6    (f1_w6   ) ,
.w7    (f1_w7   ) ,
.x0    (f1_x0   ) ,
.x1    (f1_x1   ) ,
.x2    (f1_x2   ) ,
.x3    (f1_x3   ) ,
.x4    (f1_x4   ) ,
.x5    (f1_x5   ) ,
.x6    (f1_x6   ) ,
.x7    (f1_x7   ) ,
.stall (stall[0])
);
 
reg [2*`DATA_WIDTH-1:0]f2_data0;
reg [2*`DATA_WIDTH-1:0]f2_data1;
reg [2*`DATA_WIDTH-1:0]f2_data2;
reg [2*`DATA_WIDTH-1:0]f2_data3;
reg [2*`DATA_WIDTH-1:0]f2_data4;
reg [2*`DATA_WIDTH-1:0]f2_data5;
reg [2*`DATA_WIDTH-1:0]f2_data6;
reg [2*`DATA_WIDTH-1:0]f2_data7;
reg [2*`W_WIDTH-1:0]f2_w1   ;
reg [2*`W_WIDTH-1:0]f2_w2   ;
reg [2*`W_WIDTH-1:0]f2_w3   ;
reg [2*`W_WIDTH-1:0]f2_w4   ;
reg [2*`W_WIDTH-1:0]f2_w5   ;
reg [2*`W_WIDTH-1:0]f2_w6   ;
reg [2*`W_WIDTH-1:0]f2_w7   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x0   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x1   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x2   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x3   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x4   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x5   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x6   ;
wire [2*`FFT_ANS_WIDTH-1:0]f2_x7   ;

//-------------- fft_8 dut -----------------------
 fft_8 f2(
.clk   (clk     ) ,
.ifft  (ifft_reg) ,
.data0 (f2_data0) ,
.data1 (f2_data1) ,
.data2 (f2_data2) ,
.data3 (f2_data3) ,
.data4 (f2_data4) ,
.data5 (f2_data5) ,
.data6 (f2_data6) ,
.data7 (f2_data7) ,
.w1    (f2_w1   ) ,
.w2    (f2_w2   ) ,
.w3    (f2_w3   ) ,
.w4    (f2_w4   ) ,
.w5    (f2_w5   ) ,
.w6    (f2_w6   ) ,
.w7    (f2_w7   ) ,
.x0    (f2_x0   ) ,
.x1    (f2_x1   ) ,
.x2    (f2_x2   ) ,
.x3    (f2_x3   ) ,
.x4    (f2_x4   ) ,
.x5    (f2_x5   ) ,
.x6    (f2_x6   ) ,
.x7    (f2_x7   ) ,
.stall (stall[1])
);

reg [2*`DATA_WIDTH-1:0]f3_data0;
reg [2*`DATA_WIDTH-1:0]f3_data1;
reg [2*`DATA_WIDTH-1:0]f3_data2;
reg [2*`DATA_WIDTH-1:0]f3_data3;
reg [2*`DATA_WIDTH-1:0]f3_data4;
reg [2*`DATA_WIDTH-1:0]f3_data5;
reg [2*`DATA_WIDTH-1:0]f3_data6;
reg [2*`DATA_WIDTH-1:0]f3_data7;
reg [2*`W_WIDTH-1:0]f3_w1   ;
reg [2*`W_WIDTH-1:0]f3_w2   ;
reg [2*`W_WIDTH-1:0]f3_w3   ;
reg [2*`W_WIDTH-1:0]f3_w4   ;
reg [2*`W_WIDTH-1:0]f3_w5   ;
reg [2*`W_WIDTH-1:0]f3_w6   ;
reg [2*`W_WIDTH-1:0]f3_w7   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x0   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x1   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x2   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x3   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x4   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x5   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x6   ;
wire [2*`FFT_ANS_WIDTH-1:0]f3_x7   ;

//-------------- fft_8 dut -----------------------
 fft_8 f3(
.clk   (clk     ) ,
.ifft  (ifft_reg) ,
.data0 (f3_data0) ,
.data1 (f3_data1) ,
.data2 (f3_data2) ,
.data3 (f3_data3) ,
.data4 (f3_data4) ,
.data5 (f3_data5) ,
.data6 (f3_data6) ,
.data7 (f3_data7) ,
.w1    (f3_w1   ) ,
.w2    (f3_w2   ) ,
.w3    (f3_w3   ) ,
.w4    (f3_w4   ) ,
.w5    (f3_w5   ) ,
.w6    (f3_w6   ) ,
.w7    (f3_w7   ) ,
.x0    (f3_x0   ) ,
.x1    (f3_x1   ) ,
.x2    (f3_x2   ) ,
.x3    (f3_x3   ) ,
.x4    (f3_x4   ) ,
.x5    (f3_x5   ) ,
.x6    (f3_x6   ) ,
.x7    (f3_x7   ) ,
.stall (stall[2]) 
);

reg [2*`DATA_WIDTH-1:0]f4_data0;
reg [2*`DATA_WIDTH-1:0]f4_data1;
reg [2*`DATA_WIDTH-1:0]f4_data2;
reg [2*`DATA_WIDTH-1:0]f4_data3;
reg [2*`DATA_WIDTH-1:0]f4_data4;
reg [2*`DATA_WIDTH-1:0]f4_data5;
reg [2*`DATA_WIDTH-1:0]f4_data6;
reg [2*`DATA_WIDTH-1:0]f4_data7;
reg [2*`W_WIDTH-1:0]f4_w1   ;
reg [2*`W_WIDTH-1:0]f4_w2   ;
reg [2*`W_WIDTH-1:0]f4_w3   ;
reg [2*`W_WIDTH-1:0]f4_w4   ;
reg [2*`W_WIDTH-1:0]f4_w5   ;
reg [2*`W_WIDTH-1:0]f4_w6   ;
reg [2*`W_WIDTH-1:0]f4_w7   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x0   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x1   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x2   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x3   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x4   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x5   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x6   ;
wire [2*`FFT_ANS_WIDTH-1:0]f4_x7   ;

//-------------- fft_8 dut -----------------------
 fft_8 f4(
.clk   (clk     ) ,
.ifft  (ifft_reg) ,
.data0 (f4_data0) ,
.data1 (f4_data1) ,
.data2 (f4_data2) ,
.data3 (f4_data3) ,
.data4 (f4_data4) ,
.data5 (f4_data5) ,
.data6 (f4_data6) ,
.data7 (f4_data7) ,
.w1    (f4_w1   ) ,
.w2    (f4_w2   ) ,
.w3    (f4_w3   ) ,
.w4    (f4_w4   ) ,
.w5    (f4_w5   ) ,
.w6    (f4_w6   ) ,
.w7    (f4_w7   ) ,
.x0    (f4_x0   ) ,
.x1    (f4_x1   ) ,
.x2    (f4_x2   ) ,
.x3    (f4_x3   ) ,
.x4    (f4_x4   ) ,
.x5    (f4_x5   ) ,
.x6    (f4_x6   ) ,
.x7    (f4_x7   ) ,
.stall (stall[3])
);

//-----------rotation_factor--------------
reg [9:0]k;
wire[`W_WIDTH-1:0]w1_re;
wire[`W_WIDTH-1:0]w2_re;
wire[`W_WIDTH-1:0]w3_re;
wire[`W_WIDTH-1:0]w4_re;
wire[`W_WIDTH-1:0]w5_re;
wire[`W_WIDTH-1:0]w6_re;
wire[`W_WIDTH-1:0]w7_re;
wire[`W_WIDTH-1:0]w1_im;
wire[`W_WIDTH-1:0]w2_im;
wire[`W_WIDTH-1:0]w3_im;
wire[`W_WIDTH-1:0]w4_im;
wire[`W_WIDTH-1:0]w5_im;
wire[`W_WIDTH-1:0]w6_im;
wire[`W_WIDTH-1:0]w7_im;

rotation_factor_512 r2(
.clk  (clk  ) ,
.k    (k    ) ,
.stage(stage) ,
.x1_re(w1_re) ,
.x1_im(w1_im) ,
.x2_re(w2_re) ,
.x2_im(w2_im) ,
.x3_re(w3_re) ,
.x3_im(w3_im) ,
.x4_re(w4_re) ,
.x4_im(w4_im) ,
.x5_re(w5_re) ,
.x5_im(w5_im) ,
.x6_re(w6_re) ,
.x6_im(w6_im) ,
.x7_re(w7_re) ,
.x7_im(w7_im) 
);


//------------------some regs ---------------------
reg [4:0]state;
reg [6:0]cnt;//mod 128 cntmod16 +cntmod8 is better
reg [3:0]cnt1;
reg [3:0]cnt2;
reg cnt3;
reg [15:0]cnt4;
reg on;
reg k_en;
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


reg [3:0]block_now;//default : block num = 0
reg [3:0]block_total_reg;
reg [`RAM_ADDR_WIDTH-1:0]addrb_reg;
reg [`RAM_ADDR_WIDTH-1:0]addra_reg;
reg [`RAM_DATA_WIDTH-1:0]douta_reg;
//state transform
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        state             <= state0;
        stage             <= 0     ;
        fft_ing           <= 0     ;
        cnt4              <= 0     ;
        ifft_reg          <= 0     ;
        block_total_reg   <= 0     ;
    end
    else begin
        case (state)
            state0: begin
                cnt4   <= 0     ;
                case(init_general)
                0:begin
                    state   <= state0;
                    stage   <= 1'd0  ;
                    fft_ing <= 0     ;
                end
                1:begin
                    state           <= state1;
                    fft_ing         <= 1     ;
                    ifft_reg        <= ifft  ;
                    block_total_reg <= block_total;
                end
                endcase
            end
            state1:begin
            cnt4 <= cnt4 +1'd1;
                if(addrb[6:0]==`BORDER_ADDR-1)
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
            cnt4 <= cnt4 +1'd1;
                if(addrb[6:0]==`BORDER_ADDR-1)
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
            cnt4 <= cnt4 +1'd1;
                if(addrb[6:0]==`BORDER_ADDR-1)
                     begin
                        if(block_now < block_total_reg)begin
                            state     <= state1       ;
                            stage     <= 1'd0         ;
                        end
                        else begin
                            state <= state4;
                            stage <= 2'd3  ;
                        end
                    end
                else begin
                        state <= state;
                        stage <= stage;
                end 
            end
            state4:begin
                if(cnt==2'd2)begin
                    state     <= state0;
                    fft_ing   <= 0     ;
                end
            end
        endcase
    end
end

//RAM data/addr register
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        addra <= 1'd0;
        addrb <= 1'd0;
        douta_reg <= 1'd0;
    end
    else begin
        //------for ADDR-------
        case (block_now)
            0:begin
                addra <= addra_reg;
                addrb <= addrb_reg;
            end
            1:begin
                addra <= addra_reg + 128;
                addrb <= addrb_reg + 128;
            end 
            2:begin
                addra <= addra_reg + 128*2;
                addrb <= addrb_reg + 128*2;
            end 
            3:begin
                addra <= addra_reg + 128*3;
                addrb <= addrb_reg + 128*3;
            end 
            4:begin
                addra <= addra_reg + 128*4;
                addrb <= addrb_reg + 128*4;
            end 
            5:begin
                addra <= addra_reg + 128*5;
                addrb <= addrb_reg + 128*5;
            end 
            6:begin
                addra <= addra_reg + 128*6;
                addrb <= addrb_reg + 128*6;
            end 
            // 7:begin
            //     addra <= addra_reg + 128*7;
            //     addrb <= addrb_reg + 128*7;
            // end 
            // 8:begin
            //     addra <= addra_reg + 128*8;
            //     addrb <= addrb_reg + 128*8;
            // end 
            // 9:begin
            //     addra <= addra_reg + 128*9;
            //     addrb <= addrb_reg + 128*9;
            // end 
            // 10:begin
            //     addra <= addra_reg + 128*10;
            //     addrb <= addrb_reg + 128*10;
            // end 
            // 11:begin
            //     addra <= addra_reg + 128*11;
            //     addrb <= addrb_reg + 128*11;
            // end 
            // 12:begin
            //     addra <= addra_reg + 128*12;
            //     addrb <= addrb_reg + 128*12;
            // end 
            // 13:begin
            //     addra <= addra_reg + 128*13;
            //     addrb <= addrb_reg + 128*13;
            // end 
        endcase
        //------for DATA------- 
        douta_reg <= douta;
    end
end
//address transform
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt         <= 0;
        cnt1        <= 0;
        cnt2        <= 0;
        cnt3        <= 0;
        addra_reg   <= 0;
        addrb_reg   <= 0;
        web         <= 0;
        k_en        <= 0;
        block_now   <= 0;
    end
    else begin
        case (state)
            state0:begin
                cnt        <=  0 ;
                cnt1       <=  0 ;
                cnt2       <=  0 ;
                cnt3       <=  0 ;
                addra_reg  <=  0 ;
                addrb_reg  <=  0 ;
                web        <=  0 ;
                k_en       <=  0 ;
                block_now  <=  0 ;
            end 
            state1:begin
                k_en <= 0;
                if(addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt <= 1'd0;
                     end
                else begin
                        cnt <= cnt + 1'd1;
                end
                if (addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt1  <= 0;
                        addra_reg <= 0;
                end
                else begin 
                    if(&addra_reg[6:4])      addra_reg <= addra_reg - 7'd112 + 1'd1;
                    else                     addra_reg <= addra_reg + 5'd16        ;
                     // to optimize the timing ,
                     //we need to insert two register
                     //thus lengthen the time to wait
                    if (cnt1 == 3'd7)  cnt1 <= 0       ;
                    else               cnt1 <= cnt1 + 1;
                 end
                 if(on||web)begin
                     if(addrb[6:0]==`BORDER_ADDR-1)
                     begin 
                        web   <= 0;
                        addrb_reg <= 0;
                        cnt2  <= 0;
                    end
					else begin
                        web   <= 1'd1;
                        if (cnt2 == 'd7)    cnt2 <= 1'd0     ; 
                        else                cnt2 <= cnt2+1'd1;
                        if(&addrb_reg[6:4]) addrb_reg <= addrb_reg - 7'd112 + 1'd1;
                        else                addrb_reg <= addrb_reg + 5'd16        ;
                     end
             end
            end
            state2:begin
                k_en <= 0;
                cnt3  <= 0;
                if(addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt <= 1'd0;
                     end
                else begin
                        cnt <= cnt + 1'd1;
                end
                if (addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt1  <= 0;
                        addra_reg <= 0;
                end
                else begin 

                    if     (addra_reg[3:0]==4'd15)        addra_reg <= addra_reg + 1'd1         ; 
                    else if(addra_reg[3:0]==4'd14)        addra_reg <= addra_reg - 4'd14 + 1'd1 ;
                    else                                  addra_reg <= addra_reg + 2'd2         ;

                    if  (cnt1==3'd7)    cnt1 <= 0;
                    else                cnt1 <= cnt1+1;
                 end
                 if(on||web)begin
                     if(addrb[6:0]==`BORDER_ADDR-1)
                     begin
                        web   <= 0;
                        addrb_reg <= 0;
                        cnt2  <= 0;
                    end
					else begin
                        web  <=  1'd1;
                        if (cnt2==3'd7)   cnt2 <= 1'd0;
                        else              cnt2 <= cnt2 + 1'd1;
                        if     (addrb_reg[3:0]==4'd15)          addrb_reg <= addrb_reg + 1'd1        ;
                        else if(addrb_reg[3:0]==4'd14)          addrb_reg <= addrb_reg - 4'd14 + 1'd1;
                        else                                    addrb_reg <= addrb_reg + 2'd2        ;
                        end
                     end
            end
            state3:begin
                cnt3 <= ~cnt3;
                if(cnt==2)k_en = 1;
               if(addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt <= 1'd0;
                     end
                else begin
                        cnt <= cnt + 1'd1;
                end
                if (addrb[6:0]==`BORDER_ADDR-1) begin
                        cnt1  <= 0;
                        addra_reg <= 0;
                end
                else begin 
                    addra_reg <= addra_reg + 1;
                    if(cnt1==3'd7)  cnt1   <= 0       ;
                    else            cnt1   <= cnt1 + 1;
                 end
                 if(on||web)begin
                    if(addrb[6:0]==`BORDER_ADDR-1)
                    begin                 
                        if(block_now < block_total_reg)begin
                            addrb_reg <= 0;
                            web       <= 0;
                            block_now <= block_now + 1 ;
                        end
                        else begin
                            block_now <= 6   ;
                            addrb_reg <= 'd128;
                            web       <= 0    ;
                        end
                    end
					else begin
                        web <= 1'd1;
                        if (cnt2==3'd7)     cnt2 <= 0     ;
                        else                cnt2 <= cnt2+1;
                        addrb_reg <= addrb_reg + 1;
                    end
                end
            end
            state4:begin
                web  <= 1;
                cnt <= cnt + 1'd1;
                if(cnt==2'd2)begin
                    block_now <= 0;
                    end
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
                if(addrb[6:0]==`BORDER_ADDR-1)begin
                   k  <= 1'd0; 
                end
                else begin
                    if((cnt[3:0]==2)&&(cnt>16))     k <= k + 1 ;
                    else                            k <= k     ;
                end
            end
            state3:begin
                if(k_en)begin
                    if (cnt3)   begin
                        if(&k[5:3])
                        k  <=  k - 6'd55;
                        else 
                        k  <=  k + 4'd8;                     
                    end
                    else begin
                        k  <=  k;
                    end
                end
            end
            default: k  <=  1'd0;
        endcase
    end
end
 
 always @(posedge clk ) begin
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
                    3:begin
                        f1_data0[55:28]<=$signed(douta_reg[59:32]);
                        f1_data0[27:0] <=$signed(douta_reg[27:0] );
                        f2_data0[55:28]<=$signed(douta_reg[123:96]);
                        f2_data0[27:0] <=$signed(douta_reg[91:64] );
                        f3_data0[55:28]<=$signed(douta_reg[187:160]);
                        f3_data0[27:0] <=$signed(douta_reg[155:128] );
                        f4_data0[55:28]<=$signed(douta_reg[251:224]);
                        f4_data0[27:0] <=$signed(douta_reg[219:192] );
                    end
                    4:begin
                        f1_data1[55:28]<=$signed(douta_reg[59:32]);
                        f1_data1[27:0] <=$signed(douta_reg[27:0] );
                        f2_data1[55:28]<=$signed(douta_reg[123:96]);
                        f2_data1[27:0] <=$signed(douta_reg[91:64] );
                        f3_data1[55:28]<=$signed(douta_reg[187:160]);
                        f3_data1[27:0] <=$signed(douta_reg[155:128] );
                        f4_data1[55:28]<=$signed(douta_reg[251:224]);
                        f4_data1[27:0] <=$signed(douta_reg[219:192] ); 
                    end
                    5:begin
                        f1_data2[55:28]<=$signed(douta_reg[59:32]);
                        f1_data2[27:0] <=$signed(douta_reg[27:0] );
                        f2_data2[55:28]<=$signed(douta_reg[123:96]);
                        f2_data2[27:0] <=$signed(douta_reg[91:64] );
                        f3_data2[55:28]<=$signed(douta_reg[187:160]);
                        f3_data2[27:0] <=$signed(douta_reg[155:128] );
                        f4_data2[55:28]<=$signed(douta_reg[251:224]);
                        f4_data2[27:0] <=$signed(douta_reg[219:192] );
                    end
                    6:begin
                        f1_data3[55:28]<=$signed(douta_reg[59:32]);
                        f1_data3[27:0] <=$signed(douta_reg[27:0] );
                        f2_data3[55:28]<=$signed(douta_reg[123:96]);
                        f2_data3[27:0] <=$signed(douta_reg[91:64] );
                        f3_data3[55:28]<=$signed(douta_reg[187:160]);
                        f3_data3[27:0] <=$signed(douta_reg[155:128] );
                        f4_data3[55:28]<=$signed(douta_reg[251:224]);
                        f4_data3[27:0] <=$signed(douta_reg[219:192] );
                    end
                    7:begin
                        f1_data4[55:28]<=$signed(douta_reg[59:32]);
                        f1_data4[27:0] <=$signed(douta_reg[27:0] );
                        f2_data4[55:28]<=$signed(douta_reg[123:96]);
                        f2_data4[27:0] <=$signed(douta_reg[91:64] );
                        f3_data4[55:28]<=$signed(douta_reg[187:160]);
                        f3_data4[27:0] <=$signed(douta_reg[155:128] );
                        f4_data4[55:28]<=$signed(douta_reg[251:224]);
                        f4_data4[27:0] <=$signed(douta_reg[219:192] );
                    end
                    0:begin
                        f1_data5[55:28]<=$signed(douta_reg[59:32]);
                        f1_data5[27:0] <=$signed(douta_reg[27:0] );
                        f2_data5[55:28]<=$signed(douta_reg[123:96]);
                        f2_data5[27:0] <=$signed(douta_reg[91:64] );
                        f3_data5[55:28]<=$signed(douta_reg[187:160]);
                        f3_data5[27:0] <=$signed(douta_reg[155:128] );
                        f4_data5[55:28]<=$signed(douta_reg[251:224]);
                        f4_data5[27:0] <=$signed(douta_reg[219:192] );
                    end
                    1:begin
                        f1_data6[55:28]<=$signed(douta_reg[59:32]);
                        f1_data6[27:0] <=$signed(douta_reg[27:0] );
                        f2_data6[55:28]<=$signed(douta_reg[123:96]);
                        f2_data6[27:0] <=$signed(douta_reg[91:64] );
                        f3_data6[55:28]<=$signed(douta_reg[187:160]);
                        f3_data6[27:0] <=$signed(douta_reg[155:128] );
                        f4_data6[55:28]<=$signed(douta_reg[251:224]);
                        f4_data6[27:0] <=$signed(douta_reg[219:192] );
                    end
                    2:begin
                        f1_data7[55:28]<=$signed(douta_reg[59:32]);
                        f1_data7[27:0] <=$signed(douta_reg[27:0] );
                        f2_data7[55:28]<=$signed(douta_reg[123:96]);
                        f2_data7[27:0] <=$signed(douta_reg[91:64] );
                        f3_data7[55:28]<=$signed(douta_reg[187:160]);
                        f3_data7[27:0] <=$signed(douta_reg[155:128] );
                        f4_data7[55:28]<=$signed(douta_reg[251:224]);
                        f4_data7[27:0] <=$signed(douta_reg[219:192] );
                    end 
                 endcase
             end
             else begin
                case (cnt1)
                     'd3:begin
                         f1_data0[55:28]<=$signed(douta_reg[59:32]);
                         f1_data0[27:0] <=$signed(douta_reg[27:0] );
                         f1_data1[55:28]<=$signed(douta_reg[123:96]);
                         f1_data1[27:0] <=$signed(douta_reg[91:64] );
                         f1_data2[55:28]<=$signed(douta_reg[187:160]);
                         f1_data2[27:0] <=$signed(douta_reg[155:128] );
                         f1_data3[55:28]<=$signed(douta_reg[251:224]);
                         f1_data3[27:0] <=$signed(douta_reg[219:192] );
                     end
                      'd4:begin
                         f1_data4[55:28]<=$signed(douta_reg[59:32]);
                         f1_data4[27:0] <=$signed(douta_reg[27:0] );
                         f1_data5[55:28]<=$signed(douta_reg[123:96]);
                         f1_data5[27:0] <=$signed(douta_reg[91:64] );
                         f1_data6[55:28]<=$signed(douta_reg[187:160]);
                         f1_data6[27:0] <=$signed(douta_reg[155:128] );
                         f1_data7[55:28]<=$signed(douta_reg[251:224]);
                         f1_data7[27:0] <=$signed(douta_reg[219:192] );

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
                     'd5:begin
                         f2_data0[55:28]<=$signed(douta_reg[59:32]);
                         f2_data0[27:0] <=$signed(douta_reg[27:0] );
                         f2_data1[55:28]<=$signed(douta_reg[123:96]);
                         f2_data1[27:0] <=$signed(douta_reg[91:64] );
                         f2_data2[55:28]<=$signed(douta_reg[187:160]);
                         f2_data2[27:0] <=$signed(douta_reg[155:128] );
                         f2_data3[55:28]<=$signed(douta_reg[251:224]);
                         f2_data3[27:0] <=$signed(douta_reg[219:192] );
                     end
                      'd6:begin
                         f2_data4[55:28]<=$signed(douta_reg[59:32]);
                         f2_data4[27:0] <=$signed(douta_reg[27:0] );
                         f2_data5[55:28]<=$signed(douta_reg[123:96]);
                         f2_data5[27:0] <=$signed(douta_reg[91:64] );
                         f2_data6[55:28]<=$signed(douta_reg[187:160]);
                         f2_data6[27:0] <=$signed(douta_reg[155:128] );
                         f2_data7[55:28]<=$signed(douta_reg[251:224]);
                         f2_data7[27:0] <=$signed(douta_reg[219:192] );

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
                     'd7:begin
                         f3_data0[55:28]<=$signed(douta_reg[59:32]);
                         f3_data0[27:0] <=$signed(douta_reg[27:0] );
                         f3_data1[55:28]<=$signed(douta_reg[123:96]);
                         f3_data1[27:0] <=$signed(douta_reg[91:64] );
                         f3_data2[55:28]<=$signed(douta_reg[187:160]);
                         f3_data2[27:0] <=$signed(douta_reg[155:128] );
                         f3_data3[55:28]<=$signed(douta_reg[251:224]);
                         f3_data3[27:0] <=$signed(douta_reg[219:192] );
                     end
                      'd0:begin
                         f3_data4[55:28]<=$signed(douta_reg[59:32]);
                         f3_data4[27:0] <=$signed(douta_reg[27:0] );
                         f3_data5[55:28]<=$signed(douta_reg[123:96]);
                         f3_data5[27:0] <=$signed(douta_reg[91:64] );
                         f3_data6[55:28]<=$signed(douta_reg[187:160]);
                         f3_data6[27:0] <=$signed(douta_reg[155:128] );
                         f3_data7[55:28]<=$signed(douta_reg[251:224]);
                         f3_data7[27:0] <=$signed(douta_reg[219:192] );

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
                     'd1:begin
                         f4_data0[55:28]<=$signed(douta_reg[59:32]);
                         f4_data0[27:0] <=$signed(douta_reg[27:0] );
                         f4_data1[55:28]<=$signed(douta_reg[123:96]);
                         f4_data1[27:0] <=$signed(douta_reg[91:64] );
                         f4_data2[55:28]<=$signed(douta_reg[187:160]);
                         f4_data2[27:0] <=$signed(douta_reg[155:128] );
                         f4_data3[55:28]<=$signed(douta_reg[251:224]);
                         f4_data3[27:0] <=$signed(douta_reg[219:192] );
                     end
                      'd2:begin
                         f4_data4[55:28]<=$signed(douta_reg[59:32]);
                         f4_data4[27:0] <=$signed(douta_reg[27:0] );
                         f4_data5[55:28]<=$signed(douta_reg[123:96]);
                         f4_data5[27:0] <=$signed(douta_reg[91:64] );
                         f4_data6[55:28]<=$signed(douta_reg[187:160]);
                         f4_data6[27:0] <=$signed(douta_reg[155:128] );
                         f4_data7[55:28]<=$signed(douta_reg[251:224]);
                         f4_data7[27:0] <=$signed(douta_reg[219:192] );
                         
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
                 endcase
             end
         
     end
 always @(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
         dinb<=0;
     end
     else begin
        if (state==state4)dinb <= 4396;//control data
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
                 endcase
             end
             else begin
                //there should be case(mode)
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
         end
         else dinb<=0; 
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
            if(cnt[4:0]==17)ready  <=  1'd1;
            else            ready  <=  1'd0;
        end
        else if(stage == 2'd2)begin
            //it's like the upper case,do it with base 8
            //but 8 just means the opration time alike
            // the trigger condition should be cnt==8
                if(cnt[3:0]==4'd11) ready  <=  1'd1;
                else               ready  <=  1'd0;
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
        if(stage < 2'd2)begin
            if (cnt[2:0]==2) begin
                stall <= 4'b1111;//stay
            end
            else if(cnt[2:0]==1)begin
                stall <= 4'b0000;//change   
            end
            else begin
                stall <= stall;
            end
            end

        else begin
            if (cnt[2:0]==4) begin
                stall[0] <= 1;
            end
            else if(cnt[2:0]==3)begin
                stall[0] <= 0;   
            end
            else begin
                stall[0] <= stall[0];
            end

            if (cnt[2:0]==6) begin
                stall[1] <= 1;
            end
            else if(cnt[2:0]==5)begin
                stall[1] <= 0;   
            end
            else begin
                stall[1] <= stall[1];
            end

            if (cnt[2:0]==0) begin
                stall[2] <= 1;
            end
            else if(cnt[2:0]==7)begin
                stall[2] <= 0;   
            end
            else begin
                stall[2] <= stall[2];
            end

            if (cnt[2:0]==2) begin
                stall[3] <= 1;
            end
            else if(cnt[2:0]==1)begin
                stall[3] <= 0;   
            end
            else begin
                stall[3] <= stall[3];
            end
        end
    end
end


`ifdef MSI_ENABLE
//-------interrupt setting ---------------------
//delay one cycle for usr_ack

always@(posedge clk )begin
    usr_irq_ack_1 <= usr_irq_ack;
    usr_irq_ack_2 <= usr_irq_ack_1;
    usr_irq_ack_3 <= usr_irq_ack_2;
end

// using state machine 
reg [1:0]irq_state;
localparam Waiting_for_syn = 2'b01;
localparam Waiting_for_ack = 2'b10;
assign ack = usr_irq_ack_3;

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

`endif
endmodule




