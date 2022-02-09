module behavioral_fsm(	input  a,
			input b,
			input clk,
			input reset,
			input enable,
			output reg s);
	reg state;
	reg next_state;

	always @(posedge clk)begin
	
		
		if(reset) state = 0;
		else if(enable) state = next_state;

		
	end
	
	always@(state, a, b)begin
		case(state)
			0: if(a == 1 & b ==1) begin
					next_state = 1;
					s = 0;
					end 
					else begin 
					next_state = 0;
					s = a + b;
					end
			1: if(a == 0 & b ==0) begin
					next_state = 0;
					s = 1;
					end 
					else begin 
					next_state = 1;
					s = a & b;
					end
		
	endcase
	end 
	endmodule