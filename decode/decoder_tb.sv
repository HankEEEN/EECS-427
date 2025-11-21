`timescale 1ns/1ps

module decoder_tb;

    // DUT signals
    logic clk;
    logic rst;

    logic [15:0] inst_in;
    logic Z_in, N_in, F_in;

    logic [15:0] r_dest;
    logic [15:0] r_src;
    logic rf_we;

    logic [3:0] alu_op;
    logic sub;

    logic [7:0] imm;

    logic bcond;
    logic jcond;

    logic alu_imm;
    logic mov;
    logic lui;
    logic mem;
    logic alu;
    logic pc;
    logic shift;
    logic lsh;
    logic lshi;

    // Instantiate DUT
    decoder dut (
        .inst_in(inst_in),
        .clk(clk),
        .rst(rst),
        .Z_in(Z_in),
        .N_in(N_in),
        .F_in(F_in),
        .r_dest(r_dest),
        .r_src(r_src),
        .rf_we(rf_we),
        .alu_op(alu_op),
        .sub(sub),
        .imm(imm),
        .bcond(bcond),
        .jcond(jcond),
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

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Simple pretty-printer
    task automatic print_outputs(string name);
        $display("------------------------------------------------");
        $display("Time=%0t  INST=%h  <-- %s", $time, inst_in, name);
        $display("  alu=%0b alu_op=%b sub=%0b alu_imm=%0b mov=%0b lui=%0b",
                 alu, alu_op, sub, alu_imm, mov, lui);
        $display("  mem=%0b pc=%0b bcond=%0b jcond=%0b",
                 mem, pc, bcond, jcond);
        $display("  rf_we=%0b r_dest=%0b r_src=%0b imm=%0h",
                 rf_we, r_dest, r_src, imm);
        $display("  shift=%0b lsh=%0b lshi=%0b", shift, lsh, lshi);
        $display("  Flags in: Z=%0b N=%0b F=%0b", Z_in, N_in, F_in);
        $display("------------------------------------------------\n");
    endtask

    task automatic apply_instruction(input [15:0] instr, string name);
        inst_in = instr;
        @(posedge clk);  // let it latch into IR and decode
        #1;              // small delay for comb logic
        print_outputs(name);
    endtask

    initial begin
        $dumpfile("decoder.vcd"); 
        // Init
        clk   = 0;
        rst   = 1;
        inst_in = 16'h0000;
        Z_in = 0;
        N_in = 0;
        F_in = 0;

        // Reset sequence
        repeat (2) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // We'll use:
        //   Rdest = 1
        //   Rsrc  = 2
        //   Imm   = 0x0A
        // Encodings chosen from ISA PDF and your decoder's field usage.

        // ================
        // 1) Arithmetic & Logic (12 baseline)
        // ================

        // ADD  R2, R1 : 0000 Rdest 0101 Rsrc => 0000 0001 0101 0010 = 0x0152
        apply_instruction(16'h0152, "ADD  R2, R1");

        // ADDI Imm, R1 : 0101 Rdest ImmHi ImmLo => 0101 0001 0000 1010 = 0x510A
        apply_instruction(16'h510A, "ADDI 0x0A, R1");

        // SUB  R2, R1 : 0000 Rdest 1001 Rsrc => 0000 0001 1001 0010 = 0x0192
        apply_instruction(16'h0192, "SUB  R2, R1");

        // SUBI Imm, R1 : 1001 Rdest ImmHi ImmLo => 1001 0001 0000 1010 = 0x910A
        apply_instruction(16'h910A, "SUBI 0x0A, R1");

        // CMP  R2, R1 : 0000 Rdest 1011 Rsrc => 0000 0001 1011 0010 = 0x01B2
        apply_instruction(16'h01B2, "CMP  R2, R1");

        // CMPI Imm, R1 : 1011 Rdest ImmHi ImmLo => 1011 0001 0000 1010 = 0xB10A
        apply_instruction(16'hB10A, "CMPI 0x0A, R1");

        // AND  R2, R1 : 0000 Rdest 0001 Rsrc => 0000 0001 0001 0010 = 0x0112
        apply_instruction(16'h0112, "AND  R2, R1");

        // ANDI Imm, R1 : 0001 Rdest ImmHi ImmLo > 0001 0001 0000 1010 = 0x110A
        apply_instruction(16'h110A, "ANDI 0x0A, R1");

        // OR   R2, R1 : 0000 Rdest 0010 Rsrc => 0000 0001 0010 0010 = 0x0122
        apply_instruction(16'h0122, "OR   R2, R1");

        // ORI  Imm, R1 : 0010 Rdest ImmHi ImmLo => 0010 0001 0000 1010 = 0x210A
        apply_instruction(16'h210A, "ORI  0x0A, R1");

        // XOR  R2, R1 : 0000 Rdest 0011 Rsrc => 0000 0001 0011 0010 = 0x0132
        apply_instruction(16'h0132, "XOR  R2, R1");

        // XORI Imm, R1 : 0011 Rdest ImmHi ImmLo => 0011 0001 0000 1010 = 0x310A
        apply_instruction(16'h310A, "XORI 0x0A, R1");

        // ================
        // 2) MOV & Immediates (3 baseline)
        // ================

        // MOV  R2, R1 : 0000 Rdest 1101 Rsrc => 0000 0001 1101 0010 = 0x01D2
        apply_instruction(16'h01D2, "MOV  R2, R1");

        // MOVI Imm, R1 : 1101 Rdest ImmHi ImmLo => 1101 0001 0000 1010 = 0xD10A
        apply_instruction(16'hD10A, "MOVI 0x0A, R1");

        // LUI  Imm, R1 : 1111 Rdest ImmHi ImmLo => 1111 0001 0000 1010 = 0xF10A
        apply_instruction(16'hF10A, "LUI  0x0A, R1");

        // ================
        // 3) Shifts (2 baseline)
        // ================

        // LSH  R2, R1 : 1000 Rdest 0100 Ramount => 1000 0001 0100 0010 = 0x8142
        // (ISA: opcode=1000, op_ext=0100)
        apply_instruction(16'h8142, "LSH  R2, R1");

        // LSHI Imm(2), R1 : 1000 Rdest 000s ImmLo
        // For a simple left shift, s=0, Imm=0x02 => 1000 0001 0000 0010 = 0x8102
        apply_instruction(16'h8102, "LSHI 2, R1");

        // ================
        // 4) Memory (2 baseline)
        // ================

        // LOAD R1, R2 : 0100 Rdest 0000 Raddr => 0100 0001 0000 0010 = 0x4102
        apply_instruction(16'h4102, "LOAD R1, [R2]");

        // STOR R1, R2 : 0100 Rsrc 0100 Raddr => 0100 0001 0100 0010 = 0x4142
        apply_instruction(16'h4142, "STOR R1 -> [R2]");


        // TODO: MAKE BETTER BRANCH TESTS
        // ================
        // 5) Branch / Jump (3 baseline)
        // ================
        // We’ll use cond = EQ (0000) for examples.

        // First, set flags so EQ is true (Z=1)
        Z_in = 1; N_in = 0; F_in = 0;
        @(posedge clk);

        // Bcond EQ, disp=0x0A : 1100 cond DispHi DispLo
        // => 1100 0000 0000 1010 = 0xC00A
        apply_instruction(16'hC00A, "Bcond EQ, disp=0x0A");

        // Jcond EQ, R2 : 0100 cond 1100 Rtarget
        // => 0100 0000 1100 0010 = 0x40C2
        apply_instruction(16'h40C2, "Jcond EQ, R2");

        // JAL R1, R2 : 0100 Rlink 1000 Rtarget
        // => 0100 0001 1000 0010 = 0x4182
        apply_instruction(16'h4182, "JAL R1 <- link, jump R2");

        $display("\n*** Completed stimulus for all 22 baseline EECS 427 instructions ***\n");
        $finish;
    end

endmodule
