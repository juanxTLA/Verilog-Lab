module debounce #(
  parameter [15:0] DWELL_CNT
)  (
  input   clk,
  input   sig_in,
  output  sig_out
);

// TODO:
// declare reg signals here for the 16-bit counter and 1-bit state
	reg state;
	reg[15:0] counter;
	localparam[15:0] CNT = DWELL_CNT - 1;

initial
begin
  // TODO: can add initialization values to registers here
  state <= sig_in;
  counter <= 'h0; //initialize counter to 0
end

always @(posedge clk)
begin
	if((counter & CNT) == CNT) begin
		counter <= 'h0;
		state <= sig_in;
	end
	else if(sig_in == state) begin
		counter <= 'h0;
	end
	else begin
		counter <= counter + 'h1;
	end
end

// TODO: assign sig_out to the 1-bit reg that's tracking the debounce state
assign sig_out = state;
     
endmodule
     
