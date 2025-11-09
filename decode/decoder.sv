module decoder(
    input logic [15:0] inst,
    output logic [3:0] opcode, 
    output logic [3:0] r_dest, 
    output logic [3:0] op_ext, 
    output logic [3:0] r_src,
    output logic [7:0] imm, 
    // for mux
    output logic is_immediate, 
    output logic is_mem,
    output logic is_branch, 
    output logic is_jump, 
    output logic wr_en, 
    output logic mem_read,
    output logic mem_write
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

    typedef enum logic [3:0] {
        LOAD = 1'h0,
        LPR = 1'h1, 
        SNXB = 1'h2,
        DI = 1'h3, 
        STOR = 1'h4,  
        SPR = 1'h5, 
        ZRXB = 1'h6, 
        EI = 1'h7, 
        JAL = 1'h8, // is this right 
        RETX = 1'h9, 
        TBIT = 1'ha, 
        EXCP = 1'hb, 
        JCOND = 1'hc, // is this right 
        SCOND = 1'hd, 
        TBITI = 1'he, 
        NA = 1'hf 
    } op_ext_mem; 



    assign opcode = inst[15:12]; 
    assign r_dest = inst[11:8]; 
    assign op_ext = inst[7:4]; 
    assign r_src = inst[3:0]; 
    assign imm = inst[7:0]; 

    always_comb begin 
        is_immediate = 1'b0;
        is_mem = 1'b0; 
        is_branch = 1'b0; 
        is_jump = 1'b0; 
        wr_en = 1'b0; 
        mem_read = 1'b0; 
        mem_write = 1'b0; 

        case(opcode)
            ANDI, ORI, XORI, ADDI, ADDUI, ADDCI, SUBI, SUBCI, CMPI, MOVI, MULI, LUI: begin 
                is_immediate = 1'b1; 
                wr_en = 1'b1; 
            end 

            SHIFT: begin 
                wr_en = 1'b1;
            end 

            BCOND: begin 
                is_branch = 1'b1;
            end 

             MEM: begin
                case(op_ext)
                    LOAD: begin
                        is_mem   = 1'b1;
                        wr_en    = 1'b1;
                        mem_read = 1'b1;
                    end
                    STOR: begin
                        is_mem    = 1'b1;
                        mem_write = 1'b1;
                    end
                    JCOND: begin 
                        is_jump = 1'b1;
                    end
                    JAL: begin
                        is_jump = 1'b1;
                        wr_en   = 1'b1; // writes link reg
                    end
                    default: begin
                        // do nothing
                    end
                endcase
            end

            ALU: begin
                if (op_ext != 4'b1011) // skip CMP
                    wr_en = 1'b1;
            end


            default: begin 

            end 

        endcase

    end 


endmodule