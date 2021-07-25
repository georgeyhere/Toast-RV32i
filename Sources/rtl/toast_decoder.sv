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
import toast_def_pkg ::*;

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
module toast_decoder 
    
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
//*************************************************
    // REGFILE ADDRESSES
    output logic [4:0]                      rd_addr_o,        
    output logic [4:0]                      rs1_addr_o,       
    output logic [4:0]                      rs2_addr_o, 
    
    // ALU OPERANDS
    output logic [REG_DATA_WIDTH-1 :0]      imm1_o,    
    output logic [REG_DATA_WIDTH-1 :0]      imm2_o,
    
    // CONTROL SIGNALS    
    output logic [1:0]                      alu_source_sel_o, // [1] -> op1 [2] -> op2  || gets imm
    output logic [3:0]                      alu_op_o,         // alu operation to perform
    output logic [1:0]                      branch_op_o,      // branch gen operation to perform
    output logic                            branch_flag_o,    // execute branch on ALU 'set' or 'not set'
    output logic                            mem_wr_en_o,      // enable data mem wr
    output logic                            mem_rd_en_o,      // enable data mem rd
    output logic                            rd_wr_en_o,       // enable regfile writeback 
    output logic                            memtoreg_o,       // enable regfile writeback from data mem
    output logic                            jump_en_o,        // indicates a jump
    output logic [3:0]                      mem_op_o,         // selects memory mask for load/store
    output logic                            exception_o,

//*************************************************
    // IF STAGE
    input  logic [REG_DATA_WIDTH-1 :0]      instruction_i,
    input  logic [31:0]                     pc_i
//*************************************************
    );
    
// ===========================================================================
// 			          Parameters, Registers, and Wires
// ===========================================================================
    logic [6:0]  OPCODE; 
    logic [4:0]  RD;     
    logic [3:0]  FUNCT3; 
    logic        FUNCT7; 
    
    logic [31:0] IMM_I; // I-type immediate
    logic [31:0] IMM_S; // S-type immediate
    logic [31:0] IMM_B; // SB-type immediate
    logic [31:0] IMM_U; // U-type immediate
    logic [31:0] IMM_J; // J-type immediate

   
