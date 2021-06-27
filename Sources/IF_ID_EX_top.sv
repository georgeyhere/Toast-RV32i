`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2021 09:29:37 PM
// Design Name: 
// Module Name: IF_ID_EX_top
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


module IF_ID_EX_top

    (
    input            Clk,
    input            Reset_n,
    
    input            IF_Stall,
    input            ID_Stall,
    
    output [31:0]    EX_ALU_result
    );
    
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
    
    wire [1:0]  ID_Branch_op;
    wire        ID_Branch_flag;
    wire        ID_Jump;
    wire [1:0]  ID_ALU_source_sel;
    wire [3:0]  ID_ALU_op;
    wire [31:0] ID_PC;
    wire [31:0] ID_Rs1_data;
    wire [31:0] ID_Rs2_data;
    wire [31:0] ID_Immediate_1;
    wire [31:0] ID_Immediate_2;
    
    wire [31:0] EX_Branch_dest;
    wire        EX_PC_source_sel;
    
    wire [31:0] WB_Rd_address;
    wire [31:0] WB_Rd_wr_data;
    wire        WB_wr_en;
    
    
    RV32I_IF IF_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .EX_PC_Branch_dest  (EX_PC_Branch_dest),
    .EX_PC_Source_sel   (EX_PC_Source_sel),
    .IF_Stall           (IF_Stall),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction)
    );
    
    RV32I_ID ID_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction),
    .ID_Stall           (ID_Stall),
    .WB_Regfile_Rd_addr (32'd32),
    .WB_RegFile_wr_data (32'd420),
    .WB_RegFile_wr_en   (1'b0),
    .ID_PC              (ID_PC),
    .ID_ALU_source_sel  (ID_ALU_source_sel),
    .ID_ALU_op          (ID_ALU_op),
    .ID_Branch_op       (ID_Branch_op),
    .ID_Branch_flag     (ID_Branch_flag),
    .ID_Mem_wr_en       (ID_Mem_wr_en),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_RegFile_wr_en   (ID_RegFile_wr_en),
    .ID_MemToReg        (ID_MemToReg),
    .ID_Jump            (ID_Jump),
    .ID_Mem_op          (ID_Mem_op),
    .ID_Immediate_1     (ID_Immediate_1),
    .ID_Immediate_2     (ID_Immediate_2),
    .ID_Rs1_data        (ID_Rs1_data),
    .ID_Rs2_data        (ID_Rs2_data),
    .ID_Rd_addr         (ID_Rd_addr)
    );
     
    RV32I_EX EX_inst(
    .Clk               (Clk),
    .Reset_n           (Reset_n),
    .ID_Branch_op      (ID_Branch_op),
    .ID_Branch_flag    (ID_Branch_flag),
    .ID_Jump           (ID_Jump),
    .ForwardA          (ForwardA),
    .ForwardB          (ForwardB),
    .ID_ALU_source_sel (ID_ALU_source_sel),
    .ID_ALU_op         (ID_ALU_op),
    .ID_PC             (ID_PC),
    .ID_Rs1_data       (ID_Rs1_data),
    .ID_Rs2_data       (ID_Rs2_data),
    .ID_Immediate_1    (ID_Immediate_1),
    .ID_Immediate_2    (ID_Immediate_2),
    .EX_ALU_result     (EX_ALU_result),
    .EX_PC_Branch_dest (EX_PC_Branch_dest),
    .EX_PC_source_sel  (EX_PC_source_sel)
    );
    
endmodule
