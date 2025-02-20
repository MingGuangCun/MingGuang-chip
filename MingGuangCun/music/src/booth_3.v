module booth_3
#(
    parameter N         = 32                ,
    parameter O         = 32                ,
    parameter quantify  = 14                 //4096
)
(
    input                                              clk     ,
    input                                              rst_n   ,
    input                                              in_vld  ,
    input           signed      [N-1:0]                a       ,
    input           signed      [N-1:0]                b       ,
    input           signed      [N-1:0]                c       ,
    // output          signed      [N+63-2*quantify:0]    ans     ,
    output          signed      [N-1:0]    ans                 ,
    output          reg                                out_vld 
);

reg                                     vld_s1;
reg                                     vld_s2;
reg                                     vld_s3;
reg                                     vld_s4;

reg     signed        [N-1:0]           a1  ;
reg     signed        [N-1:0]           b1  ;
reg     signed        [N-1:0]           c1  ;

reg     signed        [N+31-quantify:0]  val1;
reg     signed        [N+63-2*quantify:0]val2;

wire    signed        [N+14:0]          x1   ;
wire    signed        [N+12:0]          x2   ;
wire    signed        [N+10:0]          x3   ;
wire    signed        [N+8:0]           x4   ;
wire    signed        [N+6:0]           x5   ;
wire    signed        [N+4:0]           x6   ;
wire    signed        [N+2:0]           x7   ;
wire    signed        [N:0]             x8   ;
wire    signed        [N+16+14:0]       x9   ;
wire    signed        [N+16+12:0]       x10  ;
wire    signed        [N+16+10:0]       x11  ;
wire    signed        [N+16+8:0]        x12  ;
wire    signed        [N+16+6:0]        x13  ;
wire    signed        [N+16+4:0]        x14  ;
wire    signed        [N+16+2:0]        x15  ;
wire    signed        [N+16:0]          x16  ;

wire    signed        [N+32-quantify+14:0]          y1   ;
wire    signed        [N+32-quantify+12:0]          y2   ;
wire    signed        [N+32-quantify+10:0]          y3   ;
wire    signed        [N+32-quantify+8:0]           y4   ;
wire    signed        [N+32-quantify+6:0]           y5   ;
wire    signed        [N+32-quantify+4:0]           y6   ;
wire    signed        [N+32-quantify+2:0]           y7   ;
wire    signed        [N+32-quantify:0]             y8   ;
wire    signed        [N+32-quantify+30:0]          y9   ;
wire    signed        [N+32-quantify+28:0]          y10  ;
wire    signed        [N+32-quantify+26:0]          y11  ;
wire    signed        [N+32-quantify+24:0]          y12  ;
wire    signed        [N+32-quantify+22:0]          y13  ;
wire    signed        [N+32-quantify+20:0]          y14  ;
wire    signed        [N+32-quantify+18:0]          y15  ;
wire    signed        [N+32-quantify+16:0]          y16  ;

always @(posedge clk) begin
    if(rst_n) begin
        vld_s1                      <= 1'b0;
        vld_s2                      <= 1'b0;
        vld_s3                      <= 1'b0;
        vld_s4                      <= 1'b0;
        out_vld                     <= 1'b0;
    end
    else begin
        vld_s1                      <= in_vld;
        vld_s2                      <= vld_s1;
        vld_s3                      <= vld_s2;
        vld_s4                      <= vld_s3;
        out_vld                     <= vld_s4;
    end
end
        
always @(posedge clk) begin
    if(rst_n) begin
        a1              <= 'd0;
        b1              <= 'd0;
        c1              <= 'd0;
    end
    else if(in_vld) begin
        a1              <= a;
        b1              <= b;
        c1              <= c;
    end
    else begin
        a1              <= a1;
        b1              <= b1;
        c1              <= c1;
    end
end

reg signed [N+15:0]val_1 ;
reg signed [N+31:0]val_2 ;
always @(posedge clk) begin
    if(rst_n)begin
        val_1             <= 'd0;
        val_2             <= 'd0;
    end
    else if(vld_s1)begin
        val_1             <= x1+x2+x3+x4+x5+x6+x7+x8       ;
        val_2             <= x9+x10+x11+x12+x13+x14+x15+x16;
    end
    else begin
        val_1             <= val_1;
        val_2             <= val_2;
    end
