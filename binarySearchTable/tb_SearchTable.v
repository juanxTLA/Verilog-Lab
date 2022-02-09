`timescale 1ns/1ps
module tb_SearchTable();
    reg           reset;
    reg            req;
    reg [15:0]    search;
    reg            opReq;
    reg [1:0]     opCode;
    reg [15:0]    opSearch;
    reg [15:0]    opResult;
    reg            clk;
    wire           opRdy;
    wire           rdy;
    wire           found;
    wire           done;
    wire [15:0]    result;
    wire           opErr;
    wire [10:0]    numEntries;

    initial begin
        //opSearch = 48'h96;
        //opReq = 1'b1;
        //opResult = 16'd68;
        clk = 0;
        search = 16'h28;
        //opCode = 2'b00;
        req = 1;
    end


    always #10 clk = ~clk;
    always begin
        
        //#70; opSearch = 48'h84; opResult = 16'd1;
        //#70; opSearch = 48'h97; opResult = 16'd2;
        //#70; opSearch = 48'h57; opResult = 16'd3;
        //#70; opSearch = 48'h1; opResult = 16'd4;
        //#40; opCode = 2'b01; opSearch = 48'h57;
        //#40; opCode = 2'b10; opResult = 16'h89; opSearch = 48'h1;
        #100; search = 16'h23; req =1;
        #100; search = 16'h84;
        
        #100; search = 16'h14;
        #100; search = 16'h27;
        #200; search = 16'h24;
        //#40; opReq = 1; req = 0; opCode = 2'b11; 

    end

    SearchTable uut(
        reset,
        req,
        search,
        opReq,
        opCode,
        opSearch,
        opResult,
        clk,
        opRdy,
        rdy,
        found,
        done,
        result,
        opErr,
        numEntries
    );
endmodule