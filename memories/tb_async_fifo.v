`timescale 1ns/1ps
module tb_async_fifo (
);

  localparam       WIDTH = 6;
  localparam       DEPTH = 32;
  reg              wrClk;
  reg              wrRst;
  reg              wrEn;
  reg  [WIDTH-1:0] wrData;
  reg              rdClk;
  reg              rdRst;
  reg              rdEn;
  wire             full;
  wire             empty;
  wire [WIDTH-1:0] rdData;
  reg              rdEn_dly;
  reg  [WIDTH-1:0] rdData_dly;
  wire [WIDTH-1:0] rdData_dly_incr;
  reg              rdData_good;

  reg    tbPhase;

  initial begin
    wrClk       = 0;
    rdClk       = 0;
    wrRst       = 1;
    rdRst       = 1;
    tbPhase     = 0;
    wrEn        = 0;
    wrData      = 0;
    rdEn        = 0;
    rdEn_dly    = 0;
    rdData_dly  = '1; // this means all-ones
    rdData_good = 0;
  end

  always #10  wrClk = ~wrClk;
  always #7.5 rdClk = ~rdClk;
  always #60 wrRst = 0;
  always #60 rdRst = 0;


  always @(full, empty) begin
    if (full) begin
      if (empty) tbPhase = 1'bx;
      else tbPhase = 1;
    end else if (empty) tbPhase = 0;
  end

  always @(posedge wrClk) begin
    if (~tbPhase & ~full) begin // write until full
      wrEn <= 1'b1;
    end else begin
      wrEn <= 1'b0;
    end
    // advance wrData on successful write
    wrData <= wrData + (wrEn & ~full);
  end

  assign rdData_dly_incr = rdData_dly + 1; // limit the result of this addiiton to WIDTH bits
  always @(*) begin
    if (rdEn_dly) begin
      rdData_good = rdData_dly_incr == rdData; // comparison for expected data vs read data
    end
  end

  always @(posedge rdClk) begin
    rdEn_dly <= rdEn & ~empty;
    if (rdEn_dly) begin
      rdData_dly <= rdData;
    end
    if (tbPhase & ~empty) begin // read until empty
      rdEn <= 1'b1;
    end else begin
      rdEn <= 1'b0;
    end
  end
  
 
  async_fifo #(
    .WIDTH (WIDTH),
    .DEPTH (DEPTH)
  ) uut (
    .wrClk   (wrClk ),
    .wrRst   (wrRst ),
    .wrEn    (wrEn  ),
    .wrData  (wrData),
    .rdClk   (rdClk ),
    .rdRst   (rdRst ),
    .rdEn    (rdEn  ),
    .full    (full  ),
    .empty   (empty ),
    .rdData  (rdData)
  );

endmodule
