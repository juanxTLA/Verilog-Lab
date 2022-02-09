// Testbench for negator.v
`timescale 1ns/100 ps


module tb_negator;

   reg x=0,clk=0,en=0,reset=0;
   wire z;

   initial
      begin
        
      // negate 1100 to produce 0100 (-4 to produce +4) 
      // assuming 4 bit two's complement arithmetic        

      // reset back to state 0
      // time = 0ns
      reset = 1;
      x = 0;
      en = 1;
        
      // time = 10ns
      #10
      reset = 0;
      x = 0;   // LSB input = 0
      en = 1;
        
      // time = 20ns
      #10
      reset = 0;
      x = 0;   // next input = 0
      en = 1;

      // time = 30ns
      #10
      reset = 0;
      x = 1;   // next input = 1
      en = 1;

      // time =40ns
      #10 
      reset = 0;
      x = 1;   // MSB input = 1
      en = 1;
       


      // negate 011010 to produce 100110 (26 to produce -26) 
      // assuming 6 bit two's complement arithmetic        

      // reset back to state 0
      // time = 50ns
      reset = 1;
      x = 0;
      en = 1;
        
      // time = 60ns
      #10
      reset = 0;
      x = 0;   // LSB input = 0
      en = 1;
        
      // time = 70ns
      #10
      reset = 0;
      x = 1;   // next input = 1
      en = 1;

      // time = 80ns
      #10
      reset = 0;
      x = 0;   // next input = 0
      en = 1;

      // time =90ns
      #10 
      reset = 0;
      x = 1;   // MSB input = 1
      en = 1;
        
      // time = 100ns
      #10
      reset = 0;
      x = 1;   // next input = 1
      en = 1;

      // time =110ns
      #10 
      reset = 0;
      x = 0;   // MSB input = 0
      en = 1;
      end

   // set up a free running clock with period 10 ns
   always begin
         clk = #5 ~clk;
      end

        
   // instantiate the negator as the unit under test (uut)
   negator uut (.x(x),.clk(clk),.en(en),.reset(reset),.z(z)); 

endmodule
