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

module ID_top
    
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
    input                                Clk,
    input                                Reset_n,
    
    // pipeline in
    input  [31:0]                        IF_PC,
    input  [31:0]                        IF_Instruction,
    input                                ID_Stall,
    input                                ID_Flush,

    // regfile
    input  [4:0]                         WB_Rd_addr,
    input  [31:0]                        WB_Rd_data,
    input                                WB_RegFile_wr_en,
    
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
    
    // branch/jump destination
    output reg [REG_DATA_WIDTH-1:0]      ID_PC_dest,
    
    // ALU operands
    output reg [REG_DATA_WIDTH-1 :0]     ID_Immediate_1,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Immediate_2,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Rs1_data,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Rs2_data,
    
    output reg [4:0]                     ID_Rd_addr,
    output reg [4:0]                     ID_Rs1_addr,
    output reg [4:0]                     ID_Rs2_addr
    );
    
    wire [4:0] Rd_addr;
    wire [4:0] Rs1_addr;
    wire [4:0] Rs2_addr;
    
    wire [31:0] Immediate_1, Immediate_2;
    wire [31:0] Rs1_data, Rs2_data;
    
    wire [1:0] ALU_source_sel;
    wire [3:0] ALU_op;
    wire [1:0] Branch_op;
    wire       Branch_flag;
    wire       Mem_wr_en;
    wire       RegFile_wr_en;
    wire       MemToReg;
    wire       Jump;
    wire [2:0] Mem_op;
    
    wire [31:0] Branch_dest;
    
    ID_control RV32I_CONTROL(
    .IF_Instruction (IF_Instruction),
    .IF_PC          (IF_PC),
    .Immediate_1    (Immediate_1),
    .Immediate_2    (Immediate_2),
    .Rd_addr        (Rd_addr),
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
    .Rd_addr     (WB_Rd_addr),
    .Rd_wr_data  (WB_Rd_data),
    .Rd_wr_en    (WB_RegFile_wr_en),
    .Rs1_data    (Rs1_data),
    .Rs2_data    (Rs2_data)
    );
    
    Branch_gen ID_BranchGen (
    .Branch_op   (Branch_op),
    .PC          (IF_PC),
    .RegData     (Rs1_data),
    .Immediate   (Immediate_2),
    .Branch_dest (Branch_dest)
    );
    
    
    
    // pipeline registers
    always_ff@(posedge Clk) begin
        // reset state is the same as NOP, all control signals set to 0
        if((Reset_n == 1'b0) || (ID_Flush == 1'b1)) begin
            ID_PC <= 0;
            ID_ALU_source_sel <= 0;
            ID_ALU_op <= 0;
            ID_Branch_op <= 0;
            ID_Branch_flag <= 0;
            ID_Mem_wr_en <= 0;
            ID_Mem_rd_en <= 0;
            ID_RegFile_wr_en <= 0;
            ID_MemToReg <= 0;
            ID_Jump <= 0;
            ID_Mem_op <= 0;
            ID_Rd_addr <= 0;
            ID_Rs1_addr <=  0;
            ID_Rs2_addr <= 0;
            ID_PC_dest  <= 0;
            ID_Immediate_1 <= 0;
            ID_Immediate_2 <= 0;
            ID_Rs1_data <= 0;
            ID_Rs2_data <= 0;
        end
        else begin
            if(ID_Stall == 1'b1) begin
                ID_PC             <= ID_PC;
                ID_ALU_source_sel <= ID_ALU_source_sel;
                ID_ALU_op         <= ID_ALU_op;
                ID_Branch_op      <= ID_Branch_op;
                ID_Branch_flag    <= ID_Branch_flag;
                ID_Mem_wr_en      <= 0;
                ID_Mem_rd_en      <= 0;
                ID_RegFile_wr_en  <= 0;
                ID_MemToReg       <= 0;
                ID_Jump           <= 0;
                ID_Mem_op         <= 0;
                ID_Rd_addr        <= 0;
                ID_Rs1_addr       <= ID_Rs1_addr;
                ID_Rs2_addr       <= ID_Rs2_addr;
                ID_PC_dest        <= ID_PC_dest;
                ID_Immediate_1    <= ID_Immediate_1;
                ID_Immediate_2    <= ID_Immediate_2;
                ID_Rs1_data       <= ID_Rs1_data;
                ID_Rs2_data       <= ID_Rs2_data;
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
                ID_Jump <= Jump;
                ID_Mem_op <= Mem_op;
                ID_Rd_addr <= Rd_addr;
                ID_Rs1_addr <=  Rs1_addr;
                ID_Rs2_addr <= Rs2_addr;
                ID_PC_dest <= Branch_dest;
                ID_Immediate_1 <= Immediate_1;
                ID_Immediate_2 <= Immediate_2;
                ID_Rs1_data <= Rs1_data;
                ID_Rs2_data <= Rs2_data;
            end
        end  
    end
    
endmodule