// ===========================================================================
//                              Implementation    
// ===========================================================================
    
    // Instruction Decoding; combinatorial 
    always_comb begin
        OPCODE      = instruction_i[6:0];
        FUNCT3      = instruction_i[14:12];
        FUNCT7      = instruction_i[30];
        
        IMM_I       = { {20{instruction_i[31]}}, instruction_i[31:20] }; 
        IMM_S       = { {20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7] }; 
        IMM_B       = { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 }; 
        IMM_U       = { instruction_i[31:12], {12{1'b0}} };
        IMM_J       = { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:25], instruction_i[24:21], 1'b0};
    end
    
    // Combinatorial process to decode instructions
    always_comb begin
        // DEFAULT 
        imm1_o           = 32'b0; 
        imm2_o           = 32'b0;
        alu_source_sel_o = 2'b0;  // [1] sets ALU op1 to imm, [0] sets ALU op2 to imm
        alu_op_o         = 0;     // default ALU op: ADD
        branch_op_o      = 0;     // default: no branch
        branch_flag_o    = 0;     // default: branch if set
        mem_wr_en_o      = 0;     // default: no data mem wr 
        mem_rd_en_o      = 0;     // default: no data mem rd
        rd_wr_en_o       = 0;     // default: regfile writeback disabled
        memtoreg_o       = 0;     // default: no data mem writeback
        jump_en_o        = 0;     // default: no jump
        mem_op_o         = `MEM_LW;      
        
        rd_addr_o        = instruction_i[11:7]; 
        rs1_addr_o       = instruction_i[19:15];
        rs2_addr_o       = instruction_i[24:20];

        exception_o      = ((instruction_i == `ECALL) || (instruction_i == `EBREAK));

        case(OPCODE)
        
             // R-Type, register-register
             // -> perform arithmetic on rs1 and rs2
             // -> store result in rd
            `OPCODE_OP: begin 
                rd_wr_en_o = 1;
                case(FUNCT3)
                    `FUNCT3_ADD_SUB: alu_op_o = (FUNCT7 == 1'b1) ? `ALU_SUB : `ALU_ADD;
                    `FUNCT3_SLL:     alu_op_o = `ALU_SLL;
                    `FUNCT3_SLT:     alu_op_o = `ALU_SLT;          
                    `FUNCT3_SLTU:    alu_op_o = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_op_o = `ALU_XOR;
                    `FUNCT3_SRL_SRA: alu_op_o = (FUNCT7 == 1'b1) ? `ALU_SRA : `ALU_SRL;
                    `FUNCT3_OR:      alu_op_o = `ALU_OR;
                    `FUNCT3_AND:     alu_op_o = `ALU_AND;
                    default:         alu_op_o = `ALU_ADD;
                endcase
            end
            
            // I-type, register-immediate
            // -> perform arithmetic on rs1 and IMM_I
            // -> store result in rd
            `OPCODE_OP_IMM: begin 
                rd_wr_en_o  = (instruction_i[11:7] == 0) ? 0:1;
                alu_source_sel_o = 2'b01; // select immediate for op2
                imm2_o           = IMM_I; // assign I-type immediate
                rs2_addr_o       = 0;
                
                case(FUNCT3)
                    `FUNCT3_ADDI:      alu_op_o = `ALU_ADD;  
                    `FUNCT3_ANDI:      alu_op_o = `ALU_AND;
                    `FUNCT3_ORI:       alu_op_o = `ALU_OR;
                    `FUNCT3_XORI:      alu_op_o = `ALU_XOR;
                    `FUNCT3_SLTI:      alu_op_o = `ALU_SLT;
                    `FUNCT3_SLTIU:     alu_op_o = `ALU_SLTU;
                    `FUNCT3_SRAI_SRLI: alu_op_o = (FUNCT7 == 1'b1) ? `ALU_SRA : `ALU_SRL; 
                    `FUNCT3_SLLI:      alu_op_o = `ALU_SLL;
                    default:           alu_op_o = `ALU_ADD;
                endcase
            end
            
            // B-type, conditional branch
            // -> ALU tests op1 and op2
            // -> address generated by branch gen -> jump to PC[ pc_i + IMM_B ] 
            // -> no store
            `OPCODE_BRANCH: begin
                branch_op_o     = `PC_RELATIVE; // set branch gen control
                imm2_o          = IMM_B;        // assign B-type immediate (branch gen)
                rd_addr_o       = 0; 
                case(FUNCT3)
                    `FUNCT3_BEQ: begin
                        branch_flag_o = 0;
                        alu_op_o      = `ALU_SEQ;  // set if equal
                    end
                    `FUNCT3_BNE: begin
                        branch_flag_o = 1;
                        alu_op_o      = `ALU_SEQ;  // set if equal
                    end
                    `FUNCT3_BLT: begin
                        branch_flag_o = 0;
                        alu_op_o      = `ALU_SLT;  // set if less than, signed
                    end
                    `FUNCT3_BGE: begin
                        branch_flag_o = 1;
                        alu_op_o      = `ALU_SLT;  // set if less than, signed
                    end
                    `FUNCT3_BLTU: begin
                        branch_flag_o = 0;
                        alu_op_o      = `ALU_SLTU; // set if less than, unsigned
                    end
                    `FUNCT3_BGEU: begin
                        branch_flag_o = 1;
                        alu_op_o      = `ALU_SLTU; // set if less than, unsigned
                    end
                    default: begin
                        branch_flag_o = 0;
                        alu_op_o      = `ALU_ADD;
                    end
                endcase    
            end
            
            // LUI -> U-type Instruction, Load Upper Immediate
            // -> places IMM_U in top 20 bits, fills in lower 12 bits with zeroes
            // -> store result in rd
            `OPCODE_LUI: begin
                rd_wr_en_o       = (instruction_i[11:7] == 0) ? 0:1;
                alu_source_sel_o = 2'b11;    // set both ALU operands to immediates
                imm1_o           = 32'b0;        
                imm2_o           = IMM_U;
                alu_op_o         = `ALU_ADD; // add IMM_U to 0
                rs1_addr_o       = 0;
                rs2_addr_o       = 0;
            end
            
            
            // AUIPC -> U-type instruction, Add Upper Immediate to PC
            // -> performs pc_i + IMM_U
            // -> store result in rd
            `OPCODE_AUIPC: begin
                rd_wr_en_o       = (instruction_i[11:7] == 0) ? 0:1;
                alu_source_sel_o = 2'b11;
                imm1_o           = pc_i;
                imm2_o           = IMM_U;
                alu_op_o         = `ALU_ADD;
                rs1_addr_o       = 0;
                rs2_addr_o       = 0;
            end
            
            // JAL -> J-type instruction, jump_en_o And Link 
            // -> PC target address = PC + IMM_J
            // -> stores address of PC+4 to rd
            `OPCODE_JAL: begin
                rd_wr_en_o       = (instruction_i[11:7] == 0) ? 0:1;
                jump_en_o        = 1;
                branch_op_o      = `PC_RELATIVE;
                alu_source_sel_o = 2'b10; 
                imm1_o           = pc_i; // ALU op1
                imm2_o           = IMM_J; // Branch gen
                rs1_addr_o       = 0;
                rs2_addr_o       = 0;
            end
            
            // JALR -> I-type instruction
            // -> PC target address = {  {31{rs1 + IMM_I}}, 1'b0} } 
            // -> stores address of PC+4 to rd
            `OPCODE_JALR: begin
                rd_wr_en_o       = (instruction_i[11:7] == 0) ? 0:1;
                jump_en_o        = 1;
                branch_op_o      = `REG_OFFSET;
                alu_source_sel_o = 2'b10;
                imm1_o           = pc_i; // ALU op1
                imm2_o           = IMM_I; // Branch gen
                rs2_addr_o       = 0;
            end
            
            
            // Loads are I-type instructions
            // -> data mem load address = rs1 + IMM_I (via ALU)
            // -> store to rd
            `OPCODE_LOAD: begin
                rd_wr_en_o       = (instruction_i[11:7] == 0) ? 0:1;
                alu_source_sel_o = 2'b01;
                imm2_o           = IMM_I;
                mem_rd_en_o      = 1;
                memtoreg_o       = 1;
                rs2_addr_o       = 0;
                case(FUNCT3)
                    `FUNCT3_LW:  mem_op_o = `MEM_LW;
                    `FUNCT3_LB:  mem_op_o = `MEM_LB;
                    `FUNCT3_LH:  mem_op_o = `MEM_LH;
                    `FUNCT3_LBU: mem_op_o = `MEM_LB_U; 
                    `FUNCT3_LHU: mem_op_o = `MEM_LH_U;
                endcase
            end
            
            // Stores are S-type instructions
            // -> data mem store address = rs1 + IMM_S (via ALU)
            // -> copy rs2 to data mem
            `OPCODE_STORE: begin
                alu_source_sel_o = 2'b01;
                imm2_o           = IMM_S;
                mem_wr_en_o      = 1;
                case(FUNCT3)
                    `FUNCT3_SB: mem_op_o = `MEM_SB;
                    `FUNCT3_SH: mem_op_o = `MEM_SH;
                    `FUNCT3_SW: mem_op_o = `MEM_SW;
                endcase
            end
            
        endcase   

    end // end always_comb
    
endmodule
