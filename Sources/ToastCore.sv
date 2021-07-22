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


module ToastCore

    (
    //*************************************************
    input             Clk,
    input             Reset_n,   

    //*************************************************
    input  [31:0]     IMEM_data,
    input  [31:0]     DMEM_rd_data,

    //*************************************************
    output [31:0]     IMEM_addr,
    output [31:0]     DMEM_addr,
    output [3:0]      DMEM_wr_byte_en,
    output [31:0]     DMEM_wr_data,
    output            DMEM_wr_en,
    output            DMEM_rst,

    output            Exception
    //*************************************************
    );

// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    // hazards
    wire        IF_ID_Flush;
    wire        EX_Flush;
    bit         Stall;
    
    // forwarding
    wire [1:0]  ForwardA;
    wire [1:0]  ForwardB;
    wire        ForwardS;
    
    // Instruction Fetch
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;

    // Instruction Decode
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
    wire [3:0]  ID_Mem_op;
    wire [31:0] ID_PC_dest;
    wire [31:0] ID_Immediate_1;
    wire [31:0] ID_Immediate_2;
    wire [31:0] ID_Rs1_data;
    wire [31:0] ID_Rs2_data;
    wire [4:0]  ID_Rd_addr;
    wire [4:0]  ID_Rs1_addr;
    wire [4:0]  ID_Rs2_addr;
    wire        ID_Exception;
    
    // Execution
    wire        EX_Mem_wr_en;
    wire        EX_Mem_rd_en;
    wire [3:0]  EX_Mem_op;
    wire        EX_MemToReg;
    wire [31:0] EX_ALU_result; 
    wire [31:0] EX_Rs2_data;
    wire        EX_RegFile_wr_en;
    wire [4:0]  EX_Rd_addr;
    wire [4:0]  EX_Rs2_addr;
    wire [31:0] EX_PC_Branch_dest;
    wire        EX_PC_Branch;
    wire        EX_Exception;
    
    // Memory
    wire [31:0] MEM_dout;
    wire        MEM_MemToReg;
    wire [31:0] MEM_ALU_result;
    wire        MEM_RegFile_wr_en;
    wire [4:0]  MEM_Rd_addr;

    // Writeback
    wire [4:0]  WB_Rd_addr;
    wire [31:0] WB_Rd_data;
    wire        WB_Rd_wr_en;

