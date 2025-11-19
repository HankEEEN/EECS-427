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

    // Target Destination Addr given to IMEM and RF
    output  logic   [ADDR_WIDTH-1:0]    o_pc2imem
);

////////////////////////////////////////////////////////////////////////////////
////////////////////    Internal Registers
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    r_pc;
logic                       r_scan_out;


////////////////////////////////////////////////////////////////////////////////
////////////////////    Next-PC Candidates
////////////////////////////////////////////////////////////////////////////////
logic   [ADDR_WIDTH-1:0]    w_rf_addr;
logic   [ADDR_WIDTH-1:0]    w_ext_disp;
logic   [ADDR_WIDTH-1:0]    w_pc_plus1;
logic   [ADDR_WIDTH-1:0]    w_br_addend;
logic   [ADDR_WIDTH-1:0]    w_pc_addout;

assign w_rf_addr = ~i_rf_addr_n;
assign w_ext_disp = $signed(i_disp);
assign w_pc_plus1 = r_pc + 1'b1;
assign w_br_addend = i_bcond ? w_ext_disp : 'd0;
assign w_pc_addout = w_br_addend + w_pc_plus1;

always_comb begin
    if (i_jump)
        w_pc_next = w_rf_addr;
    else
        w_pc_next = w_pc_addout;
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


assign o_pc = r_pc;
assign o_scan_out = r_scan_out;


endmodule