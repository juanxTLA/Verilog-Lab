module mooreBehavioral_fsm(	input  a,
				input b,
				input clk,
				input reset, 
				input enable,
				output reg s);
	reg[1:0] state;
	reg[1:0] next_state;

	always @(posedge clk)begin
	
		if(reset) state = 0;
		else if(enable) state = next_state;

		
	end
	
	always@(state, a, b)begin
		case(state)
			0: begin 
			if(a^b == 1) begin 
				next_state = 1;
				s = 1;
			end
			else if(a & b == 1) begin 
				next_state = 2;
				s = 0;
			end
			else begin
				next_state = 0;
				s = 0; 
			end
			end
			
			1:begin
			if(a^b == 1)begin
				next_state = 1;
				s = 1;
			end 
			else if(a & b == 1) begin 
				next_state = 2;
				s =0;
			end
			else begin
			next_state = 0;
			s = 0; 
			end
			end

			2: begin 
			if(a^b == 1) begin
				next_state = 2;
				s = 0;
			end
			else if(a & b == 1) begin
				next_state = 3;
				s = 1;
			end
			else begin
				next_state = 1; 
				s = 1;
			end
			end

			3: begin
			if(a^b == 1) begin
				next_state = 2;
				s = 0;
			end
			else if(a & b == 1) begin
				next_state = 3;
				s = 1;
			end
			else begin
				next_state = 1; 
				s = 1;
			end
			end
		
	endcase
	end 
	endmodule