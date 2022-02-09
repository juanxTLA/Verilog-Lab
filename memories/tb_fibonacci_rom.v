`timescale 1ns/1ps
module tb_fibonacci_rom (
);

  reg         clk;
  reg         reset;
  reg         en;
  wire [5:0]  count;
  wire [23:0] rddat;
  reg  [23:0] rddat_dly1;
  reg  [23:0] rddat_dly2;
  wire        seq_okay;

  initial begin
    clk = 0;
    reset = 1;
  end

  always #10 clk = ~clk;
  always #60 reset = 0;

  always @(posedge clk)
  begin
    if (reset) begin
      en <= 1'b0;
      rddat_dly1 <= 0;
      rddat_dly2 <= 0;
    end else begin
      rddat_dly1 <= rddat;
      rddat_dly2 <= rddat_dly1;
      en <= 1'b1;
    end
  end
  assign seq_okay = (rddat == rddat_dly1 + rddat_dly2);

  up_counter # (
    .WIDTH (6),
    .TERM_CNT (35)
  ) rom_rd_ctr (
    .clk (clk),
    .reset (reset),
    .en (en),
    .count (count)
  );

  fibonacci_rom uut (
    .rdadr (count),
    .rddat (rddat)
  );

endmodule
