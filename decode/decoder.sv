module decoder(
    input logic [15:0] inst,
    output logic [3:0] opcode, 
    output logic [3:0] r_dest, 
    output logic [3:0] op_ext, 
    output logic [3:0] r_src,
    output logic [7:0] imm, 
    // for mux
    // alu_imm, mov, lui, mem, alu, pc, shift, lsh, lshi

    output logic alu_imm,
    output logic mov, 
    output logic lui, 
    output logic mem, 
    output logic alu, 
    output logic pc, 
    output logic shift, 
    output logic lsh, 
    output logic lshi 


    // output logic is_immediate, 
    // output logic is_mem,
    // output logic is_branch, 
    // output logic is_jump, 
    // output logic wr_en, 
    // output logic mem_read,
    // output logic mem_write
); 
    typedef enum logic [3:0] {
        ALU = 1'h0, // look at OP Code Ext
        ANDI = 1'h1, 
        ORI = 1'h2,
        XORI = 1'h3, 
        MEM = 1'h4, // look at OP Code Ext 
        ADDI = 1'h5, 
        ADDUI = 1'h6, 
        ADDCI = 1'h7, 
        SHIFT = 1'h8, 
        SUBI = 1'h9, 
        SUBCI = 1'ha, 
        CMPI = 1'hb, 
        BCOND = 1'hc, 
        MOVI = 1'hd, 
        MULI = 1'he, 
        LUI = 1'hf 
    } opcodes; 

    /* everything // is unused */

    typedef enum logic [3:0] {
        WAIT = 1'h0, // 
        AND = 1'h1, 
        OR = 1'h2,
        XOR = 1'h3, 
        LSH = 1'h4,  
        ADD = 1'h5, 
        ADDU = 1'h6, // 
        ADDC = 1'h7, // 
        JAL = 1'h8, 
        SUB = 1'h9, 
        SUBC = 1'ha, 
        CMP = 1'hb, 
        JCOND = 1'hc, 
        MOV = 1'hd, 
        MUL = 1'he, 

    } op_ext_alu; 

    typedef enum logic [3:0] {
        LOAD = 1'h0, 
        
        STOR = 1'h4,  
        SPR = 1'h5, // 
        ZRXB = 1'h6, // 
        EI = 1'h7, // 

        RETX = 1'h9,  // 
        TBIT = 1'ha, // 
        EXCP = 1'hb,  // 

        SCOND = 1'hd, // 
        TBITI = 1'he, //

    } op_ext_mem; 


    assign opcode = inst[15:12]; 
    assign r_dest = inst[11:8]; 
    assign op_ext = inst[7:4]; 
    assign r_src = inst[3:0]; 
    assign imm = inst[7:0]; 

    always_comb begin 
        alu_imm = 1'b0;
        mov = 1'b0;
        lui = 1'b0;
        mem = 1'b0;
        alu = 1'b0;
        pc = 1'b0;
        shift = 1'b0;
        lsh = 1'b0;
        lshi = 1'b0;

        case(opcode)
            ANDI, ORI, XORI, ADDI, ADDUI, ADDCI, SUBI, SUBCI, CMPI, MOVI, MULTI: begin 
                alu_imm = 1'b1; 
                alu = 1'b1;
                if(opcode == MOVI)
                    mov = 1'b1; 
            end

            LUI: begin 
                lui = 1'b1;
                alu = 1'b1;
            end 

            ALU: begin 
                case(opcode_ext_alu)

                endcase
            end 

            SHIFT: begin 
                shift = 1'b1;
                lsh = 1'b1;
            end 

            BCOND: begin 
                pc = 1'b1; 
            end 

            MEM: begin 
                mem = 1'b1; 
                case(op_ext_mem) 
                    LOAD: begin 
                        alu = 1'b1; 
                    end 

                    STORE: begin 
                        alu = 1'b0; 
                    end 
                endcase
            end 

            default: begin 

            end  

        endcase 
            
                

        // case(opcode)
        //     ANDI, ORI, XORI, ADDI, ADDUI, ADDCI, SUBI, SUBCI, CMPI, MOVI, MULI, LUI: begin 
        //         alu_imm = 1'b1; 
        //         wr_en = 1'b1; 
        //     end 

        //     SHIFT: begin 
        //         lsh = 1'b1; 
        //         wr_en = 1'b1;
        //     end 

        //     BCOND: begin 
        //         is_branch = 1'b1;
        //     end 

        //      MEM: begin
        //         case(op_ext)
        //             LOAD: begin
        //                 is_mem   = 1'b1;
        //                 wr_en    = 1'b1;
        //                 mem_read = 1'b1;
        //             end
        //             STOR: begin
        //                 is_mem    = 1'b1;
        //                 mem_write = 1'b1;
        //             end
        //             JCOND: begin 
        //                 is_jump = 1'b1;
        //             end
        //             JAL: begin
        //                 is_jump = 1'b1;
        //                 wr_en   = 1'b1; // writes link reg
        //             end
        //             default: begin
        //                 // do nothing
        //             end
        //         endcase
        //     end

        //     ALU: begin
        //         if (op_ext != 4'b1011) // skip CMP
        //             wr_en = 1'b1;
        //     end


        //     default: begin 

        //     end 

        // endcase

    end 


endmodule