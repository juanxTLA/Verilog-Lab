// Testbench 
`timescale 1ms/100 ps

module tb_mealy_struct;

   reg a=0,clk=0,b=0;
   wire s;

   initial
      begin
      // time = 0ns
     //reset = 1;
      a = 0;
      b = 0;
      //en= 1;
        
      // time = 10ns
      #10
     //reset = 0;
      a = 0;
      b = 0;
      //en= 1;
        
      // time = 20ns
      #10
     //reset = 0;
      a = 0;
      b = 1;
      //en= 1;

      // time = 30ns
      #10
     //reset = 0;
      a = 0;
      b = 1;
      //en= 1;

      // time =40ns
      #10 
     //reset = 0;
      a = 1;
      b = 1;
      //en= 1;

      #10
     //reset = 0;
      a = 0;
      b = 1;
      //en= 1;
        
      // time = 70ns
      #10
     //reset = 0;
      a = 1;
      b = 0;
      //en= 1;

      // time = 80ns
      #10
     //reset = 0;
      a = 1;
      b = 1;
      //en= 1;

      // time =90ns
      #10 
     //reset = 0;
      a = 0;
      b = 0;
      //en= 1;
      end

   // set up a free running clock with period 10 ns
   always
      begin
      clk = #5 ~clk;
      end

        
   // instantiate the negator as the unit under test (uut)
   structural_fsm uut(.a(a),.clk(clk),.s(s),.b(b)); 

endmodule