module decoder(
    input logic [15:0] inst,
 
    output logic [3:0] opcode, 
    output logic [3:0] r_dest, 
    output logic [3:0] op_ext, 
    output logic [3:0] r_src,
    output logic [7:0] imm,
    output logic sub, 
    output logic rf_we, 
    output logic [3:0] alu_op, 

    // control mux signals
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
); 
    typedef enum logic [3:0] {
        ALU = 4'h0, // look at OP Code Ext
        ANDI = 4'h1, 
        ORI = 4'h2,
        XORI = 4'h3,
        MEM = 4'h4, // look at OP Code Ext 
        ADDI = 4'h5, 
        LSHI = 4'h8, 
        SUBI = 4'h9, 
        CMPI = 4'hb, 
        BCOND = 4'hc, 
        MOVI = 4'hd, 
        // MULI = 4'he 
        LUI = 4'hf 
    } opcodes; 

    /* everything // is unused */

    typedef enum logic [3:0] { 
        AND = 4'h1, 
        OR = 4'h2,
        XOR = 4'h3, 
        LSH = 4'h4,
        ADD = 4'h5, 
        JAL = 4'h8, // is this needed
        SUB = 4'h9, 
        CMP = 4'hb, 
        JCOND = 4'hc, 
        MOV = 4'hd  
        //  MUL = 4'he 
    } op_ext_alu; 

    typedef enum logic [3:0] {
        LOAD = 4'h0,
        STOR = 4'h4  
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
        rf_we = 1'b0; 
        sub = 1'b0; 
        alu_op = 4'b0000; 

        case(opcode)
            ANDI, ORI, XORI, ADDI, SUBI, CMPI: begin 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1; 

                case(op_ext)
                    ADDI: begin 
                        alu_op = 4'b0001; 
                    end 

                    ANDI: begin 
                        alu_op = 4'b0010; 
                    end 

                    ORI: begin 
                        alu_op = 4'b0100; 
                    end 

                    XORI: begin 
                        alu_op = 4'b1000; 
                    end 

                    SUBI: begin 
                        alu_op = 4'b0001;                         
                        sub = 1'b1; 
                    end 

                    CMPI: begin 
                        alu_op = 4'b0001; 
                        sub = 1'b1; 
                    end

                    default: begin 

                    end 
                endcase
            end

            ALU: begin
                alu = 1'b1; 
                rf_we = 1'b1; 

                case(op_ext)
                    ADD: begin 
                        alu_op = 4'b0001; 
                    end 

                    AND: begin 
                        alu_op = 4'b0010; 
                    end 

                    OR: begin 
                        alu_op = 4'b0100; 
                    end 

                    XOR: begin 
                        alu_op = 4'b1000; 
                    end 

                    SUB: begin 
                        alu_op = 4'b0001;                         
                        sub = 1'b1; 
                    end 

                    CMP: begin 
                        alu_op = 4'b0001; 
                        sub = 1'b1; 
                    end

                    default: begin 

                    end 
                endcase
            end 

            MOV: begin 
                mov = 1'b1; 
                alu_op = 4'b0001; 
                alu = 1'b1; 
                rf_we = 1'b1; 
            end 

            MOVI: begin 
                mov = 1'b1; 
                lui = 1'b1; 
                alu_imm = 1'b1; 
                alu_op = 4'b0001;
                alu = 1'b1;  
                rf_we = 1'b1;
            end 


            LSH: begin 
                shift = 1'b1; 
                rf_we = 1'b1; 
                lsh = 1'b1; 
            end 

            LSHI: begin 
                shift = 1'b1; 
                rf_we = 1'b1; 
                lshi = 1'b1; 
            end 

            LUI: begin 
                shift = 1'b1;
                lui = 1'b1; 
                rf_we = 1'b1; 
            end 

            MEM: begin 
                mem = 1'b1; 
                case(op_ext) 
                    LOAD: begin 
                        rf_we = 1'b1; 
                    end 

                    STOR: begin 
                        rf_we = 1'b0; 
                    end 
                endcase
            end 

            // JAL: begin // is this needed??  

            // end 

            // Nothing done in decoder

            BCOND: begin 

            end 

            JCOND: begin 

            end 

            default: begin 

            end  

        endcase 

    end 


endmodule