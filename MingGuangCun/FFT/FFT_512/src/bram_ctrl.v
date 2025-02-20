module bram_ctrl  (
    input                       clk             ,
    input                       rst_n           ,
    input                       fft_ing         ,
    input       [255:0]         doutb           ,
    output reg                  pc_select       ,
    output      [10:0]          addrb_bram_ctrl ,
    output reg                  fft_ifft        ,//"1"->ifft   '0'->fft
    output reg                  init_general
);
/*----mode---
0->4096
1->2048
2->1024
----------*/
/*
3+  64*15(init)  +   4*3(ifft)   +16*0 4096   =15+960 =975
                                 +16*1 2048   =31+960 =991
                                 +16*2 1024   =47+960 =1007
                 +   4*0(fft )   +16*0 4096   =3 +960 =963
                                 +16*1 2048   =19+960 =979
                                 +16*2 1024   =35+960 =995
*/
assign addrb_bram_ctrl              =11'd1024;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        pc_select           <=1'b1;
        init_general        <=1'b0;
        fft_ifft            <=1'b0;
    end
    else begin
         if(!fft_ing) begin//when fft_ing =0 结束后才有可能改变mode与ifft 
            if(&{doutb[1:0],doutb[9:6]}) begin//modified to 3 to avoid other num &[1:0]=1
            //作高位更好，因为低位容易变化
                pc_select           <= 1'b0;
                init_general        <= 1'b1;
            end
            else begin
                pc_select           <= 1'b1;
                init_general        <= 1'b0;
            end
            if(&doutb[3:2])
                fft_ifft            <= 1'b1;
            else 
                fft_ifft            <= 1'b0;
        end
        else begin
        pc_select                   <= 1'd0;
        init_general                <= 1'd0;
        fft_ifft                    <= fft_ifft;
        end
    end
end
endmodule