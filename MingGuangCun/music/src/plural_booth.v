module plural_booth
(
    input                                      clk     ,
    input                                      rst_n   ,
    input                                      in_vld  ,
    input           signed      [31:0]         a       ,
    input           signed      [31:0]         b       ,
    output          signed      [63:0]         ans     ,
    output          reg                        out_vld
);

// control path
reg vld_s1,  vld_s4;
(* max_fanout=100 *)reg vld_s2;
(* max_fanout=100 *)reg vld_s3;
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
// stage 1
reg     signed        [15:0]            a_r     ;
reg     signed        [15:0]            a_i     ;
reg     signed        [15:0]            b_r     ;
reg     signed        [15:0]            b_i     ;

wire    signed        [15:0]            bri     ;
wire    signed        [15:0]            ari     ;
wire    signed        [15:0]            ari_    ;

always @(posedge clk) begin
    if(rst_n) begin
        a_r                         <= 16'd0;
        a_i                         <= 16'd0;
        b_r                         <= 16'd0;
        b_i                         <= 16'd0;
    end
    else if(in_vld) begin
        a_r                         <= a[31:16];
        a_i                         <= a[15:0];
        b_r                         <= b[31:16];
        b_i                         <= -b[15:0];              
    end          
    else begin
        a_r                         <= a_r;
        a_i                         <= a_i;
        b_r                         <= b_r;
        b_i                         <= b_i;
    end   
end
assign  bri     =   b_r + b_i;
assign  ari     =   a_r + a_i;
assign  ari_    =   a_r - a_i;
// catch stage 2 a_r b_i b_r
reg     signed        [15:0]            a_r1     ;
reg     signed        [15:0]            a_i1     ;
reg     signed        [15:0]            b_r1     ;
reg     signed        [15:0]            b_i1     ;
always @(posedge clk) begin
    if(rst_n) begin
        a_r1                         <= 16'd0;
        a_i1                         <= 16'd0;
        b_r1                         <= 16'd0;
        b_i1                         <= 16'd0;
    end
    else if(vld_s1) begin
        a_r1                         <= a_r;
        a_i1                         <= a_i;
        b_r1                         <= b_r;
        b_i1                         <= b_i;             
    end          
    else begin
        a_r1                         <= a_r1;
        a_i1                         <= a_i1;
        b_r1                         <= b_r1;
        b_i1                         <= b_i1;
    end   
end


// stage 2
reg     signed        [15:0]          bri1     ;
reg     signed        [15:0]          ari1     ;
reg     signed        [15:0]          ari_1    ;

always @(posedge clk) begin
    if(rst_n) begin
        bri1                       <= 16'd0;
        ari1                       <= 16'd0;
        ari_1                      <= 16'd0;        
    end
    else if(vld_s1) begin
        bri1                       <= bri ;
        ari1                       <= ari ;
        ari_1                      <= ari_;
    end
    else begin
        bri1                       <= bri1 ;
        ari1                       <= ari1 ;
        ari_1                      <= ari_1;
    end
end

localparam             N = 16;
// stage 2 booth_crisp1
wire    signed         [N+14:0]        x1  ;
wire    signed         [N+12:0]        x2  ;
wire    signed         [N+10:0]        x3  ;
wire    signed         [N+8:0]         x4  ;
wire    signed         [N+6:0]         x5  ;
wire    signed         [N+4:0]         x6  ;
wire    signed         [N+2:0]         x7  ;
wire    signed         [N:0]           x8  ;
booth_crisp #(N,4'd14)u1_b1( bri1[15:13]    , x1, a_r1);
booth_crisp #(N,4'd12)u1_b2( bri1[13:11]    , x2, a_r1);
booth_crisp #(N,4'd10)u1_b3( bri1[11:9]     , x3, a_r1);
booth_crisp #(N,4'd8 )u1_b4( bri1[9:7]      , x4, a_r1);
booth_crisp #(N,4'd6 )u1_b5( bri1[7:5]      , x5, a_r1);
booth_crisp #(N,4'd4 )u1_b6( bri1[5:3]      , x6, a_r1);
booth_crisp #(N,4'd2 )u1_b7( bri1[3:1]      , x7, a_r1);
booth_crisp #(N,4'd0 )u1_b8({bri1[1:0],1'b0}, x8, a_r1);

