// TODO: 
// Save some control bits for more than one cycle (e.g. write_enable)
// Make some or all of the flip-flops scannable (scan IR and PSR) - If you dont have an external program memory interface

// BUGFIX:
// 1. Replace rst with active-low reset rstn
// 2. Replace Z with Z_B(inverted Z) since we receive Z_bar from the alu output
// 3. inst <= {inst_i[14:0], scan_i} should have been inst <= {inst[14:0], scan_i}
// 4. Fix GE: (N==0 || Z_B==1) (Should (N==1 || Z_B==0)) for bcond and jcond
// 5. Fix Jcond FS typo (bcond_o --> jcond_o)
// 6. With synchronous IMEM and DMEM, nop logic is needed
// 7. CMP and CMPI affect only different PSR flags and do not write back any result, rf_we_o should be 0
// 8. DMEM's WEB should be active-LOW instead of active-HIGH
// 9. rf_we_o is control signal that doesn't have to be stored - should be combinational logic
// 10. Fix the stall logic
// 11. Add the flush signal to handle the taken branch

module decoder(
    
    input logic [15:0] inst_i,
    input logic clk, 
    input logic rstn, 

    // ALU flags
    input logic Z_i, 
    input logic N_i, 
    input logic F_i,

    // Scan Chain 
    input logic scan_en_i, 
    input logic scan_i, 
    output logic scan_o, 

    // for RF 
    output logic [15:0] r_dest_o, 
    output logic [15:0] r_src_o, 
    output logic rf_we_o,
    output logic [15:0] slave_we_o,

    // for alu
    output logic [3:0] alu_op_o, 
    output logic sub_o, 

    // for shfiter 
    output logic [7:0] imm_o,

    // for pc 
    output logic bcond_o, 
    output logic jcond_o,

    // for store
    output logic dmem_we, 

    // control mux signals
    output logic alu_imm_o,
    output logic mov_o, 
    output logic lui_o, 
    output logic mem_o, 
    output logic alu_o, 
    output logic pc_o, 
    output logic shift_o, 
    output logic lsh_o, 
    output logic lshi_o 

); 

    localparam logic [15:0] NOP = 16'h0020;

    logic        Z_B, N, F; 
    logic [3:0]  r_dest_shift, r_src_shift; 
    logic [15:0] inst;

    // For handling branch taken
    logic        branch_flush;

    typedef enum logic unsigned [3:0] {
        ALU = 4'h0, // look at OP Code Ext
        ANDI = 4'h1, 
        ORI = 4'h2,
        XORI = 4'h3,
        MEM = 4'h4, // look at OP Code Ext 
        ADDI = 4'h5, 
        SHIFT = 4'h8, 
        SUBI = 4'h9, 
        CMPI = 4'hb, 
        BCOND = 4'hc, 
        MOVI = 4'hd, 
        LUI = 4'hf 
    } opcode_e; 


    typedef enum logic unsigned [3:0] { 
        AND = 4'h1, 
        OR = 4'h2,
        XOR = 4'h3, 
        STOR = 4'h4, 
        ADD = 4'h5, 
        SUB = 4'h9, 
        CMP = 4'hb, 
        MOV = 4'hd,
        LOAD = 4'h0, 
        JAL = 4'h8, 
        JCOND = 4'hc  
    } op_ext_e; 
    

    typedef enum logic unsigned [3:0] {
        EQ = 4'h0,
        NE = 4'h1, 
        GT = 4'h6,  
        LE = 4'h7, 
        FS = 4'h8, 
        FC = 4'h9, 
        LT = 4'hc,
        GE = 4'hd 
    } branch_condition_e; 
    
    opcode_e opcode;
    op_ext_e op_ext;
    branch_condition_e branch_condition;
    

    // INSTRUCTION REGISTER + FLIPFLOPS
    always_ff @(posedge clk) begin 
        if(!rstn) begin 
            Z_B    <= 1;
            F    <= 0; 
            N    <= 0; 
            inst <= '0;  
        end else if(scan_en_i) begin
            Z_B    <= 1;
            F    <= 0; 
            N    <= 0;  
            inst <= {inst[14:0], scan_i};
        end else if (branch_flush) begin
            inst <= NOP;
        end else begin 
            Z_B    <= Z_i; 
            F    <= F_i; 
            N    <= N_i;
            inst <= inst_i[15:0];
        end 
    end 

    always_ff @(posedge clk) begin 
        if (!rstn) begin
            scan_o <= 1'b0; 
        end else begin 
            scan_o <= inst[15]; 
        end 
    end 



    logic [15:0] r_dest;
    logic [15:0] r_src;
    
    always_ff @(negedge clk) begin
        if (!rstn) begin
            slave_we_o <= 'd0;
        end else begin
            slave_we_o <= r_dest;
        end
    end


    always_comb begin  
        opcode = inst[15:12]; 
        r_dest_shift = inst[11:8]; 
        r_src_shift  = inst[3:0]; 
        branch_condition   = inst[11:8]; 
        op_ext = inst[7:4]; 
        
        imm_o    = inst[7:0]; 

        sub_o = 1'b0;
        alu_op_o = '0; 

        dmem_we = 1'b1; 
        rf_we_o = 1'b0;
        alu_imm_o = 1'b0;
        mov_o = 1'b0;
        lui_o = 1'b0;
        mem_o = 1'b0;
        alu_o = 1'b0;
        pc_o = 1'b0;
        shift_o = 1'b0;
        lsh_o = 1'b0;
        lshi_o = 1'b0;
        bcond_o = 1'b0; 
        jcond_o = 1'b0; 

        branch_flush = 1'b0;

        r_dest = 1'b1 << r_dest_shift;
        r_src = 1'b1 << r_src_shift;

        r_dest_o = r_dest;
        r_src_o = r_src; 


        case(opcode)

            // IMMEDIATE INSTRUCTIONS
            ADDI: begin 
                alu_op_o = 4'b0001; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b1; 
                lui_o = 1'b1;                
            end 

            ANDI: begin 
                alu_op_o = 4'b0010; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b1; 
                lui_o = 1'b1;                
            end 

            ORI: begin 
                alu_op_o = 4'b0100; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b1; 
                lui_o = 1'b1;                
            end 

            XORI: begin 
                alu_op_o = 4'b1000; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b1; 
                lui_o = 1'b1;                
            end 

            SUBI: begin 
                alu_op_o = 4'b0001;                         
                sub_o = 1'b1; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b1; 
                lui_o = 1'b1;                
            end 

            CMPI: begin 
                alu_op_o = 4'b0001; 
                sub_o = 1'b1; 
                alu_imm_o = 1'b1; 
                alu_o = 1'b1;
                rf_we_o = 1'b0; 
                lui_o = 1'b1;                
            end

            // ALU INSTRUCITONS 
            ALU: begin
                alu_o = 1'b1; 
                rf_we_o = 1'b1; 

                case(op_ext)
                    ADD: begin 
                        alu_op_o = 4'b0001; 
                    end 

                    AND: begin 
                        alu_op_o = 4'b0010; 
                    end 

                    OR: begin 
                        alu_op_o = 4'b0100; 
                    end 

                    XOR: begin 
                        alu_op_o = 4'b1000; 
                    end 

                    SUB: begin 
                        alu_op_o = 4'b0001;                         
                        sub_o = 1'b1; 
                    end 

                    CMP: begin 
                        alu_op_o = 4'b0001; 
                        sub_o = 1'b1; 
                        rf_we_o = 1'b0; 
                    end
                    
                    MOV: begin 
                        mov_o = 1'b1; 
                        alu_op_o = 4'b0001; 
                        alu_o = 1'b1; 
                        rf_we_o = 1'b1; 
                    end 

                    default: begin 

                    end 
                endcase
            end 

            // SHIFT INSTRUCTIONS
            SHIFT: begin
                shift_o = 1'b1;
                rf_we_o = 1'b1;

                casez(op_ext)
                    4'b0100: begin  // LSH
                        lsh_o = 1'b1;
                    end

                    4'b000?: begin  // LSHI
                        lshi_o = 1'b1;
                    end

                    default: begin

                    end

                endcase
            end
            
            
            MOVI: begin 
                mov_o = 1'b1; 
                lui_o = 1'b1; 
                alu_imm_o = 1'b1; 
                alu_op_o = 4'b0001;
                alu_o = 1'b1;  
                rf_we_o = 1'b1;       
            end 

            LUI: begin 
                shift_o = 1'b1;
                lui_o = 1'b1; 
                rf_we_o = 1'b1; 
            end 

            MEM: begin 
                case(op_ext) 
                    LOAD: begin 
                        mem_o = 1'b1; 
                        rf_we_o = 1'b1;
                    end 

                    4'b0100: begin // STORE
                        mem_o = 1'b1;  
                        rf_we_o = 1'b0; 
                        dmem_we = 1'b0; 
                    end 

                    JAL: begin 
                        rf_we_o = 1'b1; 
                        pc_o = 1'b1; 
                        jcond_o = 1'b1; 
                    end  

                    JCOND: begin
                        case(branch_condition)
                            EQ: begin 
                                jcond_o = (Z_B==0) ? 1'b1 : 1'b0; 
                            end 

                            NE: begin 
                                jcond_o = (Z_B==1) ? 1'b1 : 1'b0; 
                            end 

                            GE: begin 
                                jcond_o = (N==1 || Z_B==0) ? 1'b1 : 1'b0; 
                            end 

                            GT: begin 
                                jcond_o = (N==1) ? 1'b1 : 0; 
                            end   

                            LE: begin 
                                jcond_o = (N==0) ? 1'b1 : 1'b0; 
                            end 

                            FS: begin 
                                jcond_o = (F==1) ? 1'b1 : 1'b0; 
                            end 

                            FC: begin 
                                jcond_o = (F==0) ? 1'b1 : 1'b0; 
                            end 

                            LT: begin 
                                jcond_o = (N==0 && Z_B==1) ? 1'b1 : 1'b0; 
                            end 
                            
                            default: begin 
                            
                            end 
                        endcase
                    end 
                endcase
            end 

            // might need FSM 
            BCOND: begin 
                case(branch_condition)
                    EQ: begin 
                        bcond_o = (Z_B==0) ? 1'b1 : 1'b0; 
                    end 

                    NE: begin 
                        bcond_o = (Z_B==1) ? 1'b1 : 1'b0; 
                    end 

                    GE: begin 
                        bcond_o = (N==1 || Z_B==0) ? 1'b1 : 1'b0; 
                    end

                    GT: begin 
                        bcond_o = (N==1) ? 1'b1 : 1'b0; 
                    end   

                    LE: begin 
                        bcond_o = (N==0) ? 1'b1 : 1'b0; 
                    end 

                    FS: begin 
                        bcond_o = (F==1) ? 1'b1 : 1'b0; 
                    end 

                    FC: begin 
                        bcond_o = (F==0) ? 1'b1 : 1'b0; 
                    end 

                    LT: begin 
                        bcond_o = (N==0 && Z_B==1) ? 1'b1 : 1'b0; 
                    end 
                    
                    default: begin 
                    
                    end  
                endcase
            end 

            default: begin 

            end  

        endcase 

        branch_flush = bcond_o | jcond_o;

    end 


endmodule
