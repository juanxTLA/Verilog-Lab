// ============================================================================
//   Ver  :| Author					:| Mod. Date :| Changes Made:
//   V1.1 :| Alexandra Du			:| 06/01/2016:| Added Verilog file
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
`define ENABLE_LED
`define ENABLE_SW
//`define ENABLE_VGA
//`define ENABLE_ACCELEROMETER
//`define ENABLE_ARDUINO
`define ENABLE_GPIO

module DE10_LITE_Golden_Top(

	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
wire notButton0;
wire clk200;
wire [9:0] sw_sync;

assign notButton0 = ~KEY[0];

wire [15:0] shiftA;
wire [15:0] shiftB;
wire        shiftA_en;
wire        shiftB_en;
wire [31:0] aluResult;

reg [2:0] OpCode;
wire  buttonPress;
reg   buttonPress_dly;
reg   ShowOpCode;

  initial
  begin
    OpCode = 0;
  end
  
  always @(posedge clk200)
  begin
    buttonPress_dly <= buttonPress;
    if (buttonPress==1'b0 && buttonPress_dly==1'b1) begin
      OpCode <= OpCode + 3'd1;
      ShowOpCode <= 1'b1;
    end else begin
      ShowOpCode <= 1'b0;
    end
  end


//=======================================================
//  Structural coding
//=======================================================

// TODO: instantiate syspll:
syspll pll200 (
	
	.areset(!KEY[0]),
	.inclk0(MAX10_CLK1_50),
	.c0(clk200),
	.locked(LEDR[0])
);
	
meta #(
  .DATA_WIDTH (1),
  .DEPTH (2)
) meta_srst (
  .clk (clk200),
  .in_sig (KEY[1]),
  .out_sig (buttonPress)
);

meta #(
  .DATA_WIDTH (10),
  .DEPTH (2)
) meta_switches (
  .clk (clk200),
  .in_sig (SW[9:0]),
  .out_sig (sw_sync)
);

  assign shiftA_en = sw_sync[3:0]==shiftA[3:0] ? 1'b0 : 1'b1;
  assign shiftB_en = sw_sync[7:4]==shiftB[3:0] ? 1'b0 : 1'b1;

//TODO: Phase III - uncomment these after creating prbs16
prbs16 opregA_gen (
  .clk (clk200),
  .rst (ShowOpCode),
  .shiftEn (shiftA_en),
  .outSeq (shiftA)
);

prbs16 opregB_gen (
  .clk (clk200),
  .rst (ShowOpCode),
  .shiftEn (shiftB_en),
  .outSeq (shiftB)
);

//TODO: add DATA_WIDTH to this after Phase II:
alu #(.DATA_WIDTH(16)) alu_inst (
  .clk (clk200),
  .operandA (shiftA),
  .operandB (shiftB),
  .opCode   (OpCode),
  .opResult (aluResult)
);

// one millisecond timer
msec_timer  #(
  .FREQ_KHZ(200000) // 200 MHz
) u_timer (
  .clk        (clk200),
  .msec_pulse (oneMsPulse)
);

display_driver hex_leds (
  .clk        (clk200),
  .dispMode   (1'b1),       // this is tied high to always show HEX value
  .oneMsPulse (oneMsPulse),
  .OpReg      (0),          // unused
  .ShowOpReg  (1'b0),       // one-cycle pulse tied low since rEg is too big to show in 2 digits now
  .OpCode     (OpCode),
  .ShowOpCode (ShowOpCode), // one-cycle pulse
  .OpResult   (aluResult[23:0]), // 24 LSBs of the ALU output
  .HEX0       (HEX0),
  .HEX1       (HEX1),
  .HEX2       (HEX2),
  .HEX3       (HEX3),
  .HEX4       (HEX4),
  .HEX5       (HEX5)
);

endmodule