end

always @(posedge clk) begin
    if(rst_n) 
        val1            <= 'd0;
    else if(vld_s2)
        val1            <= (val_1+val_2)>>>quantify;
    else begin
        val1            <= val1;
    end
end

reg signed [N+32-quantify+15:0]val_3 ;
reg signed [N+32-quantify+31:0]val_4 ;
always @(posedge clk) begin
    if(rst_n)begin
        val_3             <= 'd0;
        val_4             <= 'd0;
    end
    else if(vld_s3)begin
        val_3             <= y1+y2+y3+y4+y5+y6+y7+y8       ;
        val_4             <= y9+y10+y11+y12+y13+y14+y15+y16;
    end
    else begin
        val_3             <= val_3;
        val_4             <= val_4;
    end
end

always @(posedge clk) begin
    if(rst_n) 
        val2            <= 'd0;
    else if(vld_s4)
        val2            <= (val_3+val_4) >>> quantify;
    else begin
        val2            <= val2;
    end
end

assign ans = val2;
booth_crisp #(N,'d30) k1_b1( a1[31:29]    , x9, b1);
booth_crisp #(N,'d28) k1_b2( a1[29:27]    , x10, b1);
booth_crisp #(N,'d26) k1_b3( a1[27:25]    , x11, b1);
booth_crisp #(N,'d24 )k1_b4( a1[25:23]    , x12, b1);
booth_crisp #(N,'d22 )k1_b5( a1[23:21]    , x13, b1);
booth_crisp #(N,'d20 )k1_b6( a1[21:19]    , x14, b1);
booth_crisp #(N,'d18 )k1_b7( a1[19:17]    , x15, b1);
booth_crisp #(N,'d16 )k1_b8( a1[17:15]    , x16, b1);
booth_crisp #(N,'d14)u1_b1( a1[15:13]    , x1, b1);
booth_crisp #(N,'d12)u1_b2( a1[13:11]    , x2, b1);
booth_crisp #(N,'d10)u1_b3( a1[11:9]     , x3, b1);
booth_crisp #(N,'d8 )u1_b4( a1[9:7]      , x4, b1);
booth_crisp #(N,'d6 )u1_b5( a1[7:5]      , x5, b1);
booth_crisp #(N,'d4 )u1_b6( a1[5:3]      , x6, b1);
booth_crisp #(N,'d2 )u1_b7( a1[3:1]      , x7, b1);
booth_crisp #(N,'d0 )u1_b8({a1[1:0],1'b0}, x8, b1);

booth_crisp #(N+32-quantify,'d30) x1_b1( c1[31:29]    , y9,  val1);
booth_crisp #(N+32-quantify,'d28) x1_b2( c1[29:27]    , y10, val1);
booth_crisp #(N+32-quantify,'d26) x1_b3( c1[27:25]    , y11, val1);
booth_crisp #(N+32-quantify,'d24 )x1_b4( c1[25:23]    , y12, val1);
booth_crisp #(N+32-quantify,'d22 )x1_b5( c1[23:21]    , y13, val1);
booth_crisp #(N+32-quantify,'d20 )x1_b6( c1[21:19]    , y14, val1);
booth_crisp #(N+32-quantify,'d18 )x1_b7( c1[19:17]    , y15, val1);
booth_crisp #(N+32-quantify,'d16 )x1_b8( c1[17:15]    , y16 ,val1);
booth_crisp #(N+32-quantify,'d14)r1_b1( c1[15:13]    , y1 , val1);
booth_crisp #(N+32-quantify,'d12)r1_b2( c1[13:11]    , y2 , val1);
booth_crisp #(N+32-quantify,'d10)r1_b3( c1[11:9]     , y3 , val1);
booth_crisp #(N+32-quantify,'d8 )r1_b4( c1[9:7]      , y4 , val1);
booth_crisp #(N+32-quantify,'d6 )r1_b5( c1[7:5]      , y5 , val1);
booth_crisp #(N+32-quantify,'d4 )r1_b6( c1[5:3]      , y6 , val1);
booth_crisp #(N+32-quantify,'d2 )r1_b7( c1[3:1]      , y7 , val1);
booth_crisp #(N+32-quantify,'d0 )r1_b8({c1[1:0],1'b0}, y8 , val1);

endmodule
