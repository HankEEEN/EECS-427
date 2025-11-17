`timescale 1ns/1ps

`ifndef CLK_PERIOD
  `define CLK_PERIOD `CLOCK_PERIOD
`endif
 

module decoder_tb; 
    logic [15:0] inst; 

    //OUTPUTS
    logic [3:0] opcode; 
    logic [3:0] r_dest; 
    logic [3:0] op_ext;
    logic [3:0] r_src;
    logic [7:0] imm; 
    logic sub; 
    logic rf_we; 
    logic [3:0] alu_op; 
    // for mux
    logic alu_imm;
    logic mov;
    logic lui;
    logic mem; 
    logic alu; 
    logic pc; 
    logic shift; 
    logic lsh; 
    logic lshi;  

    decoder decode(
        .inst(inst), 
        .opcode(opcode), 
        .r_dest(r_dest),
        .op_ext(op_ext),
        .r_src(r_src), 
        .imm(imm), 
        .sub(sub), 
        .rf_we(rf_we), 
        .alu_op(alu_op), 
        .alu_imm(alu_imm),
        .mov(mov), 
        .lui(lui), 
        .mem(mem), 
        .alu(alu), 
        .pc(pc), 
        .shift(shift), 
        .lsh(lsh), 
        .lshi(lshi) 
    ); 

    task apply_inst(input [15:0] new_inst);
    begin
        inst = new_inst;   
        #1;                

        $display("INST=%h  opcode=%0b  op_ext=%0b  r_dest=%0d r_src=%0d imm=%0d | \
            alu_imm=%b mov=%b lui=%b mem=%b alu=%b pc=%b shift=%b lsh=%b lshi=%b sub=%b rf_we=%b alu_op=%b",
            inst, opcode, op_ext, r_dest, r_src, imm,
            alu_imm, mov, lui, mem, alu, pc, shift, lsh, lshi, sub, rf_we, alu_op);
    end
    endtask
  

    // always #(`CLK_PERIOD/2)    clk = ~clk;

    initial begin
    // clk = 0;

    $display("\n=== Testing Immediate ALU Instructions ===");
    $display("-------------TEST 1: ANDI-------------");
    apply_inst({4'h1, 4'h2, 4'h0, 4'h3}); // ANDI
    $display("-------------TEST 2: ORI-------------");
    apply_inst({4'h2, 4'h2, 4'h0, 4'h3}); // ORI
    $display("-------------TEST 3: XORI-------------");
    apply_inst({4'h3, 4'h2, 4'h0, 4'h3}); // XORI
    $display("-------------TEST 4: ADDI-------------");
    apply_inst({4'h5, 4'h2, 4'h0, 4'h3}); // ADDI
    $display("-------------TEST 5: SUBI-------------");
    apply_inst({4'h9, 4'h2, 4'h0, 4'h3}); // SUBI
    $display("-------------TEST 6: CMPI-------------");
    apply_inst({4'hB, 4'h2, 4'h0, 4'h3}); // CMPI
    $display("-------------TEST 7: MOVI-------------");
    apply_inst({4'hD, 4'h2, 4'h0, 4'h3}); // MOVI
    $display("-------------TEST 7: LSHI-------------");
    // $display("-------------TEST 11: MULI-------------");
    // apply_inst({4'hE, 4'h2, 4'h0, 4'h3}); // MULI
    $display("-------------TEST 8: LUI-------------");
    apply_inst({4'hF, 4'h2, 4'h0, 4'h3}); // LUI

    $display("\n=== Testing SHIFT Opcode ===");
    apply_inst({4'h8, 4'h2, 4'h4, 4'h3}); // SHIFT + LSH op_ext=4

    $display("\n=== Testing ALU Register-Register Instructions ===");
    $display("-------------TEST 1: AND-------------");
    apply_inst({4'h0, 4'h2, 4'h1, 4'h3}); // AND
    $display("-------------TEST 2: OR-------------");
    apply_inst({4'h0, 4'h2, 4'h2, 4'h3}); // OR
    $display("-------------TEST 3: XOR-------------");
    apply_inst({4'h0, 4'h2, 4'h3, 4'h3}); // XOR
    $display("-------------TEST 4: LSH-------------");
    apply_inst({4'h0, 4'h2, 4'h4, 4'h3}); // LSH
    $display("-------------TEST 5: ADD-------------");
    apply_inst({4'h0, 4'h2, 4'h5, 4'h3}); // ADD
    $display("-------------TEST 6: JAL-------------");
    apply_inst({4'h0, 4'h2, 4'h8, 4'h3}); // JAL
    $display("-------------TEST 7: SUB-------------");
    apply_inst({4'h0, 4'h2, 4'h9, 4'h3}); // SUB
    $display("-------------TEST 9: CMP-------------");
    apply_inst({4'h0, 4'h2, 4'hB, 4'h3}); // CMP
    $display("-------------TEST 10: JCOND-------------");
    apply_inst({4'h0, 4'h2, 4'hC, 4'h3}); // JCOND
    $display("-------------TEST 11: MOV-------------");
    apply_inst({4'h0, 4'h2, 4'hD, 4'h3}); // MOV
    // $display("-------------TEST 12: MUL-------------");
    // apply_inst({4'h0, 4'h2, 4'hE, 4'h3}); // MUL
    

    $display("\n=== Testing MEM Instructions ===");
    apply_inst({4'h4, 4'h2, 4'h0, 4'h3}); // LOAD
    apply_inst({4'h4, 4'h2, 4'h4, 4'h3}); // STOR

    $display("\nAll tests completed.\n");
    $finish;
end

   



endmodule