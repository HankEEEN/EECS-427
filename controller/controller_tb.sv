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
    logic [3:0] opcode; 
    logic [3:0] r_dest; 
    logic [3:0] op_ext;
    logic [3:0] r_src;
    logic [7:0] imm;

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
        .inst_out(inst_out), 
        .imm8(imm8)
    ); 
  

    always #(`CLK_PERIOD/2)    clk = ~clk;

    initial begin
    // clk = 0; 

    $finish;
end

   



endmodule