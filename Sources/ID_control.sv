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
// Drives Control signals and generates immediate
//////////////////////////////////////////////////////////////////////////////////
import RV32I_definitions ::*;

/*
This module integrates the functions of a decoder and a control module. Models
fully combinatorial logic and will be assigned to pipeline register on each cycle
in top level module ID_top.

It decodes the following for RegFile data fetch:
    -> Rs1 address
    -> Rs2 address
    -> Rd address (to be sent down the pipeline)

It drives the control signals for:
    -> ID Stage
        -> Branch Generation operation 
            -> PC-relative Branch/Jump destination
            -> Rs1-offset  Jump destination
    -> EX Stage 
        -> ALU source selection (immediate or regfile data for operands)
        -> ALU immediate selection (select correct type of immediate for instruction)
       
*/
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
    input      [31:0]                     IF_PC,

    output     [4:0]                      Rd_addr,        
    output     [4:0]                      Rs1_addr,       
    output     [4:0]                      Rs2_addr, 
    
    // ALU OPERANDS
    output reg [REG_DATA_WIDTH-1 :0]      Immediate_1,    
    output reg [REG_DATA_WIDTH-1 :0]      Immediate_2,
    
    // CONTROL SIGNALS    
    output reg [1:0]                      ALU_source_sel, // [1] -> op1 [2] -> op2  || gets imm
    output reg [3:0]                      ALU_op,         // alu operation to perform
    output reg [1:0]                      Branch_op,      // branch gen operation to perform
    output reg                            Branch_flag,    // execute branch on ALU 'set' or 'not set'
    output reg                            Mem_wr_en,      // enable data mem wr
    output reg                            Mem_rd_en,      // enable data mem rd
    output reg                            RegFile_wr_en,  // enable regfile writeback 
    output reg                            MemToReg,       // enable regfile writeback from data mem
    output reg                            Jump,           // indicates a jump
    output reg [2:0]                      Mem_op          // selects memory mask for load/store
    );
    
// ===========================================================================
// 			          Parameters, Registers, and Wires
// ===========================================================================
    wire [6:0]  OPCODE; 
    wire [4:0]  RD;     
    wire [3:0]  FUNCT3; 
    wire [6:0]  FUNCT7; 
    
    wire [31:0] IMM_I; // I-type immediate
    wire [31:0] IMM_S; // S-type immediate
    wire [31:0] IMM_B; // SB-type immediate
    wire [31:0] IMM_U; // U-type immediate
    wire [31:0] IMM_J; // J-type immediate

   
