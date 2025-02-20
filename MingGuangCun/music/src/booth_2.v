module booth_2
#(
    parameter N         = 32                ,
    parameter O         = 32                ,
    parameter quantify  = 14                 //4096
)
(
    input                                      clk     ,
    input                                      rst_n   ,
    input                                      in_vld  ,
    input           signed      [O-1:0]        a       ,
    input           signed      [O-1:0]        b       ,
    output          signed      [O-1:0]        ans     ,
    output          reg                        out_vld
);


reg                                     vld_s1;
reg                                     vld_s2;
reg                                     vld_s3;
reg     signed        [O-1:0]           a1  ;
reg     signed        [O-1:0]           b1  ;
reg     signed        [O-1:0]           val ;
reg     signed        [O-1:0]           val_1;
reg     signed        [O-1:0]           val_2;
reg     signed        [O+15:0]          val_3;
reg     signed        [O+15:0]          val_4;
reg     signed        [O-1:0]           val_11;
reg     signed        [O+15:0]          val_21;
wire    signed        [N+14:0]          x1  ;
wire    signed        [N+12:0]          x2  ;
wire    signed        [N+10:0]          x3  ;
wire    signed        [N+8:0]           x4  ;
wire    signed        [N+6:0]           x5  ;
wire    signed        [N+4:0]           x6  ;
wire    signed        [N+2:0]           x7  ;
wire    signed        [N:0]             x8  ;

wire    signed        [N+16+14:0]       y1  ;
wire    signed        [N+16+12:0]       y2  ;
wire    signed        [N+16+10:0]       y3  ;
wire    signed        [N+16+8:0]        y4  ;
wire    signed        [N+16+6:0]        y5  ;
wire    signed        [N+16+4:0]        y6  ;
wire    signed        [N+16+2:0]        y7  ;
wire    signed        [N+16:0]          y8  ;


always @(posedge clk) begin
    if(rst_n) begin
        vld_s1                      <= 1'b0;
        vld_s2                      <= 1'b0;
        vld_s3                      <= 1'b0;
        out_vld                     <= 1'b0;
    end
    else begin
        vld_s1                      <= in_vld;
        vld_s2                      <= vld_s1;
        vld_s3                      <= vld_s2;
        out_vld                     <= vld_s3;
    end
end

always @(posedge clk) begin
    if(rst_n) begin
        a1              <= 'd0;
        b1              <= 'd0;
    end
    else if(in_vld) begin
        a1              <= a;
        b1              <= b;
    end
    else begin
        a1              <= a1;
        b1              <= b1;
    end
end

always @(posedge clk) begin
    if(rst_n) begin
        val_1           <= 'd0;
        val_2           <= 'd0;
    end
    else if(vld_s1) begin
        val_1           <= x1+x2+x3+x4;
        val_2           <= x5+x6+x7+x8;
        val_3           <= y1+y2+y3+y4;        
        val_4           <= y5+y6+y7+y8;
    end
    else begin
        val_1           <= val_1;
        val_2           <= val_2;
        val_3           <= val_3;
        val_4           <= val_4;       
    end
end
always @(posedge clk) begin
    if(rst_n) begin
        val_11           <= 'd0;
        val_21           <= 'd0;
    end
    else if(vld_s2) begin
        val_11           <= val_1 + val_2;
        val_21           <= val_3 + val_4;
    end
    else begin
        val_11           <= val_11;
        val_21           <= val_21;     
    end
end
always @(posedge clk) begin
    if(rst_n)
        val             <= 'd0        ;
    else if (vld_s3)    
        val             <= (val_11 + val_21) >>> quantify;
    else                
        val             <= val        ;
end

assign ans = val;

booth_crisp #(N,'d30 )k1_b1( a1[31:29]    , y1, b1);
booth_crisp #(N,'d28 )k1_b2( a1[29:27]    , y2, b1);
booth_crisp #(N,'d26 )k1_b3( a1[27:25]    , y3, b1);
booth_crisp #(N,'d24 )k1_b4( a1[25:23]    , y4, b1);
booth_crisp #(N,'d22 )k1_b5( a1[23:21]    , y5, b1);
booth_crisp #(N,'d20 )k1_b6( a1[21:19]    , y6, b1);
booth_crisp #(N,'d18 )k1_b7( a1[19:17]    , y7, b1);
booth_crisp #(N,'d16 )k1_b8( a1[17:15]    , y8, b1);
booth_crisp #(N,4'd14)u1_b1( a1[15:13]    , x1, b1);
booth_crisp #(N,4'd12)u1_b2( a1[13:11]    , x2, b1);
booth_crisp #(N,4'd10)u1_b3( a1[11:9]     , x3, b1);
booth_crisp #(N,4'd8 )u1_b4( a1[9:7]      , x4, b1);
booth_crisp #(N,4'd6 )u1_b5( a1[7:5]      , x5, b1);
booth_crisp #(N,4'd4 )u1_b6( a1[5:3]      , x6, b1);
booth_crisp #(N,4'd2 )u1_b7( a1[3:1]      , x7, b1);
booth_crisp #(N,4'd0 )u1_b8({a1[1:0],1'b0}, x8, b1);

endmodule
