module display_driver (
  input clk,
  input        dispMode,
  input        oneMsPulse,
  input [7:0]  OpReg,
  input        ShowOpReg, // one-cycle pulse
  input [2:0]  OpCode,
  input        ShowOpCode, // one-cycle pulse
  input [23:0] OpResult,
  output [7:0] HEX0,
  output [7:0] HEX1,
  output [7:0] HEX2,
  output [7:0] HEX3,
  output [7:0] HEX4,
  output [7:0] HEX5
);

  localparam SHOW_RESULT = 2'b00;
  localparam SHOW_OPREG  = 2'b01;
  localparam SHOW_OPCODE = 2'b10;
  
  localparam CHAR_R = 5'h10;
  localparam CHAR_O = 5'h11;
  localparam CHAR_G = 5'h12;
  localparam CHAR_BLANK = 5'h13;
  
  wire [15:0] DEC_POWER [4:0];
  assign DEC_POWER[4] = 16'd10000;
  assign DEC_POWER[3] = 16'd1000;
  assign DEC_POWER[2] = 16'd100;
  assign DEC_POWER[1] = 16'd10;
  assign DEC_POWER[0] = 16'd1;
  
  reg [1:0]  displayState;
  reg [11:0] threeSecCnt;
  
  reg [15:0] decResult;
  reg [15:0] decTemp;
  reg [2:0] decState;
  reg [3:0] decDigits [4:0];
  
  
  reg [4:0] char0;
  reg [4:0] char1;
  reg [4:0] char2;
  reg [4:0] char3;
  reg [4:0] char4;
  reg [4:0] char5;
  
  integer i;
  
  always @(*)
  begin
    if (displayState == SHOW_RESULT) begin
      if (dispMode)
        {char5,char4,char3,char2,char1,char0} = {1'b0,OpResult[23:20],1'b0,OpResult[19:16],1'b0,OpResult[15:12],1'b0,OpResult[11:8],1'b0,OpResult[7:4],1'b0,OpResult[3:0]};
      else begin
        char5 = CHAR_BLANK;
        char4 = {1'b0,decDigits[4]};
        char3 = {1'b0,decDigits[3]};
        char2 = {1'b0,decDigits[2]};
        char1 = {1'b0,decDigits[1]};
        char0 = {1'b0,decDigits[0]};
      end
    end else if (displayState==SHOW_OPREG) begin
      {char5,char4,char3,char2,char1,char0} = {CHAR_R,5'hE,CHAR_G,CHAR_BLANK,1'b0,OpReg[7:4],1'b0,OpReg[3:0]};
    end else begin
      {char5,char4,char3,char2,char1,char0} = {5'hC,CHAR_O,5'hD,5'hE,CHAR_BLANK,2'd0,OpCode[2:0]};
    end
  end

  always @(posedge clk)
  begin
    case (displayState)
    SHOW_RESULT : begin
      threeSecCnt <= 12'd0;
      if (ShowOpReg) begin
        displayState <= SHOW_OPREG;
      end else if (ShowOpCode) begin
        displayState <= SHOW_OPCODE;
      end
    end
    SHOW_OPREG : begin
      if (ShowOpCode) begin
        threeSecCnt  <= 12'd0;
        displayState <= SHOW_OPCODE;
      end else begin
        if (ShowOpReg) begin // another button press
          threeSecCnt  <= 12'd0;
        end else begin
          threeSecCnt <= threeSecCnt+oneMsPulse;
        end
        if (threeSecCnt==12'd2999) begin // timed out
          displayState <= SHOW_RESULT;
        end
      end
    end
    default : begin // SHOW_OPCODE
      if (ShowOpReg) begin
        threeSecCnt  <= 12'd0;
        displayState <= SHOW_OPREG;
      end else begin
        if (ShowOpCode) begin // another button press
          threeSecCnt  <= 12'd0;
        end else begin
          threeSecCnt <= threeSecCnt+oneMsPulse;
        end
        if (threeSecCnt==12'd2999) begin // timed out
          displayState <= SHOW_RESULT;
        end
      end
    end
    endcase
    
    if (decState==3'b111) begin // idle
      if (decResult!=OpResult) begin // new value
        decState <= 3'b100; // ten thousands
        decResult <= OpResult; // grab it right away, just in case the switch bounces (we will recalculate)
        for (i=0;i<=4;i=i+1) decDigits[i] <= {4'b0}; // reset
      end
      decTemp <= OpResult;
    end else begin // here we will decrement through the values of 10^(4...0)
      if (decTemp>=DEC_POWER[decState]) begin
        decTemp <= decTemp-DEC_POWER[decState];
        decDigits[decState] <= decDigits[decState]+4'd1;
      end else begin
        decState <= decState-1;
      end
    end
  end
  
  hex_driver hex_display [5:0] (
    .InVal ({char5,char4,char3,char2,char1,char0}),
    .OutVal ({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0})
  );
endmodule
