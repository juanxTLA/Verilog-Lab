module gray_coder #(
  parameter WIDTH
) (
  input  [WIDTH-1:0] binIn,
  output [WIDTH-1:0] gcOut
);

  wire [WIDTH-1:0] binRsh;
  assign binRsh = {1'b0,binIn[WIDTH-1:1]};
  assign gcOut[WIDTH-1:0] = binIn[WIDTH-1:0] ^ binRsh[WIDTH-1:0];

endmodule
