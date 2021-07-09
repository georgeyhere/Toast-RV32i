`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2021 05:48:27 PM
// Design Name: 
// Module Name: testbench
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


package testbench_pkg;


//----------------------------------------------------------------------------
//                               Classes:
//----------------------------------------------------------------------------  
    class get_branch_data;
        randc bit [4:0]  rd1;
        randc bit [4:0]  rd2;
        randc bit [31:0] imm;
        
        constraint rd1_range {rd1 > 0;    
                             rd1 <= 31;} 
        constraint rd2_range {rd1 > 0;    
                             rd1 <= 31;} 

        constraint imm_range {imm <= (2**32 - 1);}

        
    endclass
    
    class instn_LUI; 
        // generates a LUI instruction w/ random non-zero destination and random immediate.
        randc bit [4:0]  rd;
        randc bit [31:0] imm;
        
        constraint rd_range {rd > 0;    
                             rd <= 31;} 

        constraint imm_range {imm <= (2**20 - 1);}
    endclass
    
    class instn_LI;
        randc bit [4:0]  rd;
        randc bit [31:0] imm;
        
        constraint rd_range {rd > 0;    
                             rd <= 31;} 

        constraint imm_range {imm <= (2**32 - 1);}

        int m = (imm << 20) >> 20;       // sign extend low 12 bits
        int k = ((imm - m) >> 12) << 12; // the 20 high bits
    endclass 

    class coverage;
        bit [31:0] instruction;
        bit        checker_pass;
        
        function display();
            $timeformat(-9, 2, "ns");
            $display("[T=%0t],  ", $time);
        endfunction

        covergroup CovGrp@(posedge checker_pass);
            coverpoint instruction[6:0] {
                bins OPCODE_OP     = {`OPCODE_OP};
                bins OPCODE_OP_IMM = {`OPCODE_OP_IMM};
                bins OPCODE_BRANCH = {`OPCODE_BRANCH};
                bins OPCODE_LUI    = {`OPCODE_LUI};
                bins OPCODE_AUIPC  = {`OPCODE_AUIPC};
                bins OPCODE_JAL    = {`OPCODE_JAL};
                bins OPCODE_JALR   = {`OPCODE_JALR};
                bins OPCODE_LOAD   = {`OPCODE_LOAD};
                bins OPCODE_STORE  = {`OPCODE_STORE};
            }
        endgroup  
    endclass 

//----------------------------------------------------------------------------
//                                Utility:
//----------------------------------------------------------------------------  
    
    

//----------------------------------------------------------------------------
//                                  R - Type:
//----------------------------------------------------------------------------    
    
    function bit [31:0] encode_ADD (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, 3'b0, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SUB (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_SRA_I_SUB, rs2, rs1, 3'b0, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SLL (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLL, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SLT (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLT, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SLTU (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLTU, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_XOR (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_XOR, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SRL (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_SRA (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_SRA_I_SUB, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_OR (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_OR, rd, `OPCODE_OP};
        end
    endfunction

    function bit [31:0] encode_AND (input [4:0] rd, rs1, rs2); 
        begin
            return {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_AND, rd, `OPCODE_OP};
        end
    endfunction

//----------------------------------------------------------------------------
//                                  I - Type:
//----------------------------------------------------------------------------
    function bit [31:0] encode_ADDI (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, 3'b000, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_SLTI (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, `FUNCT3_SLTI, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_SLTIU (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, `FUNCT3_SLTIU, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_XORI (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, `FUNCT3_XOR, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_ORI (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, `FUNCT3_OR, rd, `OPCODE_OP_IMM};
        end
    endfunction
    
    function bit [31:0] encode_ANDI (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm, rs1, `FUNCT3_AND, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_SLLI (input [4:0] rd, rs1, input [4:0] shamt); 
        begin
            return {`FUNCT7_DEFAULT,shamt, rs1, `FUNCT3_SLLI, rd, `OPCODE_OP_IMM};
        end
    endfunction

    function bit [31:0] encode_SRLI (input [4:0] rd, rs1, input [4:0] shamt); 
        begin
            return {`FUNCT7_SRA_I_SUB, shamt, rs1, `FUNCT3_SRAI_SRLI, rd, `OPCODE_OP_IMM};
        end
    endfunction


//----------------------------------------------------------------------------
//                                  Branches:
//----------------------------------------------------------------------------

    function bit [31:0] encode_BEQ (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BEQ, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

    function bit [31:0] encode_BNE (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BNE, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

    function bit [31:0] encode_BLT (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BLT, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

    function bit [31:0] encode_BGE (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BGE, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

    function bit [31:0] encode_BLTU (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BLTU, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

    function bit [31:0] encode_BGEU (input [4:0] rs1, rs2, input [12:0] imm); 
        begin
            return {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BGEU, imm[4:1], imm[11], `OPCODE_BRANCH};
        end
    endfunction

//----------------------------------------------------------------------------
//                            LUI and AUIPC:
//----------------------------------------------------------------------------    
    function bit [31:0] encode_LUI (input [4:0] rd, input [31:0] imm); 
        begin
            return {imm[31:12], rd, `OPCODE_LUI};
        end
    endfunction

    function bit [31:0] encode_AUIPC (input [4:0] rd, input [31:0] imm); 
        begin
            return {imm[19:0], rd, `OPCODE_AUIPC};
        end
    endfunction

//----------------------------------------------------------------------------
//                                  Jumps:
//----------------------------------------------------------------------------    
    function bit [31:0] encode_JAL (input [4:0] rd, input [20:0] imm); 
        begin
            return {imm[20], imm[10:1], imm[11], imm[19:12], rd, `OPCODE_JAL};
        end
    endfunction

    function bit [31:0] encode_JALR (input [4:0] rd, rs1, input [11:0] imm); 
        begin
            return {imm[11:0], rs1, `FUNCT3_ADD_SUB, rd, `OPCODE_JALR};
        end
    endfunction


//----------------------------------------------------------------------------
//                                  Loads:
//----------------------------------------------------------------------------    
/*
    task encode_LB;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm, rs1, `FUNCT3_LB, rd, `OPCODE_LOAD};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_LH;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm, rs1, `FUNCT3_LH, rd, `OPCODE_LOAD};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask 

    task encode_LW;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm, rs1, `FUNCT3_LW, rd, `OPCODE_LOAD};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_LBU;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm, rs1, `FUNCT3_LBU, rd, `OPCODE_LOAD};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_LHU;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm, rs1, `FUNCT3_LHU, rd, `OPCODE_LOAD};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

*/
//----------------------------------------------------------------------------
//                                  Stores:
//----------------------------------------------------------------------------  

    
endpackage // testbench
