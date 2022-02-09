module alu #(parameter DATA_WIDTH)(
  input    clk,
  input  [DATA_WIDTH-1:0]  operandA,
  input  [DATA_WIDTH-1:0]  operandB,
  input  [2:0]  opCode,
  output [DATA_WIDTH*2-1:0] opResult
);

  reg [DATA_WIDTH*2-1:0] result;
  reg [DATA_WIDTH*2-1:0] sum;
  reg [DATA_WIDTH*2-1:0] sub;
  reg [DATA_WIDTH*2-1:0] _xor;
  reg [DATA_WIDTH*2-1:0] _and;
  reg [DATA_WIDTH*2-1:0] _or;
  reg [DATA_WIDTH*2-1:0] mult;
  reg [DATA_WIDTH*2-1:0] lshift;
  reg [DATA_WIDTH*2-1:0] rshift;
  reg	[2:0] codeReg;
  
  
  always @(posedge clk)
  begin
    
//    3'b000 : result[15:0] <= operandA + operandB; // ADD
//    3'b001 : result[15:0] <= operandA - operandB; // SUBTRACT
//    3'b010 : result[15:0] <= operandA ^ operandB; // XOR
//    3'b011 : result[15:0] <= operandA & operandB; // AND
//    3'b100 : result[15:0] <= operandA | operandB; // OR
//    3'b101 : result[15:0] <= operandA[7:0] *  operandB[7:0]; // MULT
//    3'b110 : result[15:0] <= operandA[7:0] << operandB[3:0]; // LSHIFT
//    default: result[15:0] <= operandB[7:0] >> operandB[3:0]; // RSHIFT
	 codeReg<=opCode;
	 sum[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] + operandB[DATA_WIDTH-1:0]; // ADD
    sub[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] - operandB[DATA_WIDTH-1:0]; // SUBTRACT
    _xor[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] ^ operandB[DATA_WIDTH-1:0]; // XOR
    _and[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] & operandB[DATA_WIDTH-1:0]; // AND
    _or[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] | operandB[DATA_WIDTH-1:0]; // OR
    mult[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] *  operandB[DATA_WIDTH-1:0]; // MULT
    lshift[DATA_WIDTH*2-1:0] <= operandA[DATA_WIDTH-1:0] << operandB[3:0]; // LSHIFT
    rshift[DATA_WIDTH*2-1:0] <= operandB[DATA_WIDTH-1:0] >> operandB[3:0]; // RSHIFT
  end
  always @(*)
  begin case(codeReg)
    3'b000 : result[DATA_WIDTH*2-1:0] <= sum[DATA_WIDTH*2-1:0]; // ADD
    3'b001 : result[DATA_WIDTH*2-1:0] <= sub[DATA_WIDTH*2-1:0]; // SUBTRACT
    3'b010 : result[DATA_WIDTH*2-1:0] <= _xor[DATA_WIDTH*2-1:0]; // XOR
    3'b011 : result[DATA_WIDTH*2-1:0] <= _and[DATA_WIDTH*2-1:0]; // AND
    3'b100 : result[DATA_WIDTH*2-1:0] <= _or[DATA_WIDTH*2-1:0]; // OR
    3'b101 : result[DATA_WIDTH*2-1:0] <= mult[DATA_WIDTH*2-1:0]; // MULT
    3'b110 : result[DATA_WIDTH*2-1:0] <= lshift[DATA_WIDTH*2-1:0]; // LSHIFT
    default: result[DATA_WIDTH*2-1:0] <= rshift[DATA_WIDTH*2-1:0]; // RSHIFT
  endcase
  end
  assign opResult = result;
  
endmodule
