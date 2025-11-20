`timescale 1ns/1ps

`ifndef CLK_PERIOD
 `define CLK_PERIOD 20
`endif

module pc_new_tb;

parameter   ADDR_WIDTH = 16;
parameter   DISP_WIDTH = 8;

////////////////////////////////////////////////////////////////////////////////
////////////////////    Ports Definitions
////////////////////////////////////////////////////////////////////////////////
logic                               r_sys_clk;
logic                               r_sys_rstn;
logic                               r_scan_en;
logic                               r_scan_in;
logic                               w_scan_out;
logic                               r_stall;
logic       [OFFSET_WIDTH-1:0]      r_disp;
logic       [ADDR_WIDTH-1:0]        r_rf_addr_n;
logic                               r_bcond;
logic                               r_jump;
logic       [ADDR_WIDTH-1:0]        r_pc;


////////////////////////////////////////////////////////////////////////////////
////////////////////    Module Instantiation
////////////////////////////////////////////////////////////////////////////////
pc_new #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .OFFSET_WIDTH           (DISP_WIDTH)
) pc_new_dut (
    .i_sys_clk              (r_sys_clk),
    .i_sys_rstn             (r_sys_rstn),

    .i_scan_en              (r_scan_en),
    .i_scan_in              (r_scan_in),
    .o_scan_out             (w_scan_out),

    .i_stall                (r_stall),

    .i_disp                 (r_disp),
    .i_rf_addr_n            (r_rf_addr_n),

    .i_bcond                (r_bcond),
    .i_jump                 (r_jump),

    .o_pc                   (w_pc)
);


////////////////////////////////////////////////////////////////////////////////
////////////////////    Clock Signal Setup
////////////////////////////////////////////////////////////////////////////////
always #(`CLK_PERIOD/2)     r_sys_clk = ~r_sys_clk;
initial begin
    r_sys_clk = 1'b0;
end


////////////////////////////////////////////////////////////////////////////////
////////////////////    Reset Signal Setup
////////////////////////////////////////////////////////////////////////////////
initial begin
    r_sys_rstn = 1'b0;
    repeat(10) @(negedge r_sys_clk);
    r_sys_rstn = 1'b1;
end


////////////////////////////////////////////////////////////////////////////////
////////////////////    Stimuli Setup
////////////////////////////////////////////////////////////////////////////////
initial begin
    r_scan_en = 1'b0;
    r_scan_in = 1'b0;
    r_stall = 1'b0;
    r_disp = 'd0;
    r_f_addr_n = 'd0;
    r_bcond = 1'b0;
    r_jump = 1'b0;
    r_pc = 'd0;
    repeat(20) @(posedge r_sys_clk);

    // PC = 10
    // Test 1 - Bcond not taken
    r_bcond = 1'b0;
    @(posedge r_sys_clk);
    
    // PC = 11
    @(posedge r_sys_clk);

    // PC = 12
    // Test 2 - Bcond taken
    r_bcond = 1'b1;
    r_disp = 'd11;
    @(posedge r_sys_clk);
    r_bcond = 1'b0;

    // PC = 24
    @(posedge r_sys_clk);

    // PC = 25
    // Test 3 - Jcond taken
    r_jump = 1'b1;
    r_rf_addr_n = 'hFF9B;
    @(posedge r_sys_clk);
    r_jump = 1'b0;

    // PC = 100
    @(posedge r_sys_clk);

    // PC = 101
    // Test 4 - Jcond not taken 
    r_jump = 1'b0;
    @(posedge r_sys_clk);
    
    // PC = 102
    // Test 5 - JAL
    r_jump = 1'b1;
    r_rf_addr_n = 'hFFFF;
    @(posedge r_sys_clk) ;
    r_jump = 1'b0;
    // o_pc = 103

    // Test 6 - Test scan chain DFT
    // Shift in 16-bit pattern 0x00AA (1010_1010)
    r_scan_en = 1'b1;
    r_pattern_in = 16'h00AA;
    $display("\n--- Shifting in pattern 0x%h ---", r_pattern_in);
    for (int i = ADDR_WIDTH - 1; i >= 0; i--) begin
        r_scan_in = r_pattern_in[i];
        @(posedge r_sys_clk);
    end
    r_scan_en = 1'b0;

    // Run 10 clock cycles functionally (PC should increment from 0 to 10)
    repeat(10) @(posedge r_sys_clk);

    // Shift out the result
    r_scan_en = 1'b1;
    r_scan_in = 1'b0;
    r_pattern_out = 16'h0000;
    for (int i = ADDR_WIDTH - 1; i >= 0; i--) begin
        r_pattern_out[i] = w_scan_out;
        @(posedge r_sys_clk);
    end
    r_scan_en = 1'b0;
    $display("\n--- Shifting out pattern 0x%h ---", r_pattern_out);

    $finish;
end


endmodule