module structural_fsm(	input  a,
			input b,
			input clk,
			output s);

	wire n0, n1, n3, n5, n6, d, q, qnot;

	//not anot(n0,a);
	//not bnot(n1,b);
	//sequential part
	/*
	and and2(n5,a,b);
	and and3(n6,q,b);
	and and4(n7,q,a);
	or or0(d,n5,n6,n7);
	*/

	xor xor0(n3,a,b);
	xor xor1(s,n3,q);
	and and0(n5,n3,q);
	and and1(n6,a,b);
	or din(d,n5,n6);
	dff dff2(q,qnot,d,clk);

	//s part
	/*
	and and0(n3,n0,n1,q);
	and and1(n4,qnot,n0,b);
	and and5(n9,q,a,b);
	and and6(n10,qnot,a,n1);
	or or1(s,n3,n4,n9,n10);
	*/

	

endmodule


module dff(q,qbar,d,clk);
	input d,clk; 
	output q, qbar; 
	not not1(dbar,d); 
	nand_gate nand1(x,clk,d); 
	nand_gate nand2(y,clk,dbar); 
	nand_gate nand3(q,qbar,y); 
	nand_gate nand4(qbar,q,x); 
endmodule


module nand_gate(c,a,b); 
	input a,b; 
	output c; 
	assign c = ~(a&b); 
endmodule