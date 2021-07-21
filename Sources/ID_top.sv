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
    //*************************************************
    input                                Clk,
    input                                Reset_n,
    
    //*************************************************
    // pipeline in
    input      [REG_DATA_WIDTH-1:0]      IF_PC,
    input      [REG_DATA_WIDTH-1:0]      IF_Instruction,
    input                                ID_Stall,
    input                                ID_Flush,

    // regfile
    input      [REGFILE_ADDR_WIDTH-1:0]  WB_Rd_addr,
    input      [REG_DATA_WIDTH-1:0]      WB_Rd_data,
    input                                WB_RegFile_wr_en,
    

    //*************************************************
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
    output reg [3:0]                     ID_Mem_op,
    
    // branch/jump destination
    output reg [REG_DATA_WIDTH-1:0]      ID_PC_dest,
    
    // ALU operands
    output reg [REG_DATA_WIDTH-1 :0]     ID_Immediate_1,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Immediate_2,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Rs1_data,
    output reg [REG_DATA_WIDTH-1 :0]     ID_Rs2_data,
    
    // regfile addresses
    output reg [REGFILE_ADDR_WIDTH-1:0]  ID_Rd_addr,
    output reg [REGFILE_ADDR_WIDTH-1:0]  ID_Rs1_addr,
    output reg [REGFILE_ADDR_WIDTH-1:0]  ID_Rs2_addr,

    output reg                           ID_Exception
    //*************************************************
    );
    
// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================

    wire [4:0] Rd_addr_i;
    wire [4:0] Rs1_addr_i;
    wire [4:0] Rs2_addr_i;
    
    wire [31:0] Immediate_1_i, Immediate_2_i;
    
    wire [1:0] ALU_source_sel_i;
    wire [3:0] ALU_op_i;
    wire [1:0] Branch_op_i;
    wire       Branch_flag_i;
    wire       Mem_wr_en_i;
    wire       RegFile_wr_en_i;
    wire       MemToReg_i;
    wire       Jump_i;
    wire [3:0] Mem_op_i;
    
    wire [31:0] Branch_dest_i;

    wire        Exception_i;

// ===========================================================================
//                              Instantiation   
// ===========================================================================    
    ID_control RV32I_CONTROL(
    .IF_Instruction (IF_Instruction),
    .IF_PC          (IF_PC),
    .Immediate_1    (Immediate_1_i),
    .Immediate_2    (Immediate_2_i),
    .Rd_addr        (Rd_addr_i),
    .Rs1_addr       (Rs1_addr_i),
    .Rs2_addr       (Rs2_addr_i),
    .ALU_source_sel (ALU_source_sel_i), // ctrl
    .ALU_op         (ALU_op_i),         // ctrl
    .Branch_op      (Branch_op_i),      // ctrl
    .Branch_flag    (Branch_flag_i),    // ctrl
    .Mem_wr_en      (Mem_wr_en_i),      // ctrl
    .Mem_rd_en      (Mem_rd_en_i),      // ctrl
    .RegFile_wr_en  (RegFile_wr_en_i),  // ctrl
    .MemToReg       (MemToReg_i),       // ctrl
    .Mem_op         (Mem_op_i),         // ctrl
    .Jump           (Jump_i),           // ctrl
    .Exception      (Exception_i)
    );
    
    ID_regfile RV32I_REGFILE(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .Rs1_addr    (ID_Rs1_addr),
    .Rs2_addr    (ID_Rs2_addr),
    .Rd_addr     (WB_Rd_addr),
    .Rd_wr_data  (WB_Rd_data),
    .Rd_wr_en    (WB_RegFile_wr_en),
    .Rs1_data    (ID_Rs1_data),
    .Rs2_data    (ID_Rs2_data)
    );
    
    Branch_gen ID_BranchGen (
    .Branch_op   (Branch_op_i),
    .PC          (IF_PC),
    .RegData     (ID_Rs1_data),
    .Immediate   (Immediate_2_i),
    .Branch_dest (Branch_dest_i)
    );
    
    
// ===========================================================================
//                              Implementation    
// ===========================================================================    
    // pipeline registers
    always_ff@(posedge Clk) begin
        // reset state is the same as NOP, all control signals set to 0
        if((Reset_n == 1'b0) || (ID_Flush == 1'b1)) begin
            ID_PC             <= 0;
            ID_ALU_source_sel <= 0;
            ID_ALU_op         <= 0;
            ID_Branch_op      <= 0;
            ID_Branch_flag    <= 0;
            ID_Mem_wr_en      <= 0;
            ID_Mem_rd_en      <= 0;
            ID_RegFile_wr_en  <= 0;
            ID_MemToReg       <= 0;
            ID_Jump           <= 0;
            ID_Mem_op         <= 0;
            ID_Rd_addr        <= 0;
            ID_Rs1_addr       <= 0;
            ID_Rs2_addr       <= 0;
            ID_PC_dest        <= 0;
            ID_Immediate_1    <= 0;
            ID_Immediate_2    <= 0;
            ID_Exception      <= 0;
        end
        else begin
            // on stall, drop control signals to 0
            if(ID_Stall == 1'b1) begin
                ID_PC             <= ID_PC;
                ID_ALU_source_sel <= ID_ALU_source_sel;
                ID_ALU_op         <= ID_ALU_op;
                ID_Branch_op      <= ID_Branch_op;
                ID_Branch_flag    <= ID_Branch_flag;
                ID_Mem_wr_en      <= 0; 
                ID_Mem_rd_en      <= 0;
                ID_RegFile_wr_en  <= 0;
                ID_MemToReg       <= ID_MemToReg;
                ID_Jump           <= 0;
                ID_Mem_op         <= ID_Mem_op;
                ID_Rd_addr        <= ID_Rd_addr;
                ID_Rs1_addr       <= ID_Rs1_addr;
                ID_Rs2_addr       <= ID_Rs2_addr;
                ID_PC_dest        <= ID_PC_dest;
                ID_Immediate_1    <= ID_Immediate_1;
                ID_Immediate_2    <= ID_Immediate_2;
                ID_Exception      <= ID_Exception;
            end
            else begin
                ID_PC <= IF_PC;
                ID_ALU_source_sel <= ALU_source_sel_i;
                ID_ALU_op         <= ALU_op_i;
                ID_Branch_op      <= Branch_op_i;
                ID_Branch_flag    <= Branch_flag_i;
                ID_Mem_wr_en      <= Mem_wr_en_i;
                ID_Mem_rd_en      <= Mem_rd_en_i;
                ID_RegFile_wr_en  <= RegFile_wr_en_i;
                ID_MemToReg       <= MemToReg_i;
                ID_Jump           <= Jump_i;
                ID_Mem_op         <= Mem_op_i;
                ID_Rd_addr        <= Rd_addr_i;
                ID_Rs1_addr       <= Rs1_addr_i;
                ID_Rs2_addr       <= Rs2_addr_i;
                ID_PC_dest        <= Branch_dest_i;
                ID_Immediate_1    <= Immediate_1_i;
                ID_Immediate_2    <= Immediate_2_i;
                ID_Exception      <= Exception_i;
            end
        end  
    end
    
endmodule
