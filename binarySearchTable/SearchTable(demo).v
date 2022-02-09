module SearchTable (
    input           reset,
    input           req,
    input [47:0]    search,
    input           opReq,
    input [1:0]     opCode,
    input [47:0]    opSearch,
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
    reg [47:0] entries  [0:1023];
    reg [15:0] data     [0:1023];

    reg [9:0] highEntry; //next entry to occupy
    reg [9:0] tempHigh;
    reg [9:0] tempLow;
    reg [9:0] lowEntry; //lowest entry
    reg [9:0] dif;
    reg [15:0]dispResult;
    reg exists;

    reg empty;

    //readState
    reg [1:0] readState;
    reg [1:0] nextRdState;
    //writeState
    reg [1:0] writeState;
    reg [1:0] nextWrState;
    integer i;
    
    //initialize
    initial begin
        
        for(i = 0; i < 1024; i = i + 1) begin
                entries [i] = {48{1'b1}};
                data [i] = {15{1'b0}};
        end

        highEntry = 10'b1;

        writeState = 2'b00;
        readState = 2'b00;
        opErr = 0;
        done = 0;
        found = 0;
        empty = 1;

        i = 0;
    end

    always @(*) begin
        
        case(readState)
            2'b00: begin
                if(!req || opReq) begin
                    nextRdState <= 2'b00;
                    //rdy <= 1'b1;
                end

                else begin
                    nextRdState <= 2'b01;
                    //rdy <= 1'b0;
                end
            end

            2'b01: begin //search
                if(empty) exists = 1'b0;
                //check for out of bounds              
                else if(search > entries[highEntry - 1] | search < entries[0]) begin
                    exists = 0;
                    tempLow = highEntry;
                end

                else if(search == entries[highEntry - 1] | search == entries[0]) begin
                    exists = 1'b1;
                    tempLow = highEntry;
                    dif = search == entries[0] ? 0 : highEntry - 1;
                end

                else begin
                    tempHigh = highEntry - 1;
                    tempLow = 0;
                    while(tempLow <= tempHigh) begin
                        dif = $floor((tempHigh + tempLow)/2);
                        if(entries[dif] == search) begin
                            exists = 1'b1;
                            tempLow = dif; //address of found value
                            tempHigh = 0;
                        end
                        
                        else if (search < entries[dif]) begin
                            tempHigh = dif -1;
                            exists = 1'b0;
                            
                        end  
                        else if (search > entries[dif]) begin
                            tempLow = dif + 1;
                            exists = 1'b0;
                        end
                    end
                end

                nextRdState <= 2'b00;
                //rdy <= 1'b1;
                found = exists ? 1 : 0;
                done <= found;
                result <= data[dif];
            end
            
        endcase
        
        
        case(writeState)
            //find state
            //op state with another case statement that performs the operations
            //reset state
            2'b00 : begin
                if(!opReq || req) begin
                    nextWrState <= 2'b00;
                    //opRdy <= 1'b1;
                    opErr = 1'b0;
                end

                else begin
                    nextWrState <= 2'b01;
                    //opRdy <= 1'b0;
                end
            end
            //comment
            2'b01 : begin // search for value

                if(empty) exists = 1'b0;
                //check for out of bounds              
                else if(opSearch > entries[highEntry - 1] || opSearch < entries[0]) begin
                    exists = 0;
                    tempLow = opSearch < entries[0] ? 0 : highEntry;
                end

                else if(opSearch == entries[highEntry - 1] || opSearch == entries[0]) begin
                    exists = 1'b1;
                    //tempLow = highEntry;
                    dif = opSearch == entries[0] ? 0 : highEntry - 1;
                end

                else begin
                    tempHigh = highEntry - 1;
                    tempLow = 0;
                    while(tempLow <= tempHigh) begin
                        dif = $floor((tempHigh + tempLow)/2);
                        if(entries[dif] == opSearch) begin
                            exists = 1'b1;
                            tempLow = dif; //address of found value
                            tempHigh = 0;
                        end
                        
                        else if (opSearch < entries[dif]) begin
                            tempHigh = dif -1;
                            exists = 1'b0;
                            
                        end  
                        else if (opSearch > entries[dif]) begin
                            tempLow = dif + 1;
                            exists = 1'b0;
                        end
                    end
                end

                nextWrState <= 2'b10;
                //opRdy <= 1'b0;
            end
            
            2'b10 : begin //operation step
                case(opCode)
                    2'b00 : begin //add
                        //another if may go in a higher order to check for full
                        if(empty || tempLow == highEntry) begin
                            entries[highEntry-1] = opSearch;
                            data[highEntry-1] = opResult;
                            highEntry = highEntry + 1;
                            empty = 1'b0;
                        end

                        else if(!exists) begin
                            
                            if(opSearch < entries[0]) begin
                                tempLow = 0;
                                for(i = highEntry; i > tempLow; i = i - 1) begin
                                    entries[i] = entries[i-1];
                                    data[i] = data[i-1];
                                end
                            end
                            else begin
                                for(i = highEntry; i >= tempLow; i = i - 1) begin
                                    entries[i] = entries[i-1];
                                    data[i] = data[i-1];
                                end
                            end
                            
                            entries[tempLow] = opSearch;
                            data[tempLow] = opResult;
                            highEntry = highEntry + 1;
                        end

                        else opErr = 1'b1; //maybe one other state to set it to 0? 
                    end

                    2'b01 : begin //delete
                        if(empty || !exists) begin
                            opErr = 1'b1;
                        end
                        else begin
                            if(tempLow == highEntry && dif != 0) begin
                                entries[dif] = {48{1'b1}};
                                data [dif] = {48{1'b0}};
                                highEntry = highEntry - 1;
                            end

                            else begin
                                for(i = dif; i <= highEntry; i = i + 1) begin
                                    entries[i] = entries[i+1];
                                    data[i] = data[i+1];     
                                end
                                
                                highEntry = highEntry - 1;

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
                        for(i = 0; i < 1024; i = i + 1) begin
                            entries [i] = {48{1'b1}};
                            data [i] = {48{1'b0}};
                            highEntry = 48'h1;
                            empty = 1;
                        end
                    end

                endcase
                nextWrState <= 2'b00;
                exists = 0;
                //opRdy <=1;
            end
        endcase
    end

    always @(posedge clk) begin
        writeState <= nextWrState;
        readState <= nextRdState;
    end

    always @(req, opReq, opCode) begin
        writeState <= 0;
        readState <= 0;
        exists = 0;
        //dif = 0;
        //tempLow = 0;
        //tempHigh = 0;
    end

    assign opRdy = ~req;
    assign rdy = ~opReq;
    assign numEntries = empty ? 0 : highEntry; //assign
endmodule
    