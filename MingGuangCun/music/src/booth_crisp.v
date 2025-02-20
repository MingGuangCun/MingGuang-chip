module booth_crisp
#(
  parameter       N=        'd28    ,
  parameter       K=        'd0 
)
(
  input                       [2:0]       a             ,
  output reg  signed          [N+K:0]     a_crisp       ,
  input       signed          [N-1:0]     b
);
always@(*)begin
    case (a)
        3'b000:a_crisp  = 3'd0          ;
        3'b001:a_crisp  = b<<<K         ;
        3'b010:a_crisp  = b<<<K         ;
        3'b011:a_crisp  = b<<<(K+1)     ;
        3'b100:a_crisp  = -b<<<(K+1)    ;
        3'b101:a_crisp  = -b<<<(K)      ;
        3'b110:a_crisp  = -b<<<(K)      ;
        3'b111:a_crisp  = 3'd0          ;
        default:a_crisp = 3'd0          ; 
    endcase
end
endmodule
