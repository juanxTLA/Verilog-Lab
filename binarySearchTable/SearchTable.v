module SearchTable (
    input           reset,
    input           req,
    input [15:0]    search,
    input           opReq,
    input [1:0]     opCode,
    input [15:0]    opSearch,
    input [15:0]    opResult,
    input           clk,
    output          opRdy,
    output          rdy,
    output reg      found,
    output reg      done,
    output reg [15:0]   result,
    output reg      opErr,
    output [10:0]   numEntries 
);
//necesitamos dos fsm una se encarga de escribir y otra se encarga de leer
//keep data and entries in the same module for simplicity
    reg [15:0] entries  [0:31];
    reg [15:0] data     [0:31];

    reg [4:0] highEntry; //next entry to occupy
    reg [4:0] tempHigh;
    reg [4:0] tempLow;
    reg [4:0] lowEntry; //lowest entry
    reg [4:0] dif;
    reg [15:0]dispResult;
    reg 	     exists, operation;
	

    //readState
    reg [1:0] readState;
    reg [1:0] nextRdState;
    //writeState
    reg [2:0] writeState;
    reg [2:0] nextWrState;
	reg       empty;
    integer   i;
    
    //initialize
    initial begin
        
        for(i = 0; i < 32; i = i + 1) begin
            entries [i] = {16{1'b1}};
            data [i] = {16{1'b0}};
        end

        highEntry = 5'b1;

        entries[0] = 16'h23;
        entries[1] = 16'h25;
        entries[2] = 16'h26;
        entries[3] = 16'h29;

        highEntry = 5'd4;

        writeState = 2'b00;
        readState = 2'b00;
        opErr = 0;
        done = 0;
        found = 0;
        empty = 0;
        i = 0;
		  operation = 0;
    end

    always @(readState, writeState) begin
        
        case(readState)
            2'b00: begin
                if(!req || opReq) begin
                    nextRdState <= 2'b00;
                end

                else begin
                    tempHigh = highEntry - 1;
                    tempLow = 0;
                    nextRdState <= 2'b01;
                end

                found <= 1'b0; done <= 1'b0;
            end

            2'b01: begin //get index
                if(empty) begin
                    exists = 1'b0;
                    nextRdState <= 2'b11;
                end
                //check for out of bounds              
                else if(search > entries[highEntry - 1] | search < entries[0]) begin
                    exists = 0;
                    nextRdState <= 2'b11;
                end

                else if(search == entries[highEntry - 1] | search == entries[0]) begin
                    exists = 1'b1;
                    dif = search == entries[0] ? 10'b0 : highEntry - 1;
                    nextRdState <= 2'b11;
                end

                else begin
                    if(tempLow > tempHigh) begin
                        nextRdState <= 2'b11;
                    end
                    else begin
                        dif =(tempHigh + tempLow)/2; //index to search for
                        nextRdState <= 2'b10;
                    end
                end
/*
                nextRdState <= 2'b00;
                //rdy <= 1'b1;
                found = exists ? 1 : 0;
                done <= found;
                result <= empty ? 0 : data[dif];*/
            end

            2'b10: begin
                if(entries[dif] == search) begin
                    exists = 1'b1;
                    //tempLow = dif; //address of found value
                end
                
                else if (search < entries[dif]) begin
                    tempHigh = dif -1;
                    exists = 1'b0; 
                end  
                else if (search > entries[dif]) begin
                    tempLow = dif + 1;
                    exists = 1'b0;
                end

                nextRdState = exists ? 2'b11 : 2'b01;
            end

            2'b11: begin // output 
                done <= 1'b1;
                if(exists) begin
                    found <= 1'b1;
                    result <= data[dif];
                    
                end

                else found <= 1'b0;
                nextRdState <= 2'b00;
                dif = 0;
            end

            
        endcase
        
        
        case(writeState)
            //find state
            //op state with another case statement that performs the operations
            //reset state
            3'b000 : begin
                if(!opReq || req) begin
                    nextWrState <= 3'b000;
                    
                end
                else begin
                    nextWrState <= 3'b001;
                    tempHigh = highEntry - 1;
                    tempLow = 0;
                end

                opErr = 1'b0;
            end
            //comment
            3'b001: begin //get index
                if(empty) begin
                    exists = 1'b0;
                    nextWrState <= 3'b011;
                end
                //check for out of bounds              
                else if(search > entries[highEntry - 1] | search < entries[0]) begin
                    exists = 0;
                    nextWrState <= 3'b011;
                    dif = search < entries[0] ? 16'b0 : highEntry;
                end

                else if(search == entries[highEntry - 1] | search == entries[0]) begin
                    exists = 1'b1;
                    nextWrState <= 3'b011;
                end

                else begin
                    if(tempLow > tempHigh) begin
                        nextRdState <= 3'b011;
                    end
                    else begin
                        dif =(tempHigh + tempLow)/2; //index to search for
                        nextRdState <= 3'b010;
                    end
                end
            end

            3'b010: begin //search
                if(entries[dif] == search) begin
                    exists = 1'b1;
                end
                
                else if (search < entries[dif]) begin
                    tempHigh = dif -1;
                    exists = 1'b0; 
                end  
                else if (search > entries[dif]) begin
                    tempLow = dif + 1;
                    exists = 1'b0;
                end
                nextWrState = exists ? 3'b100 : 3'b001;
            end

            
            3'b011 : begin //operation step
                case(opCode)
                    2'b00 : begin //add
                        //another if may go in a higher order to check for full
					    operation = 1;
                        if(empty) begin
                            entries[0] = opSearch;
                            data[0] = opResult;
                            highEntry = 16'h1;
                            empty = 1'b0;
                        end

                        else if(!exists) begin
                            if(opSearch < entries[0]) begin
                                dif = 0;
                                for(i = 1; i > 0; i = i - 1) begin
                                    entries[i] = entries[i-1];
                                    data[i] = data[i-1];
                                end
                            end
                            else begin
                                for(i = highEntry; i >= dif; i = i - 1) begin
                                    entries[i] = entries[i-1];
                                    data[i] = data[i-1];
									
                                end
                            end
                            
                            entries[dif] = opSearch;
                            data[dif] = opResult;
                            highEntry = highEntry + 1;
							operation = 0;
                        end

                        else opErr = 1'b1; //maybe one other state to set it to 0? 
                    end

                    2'b01 : begin //delete
								operation = 1;
                        if(empty || !exists) begin
                            opErr = 1'b1;
                        end
                        else begin
                            if(dif == highEntry - 1) begin
                                entries[dif] = {16{1'b1}};
                                data [dif] = {16{1'b0}};
                                highEntry = highEntry - 1;
                            end

                            else begin
                                for(i = dif; i <= highEntry; i = i + 1) begin
                                    entries[i] = entries[i+1];
                                    data[i] = data[i+1];     
                                end
                                
                                highEntry = highEntry - 1;
										  operation = 0;

                            end
                        end

                        empty = highEntry == 1 ? 1 : 0;
                    end

                    2'b10 : begin //update
                        if(empty || !exists) begin
                            opErr = 1'b1;
                        end

                        else data[dif] = opResult;
                
                    end

                    2'b11 : begin//clear
							operation = 1;
                        for(i = 0; i < 32; i = i + 1) begin
                            entries [i] = {16{1'b1}};
                            data [i] = {16{1'b0}};
                        end
                        
                        highEntry = 16'h1;
                        empty = 1'b1;
					    operation = 0;
                    end

                endcase
                nextWrState <= 3'b000;
                exists = 0;
 
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 32; i = i + 1) begin
                entries [i] = {16{1'b1}};
                data [i] = {16{1'b0}};
                highEntry = 16'h1;
                
            end
            writeState <= 0;
            readState <= 0;
            empty = 1;
            highEntry = 16'h1;
        end
        else if (~operation)begin
            writeState <= nextWrState;
            readState <= nextRdState;
        end
    end

    always @(req, opReq) begin
        writeState <= 0;
        readState <= 0;
        //nextWrState <= 0;
        //nextRdState<=0;
        //dif = 0;
        //tempLow = 0;
        //tempHigh = 0;
    end

    assign opRdy = ~req;
    assign rdy = ~opReq;
    assign numEntries = empty ? 0 : highEntry; //assign

endmodule
    

    