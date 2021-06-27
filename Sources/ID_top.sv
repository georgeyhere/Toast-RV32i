`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 04:23:14 PM
// Design Name: 
// Module Name: ID_top
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

module RV32I_ID
    
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
    input             Clk,
    input             Reset_n,
    
    // pipeline in
    input  [31:0]     IF_PC,
    input  [31:0]     IF_Instruction,
    input             ID_Stall,
    
    // hazard detection
    input             EX_Mem_rd_en,
    input  [4:0]      EX_RegFile_rd_addr,
    
    // regfile
    input  [4:0]      WB_Regfile_Rd_addr,
    input  [31:0]     WB_RegFile_wr_data,
    input             WB_RegFile_wr_en,
    
    // pipeline out
    output reg [REG_DATA_WIDTH-1:0]      ID_PC,
    
    // control signals
    output reg [1:0]                     ID_ALU_source_sel,
    output reg [ALU_OP_WIDTH-1 :0]       ID_ALU_op,
    output reg [1:0]                     ID_Branch_op, 
    output reg                           ID_Branch_flag,
    output reg                           ID_Mem_wr_en,
    output reg                           ID_Mem_rd_en,
    output reg                           ID_RegFile_wr_en,
    output reg                           ID_MemToReg,
    output reg                           ID_Jump,
    output reg [2:0]                     ID_Mem_op,
    
    // ALU operands
    output     [REG_DATA_WIDTH-1 :0]     ID_Immediate_1,
    output     [REG_DATA_WIDTH-1 :0]     ID_Immediate_2,
    output     [REG_DATA_WIDTH-1 :0]     ID_Rs1_data,
    output     [REG_DATA_WIDTH-1 :0]     ID_Rs2_data,
    
    output     [4:0] ID_Rd_addr
    );
    
    wire [4:0] Rs1_addr;
    wire [4:0] Rs2_addr;
    
    wire [1:0] ALU_source_sel;
    wire [3:0] ALU_op;
    wire [1:0] Branch_op;
    wire       Branch_flag;
    wire       Mem_wr_en;
    wire       RegFile_wr_en;
    wire       MemToReg;
    wire       Jump;
    wire [2:0] Mem_op;
    
    ID_control RV32I_CONTROL(
    .IF_Instruction (IF_Instruction),
    .IF_PC          (IF_PC),
    .Immediate_1    (ID_Immediate_1),
    .Immediate_2    (ID_Immediate_2),
    .Rd_addr        (ID_Rd_addr),
    .Rs1_addr       (Rs1_addr),
    .Rs2_addr       (Rs2_addr),
    
    .ALU_source_sel (ALU_source_sel), // ctrl
    .ALU_op         (ALU_op),         // ctrl
    .Branch_op      (Branch_op),      // ctrl
    .Branch_flag    (Branch_flag),    // ctrl
    .Mem_wr_en      (Mem_wr_en),      // ctrl
    .Mem_rd_en      (Mem_rd_en),      // ctrl
    .RegFile_wr_en  (RegFile_wr_en),  // ctrl
    .MemToReg       (MemToReg),       // ctrl
    .Mem_op         (Mem_op),         // ctrl
    .Jump           (Jump)            // ctrl
    );
    
    ID_regfile RV32I_REGFILE(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .Rs1_addr    (Rs1_addr), // from control
    .Rs2_addr    (Rs2_addr), // from control
    .Rd_addr     (WB_Regfile_Rd_addr),
    .Rd_wr_data  (WB_RegFile_wr_data),
    .Rd_wr_en    (WB_RegFile_wr_en),
    .Rs1_data    (ID_Rs1_data),
    .Rs2_data    (ID_Rs2_data)
    );
    
    initial ID_PC = 0;
    
    // pipeline registers
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            ID_PC <= 0;
            ID_ALU_source_sel <= 0;
            ID_ALU_op <= 0;
            ID_Branch_op <= 0;
            ID_Branch_flag <= 0;
            ID_Mem_wr_en <= 0;
            ID_Mem_rd_en <= 0;
            ID_RegFile_wr_en <= 0;
            ID_MemToReg <= 0;
            ID_Mem_op <= 0;
        end
        else begin
            if(ID_Stall == 1'b1) begin
                ID_PC <= 0;
                ID_ALU_source_sel <= 0;
                ID_ALU_op <= 0;
                ID_Branch_op <= 0;
                ID_Branch_flag <= 0;
                ID_Mem_wr_en <= 0;
                ID_Mem_rd_en <= 0;
                ID_RegFile_wr_en <= 0;
                ID_MemToReg <= 0;
                ID_Mem_op <= 0;
            end
            else begin
                ID_PC <= IF_PC;
                ID_ALU_source_sel <= ALU_source_sel;
                ID_ALU_op <= ALU_op;
                ID_Branch_op <= Branch_op;
                ID_Branch_flag <= Branch_flag;
                ID_Mem_wr_en <= Mem_wr_en;
                ID_Mem_rd_en <= Mem_rd_en;
                ID_RegFile_wr_en <= RegFile_wr_en;
                ID_MemToReg <= MemToReg;
                ID_Mem_op <= Mem_op;
            end
        end  
    end
    
endmodule
