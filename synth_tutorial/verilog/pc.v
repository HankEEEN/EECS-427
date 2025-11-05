





// module pc (
//     input logic clk,
//     input logic reset,        
//     input logic branch,       
//     input logic stall,        
//     input logic scan_en, // scan mode
//     input logic scan_in, // scan input bit
//     input logic [15:0] next_pc_in, 
//     output logic [15:0] pc_out,       
//     output logic scan_out // scan output bit
// );
//     logic [15:0] pc_reg;

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             pc_reg <= 16'h0000;         
//         end else if (scan_en) begin
//             pc_reg <= {pc_reg[14:0], scan_in}; // scan shift mode
//         end else if (branch) begin
//             pc_reg <= next_pc_in;       
//         end else if (!stall) begin
//             pc_reg <= pc_reg + 16'h0001; 
//         end
//         // else: stall -> value remains the same
//     end

//     assign pc_out = pc_reg;
//     assign scan_out = pc_reg[15];

// endmodule
