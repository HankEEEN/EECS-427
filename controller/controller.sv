// From spec: 
/* you may need to latch the Write_Enable signal on the falling edge of the clock 
so that you do not use the control signal value of the next instruction */ 
/* Scanning IR and PSR will be important */ 

module controller(
    input logic clk, 
    input logic rst, 

    input logic Z_in, 
    input logic N_in, 
    input logic F_in, 
    input logic [15:0] inst_in, 

    output logic Z, 
    output logic N, 
    output logic F, 
    output logic [15:0] inst_out, 
    output logic [7:0] imm8
); 

    // always_comb begin 
    //     if(inst_in[15:12] == 4'hc) begin // BCOND

    //     end 
    // end 

    always_ff @(posedge clk) begin 
        if(rst) begin 
            Z <= 0;
            F <= 0; 
            N <= 0; 
            inst_out <= '0;  
            imm8 <= '0;    
        end else begin 
            Z <= Z_in; 
            F <= F_in; 
            N <= N_in;
            inst_out <= inst_in[15:0]; 
            imm8 <= inst_in[7:0];       
        end 
    end 


endmodule