// ===========================================================================
//                                 Instantiation
// ===========================================================================    
    Forwarding FWD_inst(
    .ForwardA           (ForwardA),
    .ForwardB           (ForwardB),
    .ForwardM           (ForwardM),
    .ID_Rs1_addr        (ID_Rs1_addr),
    .ID_Rs2_addr        (ID_Rs2_addr),
    .ID_Rd_addr         (ID_Rd_addr),
    .EX_Rd_addr         (EX_Rd_addr),
    .EX_Rs2_addr        (EX_Rs2_addr),
    .MEM_Rd_addr        (MEM_Rd_addr),
    .ID_Mem_wr_en       (ID_Mem_wr_en),
    .EX_RegFile_wr_en   (EX_RegFile_wr_en),
    .EX_Mem_rd_en       (EX_Mem_rd_en),
    .MEM_RegFile_wr_en  (MEM_RegFile_wr_en),
    .ID_ALU_source_sel  (ID_ALU_source_sel)
    );
    
    Hazard_detection HD_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .IF_Instruction     (IF_Instruction),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_Rd_addr         (ID_Rd_addr),
    .EX_PC_Branch       (EX_PC_Branch),
    .ID_Jump            (ID_Jump),
    .Stall              (Stall),
    .IF_ID_Flush        (IF_ID_Flush),
    .EX_Flush           (EX_Flush),
    .DMEM_wr_en         (EX_Mem_wr_en)
    );
    
    
    IF_top IF_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .IMEM_data          (IMEM_data),
    .IMEM_addr          (IMEM_addr),
    .ID_PC_dest         (ID_PC_dest),
    .ID_Jump            (ID_Jump),
    .EX_PC_Branch_dest  (EX_PC_Branch_dest),
    .EX_PC_Branch       (EX_PC_Branch),
    .IF_Stall           (Stall), 
    .IF_Flush           (IF_ID_Flush),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction)
    );
    
    ID_top ID_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .IF_PC              (IF_PC),
    .IF_Instruction     (IF_Instruction),
    .ID_Stall           (Stall), //!
    .ID_Flush           (IF_ID_Flush),
    .EX_RegFile_wr_en   (EX_RegFile_wr_en),
    .EX_Rd_addr         (EX_Rd_addr),
    .EX_ALU_result      (EX_ALU_result),
    .WB_Rd_addr         (WB_Rd_addr),
    .WB_Rd_data         (WB_Rd_data),
    .WB_RegFile_wr_en   (WB_RegFile_wr_en),
    .ID_PC              (ID_PC),
    .ID_ALU_source_sel  (ID_ALU_source_sel),
    .ID_ALU_op          (ID_ALU_op),
    .ID_Branch_op       (ID_Branch_op),
    .ID_Branch_flag     (ID_Branch_flag),
    .ID_Mem_wr_en       (ID_Mem_wr_en),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_RegFile_wr_en   (ID_RegFile_wr_en),
    .ID_MemToReg        (ID_MemToReg),
    .ID_Mem_op          (ID_Mem_op),
    .ID_PC_dest         (ID_PC_dest),
    .ID_Jump            (ID_Jump),
    .ID_Exception       (ID_Exception),
    .ID_Immediate_1     (ID_Immediate_1),
    .ID_Immediate_2     (ID_Immediate_2),
    .ID_Rs1_data        (ID_Rs1_data),
    .ID_Rs2_data        (ID_Rs2_data),
    .ID_Rd_addr         (ID_Rd_addr),
    .ID_Rs1_addr        (ID_Rs1_addr),
    .ID_Rs2_addr        (ID_Rs2_addr)
    );
     
    EX_top EX_inst(
    .Clk                (Clk),
    .Reset_n            (Reset_n),
    .EX_Mem_wr_en       (EX_Mem_wr_en),
    .EX_Mem_rd_en       (EX_Mem_rd_en),
    .EX_Mem_op          (EX_Mem_op),
    .EX_Rs2_addr        (EX_Rs2_addr),
    .EX_Rs2_data        (EX_Rs2_data),
    .EX_MemToReg        (EX_MemToReg),
    .EX_ALU_result      (EX_ALU_result),
    .EX_PC_Branch_dest  (EX_PC_Branch_dest),
    .EX_PC_Branch       (EX_PC_Branch),
    .EX_RegFile_wr_en   (EX_RegFile_wr_en),
    .EX_Rd_addr         (EX_Rd_addr),
    .EX_Exception       (EX_Exception),
    .EX_Flush           (EX_Flush),
    .ID_Mem_wr_en       (ID_Mem_wr_en),
    .ID_Mem_rd_en       (ID_Mem_rd_en),
    .ID_Mem_op          (ID_Mem_op),
    .ID_MemToReg        (ID_MemToReg),
    .ID_PC_dest         (ID_PC_dest),
    .ID_Branch_op       (ID_Branch_op),
    .ID_Branch_flag     (ID_Branch_flag),
    .ID_Jump            (ID_Jump),
    .ForwardA           (ForwardA),
    .ForwardB           (ForwardB),
    .WB_Rd_data         (WB_Rd_data),
    .ID_ALU_source_sel  (ID_ALU_source_sel),
    .ID_ALU_op          (ID_ALU_op),
    .ID_Rd_addr         (ID_Rd_addr),
    .ID_Rs2_addr        (ID_Rs2_addr),
    .ID_RegFile_wr_en   (ID_RegFile_wr_en),
    .ID_PC              (ID_PC),
    .ID_Rs1_data        (ID_Rs1_data),
    .ID_Rs2_data        (ID_Rs2_data),
    .ID_Immediate_1     (ID_Immediate_1),
    .ID_Immediate_2     (ID_Immediate_2),
    .ID_Exception       (ID_Exception)
    );
    

    MEM_top MEM_inst(
    .Clk               (Clk),
    .Reset_n           (Reset_n),
    .mem_addr          (DMEM_addr),
    .mem_wr_byte_en    (DMEM_wr_byte_en),
    .mem_wr_data       (DMEM_wr_data),
    .mem_wr_en         (DMEM_wr_en),
    .mem_rst           (DMEM_rst),
    .mem_rd_data       (DMEM_rd_data),
    .ForwardM          (ForwardM),
    .WB_Rd_data        (WB_Rd_data),
    .MEM_dout          (MEM_dout),
    .MEM_MemToReg      (MEM_MemToReg),
    .MEM_ALU_result    (MEM_ALU_result),
    .MEM_RegFile_wr_en (MEM_RegFile_wr_en),
    .MEM_Rd_addr       (MEM_Rd_addr),
    .MEM_Exception     (Exception),
    .EX_Mem_wr_en      (EX_Mem_wr_en),
    .EX_Mem_op         (EX_Mem_op),
    .EX_MemToReg       (EX_MemToReg),
    .EX_ALU_result     (EX_ALU_result),
    .EX_Rs2_data       (EX_Rs2_data),
    .EX_RegFile_wr_en  (EX_RegFile_wr_en),
    .EX_Rd_addr        (EX_Rd_addr),
    .EX_Exception      (EX_Exception)
    );


    WB_top WB_inst(
    .WB_Rd_addr        (WB_Rd_addr),
    .WB_Rd_data        (WB_Rd_data),
    .WB_RegFile_wr_en  (WB_RegFile_wr_en),
    .MEM_Rd_addr       (MEM_Rd_addr),
    .MEM_dout          (MEM_dout),
    .MEM_ALU_result    (MEM_ALU_result),
    .MEM_MemToReg      (MEM_MemToReg),
    .MEM_RegFile_wr_en (MEM_RegFile_wr_en)
    );

endmodule
