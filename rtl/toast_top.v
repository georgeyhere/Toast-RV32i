`timescale 1ns / 1ps
`default_nettype none
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
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_top

    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH
          parameter REGFILE_ADDR_WIDTH  = `REGFILE_ADDR_WIDTH
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH
          parameter ALU_OP_WIDTH    = `ALU_OP_WIDTH
          )
    `else
        #(parameter REG_DATA_WIDTH  = 32,
          parameter REGFILE_ADDR_WIDTH  = 5,
          parameter IMEM_ADDR_WIDTH = 32,
          parameter ALU_OP_WIDTH    = 4)
    `endif
    (
    // Clock and Reset
    input  wire              clk_i,
    input  wire              resetn_i,   

    // Data memory interface
    output wire   [3:0]      DMEM_wr_byte_en_o,
    output wire   [31:0]     DMEM_addr_o,
    output wire   [31:0]     DMEM_wr_data_o,
    input  wire   [31:0]     DMEM_rd_data_i,
    output wire              DMEM_rst_o,

    // Instruction memory interface
    input  wire   [31:0]     IMEM_data_i,
    output wire   [31:0]     IMEM_addr_o,
    
    // ECALL, EBREAK, misaligned store indicator
    output wire              exception_o
    );

// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    
    // forwarding
    wire [1:0]                     forwardA;
    wire [1:0]                     forwardB;
    wire                           forwardM;
     
    // stalls and flushes     
    wire                           stall_IF_ID;
    wire                           flush_IF_ID;
    wire                           flush_EX;
     
    // IF     
    wire [REG_DATA_WIDTH-1:0]      IF_instruction;
    wire [REG_DATA_WIDTH-1:0]      IF_pc;

    // ID
    wire [REG_DATA_WIDTH-1:0]      ID_pc;
    wire [1:0]                     ID_alu_source_sel;
    wire [ALU_OP_WIDTH-1 :0]       ID_alu_ctrl;
    wire [1:0]                     ID_branch_op;
    wire                           ID_branch_flag;
    wire                           ID_mem_wr_en;
    wire                           ID_mem_rd_en;
    wire                           ID_rd_wr_en;
    wire                           ID_memtoreg;
    wire                           ID_jump_en;
    wire [3:0]                     ID_mem_op;
    wire [REG_DATA_WIDTH-1:0]      ID_pc_dest;
    wire [REG_DATA_WIDTH-1 :0]     ID_imm1;
    wire [REG_DATA_WIDTH-1 :0]     ID_imm2;
    wire [REG_DATA_WIDTH-1 :0]     ID_rs1_data;
    wire [REG_DATA_WIDTH-1 :0]     ID_rs2_data;
    wire [REGFILE_ADDR_WIDTH-1:0]  ID_rd_addr;
    wire [REGFILE_ADDR_WIDTH-1:0]  ID_rs1_addr;
    wire [REGFILE_ADDR_WIDTH-1:0]  ID_rs2_addr;
    wire                           ID_exception;

    // EX
    wire                           EX_exception;
    wire                           EX_mem_wr_en;
    wire                           EX_mem_rd_en;
    wire [3:0]                     EX_mem_op;
    wire [REG_DATA_WIDTH-1:0]      EX_rs2_data;
    wire                           EX_memtoreg;
    wire                           EX_rd_wr_en;
    wire [REGFILE_ADDR_WIDTH-1:0]  EX_rd_addr;
    wire [REGFILE_ADDR_WIDTH-1:0]  EX_rs2_addr;
    wire [REG_DATA_WIDTH-1:0]      EX_alu_result;
    wire [REG_DATA_WIDTH-1:0]      EX_pc_dest;
    wire                           EX_branch_en;

    // MEM
    wire [REG_DATA_WIDTH-1:0]      MEM_dout;
    wire                           MEM_memtoreg;
    wire [REG_DATA_WIDTH-1:0]      MEM_alu_result;
    wire                           MEM_rd_wr_en;
    wire [REGFILE_ADDR_WIDTH-1:0]  MEM_rd_addr;

    // WB
    wire [REGFILE_ADDR_WIDTH-1:0]  WB_rd_addr;
    wire [REG_DATA_WIDTH-1:0]      WB_rd_wr_data;
    wire                           WB_rd_wr_en;


