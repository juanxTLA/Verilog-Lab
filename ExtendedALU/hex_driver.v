module  hex_driver (
  input      [4:0] InVal,
  output reg [7:0] OutVal
);

always @(InVal)
begin
  case (InVal)
  5'd0  : OutVal = 8'hC0;
  5'd1  : OutVal = 8'hF9;
  5'd2  : OutVal = 8'hA4;
  5'd3  : OutVal = 8'hB0;
  5'd4  : OutVal = 8'h99;
  5'd5  : OutVal = 8'h92;
  5'd6  : OutVal = 8'h82;
  5'd7  : OutVal = 8'hF8;
  5'd8  : OutVal = 8'h80;
  5'd9  : OutVal = 8'h90;
  5'd10 : OutVal = 8'h88;
  5'd11 : OutVal = 8'h83;
  5'd12 : OutVal = 8'hC6;
  5'd13 : OutVal = 8'hA1;
  5'd14 : OutVal = 8'h86;
  5'd15 : OutVal = 8'h8E;
  5'd16 : OutVal = 8'hAF; // r
  5'd17 : OutVal = 8'hA3; // g
  5'd18 : OutVal = 8'h90; // o
  default : OutVal = 8'hFF; // blank
  endcase
end

endmodule
	  