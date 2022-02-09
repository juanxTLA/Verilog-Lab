module gray_decoder #(
  parameter WIDTH
) (
  input  [WIDTH-1:0] gcIn,
  output [WIDTH-1:0] binOut
);

  reg [WIDTH-1:0] gcTmp;
  integer i;

  always @(gcIn) begin
    gcTmp[WIDTH-1] = gcIn[WIDTH-1];
    for (i=WIDTH-2; i>=0; i=i-1) gcTmp[i] = gcTmp[i+1] ^ gcIn[i];
  end

  assign binOut = gcTmp;
endmodule
