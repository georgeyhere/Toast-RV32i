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
    
    output [31:0]    EX_ALU_result
    );
    
    wire        IF_ID_Flush;
    wire        EX_Flush;
    wire        Stall;
    
    wire [1:0]  ForwardA;
    wire [1:0]  ForwardB;
    
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
    wire [4:0]  IF_Rs1_addr;
    wire [4:0]  IF_Rs2_addr;
    
    wire [31:0] ID_PC;
    wire [1:0]  ID_ALU_source_sel;
    wire [3:0]  ID_ALU_op;
    wire [1:0]  ID_Branch_op;
    wire        ID_Branch_flag;
    wire        ID_Mem_wr_en;
    wire        ID_Mem_rd_en;
    wire        ID_RegFile_wr_en; 
    wire        ID_MemToReg;
    wire        ID_Jump;
    wire [31:0] ID_PC_dest;
    wire [31:0] ID_Immediate_1;
    wire [31:0] ID_Immediate_2;
    wire [31:0] ID_Rs1_data;
    wire [31:0] ID_Rs2_data;
    wire [4:0]  ID_Rd_addr;
    wire [4:0]  ID_Rs1_addr;
    wire [4:0]  ID_Rs2_addr;
    
    
    
    wire        EX_Mem_wr_en;
    wire        EX_Mem_rd_en;
    wire [2:0]  EX_Mem_op;
    wire        EX_MemToReg;
    wire        EX_ALU_result; 
    wire [31:0] EX_PC_Branch_dest;
    wire        EX_PC_Branch;
    wire        EX_RegFile_wr_en;
    wire [4:0]  EX_Rd_addr;
    
    
    wire [31:0] WB_Rd_addr;
    wire [31:0] WB_Rd_data;
    wire        WB_Rd_wr_en;
    
    
    Forwarding FWD_inst(
    .ForwardA           (ForwardA),
    .ForwardB           (ForwardB),
    .ID_Rs1_addr        (ID_Rs1_addr),
    .ID_Rs2_addr        (ID_Rs2_addr),
    .EX_Rd_addr         (EX_Rd_addr),
    .MEM_Rd_addr        (MEM_Rd_addr),
    .EX_RegFile_wr_en   (EX_RegFile_wr_en),
    .MEM_RegFile_wr_en  (MEM_RegFile_wr_en)
    );
    
    Hazard_detection HD_inst(
    .IF_Instruction     (IF_Instruction),
    .IF_Rs1_addr        (IF_Rs1_addr),
    .IF_Rs2_addr        (IF_Rs2_addr),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_Rd_addr         (ID_Rd_addr),
    .EX_PC_Branch       (EX_PC_Branch),
    .ID_Jump            (ID_Jump),
    .Stall              (Stall),
    .IF_ID_Flush        (IF_ID_Flush),
    .EX_Flush           (EX_Flush)
    );
    
    
    RV32I_IF IF_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .EX_PC_Branch_dest  (EX_PC_Branch_dest),
    .EX_PC_Branch       (EX_PC_Branch),
    .ID_PC_dest         (ID_PC_dest),
    .ID_Jump            (ID_Jump),
    .IF_Stall           (Stall), //!
    .IF_Flush           (IF_ID_Flush),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction),
    .IF_Rs1_addr        (IF_Rs1_addr),
    .IF_Rs2_addr        (IF_Rs2_addr)
    );
    
    RV32I_ID ID_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction),
    .ID_Stall           (Stall), //!
    .ID_Flush           (IF_ID_Flush),
    .WB_Rd_addr         (32'd32),
    .WB_Rd_data         (32'd420),
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
    .ID_PC_dest         (ID_PC_dest),
    .ID_Immediate_1     (ID_Immediate_1),
    .ID_Immediate_2     (ID_Immediate_2),
    .ID_Rs1_data        (ID_Rs1_data),
    .ID_Rs2_data        (ID_Rs2_data),
    .ID_Rd_addr         (ID_Rd_addr),
    .ID_Rs1_addr        (ID_Rs1_addr),
    .ID_Rs2_addr        (ID_Rs2_addr)
    );
     
    RV32I_EX EX_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .EX_Mem_wr_en       (EX_Mem_wr_en),
    .EX_Mem_rd_en       (EX_Mem_rd_en),
    .EX_Mem_op          (EX_Mem_op),
    .EX_MemToReg        (EX_MemToReg),
    .EX_ALU_result      (EX_ALU_result),
    .EX_PC_Branch_dest  (EX_PC_Branch_dest),
    .EX_PC_Branch       (EX_PC_Branch),
    .EX_RegFile_wr_en   (EX_RegFile_wr_en),
    .EX_Rd_addr         (EX_Rd_addr),
    .EX_Jump            (EX_Jump),
    .EX_Flush           (EX_Flush),
    .ID_Mem_wr_en       (ID_Mem_wr_en),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_Mem_op          (ID_Mem_op),
    .ID_MemToReg        (ID_MemToReg),
    .ID_Branch_op       (ID_Branch_op),
    .ID_Branch_flag     (ID_Branch_flag),
    .ID_Jump            (ID_Jump),
    .ForwardA           (ForwardA),
    .ForwardB           (ForwardB),
    .ID_ALU_source_sel  (ID_ALU_source_sel),
    .ID_ALU_op          (ID_ALU_op),
    .ID_Rd_addr         (ID_Rd_addr),
    .ID_RegFile_wr_en   (ID_RegFile_wr_en),
    .ID_PC              (ID_PC),
    .ID_Rs1_data        (ID_Rs1_data),
    .ID_Rs2_data        (ID_Rs2_data),
    .ID_Immediate_1     (ID_Immediate_1),
    .ID_Immediate_2     (ID_Immediate_2)
    );
    
endmodule
