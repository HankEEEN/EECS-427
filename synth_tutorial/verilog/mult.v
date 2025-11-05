//EESC427 TUTORIAL # FALL 2015

module mult(clk, a, b, result, resetn);
   input         clk;
   input   [7:0] a, b;
   input         resetn;
   
   output [15:0] result;
   reg     [7:0] a_int, b_int;
   reg    [15:0] result_int;
   wire   [15:0] anything;
       
always @(posedge clk)
  begin
     if(!resetn) begin
	a_int <= 1'b0;
	b_int <= 1'b1;
     end
     else begin
	a_int <= a;
	b_int <= b;
	result_int <= anything;
     end     
  end // always @ (posedge clk or negedge resetn)
   
   assign anything = a_int*b_int;
   assign result   = result_int;

endmodule // mult