`timescale 1ns/1ps

`ifndef CLK_PERIOD
  `define CLK_PERIOD `CLOCK_PERIOD
`endif


module pc_tb;

parameter   ADDR_WIDTH = 16;
parameter   DISP_WIDTH = 8;

////////////////////////////////////////////////////////////////////////////////
////////////////////    Ports Definitions
////////////////////////////////////////////////////////////////////////////////
logic                       r_sys_clk;
logic                       r_sys_rstn;

logic                       r_scan_en;  // 1: shift mode, 0: normal functional mode
logic                       r_scan_in;
logic                       w_scan_out;

logic                       r_stall;

logic                       r_is_branch;
logic                       r_predict_taken;

logic   [DISP_WIDTH-1:0]    r_disp;
logic   [ADDR_WIDTH-1:0]    r_rf_addr;
logic                       r_jcond;
logic                       r_jal;

logic                       r_mispredict;
logic   [ADDR_WIDTH-1:0]    r_correct_pc;

logic                       w_writeback_enable;
logic   [ADDR_WIDTH-1:0]    w_writeback_data;
logic   [ADDR_WIDTH-1:0]    w_pc2imem;


////////////////////////////////////////////////////////////////////////////////
////////////////////    Module Instantiation
////////////////////////////////////////////////////////////////////////////////
pc #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .OFFSET_WIDTH           (DISP_WIDTH)
) pc_dut (
    .i_sys_clk              (r_sys_clk),
    .i_sys_rstn             (r_sys_rstn),
    .i_scan_en              (r_scan_en),
    .i_scan_in              (r_scan_in),
    .o_scan_out             (w_scan_out),
    .i_stall                (r_stall),
    .i_is_branch            (r_is_branch),
    .i_predict_taken        (r_predict_taken),
    .i_disp                 (r_disp),
    .i_rf_addr              (r_rf_addr),
    .i_jcond                (r_jcond),
    .i_jal                  (r_jal),
    .i_mispredict           (r_mispredict),
    .i_correct_pc           (r_correct_pc),
    .o_writeback_enable     (w_writeback_enable),
    .o_writeback_data       (w_writeback_data),
    .o_pc2imem              (w_pc2imem)
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
    repeat(30) @(negedge r_sys_clk);
    r_sys_rstn = 1'b1;
end


logic    [ADDR_WIDTH-1:0]    r_pattern_in ;
logic    [ADDR_WIDTH-1:0]    r_pattern_out;

////////////////////////////////////////////////////////////////////////////////
////////////////////    Set Up Other Stimuli
////////////////////////////////////////////////////////////////////////////////
initial begin
    r_pattern_in = 'd0;
    r_pattern_out = 'd0;
end

initial begin
    r_scan_en = 1'b0;
    r_scan_in = 1'b0;
    r_stall = 1'b0;
    r_is_branch = 1'b0;
    r_predict_taken = 1'b0;
    r_disp = 'd0;
    r_rf_addr = 'd0;
    r_jcond = 1'b0;
    r_jal = 1'b0;
    r_mispredict = 1'b0;
    r_correct_pc = 'd0;
    repeat(50) @(posedge r_sys_clk);

    // PC should start at 50 - 30 = 20
    // TEST 1 - Bcond - Early branch identification (opcode) + Predict taken + No misprediction
    // PC should now be 20 + 16 = 36 
    r_is_branch = 1'b1;
    r_predict_taken = 1'b1;
    r_disp = 'b0000_1111;
    r_mispredict = 1'b0;
    @(posedge r_sys_clk);

    // Bcond - Early branch identification (opcode) + Predict taken + Branch misprediction
    // PC should temporarily be 36 + 16 = 52
    r_is_branch = 1'b1;
    r_predict_taken = 1'b1;
    r_disp = 'b0000_1111;
    r_mispredict = 1'b0;
    @(posedge r_sys_clk);
    r_is_branch = 1'b0;
    r_predict_taken = 1'b0;
    r_disp = 'b0000_0000;
    // PC increments from 52 to 55 during the next 3 clk cycles when waiting for the branch resolution
    repeat(3) @(posedge r_sys_clk);
    // PC should now be corrected back to 37
    r_mispredict = 1'b1;
    r_correct_pc = 'd37;
    @(posedge r_sys_clk);
    

    // Bcond - Early branch identification (opcode) + Predict not taken + No misprediction
    // PC should now be 37 + 1 = 38
    r_is_branch = 1'b1;
    r_predict_taken = 1'b0;
    r_disp = 'b0001_0110;
    r_mispredict = 1'b0;
    @(posedge r_sys_clk);
    
    // Bcond - Early branch identification (opcode) + Predict not taken + Branch misprediction
    // PC should not become 38 + 1 = 39
    r_is_branch = 1'b1;
    r_predict_taken = 1'b0;
    r_disp = 'b0000_1100;
    r_mispredict = 1'b0;
    @(posedge r_sys_clk);
    r_is_branch = 1'b0;
    r_predict_taken = 1'b0;
    r_disp = 'b0000_0000;
    // PC increments from 39 to 42 during the next 3 clk cycles when waiting for the branch resolution
    repeat(3) @(posedge r_sys_clk);
    // PC should now be corrected to 50
    r_mispredict = 1'b1;
    r_correct_pc = 'd50;
    @(posedge r_sys_clk);
    r_mispredict = 1'b0;


    // TEST 2 - Jcond
    // PC should now be 240
    r_jcond = 1'b1;
    r_rf_addr = 'h00f0;
    r_predict_taken = 1'b1;
    @(posedge r_sys_clk);
    r_jcond = 1'b0;
    r_predict_taken = 1'b0;
    repeat(3) @(posedge r_sys_clk);
    r_mispredict = 1'b1;
    r_correct_pc = 'd50;
    @(posedge r_sys_clk);
    r_mispredict = 1'b0;

    
    // TEST 3 - JAL - rf writeback activated
    // PC should now be 16
    r_jcond = 1'b0;
    r_jal = 1'b1;
    r_rf_addr = 'h0010;
    @(posedge r_sys_clk);

    
    // TEST 4 - Normal PC Increment from 16 to 32
    r_jal = 1'b0;
    repeat(16) @(posedge r_sys_clk);
    @(posedge r_sys_clk);


    // TEST 5 - Test scan chain DFT
    // Shift in 16-bit pattern 0x00AA (1010_1010)
    r_scan_en = 1'b1;
    r_pattern_in = 16'h00AA;
    $display("\n--- Shifting in pattern 0x%h ---", r_pattern_in);
    for (int i = ADDR_WIDTH - 1; i >= 0; i--) begin
        r_scan_in = r_pattern_in[i];
        @(posedge r_sys_clk);
    end
    r_scan_en = 1'b0;

    // Run 5 clock cycles functionally (PC should increment from 170 to 175)
    repeat(5) @(posedge r_sys_clk);

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