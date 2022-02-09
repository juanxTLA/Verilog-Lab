module prbs16 #(
  parameter NUM_CYC = 1
) (
  input         clk,
  input         rst,
  input         shiftEn,
  output [15:0] outSeq
);

  reg [15:0] lfsrReg;
  reg sum1;
  reg sum2;
  reg sum3;
  
  always @(posedge clk)
  begin
    // TODO: create a synchronous reset...
    if (rst == 1)
		lfsrReg <= 16'hFFFF;
    // TODO: create a clock enable
    else if (shiftEn) begin 
		lfsrReg[1]<=lfsrReg[0];
		lfsrReg[2]<=lfsrReg[1];
		lfsrReg[3]<=lfsrReg[2];
		lfsrReg[4]<=lfsrReg[3];
		lfsrReg[5]<=lfsrReg[4];
		lfsrReg[6]<=lfsrReg[5];
		lfsrReg[7]<=lfsrReg[6];
		lfsrReg[8]<=lfsrReg[7];
		lfsrReg[9]<=lfsrReg[8];
		lfsrReg[10]<=lfsrReg[9];
		lfsrReg[11]<=lfsrReg[10];
		lfsrReg[12]<=lfsrReg[11];
		lfsrReg[13]<=lfsrReg[12];
		lfsrReg[14]<=lfsrReg[13];
		lfsrReg[15]<=lfsrReg[14];
		lfsrReg[0] <= lfsrReg[12] ^ lfsrReg[15] ^ lfsrReg[11] ^lfsrReg[10];
		
		if(lfsrReg == 16'h0000)
			lfsrReg <= 16'hFFFF;
		end 
		
  end

  assign outSeq = lfsrReg;
endmodule
