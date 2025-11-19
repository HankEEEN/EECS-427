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

    // Branch Targets Inputs
    input   logic   [OFFSET_WIDTH-1:0]  i_disp,
    input   logic   [ADDR_WIDTH-1:0]    i_rf_addr_n,

    // Branch Decision Inputs
    input   logic                       i_bcond,
    input   logic                       i_jump,

    // Target Destination Addr given to IMEM to identify which inst to fetch
    output  logic   [ADDR_WIDTH-1:0]    o_pc2imem,

    // PC + 1 output to the RF for JAL
    output  logic   [ADDR_WIDTH-1:0]    o_pc2rf
);

////////////////////////////////////////////////////////////////////////////////
////////////////////    Internal Registers
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc;
logic                       r_scan_out;


////////////////////////////////////////////////////////////////////////////////
////////////////////    Next-PC Candidates
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc_normal;
logic   [ADDR_WIDTH-1:0]    r_bcond_target;
logic   [ADDR_WIDTH-1:0]    r_rf_target;
logic   [ADDR_WIDTH-1:0]    r_pc_next;

assign r_pc_normal = r_pc + 1'b1;
assign r_bcond_target = r_pc + 1'b1 + {{OFFSET_WIDTH{i_disp[OFFSET_WIDTH-1]}}, i_disp};
assign r_rf_target = ~i_rf_addr_n;

always_comb begin
    if (i_bcond) 
        r_pc_next = r_bcond_target;
    else if (i_jump)
        r_pc_next = r_rf_target;
    else
        r_pc_next = r_pc_normal;
end


////////////////////////////////////////////////////////////////////////////////
////////////////////    Next PC Logic
////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge i_sys_clk) begin
    if (!i_sys_rstn)
        r_pc <= 'd0;
    else if (i_scan_en)
        r_pc <= {r_pc[ADDR_WIDTH-2:0], i_scan_in};
    else
        r_pc <= r_pc_next;
end


////////////////////////////////////////////////////////////////////////////////
////////////////////    Scan Chain Logic
////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge i_sys_clk) begin
    if (!i_sys_rstn)
        r_scan_out <= 1'b0;
    else if (i_scan_en)
        r_scan_out <= r_pc[ADDR_WIDTH-1];
end


assign o_pc2imem = r_pc;
assign o_pc2rf = r_pc_normal;
assign o_scan_out = r_scan_out;


endmodule