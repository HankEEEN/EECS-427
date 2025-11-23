// TODO: 
// Save some control bits for more than one cycle (e.g. write_enable)
// Make some or all of the flip-flops scannable (scan IR and PSR) - If you dont have an external program memory interface

module decoder(
    
    input logic [15:0] inst_in,
    input logic clk, 
    input logic rst, 

    // ALU flags
    input logic Z_in, 
    input logic N_in, 
    input logic F_in,

    // Scan Chain 
    input logic scan_en, 
    input logic scan_in, 
    output logic scan_out, 

    // for RF 
    output logic [15:0] r_dest, 
    output logic [15:0] r_src, 
    output logic rf_we,

    // for alu
    output logic [3:0] alu_op, 
    output logic sub, 

    // for shfiter 
    output logic [7:0] imm,

    // for pc 
    output logic bcond, 
    output logic jcond,

    // control mux signals
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

    logic        Z, N, F; 
    logic [3:0]  opcode, op_ext, cond, r_dest_shift, r_src_shift; 
    logic [15:0] inst; 
    

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

    typedef enum logic unsigned [3:0] { 
        AND = 4'h1, 
        OR = 4'h2,
        XOR = 4'h3, 
        LSH = 4'h4,
        ADD = 4'h5, 
        SUB = 4'h9, 
        CMP = 4'hb, 
        MOV = 4'hd  
        //  MUL = 4'he 
    } op_ext_alu; 

    typedef enum logic unsigned [3:0] {
        LOAD = 4'h0,
        STOR = 4'h4, 
        JAL = 4'h8, 
        JCOND = 4'hc  
    } op_ext_mem; 

    typedef enum logic unsigned[3:0] {
        EQ = 4'h0,
        NE = 4'h1, 
        GT = 4'h6,  
        LE = 4'h7, 
        FS = 4'h8, 
        FC = 4'h9, 
        LT = 4'hc,
        GE = 4'hd 
    } branch_conditions; 
    

    // INSTRUCTION REGISTER + FLIPFLOPS
    always_ff @(posedge clk) begin 
        if(rst) begin 
            Z    <= 0;
            F    <= 0; 
            N    <= 0; 
            inst <= '0;  
        end else if(scan_en) begin
            Z    <= 0;
            F    <= 0; 
            N    <= 0; 
            inst <= {inst[14:0], scan_in}; 
        end else begin 
            Z    <= Z_in; 
            F    <= F_in; 
            N    <= N_in;
            inst <= inst_in[15:0]; 
        end 
    end 

    always_ff @(posedge clk) begin 
        if (rst) begin 
            scan_out <= 1'b0; 
        end else begin 
            scan_out <= inst[15]; 
        end 
    end 


    always_comb begin  
        opcode = inst[15:12]; 
        r_dest_shift = inst[11:8]; 
        r_src_shift  = inst[3:0]; 
        cond   = inst[11:8]; 
        op_ext = inst[7:4]; 
        imm    = inst[7:0]; 

        sub = 1'b0;
        rf_we = 1'b0;  
        alu_op = '0; 

        alu_imm = 1'b0;
        mov = 1'b0;
        lui = 1'b0;
        mem = 1'b0;
        alu = 1'b0;
        pc = 1'b0;
        shift = 1'b0;
        lsh = 1'b0;
        lshi = 1'b0;
        bcond = 1'b0; 
        jcond = 1'b0; 

        r_dest = 1'b1 << r_dest_shift; 
        r_src = 1'b1 << r_src_shift; 


        case(opcode)

            // IMMEDIATE INSTRUCTIONS
            ADDI: begin 
                alu_op = 4'b0001; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end 

            ANDI: begin 
                alu_op = 4'b0010; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end 

            ORI: begin 
                alu_op = 4'b0100; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end 

            XORI: begin 
                alu_op = 4'b1000; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end 

            SUBI: begin 
                alu_op = 4'b0001;                         
                sub = 1'b1; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end 

            CMPI: begin 
                alu_op = 4'b0001; 
                sub = 1'b1; 
                alu_imm = 1'b1; 
                alu = 1'b1;
                rf_we = 1'b1; 
                lui = 1'b1;                
            end

            // ALU INSTRUCITONS 
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

            // SHIFT INSTRUCTIONS

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

            // BCOND IN CONTROLLER 
            MEM: begin 
                case(op_ext) 
                    LOAD: begin 
                        mem = 1'b1; 
                        rf_we = 1'b1; 
                    end 

                    STOR: begin
                        mem = 1'b1;  
                        rf_we = 1'b0; 
                    end 

                    JAL: begin 
                        rf_we = 1'b1; 
                        pc = 1'b1; 
                        jcond = 1'b1; 
                    end  

                    JCOND: begin
                        case(cond)
                            EQ: begin 
                                jcond = (Z==1) ? 1 : 0; 
                            end 

                            NE: begin 
                                jcond = (Z==0) ? 1 : 0; 
                            end 
                            GT: begin 
                                jcond = (N==1) ? 1 : 0; 
                            end   
                            LE: begin 
                                jcond = (N==0) ? 1 : 0; 
                            end 

                            FS: begin 
                                bcond = (F==1) ? 1 : 0; 
                            end 

                            FC: begin 
                                jcond = (F==0) ? 1 : 0; 
                            end 

                            LT: begin 
                                jcond = (N==0 && Z==0) ? 1 : 0; 
                            end 

                            GE: begin 
                                jcond = (N==0 || Z==0) ? 1 : 0; 
                            end 
                        endcase
                    end 
                endcase
            end 

            // might need FSM 
            BCOND: begin 
                case(cond)
                            EQ: begin 
                                bcond = (Z==1) ? 1 : 0; 
                            end 

                            NE: begin 
                                bcond = (Z==0) ? 1 : 0; 
                            end 
                            GT: begin 
                                bcond = (N==1) ? 1 : 0; 
                            end   
                            LE: begin 
                                bcond = (N==0) ? 1 : 0; 
                            end 

                            FS: begin 
                                bcond = (F==1) ? 1 : 0; 
                            end 

                            FC: begin 
                                bcond = (F==0) ? 1 : 0; 
                            end 

                            LT: begin 
                                bcond = (N==0 && Z==0) ? 1 : 0; 
                            end 

                            GE: begin 
                                bcond = (N==0 || Z==0) ? 1 : 0; 
                            end 
                        endcase
            end 

            default: begin 

            end  

        endcase 

    end 


endmodule