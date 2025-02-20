module bram_ctrl  (
    input                       clk             ,
    input                       rst_n           ,
    input                       fft_ing         ,
    input       [255:0]         doutb           ,
    output reg                  pc_select       ,
    output      [10:0]          addrb_bram_ctrl ,
    output reg                  fft_ifft        ,//"1"->ifft   '0'->fft
    output reg                  init_general    ,
    output reg  [3:0]           block_total     
);


//131071 ifft
//65535
//131072*block_total + 65535 = fft_flag_pc  
//131072*block_total + 131071 = fft_flag_pc  
// 65535,196607,327679,458751,589823,720895,851967
assign addrb_bram_ctrl              ='d896;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        pc_select           <=1'b1;
        init_general        <=1'b0;
        fft_ifft            <=1'b0;
        block_total         <=1'd0;
    end
    else begin
         if(!fft_ing) begin//when fft_ing =0 结束后才有可能改变mode与ifft 
            if(&doutb[15:0]) begin
            //作高位更好，因为低位容易变化
                pc_select           <= 1'b0;
            end
            else begin
                pc_select           <= 1'b1;
            end
            if((pc_select)&&(&doutb[15:0]))begin
              init_general        <= 1'b1;
            end
            else begin
              init_general        <= 1'b0;
            end
            if(doutb[16])
                fft_ifft            <= 1'b1;
            else 
                fft_ifft            <= 1'b0;
            case (doutb[20:17])
                1'd0:block_total  <= 1'd0 ;
                1'd1:block_total  <= 1'd1 ;
                2'd2:block_total  <= 2'd2 ;
                2'd3:block_total  <= 2'd3 ;
                3'd4:block_total  <= 3'd4 ;
                3'd5:block_total  <= 3'd5 ;
                3'd6:block_total  <= 3'd6 ;
                // 3'd7:block_total  <= 3'd7 ;
                // 4'd8:block_total  <= 4'd8 ;
                // 4'd9:block_total  <= 4'd9 ;
                // 4'd10:block_total <= 4'd10;
                // 4'd11:block_total <= 4'd11;
                // 4'd12:block_total <= 4'd12;
                // 4'd13:block_total <= 4'd13;
                default: block_total <= 0;
            endcase 
        end
        else begin
        pc_select                   <= 1'd0;
        init_general                <= 1'd0;
        fft_ifft                    <= fft_ifft   ;
        block_total                 <= block_total;
        end
    end
end
endmodule