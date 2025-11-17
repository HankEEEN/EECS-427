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
    output logic [15:0] inst
); 

always_ff @(posedge clk) begin 
    if(rst) begin 
        Z <= 0;
        F <= 0; 
        N <= 0; 
        inst <= 0; 
    end else begin 
        Z <= Z_in; 
        F <= F_in; 
        N <= N_in;
        inst <= inst_in; 
    end 
end 

endmodule