// ===========================================================================
//                                 Instantiation
// ===========================================================================    
   
    //*********************************    
    //            CONTROL
    //*********************************
    toast_control control_i   (
        .clk_i               (clk_i),
        .resetn_i            (resetn_i),

        // forwarding
        .forwardA_o          (forwardA),
        .forwardB_o          (forwardB),
        .forwardM_o          (forwardM),

        .ID_alu_source_sel_i (ID_alu_source_sel),
        .ID_rs1_addr_i       (ID_rs1_addr),
        .ID_rs2_addr_i       (ID_rs2_addr),
        .ID_rd_addr_i        (ID_rd_addr),
        .EX_rd_addr_i        (EX_rd_addr),
        .EX_rs2_addr_i       (EX_rs2_addr),
        .MEM_rd_addr_i       (MEM_rd_addr),
        .EX_rd_wr_en_i       (EX_rd_wr_en),
        .MEM_rd_wr_en_i      (MEM_rd_wr_en),

        // pipeline stall/flushes
        .stall_o             (stall_IF_ID),
        .IF_ID_flush_o       (flush_IF_ID),
        .EX_flush_o          (flush_EX),

        .IF_instruction_i    (IF_instruction),
        .ID_mem_rd_en_i      (ID_mem_rd_en),
        .EX_branch_en_i      (EX_branch_en),
        .ID_jump_en_i        (ID_jump_en)
    );


    //*********************************    
    //          IF STAGE
    //*********************************
    toast_IF_stage if_stage_i   (
        .clk_i               (clk_i),
        .resetn_i            (resetn_i),
   
        .stall_i             (stall_IF_ID),
        .flush_i             (flush_IF_ID),

        // Instruction memory interface
        .IMEM_addr_o         (IMEM_addr_o),
        .IMEM_data_i         (IMEM_data_i),

        // Branches and Jumps
        .EX_branch_en_i      (EX_branch_en),
        .EX_pc_dest_i        (EX_pc_dest),
        .ID_jump_en_i        (ID_jump_en),
        .ID_pc_dest_i        (ID_pc_dest),
 
        // Pipeline out 
        .IF_instruction_o    (IF_instruction),
        .IF_pc_o             (IF_pc)
    );


    //*********************************    
    //          ID STAGE
    //*********************************
    toast_ID_stage id_stage_i   (
        .clk_i               (clk_i),
        .resetn_i            (resetn_i),
   
        .stall_i             (stall_IF_ID),
        .flush_i             (flush_IF_ID),
        .ID_exception_o      (ID_exception),

        // pipeline in
        .IF_pc_i             (IF_pc),
        .IF_instruction_i    (IF_instruction),

        // pipeline out
        .ID_pc_o             (ID_pc),
        .ID_alu_source_sel_o (ID_alu_source_sel),
        .ID_alu_ctrl_o       (ID_alu_ctrl),
        .ID_mem_wr_en_o      (ID_mem_wr_en),
        .ID_mem_rd_en_o      (ID_mem_rd_en),
        .ID_rd_wr_en_o       (ID_rd_wr_en),
        .ID_memtoreg_o       (ID_memtoreg),
        .ID_mem_op_o         (ID_mem_op),

        // regfile
        .ID_imm1_o           (ID_imm1),
        .ID_imm2_o           (ID_imm2),
        .ID_rs1_data_o       (ID_rs1_data),
        .ID_rs2_data_o       (ID_rs2_data),
        .ID_rs1_addr_o       (ID_rs1_addr),
        .ID_rs2_addr_o       (ID_rs2_addr),
        .ID_rd_addr_o        (ID_rd_addr),

        .WB_rd_addr_i        (WB_rd_addr),
        .WB_rd_wr_data_i     (WB_rd_wr_data),
        .WB_rd_wr_en_i       (WB_rd_wr_en),
        
        // branch/jump
        .ID_jump_en_o        (ID_jump_en),
        .ID_pc_dest_o        (ID_pc_dest),
        .ID_branch_op_o      (ID_branch_op),
        .ID_branch_flag_o    (ID_branch_flag),

        .EX_rd_wr_en_i       (EX_rd_wr_en),
        .EX_rd_addr_i        (EX_rd_addr),
        .EX_alu_result_i     (EX_alu_result)
    );


    //*********************************    
    //          EX STAGE
    //*********************************
    toast_EX_stage ex_stage_i (
        .clk_i                (clk_i),
        .resetn_i             (resetn_i),

        .flush_i              (flush_EX),
        .EX_exception_o       (EX_exception),

        // pipeline in
        .ID_mem_wr_en_i       (ID_mem_wr_en),
        .ID_mem_rd_en_i       (ID_mem_rd_en),
        .ID_mem_op_i          (ID_mem_op),
        .ID_memtoreg_i        (ID_memtoreg),
        .ID_rd_wr_en_i        (ID_rd_wr_en),
        .ID_rd_addr_i         (ID_rd_addr),
        .ID_rs2_addr_i        (ID_rs2_addr),
        .ID_exception_i       (ID_exception),

        // pipeline out
        .EX_mem_wr_en_o       (EX_mem_wr_en),
        .EX_mem_rd_en_o       (EX_mem_rd_en),
        .EX_mem_op_o          (EX_mem_op),
        .EX_memtoreg_o        (EX_memtoreg),
        .EX_rd_wr_en_o        (EX_rd_wr_en),
        .EX_rd_addr_o         (EX_rd_addr),
        .EX_rs2_addr_o        (EX_rs2_addr),
        .EX_rs2_data_o        (EX_rs2_data),

        // branch logic
        .EX_branch_en_o       (EX_branch_en),
        .EX_pc_dest_o         (EX_pc_dest),
        .ID_pc_dest_i         (ID_pc_dest),
        .ID_branch_op_i       (ID_branch_op),
        .ID_branch_flag_i     (ID_branch_flag),
        .ID_jump_en_i         (ID_jump_en),

        // forwarding
        .forwardA_i           (forwardA),
        .forwardB_i           (forwardB),
        .WB_rd_wr_data_i      (WB_rd_wr_data),

        // ALU 
        .EX_alu_result_o      (EX_alu_result),

        .ID_alu_source_sel_i  (ID_alu_source_sel),
        .ID_alu_ctrl_i        (ID_alu_ctrl),
        .ID_pc_i              (ID_pc),
        .ID_rs1_data_i        (ID_rs1_data),
        .ID_rs2_data_i        (ID_rs2_data),
        .ID_imm1_i            (ID_imm1),
        .ID_imm2_i            (ID_imm2)
    );


    //*********************************    
    //          MEM STAGE
    //*********************************
    toast_MEM_stage mem_stage_i (
        .clk_i                 (clk_i),
        .resetn_i              (resetn_i),

        .MEM_exception_o       (exception_o),

        // Data memory interface
        .DMEM_addr_o           (DMEM_addr_o),
        .DMEM_wr_byte_en_o     (DMEM_wr_byte_en_o),
        .DMEM_wr_data_o        (DMEM_wr_data_o),
        .DMEM_rst_o            (DMEM_rst_o),
        .DMEM_rd_data_i        (DMEM_rd_data_i),

        // Data memory write source
        .ForwardM_i            (forwardM),
        .EX_alu_result_i       (EX_alu_result),
        .EX_rs2_data_i         (EX_rs2_data),

        // pipeline in
        .EX_mem_wr_en_i        (EX_mem_wr_en),
        .EX_mem_op_i           (EX_mem_op),
        .EX_memtoreg_i         (EX_memtoreg),
        .EX_rd_wr_en_i         (EX_rd_wr_en),
        .EX_rd_addr_i          (EX_rd_addr),
        .EX_exception_i        (EX_exception),

        // pipeline out
        .MEM_dout_o            (MEM_dout),
        .MEM_memtoreg_o        (MEM_memtoreg),
        .MEM_alu_result_o      (MEM_alu_result),
        .MEM_rd_wr_en_o        (MEM_rd_wr_en),
        .MEM_rd_addr_o         (MEM_rd_addr)
    );


    //*********************************    
    //          WB STAGE
    //*********************************
    toast_WB_stage wb_stage_i (
        .WB_rd_addr_o          (WB_rd_addr),
        .WB_rd_wr_data_o       (WB_rd_wr_data),
        .WB_rd_wr_en_o         (WB_rd_wr_en),

        .MEM_rd_addr_i         (MEM_rd_addr),
        .MEM_dout_i            (MEM_dout),
        .MEM_alu_result_i      (MEM_alu_result),
        .MEM_memtoreg_i        (MEM_memtoreg),
        .MEM_rd_wr_en_i        (MEM_rd_wr_en)
    );

endmodule
