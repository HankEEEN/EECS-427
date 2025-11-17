`timescale 1ns/1ps

`ifndef CLK_PERIOD
  `define CLK_PERIOD `CLOCK_PERIOD
`endif


module controller_tb; 
    logic clk; 
    logic rst; 

    logic Z_in; 
    logic N_in; 
    logic F_in; 
    logic [15:0] inst_in; 

    logic Z;
    logic N; 
    logic F; 
    logic [15:0] inst;

    controller control(
        .clk(clk),
        .rst(rst),
        .Z_in(Z_in), 
        .N_in(N_in),
        .F_in(F_in),
        .inst_in(inst_in), 
        .Z(Z), 
        .N(N),
        .F(F),
        .inst(inst)
    ); 
  

    always #(`CLK_PERIOD/2)    clk = ~clk;

    initial begin
    // clk = 0; 

    $finish;
end

   



endmodule