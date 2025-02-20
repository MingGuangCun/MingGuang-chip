module booth_crisp
#(parameter N='d28,
  parameter K='d0 
)
(
input [2:0]a,//三位一组
output reg signed [N+K:0]a_crisp,//返回的是b乘真值表的结果再移k位，
input signed[N-1:0]b//b有N位
);
always@(*)begin
    case (a)
        3'b000:a_crisp=3'd0;
        3'b001:a_crisp=b<<<K;//{b,{K{1'b0}}};
        3'b010:a_crisp=b<<<K;//{b,{K{1'b0}}};
        3'b011:a_crisp=b<<<(K+1);//{b,{(K+1){1'b0}}};
        3'b100:a_crisp=-b<<<(K+1);//-{b,{(K+1){1'b0}}};
        3'b101:a_crisp=-b<<<(K);//{b,{K{1'b0}}};
        3'b110:a_crisp=-b<<<(K);//{b,{K{1'b0}}};
        3'b111:a_crisp=3'd0;
        default:a_crisp=3'd0; 
    endcase
end
endmodule
