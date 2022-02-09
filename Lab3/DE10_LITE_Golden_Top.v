// ============================================================================
//   Ver  :| Author              :| Mod. Date :| Changes Made:
//   V1.1 :| Alexandra Du        :| 06/01/2016:| Added Verilog file
// ============================================================================


//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

//`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
//`define ENABLE_CLOCK2
//`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
//`define ENABLE_LED
`define ENABLE_SW
//`define ENABLE_VGA
//`define ENABLE_ACCELEROMETER
//`define ENABLE_ARDUINO
`define ENABLE_GPIO

module DE10_LITE_Golden_Top(

   //////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
   input                      ADC_CLK_10,
`endif
   //////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
   input                      MAX10_CLK1_50,
`endif
   //////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
   input                      MAX10_CLK2_50,
`endif

   //////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
   output          [12:0]     DRAM_ADDR,
   output           [1:0]     DRAM_BA,
   output                     DRAM_CAS_N,
   output                     DRAM_CKE,
   output                     DRAM_CLK,
   output                     DRAM_CS_N,
   inout           [15:0]     DRAM_DQ,
   output                     DRAM_LDQM,
   output                     DRAM_RAS_N,
   output                     DRAM_UDQM,
   output                     DRAM_WE_N,
`endif

   //////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
   output           [7:0]     HEX0,
`endif
`ifdef ENABLE_HEX1
   output           [7:0]     HEX1,
`endif
`ifdef ENABLE_HEX2
   output           [7:0]     HEX2,
`endif
`ifdef ENABLE_HEX3
   output           [7:0]     HEX3,
`endif
`ifdef ENABLE_HEX4
   output           [7:0]     HEX4,
`endif
`ifdef ENABLE_HEX5
   output           [7:0]     HEX5,
`endif

   //////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
   input            [1:0]     KEY,
`endif

   //////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
   output           [9:0]     LEDR,
`endif

   //////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
   input            [9:0]     SW,
`endif

   //////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
   output           [3:0]     VGA_B,
   output           [3:0]     VGA_G,
   output                     VGA_HS,
   output           [3:0]     VGA_R,
   output                     VGA_VS,
`endif

   //////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
   output                     GSENSOR_CS_N,
   input            [2:1]     GSENSOR_INT,
   output                     GSENSOR_SCLK,
   inout                      GSENSOR_SDI,
   inout                      GSENSOR_SDO,
`endif

   //////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
   inout           [15:0]     ARDUINO_IO,
   inout                      ARDUINO_RESET_N,
`endif

   //////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
   inout           [35:0]     GPIO
`endif
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

  wire        clk50 = MAX10_CLK1_50; // declare and assign in one expression (and shortens the name a bit)
  wire [1:0]  buttonPress; // debounce output
  wire        oneMsPulse;  // high for 1 clock cycle every 1 msec
  wire [15:0] OpResult;    // ALU output
  wire [9:0]  switch_meta; // SW inputs, post synchronizer

  reg  [7:0]  OpReg;       // 8-bit OPREG
  reg  [2:0]  OpCode;      // 3-bit OPCODE
  reg  [1:0]  buttonPress_dly; // delay each bit of buttonPress[1:0] by 1 clock cycle for falling edge detect
  reg         ShowOpReg;   // pulse to change display to show OPREG for 3 sec
  reg         ShowOpCode;  // pulse to change display to show OPCODE for 3 sec
  
  // NOTE: this is not necessary, but gives a reasonable initial value for the
  // board, and definitely sets up sims
  initial
  begin
    OpCode = 0;
    OpReg  = 0;
  end
  
  // Here we have a negative edge detection on the debouncer outputs
  always @(posedge clk50)
  begin
    buttonPress_dly <= buttonPress; // delay by one cycle...

    if (buttonPress[0]==1'b0 && buttonPress_dly[0]==1'b1) begin // then compare the newest state with the prior one if
	                                                        // it is low this cycle but high last cycle, it had a 
								// falling edge
      OpReg <= SW[7:0]; // load OPREG from the switches
      ShowOpReg <= 1'b1; // and show it!
    end else begin
      ShowOpReg <= 1'b0;
    end
    if (buttonPress[1]==1'b0 && buttonPress_dly[1]==1'b1) begin
      OpCode <= OpCode + 3'd1; // increment OPCODE
      ShowOpCode <= 1'b1; // and show it!
    end else begin
      ShowOpCode <= 1'b0;
    end
  end
       
//=======================================================
//  Structural coding
//=======================================================

// Note: synchronizer - we will learn about this later
meta #(
  .DATA_WIDTH (10),
  .DEPTH      (2)
) SW_in_meta (
  .clk     (clk50),
  .in_sig  (SW[9:0]),
  .out_sig (switch_meta)
);

// a pair of debouncers
debounce #(.DWELL_CNT(16'd1)) dbc0 (
  .clk     (clk50),
  .sig_in  (KEY[0]),
  .sig_out (buttonPress[0])
);
debounce #(.DWELL_CNT(16'd1)) dbc1 (
  .clk     (clk50),
  .sig_in  (switch_meta[9] & KEY[1]),
  .sig_out (buttonPress[1])
);

// millisecond timer
msec_timer  #(
  .FREQ_KHZ(50000) // 50 MHz
) u_timer (
  .clk        (clk50),
  .msec_pulse (oneMsPulse)
);

// ALU
alu u_alu (
  .clk       (clk50),
  .operandA  (OpReg),
  .operandB  (switch_meta[7:0]),
  .opCode    (OpCode),
  .opResult  (OpResult)
);

// HEX LED display
display_driver hex_leds (
  .clk        (clk50),
  .dispMode   (SW[8]),
  .oneMsPulse (oneMsPulse),
  .OpReg      (OpReg),
  .ShowOpReg  (ShowOpReg), // one-cycle pulse
  .OpCode     (OpCode),
  .ShowOpCode (ShowOpCode), // one-cycle pulse
  .OpResult   (16'h1ECE),
//TODO: enable this after Phase I  .OpResult   (OpResult),
  .HEX0       (HEX0),
  .HEX1       (HEX1),
  .HEX2       (HEX2),
  .HEX3       (HEX3),
  .HEX4       (HEX4),
  .HEX5       (HEX5),
);


endmodule