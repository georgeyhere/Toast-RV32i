`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2021 10:06:41 AM
// Design Name: 
// Module Name: RV32I_encoding
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import RV32I_definitions::*;

package RV32I_encoding;

// ===========================================================================
// 				              Instruction Formats
// ===========================================================================    
    
    // R - Type
    typedef struct packed
    {
        logic[6:0] FUNCT7;
        logic[4:0] Rs2;
        logic[4:0] Rs1;
        logic[2:0] FUNCT3;
        logic[4:0] Rd;
        logic[6:0] OPCODE;
    } R_TYPE_INSTRUCTION;
    
    
    // I - Type
    typedef struct packed
    {
        logic[11:0] Imm12; 
        logic[4:0]  Rs1;
        logic[2:0]  FUNCT3;
        logic[4:0]  Rd;
        logic[6:0]  OPCODE;
    } I_TYPE_INSTRUCTION;
    

// ===========================================================================
//                            Instruction Generation   
// ===========================================================================    

//----------------------------------------------------------------------------
//                                  R - Type:
//----------------------------------------------------------------------------
    function [31:0]ADD_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION ADD_test; 
            ADD_test.FUNCT7 = `FUNCT7_DEFAULT;
            ADD_test.Rs2    = rs2;
            ADD_test.Rs1    = rs1;
            ADD_test.FUNCT3 = `FUNCT3_ADD_SUB;
            ADD_test.Rd     = rd;
            ADD_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", ADD_test);
            $fclose(filewrite);
            ADD_gen = ADD_test;
        end
    endfunction
    
    
    function [31:0]SUB_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a"); 
            R_TYPE_INSTRUCTION SUB_test; 
            SUB_test.FUNCT7 = `FUNCT7_SRA_I_SUB;
            SUB_test.Rs2    = rs2;
            SUB_test.Rs1    = rs1;
            SUB_test.FUNCT3 = `FUNCT3_ADD_SUB;
            SUB_test.Rd     = rd;
            SUB_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SUB_test);
            $fclose(filewrite);
            SUB_gen = SUB_test;
        end
    endfunction
    
    function [31:0]SLL_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SLL_test; 
            SLL_test.FUNCT7 = `FUNCT7_DEFAULT;
            SLL_test.Rs2    = rs2;
            SLL_test.Rs1    = rs1;
            SLL_test.FUNCT3 = `FUNCT3_SLL;
            SLL_test.Rd     = rd;
            SLL_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SLL_test);
            $fclose(filewrite);
            SLL_gen = SLL_test;
        end
    endfunction
    
    function [31:0]SLTU_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SLTU_test; 
            SLTU_test.FUNCT7 = `FUNCT7_DEFAULT;
            SLTU_test.Rs2    = rs2;
            SLTU_test.Rs1    = rs1;
            SLTU_test.FUNCT3 = `FUNCT3_SLTU;
            SLTU_test.Rd     = rd;
            SLTU_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SLTU_test);
            $fclose(filewrite);
            SLTU_gen = SLTU_test;
        end
    endfunction
    
    function [31:0]XOR_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION XOR_test; 
            XOR_test.FUNCT7 = `FUNCT7_DEFAULT;
            XOR_test.Rs2    = rs2;
            XOR_test.Rs1    = rs1;
            XOR_test.FUNCT3 = `FUNCT3_XOR;
            XOR_test.Rd     = rd;
            XOR_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", XOR_test);
            $fclose(filewrite);
            XOR_gen = XOR_test;
        end
    endfunction
    
    function [31:0]SRL_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SRL_test; 
            SRL_test.FUNCT7 = `FUNCT7_DEFAULT;
            SRL_test.Rs2    = rs2;
            SRL_test.Rs1    = rs1;
            SRL_test.FUNCT3 = `FUNCT3_SRL_SRA;
            SRL_test.Rd     = rd;
            SRL_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SRL_test);
            $fclose(filewrite);
            SRL_gen  = SRL_test;
        end
    endfunction
    
    function [31:0]SRA_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SRA_test; 
            SRA_test.FUNCT7 = `FUNCT7_SRA_I_SUB;
            SRA_test.Rs2    = rs2;
            SRA_test.Rs1    = rs1;
            SRA_test.FUNCT3 = `FUNCT3_SRL_SRA;
            SRA_test.Rd     = rd;
            SRA_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SRA_test);
            $fclose(filewrite);
            SRA_gen = SRA_test;
        end
    endfunction
    
    function [31:0]OR_gen (input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION OR_test; 
            OR_test.FUNCT7 = `FUNCT7_DEFAULT;
            OR_test.Rs2    = rs2;
            OR_test.Rs1    = rs1;
            OR_test.FUNCT3 = `FUNCT3_OR;
            OR_test.Rd     = rd;
            OR_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", OR_test);
            $fclose(filewrite);
            OR_gen = OR_test;
        end
    endfunction
    
    function [31:0]AND_gen(input [4:0] rd, rs1, rs2);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION AND_test; 
            AND_test.FUNCT7 = `FUNCT7_DEFAULT;
            AND_test.Rs2    = rs2;
            AND_test.Rs1    = rs1;
            AND_test.FUNCT3 = `FUNCT3_AND;
            AND_test.Rd     = rd;
            AND_test.OPCODE = `OPCODE_OP;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", AND_test);
            $fclose(filewrite);
            AND_gen = AND_test;
        end
    endfunction

