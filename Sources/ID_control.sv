`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2021 10:56:10 AM
// Design Name: 
// Module Name: ID_control
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
import RV32I_definitions ::*;

module ID_control    
    
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH      = `REG_DATA_WIDTH,
          parameter REGFILE_ADDR_WIDTH  = `REGFILE_ADDR_WIDTH
          parameter REGFILE_DEPTH       = `REGFILE_DEPTH
          parameter ALU_OP_WIDTH        = `ALU_OP_WIDTH
          )
    `else
        #(parameter REG_DATA_WIDTH      = 32,
          parameter REGFILE_ADDR_WIDTH  = 5,
          parameter REGFILE_DEPTH       = 32,
          parameter ALU_OP_WIDTH        = 4
          )
    `endif

    (
    input      [REG_DATA_WIDTH-1 :0]      IF_Instruction,

    output reg                            Rd_wr_en,
    
    output reg                            ALU_source_sel,
    output reg [ALU_OP_WIDTH-1 :0]        ALU_op,
    output reg [REG_DATA_WIDTH-1 :0]      Immediate,
    
    output reg                            Branch_en,
    
    output     [REGFILE_ADDR_WIDTH-1 :0]  Rd_address,
    output     [REGFILE_ADDR_WIDTH-1 :0]  Rs1_address,
    output     [REGFILE_ADDR_WIDTH-1 :0]  Rs2_address
    );
    
// ===========================================================================
// 			          Parameters, Registers, and Wires
// ===========================================================================
    wire [6:0]  OPCODE; 
    wire [4:0]  RD;     
    wire [3:0]  FUNCT3; 
    wire [6:0]  FUNCT7; 
    
    wire [31:0] IMM_I;  // I-type immediate
    wire [31:0] IMM_S;  // S-type immediate
    wire [31:0] IMM_SB; // SB-type immediate

// ===========================================================================
//                              Implementation    
// ===========================================================================
    assign Rd_address  = IF_Instruction[11:7];
    assign Rs1_address = IF_Instruction[19:15];
    assign Rs2_address = IF_Instruction[24:20];
    
    assign OPCODE      = IF_Instruction[6:0];
    assign FUNCT3      = IF_Instruction[14:12];
    assign FUNCT7      = IF_Instruction[31:25];
    
    assign IMM_I       = { {20{IF_Instruction[31]}}, IF_Instruction[31:20] }; 
    assign IMM_S       = { {20{IF_Instruction[31]}}, IF_Instruction[31:25], IF_Instruction[11:7] }; 
    assign IMM_SB      = { {20{IF_Instruction[31]}}, IF_Instruction[7], IF_Instruction[30:25], IF_Instruction[11:8], 1'b0 }; 
  
    
    always_comb begin
        // DEFAULTS
        Rd_wr_en       = 1;      // only disabled for branches and jumps
        ALU_source_sel = 0;      // sel r1 and r2
        Immediate      = 32'bx; 
        Branch_en      = 0;      // asserted to indicate branch instruction
        ALU_op         = 0;
        
        case(OPCODE)
        
             // R-Type, register-register
            `OPCODE_OP: begin 
                case(FUNCT3)
                    `FUNCT3_ADD_SUB: ALU_op = (FUNCT7 == 1'b1) ? `ALU_SUB : `ALU_ADD;
                    `FUNCT3_SLL:     ALU_op = `ALU_SLL;
                    `FUNCT3_SLT:     ALU_op = `ALU_SLT;          
                    `FUNCT3_SLTU:    ALU_op = `ALU_SLTU;
                    `FUNCT3_XOR:     ALU_op = `ALU_XOR;
                    `FUNCT3_SRL_SRA: ALU_op = (FUNCT7 == 1'b1) ? `ALU_SRA : `ALU_SRL;
                    `FUNCT3_OR:      ALU_op = `ALU_OR;
                    `FUNCT3_AND:     ALU_op = `ALU_AND;
                    default:         ALU_op = `ALU_ADD;
                endcase
            end
            
            // I-type, register-immediate
            `OPCODE_OP_IMM: begin 
                ALU_source_sel = 1;     // select immediate for op2
                Immediate      = IMM_I; // assign I-type immediate
                
                case(FUNCT3)
                    `FUNCT3_ADDI:      ALU_op = `ALU_ADD;  
                    `FUNCT3_ANDI:      ALU_op = `ALU_AND;
                    `FUNCT3_ORI:       ALU_op = `ALU_OR;
                    `FUNCT3_XORI:      ALU_op = `ALU_XOR;
                    `FUNCT3_SLTI:      ALU_op = `ALU_SLT;
                    `FUNCT3_SLTIU:     ALU_op = `ALU_SLTU;
                    `FUNCT3_SRAI_SRLI: ALU_op = (FUNCT7 == 1'b1) ? `ALU_SRA : `ALU_SRL; 
                    `FUNCT3_SLLI:      ALU_op = `ALU_SLL;
                    default:           ALU_op = `ALU_ADD;
                endcase
            end
            
            // SB-type, conditional branch
            `OPCODE_BRANCH: begin
                Branch_en = 1;      // enable branch check
                Rd_wr_en  = 0;      // disable register writeback
                Immediate = IMM_SB; // assign SB-type immediate
                 
                case(FUNCT3)
                    `FUNCT3_BEQ:      ALU_op = `ALU_SEQ;  // set if equal
                    `FUNCT3_BNE:      ALU_op = `ALU_SEQ;  // set if equal
                    `FUNCT3_BLT:      ALU_op = `ALU_SLT;  // set if less than, signed
                    `FUNCT3_BGE:      ALU_op = `ALU_SLT;  // set if less than, signed
                    `FUNCT3_BLTU:     ALU_op = `ALU_SLTU; // set if less than, unsigned
                    `FUNCT3_BGEU:     ALU_op = `ALU_SLTU; // set if less than, unsigned
                    default:          ALU_op = `ALU_ADD;
                endcase    
            end
         
        endcase     
    end // end always_comb
    
endmodule
