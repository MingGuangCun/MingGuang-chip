`timescale 1ns/1ns
module fft_512_tb();

    reg clk=0;
    reg rst_n=0;
    reg init_general=0;
    reg ifft=0;
    reg [255:0]douta;
    reg [255:0]doutb;
    reg wea=0;
    wire web;
    wire [10:0]addra;
    wire [10:0]addrb;
    wire [255:0]dina;
    wire [255:0]dinb;
    wire fft_ing;
    reg [31:0]ram1[4095:0] ;
    reg [255:0]ram2[1024:0];
    wire [3:0]block_total;
    assign block_total = 4'd1;
    always#5 clk=~clk;
    initial begin
       //$readmemb("E:/fft/fft4096/fft4096/fft_date.txt",ram1);
    //    $readmemb("E:\fft\simulations\fft_data\test_fft_101_bin.txt",ram1);
       $readmemb("E:/fft/simulations/fft_data/test_fft_101_bin.txt",ram1);
    //    $readmemb("E:/fft/simulations/music_b.txt",ram1);
       //for ifft simulation

        //$readmemb("E:/fft/simulations/fft_data/test_1_error_data_ifft_bin.txt",ram1);
       //for fft simulation
       #100
       rst_n=1;
       #200
       init_general <= 1'd1;
       # 40000
       $stop();
    end

    genvar i;
        generate        
        for ( i = 0; i < 1024 ; i = i + 1) begin :ram2_to_ram1
        initial begin
            ram2[i][31:0]   <=$signed(ram1[4*i][15:0]);
            ram2[i][63:32]  <=$signed(ram1[4*i][31:16]);
            ram2[i][95:64]  <=$signed(ram1[4*i+1][15:0]);
            ram2[i][127:96] <=$signed(ram1[4*i+1][31:16]);
            ram2[i][159:128]<=$signed(ram1[4*i+2][15:0]);
            ram2[i][191:160]<=$signed(ram1[4*i+2][31:16]);
            ram2[i][223:192]<=$signed(ram1[4*i+3][15:0]);
            ram2[i][255:224]<=$signed(ram1[4*i+3][31:16]);
        end
        end
    endgenerate


    always @(posedge clk ) begin
       if(wea)begin
        ram2[addra]<=dina;
       end
       else begin
        douta<=ram2[addra];
       end
       if(web)begin
        ram2[addrb]<=dinb;
       end
       else begin
        doutb<=ram2[addrb];
       end
    end


    
    fft_512 f1 (
         .clk          (clk)
        ,.rst_n        (rst_n)      
        ,.init_general (init_general)
        ,.block_total  (block_total)
        ,.ifft         (ifft) 
        ,.douta        (douta) 
        ,.addra        (addra) 
        ,.web          (web) 
        ,.addrb        (addrb) 
        ,.dinb         (dinb) 
        ,.fft_ing      (fft_ing) 
    );

endmodule
