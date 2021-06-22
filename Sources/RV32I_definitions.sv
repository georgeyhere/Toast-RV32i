`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: George Yu
// 
// Create Date: 06/14/2021 12:25:28 PM
// Design Name: 
// Module Name: RV32I_definitions
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
// RV32I encoding cheatsheet: https://metalcode.eu/2019-12-06-rv32i.html
//////////////////////////////////////////////////////////////////////////////////


package RV32I_definitions;
    
    // OPCODES
    `define OPCODE_OP      7'b0110011  
    `define OPCODE_OP_IMM  7'b0010011
    `define OPCODE_BRANCH  7'b1100011
    `define OPCODE_LUI     7'b0110111
    `define OPCODE_AUIPC   7'b0010111
    `define OPCODE_JAL     7'b1101111
    `define OPCODE_JALR    7'b1100111
    `define OPCODE_LOAD    7'b0000011
    `define OPCODE_STORE   7'b0100011
    
    // FUNCT3
    `define FUNCT3_ADD     3'b000
    `define FUNCT3_SUB     3'b000
    `define FUNCT3_SLL     3'b001
    `define FUNCT3_SLT     3'b010
    `define FUNCT3_SLTU    3'b011
    `define FUNCT3_XOR     3'b100
    `define FUNCT3_SRL     3'b101
    `define FUNCT3_SRA     3'b101
    `define FUNCT3_OR      3'b110
    `define FUNCT3_AND     3'b111
    
    `define FUNCT3_BEQ     3'b000
    `define FUNCT3_BNE     3'b001
    `define FUNCT3_BLT     3'b100
    `define FUNCT3_BGE     3'b101
    `define FUNCT3_BLTU    3'b110
    `define FUNCT3_BGEU    3'b111

endpackage