// stage 2 booth_crisp2
wire    signed         [N+14:0]        y1  ;
wire    signed         [N+12:0]        y2  ;
wire    signed         [N+10:0]        y3  ;
wire    signed         [N+8:0]         y4  ;
wire    signed         [N+6:0]         y5  ;
wire    signed         [N+4:0]         y6  ;
wire    signed         [N+2:0]         y7  ;
wire    signed         [N:0]           y8  ;
booth_crisp #(N,4'd14)u2_b1( ari1[15:13]    , y1, b_i1);
booth_crisp #(N,4'd12)u2_b2( ari1[13:11]    , y2, b_i1);
booth_crisp #(N,4'd10)u2_b3( ari1[11:9]     , y3, b_i1);
booth_crisp #(N,4'd8 )u2_b4( ari1[9:7]      , y4, b_i1);
booth_crisp #(N,4'd6 )u2_b5( ari1[7:5]      , y5, b_i1);
booth_crisp #(N,4'd4 )u2_b6( ari1[5:3]      , y6, b_i1);
booth_crisp #(N,4'd2 )u2_b7( ari1[3:1]      , y7, b_i1);
booth_crisp #(N,4'd0 )u2_b8({ari1[1:0],1'b0}, y8, b_i1);

// stage 2 booth_crisp3
wire    signed         [N+14:0]        z1  ;
wire    signed         [N+12:0]        z2  ;
wire    signed         [N+10:0]        z3  ;
wire    signed         [N+8:0]         z4  ;
wire    signed         [N+6:0]         z5  ;
wire    signed         [N+4:0]         z6  ;
wire    signed         [N+2:0]         z7  ;
wire    signed         [N:0]           z8  ;
booth_crisp #(N,4'd14)u3_b1( ari_1[15:13]    , z1, b_r1);
booth_crisp #(N,4'd12)u3_b2( ari_1[13:11]    , z2, b_r1);
booth_crisp #(N,4'd10)u3_b3( ari_1[11:9]     , z3, b_r1);
booth_crisp #(N,4'd8 )u3_b4( ari_1[9:7]      , z4, b_r1);
booth_crisp #(N,4'd6 )u3_b5( ari_1[7:5]      , z5, b_r1);
booth_crisp #(N,4'd4 )u3_b6( ari_1[5:3]      , z6, b_r1);
booth_crisp #(N,4'd2 )u3_b7( ari_1[3:1]      , z7, b_r1);
booth_crisp #(N,4'd0 )u3_b8({ari_1[1:0],1'b0}, z8, b_r1);

// stage 3
reg     signed        [31:0]          ar_bri1   ;
reg     signed        [31:0]          bi_ari1   ;
reg     signed        [31:0]          br_ari1_  ;
reg     signed        [31:0]          ar_bri2   ;
reg     signed        [31:0]          bi_ari2   ;
reg     signed        [31:0]          br_ari2_  ;

always @(posedge clk) begin
    if(rst_n) begin
        ar_bri1                       <= 32'd0;
        bi_ari1                       <= 32'd0;
        br_ari1_                      <= 32'd0;       
        ar_bri2                       <= 32'd0;
        bi_ari2                       <= 32'd0;
        br_ari2_                      <= 32'd0;             
    end
    else if(vld_s2) begin
        ar_bri1                       <= x1+x2+x3+x4;
        bi_ari1                       <= y1+y2+y3+y4;
        br_ari1_                      <= z1+z2+z3+z4;      
        ar_bri2                       <= x5+x6+x7+x8;
        bi_ari2                       <= y5+y6+y7+y8;
        br_ari2_                      <= z5+z6+z7+z8;     
    end
    else begin
        ar_bri1                       <= ar_bri1 ;
        bi_ari1                       <= bi_ari1 ;
        br_ari1_                      <= br_ari1_;
        ar_bri2                       <= ar_bri2 ;
        bi_ari2                       <= bi_ari2 ;
        br_ari2_                      <= br_ari2_;
    end
end
// stage 4
reg     signed        [31:0]          ar_bri   ;
reg     signed        [31:0]          bi_ari   ;
reg     signed        [31:0]          br_ari_  ;

always @(posedge clk) begin
    if(rst_n) begin
        ar_bri                       <= 32'd0;
        bi_ari                       <= 32'd0;
        br_ari_                      <= 32'd0;           
    end
    else if(vld_s3) begin
        ar_bri                       <= ar_bri1+ar_bri2;
        bi_ari                       <= bi_ari1+bi_ari2;
        br_ari_                      <= br_ari1_+br_ari2_;     
    end
    else begin
        ar_bri                       <= ar_bri ;
        bi_ari                       <= bi_ari ;
        br_ari_                      <= br_ari_;
    end
end

// stage 5
reg     signed        [31:0]          result_r;
reg     signed        [31:0]          result_i;
always @(posedge clk) begin
    if(rst_n) begin
        result_r                       <= 32'd0;
        result_i                       <= 32'd0;
    end
    else if(vld_s4) begin
        result_r                       <= ar_bri - bi_ari;
        result_i                       <= ar_bri - br_ari_;
    end
    else begin
        result_r                       <= result_r;
        result_i                       <= result_i;
    end
end

assign  ans     =       {result_r,result_i};

endmodule
