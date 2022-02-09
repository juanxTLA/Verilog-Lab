module async_fifo #(
  parameter WIDTH,
  parameter DEPTH
) (
  input              wrClk,
  input              wrRst,
  input              wrEn,
  input  [WIDTH-1:0] wrData,
  input              rdClk,
  input              rdRst,
  input              rdEn,
  output             full,
  output             empty,
  output [WIDTH-1:0] rdData
);

  // use the Verilog function $clog2 to easily find the ceiling(log2(N)) of N
  localparam DEPTH_LOG = $clog2(DEPTH);
  // for FULL detection, make sure to store an extra bit
  localparam PTR_WIDTH = (DEPTH == 2**DEPTH_LOG) ? DEPTH_LOG+1 : DEPTH_LOG;

  // remember that the pointers need to use PTR_WIDTH, but the
  // FIFO RAM needs to use DEPTH_LOG, which may be 1 bit narrower than
  // PTR_WIDTH
  wire n0, n1;
  wire [PTR_WIDTH-1:0] wrAdr;
  wire [PTR_WIDTH-1:0] rdAdr; 
  wire [PTR_WIDTH-1:0] n2;
  wire [PTR_WIDTH-1:0] n3; 
  wire [PTR_WIDTH-1:0] n4;
  wire [PTR_WIDTH-1:0] n5;
  wire [PTR_WIDTH-1:0] n6;
  wire [PTR_WIDTH-1:0] n7;
  wire [PTR_WIDTH-1:0] n8;
  wire [PTR_WIDTH-1:0] n9;

  and a1(n0, wrEn, ~full);
  and a2(n1, rdEn, ~empty);

  up_counter #(
    .WIDTH    (PTR_WIDTH),
    .TERM_CNT (DEPTH)
  ) 
  writePtr(
    .clk    (wrClk),
    .reset  (wrRst),
    .en     (n0),
    .count  (wrAdr)//out
  );

  up_counter #(
    .WIDTH    (PTR_WIDTH),
    .TERM_CNT (DEPTH)
  ) 
  readPtr(
    .clk    (rdClk),
    .reset  (rdRst),
    .en     (n1),
    .count  (rdAdr) //out
  );

  sdp_ram_infer #(
    .WIDTH  (WIDTH),
    .DEPTH  (DEPTH),
    .DEPTH_LOG  (DEPTH_LOG)
  ) 
  fifoRam (
    .wrClk    (wrClk),
    .wrEn     (n0),
    .wrDat    (wrData),
    .wrAdr    (wrAdr[DEPTH_LOG-1:0]),
    .rdClk    (rdClk),
    .rdEn     (n1),
    .rdDat    (rdData), //out
    .rdAdr    (rdAdr[DEPTH_LOG-1:0]),
    .rdRst    (rdRst)
  );
  //gray coders and decoders section
  //I have created a flip flop module to account for the different clock domains of the flip flop sections
  gray_coder # (
    .WIDTH  (PTR_WIDTH)
  )
  grayCoderWrPointer(
    .binIn  (wrAdr),
    .gcOut  (n2)
  );

  dffJuan #(
    .WIDTH (PTR_WIDTH)
  )
  ff0(
    .clk    (wrClk),
    .d      (n2),
    .q      (n4)
  );

  meta #(
    .DATA_WIDTH   (PTR_WIDTH),
    .DEPTH        (2)
  )
  meta0 (
    .clk      (rdClk),
    .in_sig   (n4),
    .out_sig  (n6)
  );

  gray_decoder #(
    .WIDTH    (PTR_WIDTH)
  )
  decoderToEmpty(
    .gcIn     (n6),
    .binOut   (n8)
  );

  gray_coder # (
    .WIDTH  (PTR_WIDTH)
  )
  grayCoderRdPointer(
    .binIn  (rdAdr),
    .gcOut  (n3)
  );

  dffJuan #(
    .WIDTH (PTR_WIDTH)
  )
  ff1(
    .clk    (rdClk),
    .d      (n3),
    .q      (n5)
  );

  meta #(
    .DATA_WIDTH   (PTR_WIDTH),
    .DEPTH        (2)
  )
  meta1 (
    .clk      (wrClk),
    .in_sig   (n5),
    .out_sig  (n7)
  );

  gray_decoder #(
    .WIDTH    (PTR_WIDTH)
  )
  decoderToFull(
    .gcIn     (n7),
    .binOut   (n9)
  );

  assign full = ((DEPTH) == (wrAdr-n9)) ? 1 : 0;
  assign empty = (rdAdr == n8) ? 1 : 0;

endmodule
