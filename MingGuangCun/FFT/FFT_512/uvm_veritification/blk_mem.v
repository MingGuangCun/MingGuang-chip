module blk_mem (
    input clka,
    input wea,      
    input [10:0]addra,  
    input [255:0]dina,    
    output reg [255:0]douta,  
    input clkb,
    input web,      
    input [10:0]addrb,  
    input [255:0]dinb,    
    output reg[255:0]doutb  
);
reg [255:0] RAM [1024:0];         //DATAWIDTH = 16, DEPTH = 256 = 2^8
//32*2*512*8 bit /256 = 1024 ->depth 1024 is ok
always @(posedge clka) begin     
        if(wea) begin
            RAM[addra] <= dina;
        end
        douta <= RAM[addra];
end

always @(posedge clkb) begin     
        if(web) begin
            RAM[addrb] <= dinb;
        end
        doutb <= RAM[addrb];
end 
endmodule