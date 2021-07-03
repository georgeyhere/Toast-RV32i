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


module testbench();

    reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst; 
    
    reg [31:0] instruction;
    reg [31:0] pc;
    
    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;     


    task insert_NOPs;
        input [4:0] count;
        begin
            for(int i=0; i<count; i++) begin
                instruction = 32'b0;
                UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
                pc = pc + 32'd4; 
            end
        end
    endtask

//----------------------------------------------------------------------------
//                                  R - Type:
//----------------------------------------------------------------------------    

    task encode_ADD;
        input [4:0]  rd;
        input [4:0]  rs1;
        input [4:0]  rs2;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, 3'b0, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask // encode_ADD

    task encode_SUB;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        begin
            instruction = {`FUNCT7_SRA_I_SUB, rs2, rs1, 3'b0, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_SLL;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLL, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_SLT;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLT, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_SLTU;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SLTU, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_XOR;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_XOR, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_SRL;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_SRA;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_SRA_I_SUB, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_OR;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_OR, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask

    task encode_AND;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;
        begin
            instruction = {`FUNCT7_DEFAULT, rs2, rs1, `FUNCT3_AND, rd, `OPCODE_OP};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask


//----------------------------------------------------------------------------
//                                  I - Type:
//----------------------------------------------------------------------------
    task encode_ADDI;
        input [4:0] rd;
	    input [4:0] rs1;
	    input [11:0] imm;
	    begin
	   	   instruction = {imm, rs1, 3'b000, rd, `OPCODE_OP_IMM};
	   	   UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
	   	   pc = pc + 32'd4;
	    end
    endtask
    

    task encode_SLTI;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
           instruction = {imm, rs1, `FUNCT3_SLTI, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask


    task encode_SLTIU;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
           instruction = {imm, rs1, `FUNCT3_SLTIU, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask


    task encode_XORI;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
           instruction = {imm, rs1, `FUNCT3_XOR, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask


    task encode_ORI;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
           instruction = {imm, rs1, `FUNCT3_OR, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask

    task encode_ANDI;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
           instruction = {imm, rs1, `FUNCT3_AND, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask

    task encode_SLLI;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] shamt;
        begin
           instruction = {`FUNCT7_DEFAULT,shamt, rs1, `FUNCT3_SLLI, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask

    task encode_SRLI;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] shamt;
        begin
           instruction = {`FUNCT7_SRA_I_SUB, shamt, rs1, `FUNCT3_SRAI_SRLI, rd, `OPCODE_OP_IMM};
           UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
           pc = pc + 32'd4;
        end
    endtask

//----------------------------------------------------------------------------
//                                  Branches:
//----------------------------------------------------------------------------
    task encode_BEQ;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BEQ, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_BNE;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BNE, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask


    task encode_BLT;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BLT, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_BGE;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BGE, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_BLTU;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BLTU, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask


    task encode_BGEU;
        input [4:0] rs1;
        input [4:0] rs2;
        input [12:0] imm;
        begin
            instruction = {imm[12], imm[10:5], rs2, rs1, `FUNCT3_BGEU, imm[4:1], imm[11], `OPCODE_BRANCH};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

//----------------------------------------------------------------------------
//                            LUI and AUIPC:
//----------------------------------------------------------------------------    
    task encode_LUI;
        input [4:0] rd;
        input [19:0] imm;
        begin
            instruction = {imm[19:0], rd, `OPCODE_LUI}
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_AUIPC;
        input [4:0] rd;
        input [19:0] imm;
        begin
            instruction = {imm[19:0], rd, `OPCODE_AUIPC};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask


//----------------------------------------------------------------------------
//                                  Jumps:
//----------------------------------------------------------------------------    
    task encode_JAL;
        input [4:0] rd;
        input [20:0] imm;
        begin
            instruction = {imm[20], imm[10:1], imm[11], imm[19:12], rd, `OPCODE_JAL};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask

    task encode_JALR;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;
        begin
            instruction = {imm[11:0], rs1, `FUNCT3_ADD_SUB, rd, `OPCODE_JALR};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endtask


//----------------------------------------------------------------------------
//                                  Loads:
//----------------------------------------------------------------------------    
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


//----------------------------------------------------------------------------
//                                  Stores:
//----------------------------------------------------------------------------  
    task encode_SB;




    initial begin
        pc=0;
        encode_ADDI(4, 0, 1);
        encode_ADDI(5, 0, 2);
        encode_ADD(6, 4, 5);
        Reset_n = 0;
        #100;
        Reset_n = 1;
    end


    
    
endmodule