//----------------------------------------------------------------------------
//                                  I - Type:
//----------------------------------------------------------------------------
    
    // - SLLI, SRLI, and SRAI use R-type instruction *encoding* but should NOT
    //   be confused for R-Type instructions.
    // - Rs2 field for these instructions contains 5 bit immediate shamt, or shift amount
    // - These instructions also use the IMM opcode.
    
    function [31:0]SLLI_gen(input [4:0] rd, rs1, shamt);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SLLI_test; 
            SLLI_test.FUNCT7 = `FUNCT7_DEFAULT;
            SLLI_test.Rs2    = shamt;
            SLLI_test.Rs1    = rs1;
            SLLI_test.FUNCT3 = `FUNCT3_SLLI;
            SLLI_test.Rd     = rd;
            SLLI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SLLI_test);
            $fclose(filewrite);
            SLLI_gen = SLLI_test;
        end
    endfunction
    
    function [31:0]SRLI_gen (input [4:0] rd, rs1, shamt);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SRLI_test; 
            SRLI_test.FUNCT7 = `FUNCT7_DEFAULT;
            SRLI_test.Rs2    = shamt;
            SRLI_test.Rs1    = rs1;
            SRLI_test.FUNCT3 = `FUNCT3_SRAI_SRLI;
            SRLI_test.Rd     = rd;
            SRLI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SRLI_test);
            $fclose(filewrite);
            SRLI_gen = SRLI_test;
        end
    endfunction
    
    function [31:0]SRAI_gen (input [4:0] rd, rs1, shamt);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            R_TYPE_INSTRUCTION SRAI_test; 
            SRAI_test.FUNCT7 = `FUNCT7_SRA_I_SUB;
            SRAI_test.Rs2    = shamt;
            SRAI_test.Rs1    = rs1;
            SRAI_test.FUNCT3 = `FUNCT3_SRAI_SRLI;
            SRAI_test.Rd     = rd;
            SRAI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SRAI_test);
            $fclose(filewrite);
            SRAI_gen = SRAI_test;
        end
    endfunction
    
    function [31:0]ADDI_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION ADDI_test; 
            ADDI_test.Imm12  = imm12;
            ADDI_test.Rs1    = rs1;
            ADDI_test.FUNCT3 = `FUNCT3_ADDI;
            ADDI_test.Rd     = rd;
            ADDI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", ADDI_test);
            $fclose(filewrite);
            ADDI_gen = ADDI_test;
        end
    endfunction
    
    function [31:0]SLTI_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION SLTI_test; 
            SLTI_test.Imm12  = imm12;
            SLTI_test.Rs1    = rs1;
            SLTI_test.FUNCT3 = `FUNCT3_SLTI;
            SLTI_test.Rd     = rd;
            SLTI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SLTI_test);
            $fclose(filewrite);
            SLTI_gen = SLTI_test;
        end
    endfunction
    
    function [31:0]SLTIU_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION SLTIU_test; 
            SLTIU_test.Imm12  = imm12;
            SLTIU_test.Rs1    = rs1;
            SLTIU_test.FUNCT3 = `FUNCT3_SLTIU;
            SLTIU_test.Rd     = rd;
            SLTIU_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", SLTIU_test);
            $fclose(filewrite);
            SLTIU_gen = SLTIU_test;
        end
    endfunction
    
    function [31:0]XORI_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION XORI_test; 
            XORI_test.Imm12  = imm12;
            XORI_test.Rs1    = rs1;
            XORI_test.FUNCT3 = `FUNCT3_XORI;
            XORI_test.Rd     = rd;
            XORI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", XORI_test);
            $fclose(filewrite);
            XORI_gen = XORI_test;
        end
    endfunction
    
    function [31:0]ORI_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION ORI_test; 
            ORI_test.Imm12  = imm12;
            ORI_test.Rs1    = rs1;
            ORI_test.FUNCT3 = `FUNCT3_ORI;
            ORI_test.Rd     = rd;
            ORI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", ORI_test);
            $fclose(filewrite);
            ORI_gen = ORI_test;
        end
    endfunction
    
    function [31:0]ANDI_gen (input [4:0] rd, rs1, input [11:0] imm12);        
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");  
            I_TYPE_INSTRUCTION ANDI_test; 
            ANDI_test.Imm12  = imm12;
            ANDI_test.Rs1    = rs1;
            ANDI_test.FUNCT3 = `FUNCT3_ANDI;
            ANDI_test.Rd     = rd;
            ANDI_test.OPCODE = `OPCODE_OP_IMM;
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            $fdisplay(filewrite, "%8h", ANDI_test);
            $fclose(filewrite);
            ANDI_gen = ANDI_test;
        end
    endfunction
  
//----------------------------------------------------------------------------
//                                  B - Type:
//----------------------------------------------------------------------------    
    function [31:0]BEQ_gen(input [4:0] rs1, rs2, input [12:0] imm);
        begin
            static int filewrite = $fopen("./IMEM.txt", "a");
            for(int i=0; i<3; i++) begin
                $fdisplay(filewrite, "%8b", 0);
            end
            BEQ_gen = {imm[12], imm[10:5], rs2, rs1, 3'b0, imm[4:1], imm[11], `OPCODE_BRANCH};
            $fdisplay(filewrite, "%8h", BEQ_gen);
            $fclose(filewrite);
        end
    endfunction

//----------------------------------------------------------------------------
//                                  J - Type:
//----------------------------------------------------------------------------        
    
   
endpackage