// ===========================================================================
//                              Implementation    
// ===========================================================================
    
    // Instruction Decoding
    assign OPCODE      = IF_Instruction[6:0];
    assign FUNCT3      = IF_Instruction[14:12];
    assign FUNCT7      = IF_Instruction[31:25];
    
    assign IMM_I       = { {20{IF_Instruction[31]}}, IF_Instruction[31:20] }; 
    assign IMM_S       = { {20{IF_Instruction[31]}}, IF_Instruction[31:25], IF_Instruction[11:7] }; 
    assign IMM_B       = { {20{IF_Instruction[31]}}, IF_Instruction[7], IF_Instruction[30:25], IF_Instruction[11:8], 1'b0 }; 
    assign IMM_U       = { IF_Instruction[31:12], {12{1'b0}} };
    assign IMM_J       = { {11{1'b0}}, IF_Instruction[31], IF_Instruction[19:12], IF_Instruction[20], IF_Instruction[10:1], 1'b0};
    
    assign Rd_addr  = IF_Instruction[11:7];
    assign Rs1_addr = IF_Instruction[19:15];
    assign Rs2_addr = IF_Instruction[24:20];
    
    // Combinatorial process to decode instructions
    always_comb begin
        // DEFAULT 
        Immediate_1    = 32'b0; 
        Immediate_2    = 32'b0;
        ALU_source_sel = 2'b0;  // [1] sets ALU op1 to imm, [0] sets ALU op2 to imm
        ALU_op         = 0;     // default ALU op: ADD
        Branch_op      = 0;     // default: no branch
        Branch_flag    = 0;     // default: branch if set
        Mem_wr_en      = 0;     // default: no data mem wr 
        Mem_rd_en      = 0;     // default: no data mem rd
        RegFile_wr_en  = 0;     // default: regfile writeback disabled
        MemToReg       = 0;     // default: no data mem writeback
        Jump           = 0;     // default: no jump
        Mem_op         = 0;     // default: no data mem mask
        
        
        case(OPCODE)
        
             // R-Type, register-register
             // -> perform arithmetic on rs1 and rs2
             // -> store result in rd
            `OPCODE_OP: begin 
                RegFile_wr_en = 1;
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
            // -> perform arithmetic on rs1 and IMM_I
            // -> store result in rd
            `OPCODE_OP_IMM: begin 
                RegFile_wr_en  = 1;
                ALU_source_sel = 2'b01; // select immediate for op2
                Immediate_2    = IMM_I; // assign I-type immediate
                
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
            
            // B-type, conditional branch
            // -> ALU tests op1 and op2
            // -> address generated by branch gen -> jump to PC[ IF_PC + IMM_B ] 
            // -> no store
            `OPCODE_BRANCH: begin
                Branch_op     = `PC_RELATIVE; // set branch gen control
                RegFile_wr_en = 0;            // disable register writeback
                Immediate_2   = IMM_B;        // assign B-type immediate (branch gen)
                 
                case(FUNCT3)
                    `FUNCT3_BEQ: begin
                        Branch_flag = 0;
                        ALU_op      = `ALU_SEQ;  // set if equal
                    end
                    `FUNCT3_BNE: begin
                        Branch_flag = 1;
                        ALU_op      = `ALU_SEQ;  // set if equal
                    end
                    `FUNCT3_BLT: begin
                        Branch_flag = 0;
                        ALU_op      = `ALU_SLT;  // set if less than, signed
                    end
                    `FUNCT3_BGE: begin
                        Branch_flag = 1;
                        ALU_op      = `ALU_SLT;  // set if less than, signed
                    end
                    `FUNCT3_BLTU: begin
                        Branch_flag = 0;
                        ALU_op      = `ALU_SLTU; // set if less than, unsigned
                    end
                    `FUNCT3_BGEU: begin
                        Branch_flag = 1;
                        ALU_op      = `ALU_SLTU; // set if less than, unsigned
                    end
                    default: begin
                        Branch_flag = 0;
                        ALU_op      = `ALU_ADD;
                    end
                endcase    
            end
            
            // LUI -> U-type Instruction, Load Upper Immediate
            // -> places IMM_U in top 20 bits, fills in lower 12 bits with zeroes
            // -> store result in rd
            `OPCODE_LUI: begin
                RegFile_wr_en  = 1;
                ALU_source_sel = 2'b11;    // set both ALU operands to immediates
                Immediate_1    = 32'b0;        
                Immediate_2    = IMM_U;
                ALU_op         = `ALU_ADD; // add IMM_U to 0
            end
            
            
            // AUIPC -> U-type instruction, Add Upper Immediate to PC
            // -> performs IF_PC + IMM_U
            // -> store result in rd
            `OPCODE_AUIPC: begin
                RegFile_wr_en  = 1;
                ALU_source_sel = 2'b11;
                Immediate_1    = IF_PC;
                Immediate_2    = IMM_U;
                ALU_op         = `ALU_ADD;
            end
            
            // JAL -> J-type instruction, Jump And Link 
            // -> PC target address = PC + IMM_J
            // -> stores address of PC+4 to rd
            `OPCODE_JAL: begin
                RegFile_wr_en  = 1;
                Jump           = 1;
                Branch_op      = `PC_RELATIVE;
                ALU_source_sel = 2'b10; 
                Immediate_1    = IF_PC; // ALU op1
                Immediate_2    = IMM_J; // Branch gen
            end
            
            // JALR -> I-type instruction
            // -> PC target addres = {  {31{rs1 + IMM_I}}, 1'b0} }
            // -> stores address of PC+4 to rd
            `OPCODE_JALR: begin
                Jump           = 1;
                Branch_op      = `REG_OFFSET;
                ALU_source_sel = 2'b10;
                Immediate_1    = IF_PC; // ALU op1
                Immediate_2    = IMM_I; // Branch gen
            end
            
            
            // Loads are I-type instructions
            // -> data mem load address = rs1 + IMM_I (via ALU)
            // -> store to rd
            `OPCODE_LOAD: begin
                RegFile_wr_en  = 1;
                ALU_source_sel = 2'b01;
                Immediate_2    = IMM_I;
                Mem_rd_en      = 1;
                MemToReg       = 1;
                case(FUNCT3)
                    `FUNCT3_LW: Mem_op = `MEM_LW;
                    `FUNCT3_LB: Mem_op = `MEM_LB;
                endcase
            end
            
            // Stores are S-type instructions
            // -> data mem store address = rs1 + IMM_S (via ALU)\
            // -> copy rs2 to data mem
            `OPCODE_STORE: begin
                ALU_source_sel = 2'b01;
                Immediate_2    = IMM_S;
                Mem_wr_en      = 1;
                RegFile_wr_en  = 0;
                case(FUNCT3)
                    `FUNCT3_SW: Mem_op = `MEM_SW;
                    `FUNCT3_SB: Mem_op = `MEM_SB;
                endcase
            end
         
        endcase     
    end // end always_comb
    
endmodule
