// example serial two's comp negator module from class
module negator (input x,clk,en,reset, output reg z);

reg state=0, next_state=0;

always @ (x,state)
   begin 
      case (state)
		   0 : if (x==0) begin next_state=0; z <= 0; end
			    else begin next_state=1; z <= 1; end
		   1 : begin next_state = 1; z <= ~x; end
		endcase
	end	
	
always @ (posedge clk)	
	if (reset) 
	   state = 0;
	else 
      if (en) state = next_state;
		
endmodule 
