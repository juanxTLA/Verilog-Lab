module fibonacci_rom
(
  input  [23:0]  rdadr,
  output [23:0] rddat 
);

  reg [23:0] rom [0:35];
  integer i;

  initial begin
  // TODO: put the initialization sequence here for address 0-35
  // Note - it is recommended to set the values of the first
  // two addresses (i.e. 0 and 1) to 1 each, and then set addresses
  // 2 through 35 by using a for loop
  rom[0] = 0;
  rom [1] = 1;
  
  for(i = 2; i < 36; i = i + 1)
  begin
    rom[i] = rom[i-1] + rom[i-2];
  end

  end

  assign rddat = rom[rdadr];

endmodule
