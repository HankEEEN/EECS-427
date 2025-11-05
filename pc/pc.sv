module pc #(
    parameter ADDR_WIDTH = 16,
    parameter OFFSET_WIDTH = 8
) (
    // --- System Control Signals ---
    input   logic                       i_sys_clk,
    input   logic                       i_sys_rstn,

    // --- Scan Chain Mode (muxed-D) ---
    input   logic                       i_scan_en,  // 1: shift mode, 0: normal functional mode
    input   logic                       i_scan_in,
    output  logic                       o_scan_out,

    // --- Flow Control ---
    input   logic                       i_stall,    // Hold PC for I$ miss, Ibuffer congestion, etc.

    // Predicted Path Inputs
    input   logic                       i_is_branch,
    input   logic                       i_predict_taken,

    // Predicted Targets Inputs
    input   logic   [OFFSET_WIDTH-1:0]  i_disp,
    input   logic   [ADDR_WIDTH-1:0]    i_rf_addr,
    input   logic                       i_jcond,
    input   logic                       i_jal,

    // Misprediction Squash/Correction
    input   logic                       i_mispredict,
    input   logic   [ADDR_WIDTH-1:0]    i_correct_pc,

    // JAL writeback
    output  logic                       o_writeback_enable,
    output  logic   [ADDR_WIDTH-1:0]    o_writeback_data, 

    // Target Destination Addr given to IMEM to identify which inst to fetch
    output  logic   [ADDR_WIDTH-1:0]    o_pc2imem
);

////////////////////////////////////////////////////////////////////////////////
////////////////////    Internal Registers
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc;
logic   [ADDR_WIDTH-1:0]    r_writeback_data;
logic                       r_writeback_enable;


////////////////////////////////////////////////////////////////////////////////
////////////////////    Next-PC Candidates
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc_normal, r_pc_taken, r_pc_predict;

assign r_pc_normal = r_pc + 1'b1;
assign r_pc_taken = r_pc + 1'b1 + {{OFFSET_WIDTH{i_disp[OFFSET_WIDTH-1]}}, i_disp};

always_comb begin
    r_pc_predict = r_pc_normal; // Default to normal pc increment
    if (i_is_branch | i_jcond)
        r_pc_predict = i_predict_taken ? (i_is_branch ? r_pc_taken : i_rf_addr) : r_pc_normal; 
    if (i_jal)
        r_pc_predict = i_rf_addr;
end


////////////////////////////////////////////////////////////////////////////////
////////////////////    Next PC Logic
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc_next;
assign r_pc_next =  (i_mispredict)  ?   i_correct_pc    :
                    (i_stall)       ?   r_pc            :
                    r_pc_predict;

always_ff @(posedge i_sys_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn)
        r_pc <= 'd0;
    else if (i_scan_en)
        r_pc <= {r_pc[ADDR_WIDTH-2:0], i_scan_in};
    else 
        r_pc <= r_pc_next;
end

assign o_pc2imem = r_pc;
assign o_scan_out = r_pc[ADDR_WIDTH-1];


////////////////////////////////////////////////////////////////////////////////
////////////////////    JAL Link Writeback PC + 1
////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge i_sys_clk or negedge i_sys_rstn) begin
    if (!i_sys_rstn) begin
        r_writeback_enable <= 1'b0;
        r_writeback_data <= 'd0;
    end else begin
        r_writeback_enable <= (!i_jcond & i_jal);
        if (i_jal & !i_jcond)
            r_writeback_data <= r_pc_next + 1'b1;
    end
end

assign o_writeback_enable = r_writeback_enable;
assign o_writeback_data = r_writeback_data;


endmodule