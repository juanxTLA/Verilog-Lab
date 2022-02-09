module alu (
  input    clk,
  input  [7:0]  operandA,
  input  [7:0]  operandB,
  input  [2:0]  opCode,
  output [15:0] opResult
);

	reg [15:0] out;
  always @(posedge clk)
  begin
  // TODO: add code here for the ALU; remember to either
  //       change opResult to a output reg ... type, or
  //       to declare a reg to assign in this procedure
  //       and then assign opResult = your_reg
  //this section of the code is the one where the critical path is
  case (opCode)
		3'b000: out = operandA + operandB;
		3'b001: out = operandA - operandB;
		3'b010: out = operandA ^ operandB;
		3'b011: out = operandA & operandB;
		3'b100: out = operandA | operandB;
		3'b101: out = operandA * operandB;
		3'b110: out = operandA << operandB;
		3'b111: out = operandA >> operandB;
  endcase
  end
  assign opResult = out;
  
endmodule
