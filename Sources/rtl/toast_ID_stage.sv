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
import toast_def_pkg ::*;

module toast_ID_stage
    
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
    input  logic                           clk_i,
    input  logic                           resetn_i,
    input  logic                           flush_i,
    input  logic                           stall_i,

    // pipeline out
    output logic [REG_DATA_WIDTH-1:0]      ID_pc_o,

    // control signals
    output logic [1:0]                     ID_alu_source_sel_o,
    output logic [ALU_OP_WIDTH-1 :0]       ID_alu_ctrl_o,
    output logic [1:0]                     ID_branch_op_o, 
    output logic                           ID_branch_flag_o,
    output logic                           ID_mem_wr_en_o,
    output logic                           ID_mem_rd_en_o,
    output logic                           ID_rd_wr_en_o,
    output logic                           ID_memtoreg_o,
    output logic                           ID_jump_en_o,
    output logic [3:0]                     ID_mem_op_o,
    
    // branch/jump destination
    output logic [REG_DATA_WIDTH-1:0]      ID_pc_dest_o,
   
    // ALU operands
    output logic [REG_DATA_WIDTH-1 :0]     ID_imm1_o,
    output logic [REG_DATA_WIDTH-1 :0]     ID_imm2_o,
    output logic [REG_DATA_WIDTH-1 :0]     ID_rs1_data_o,
    output logic [REG_DATA_WIDTH-1 :0]     ID_rs2_data_o,
  
    // regfile addresses
    output logic [REGFILE_ADDR_WIDTH-1:0]  ID_rd_addr_o,
    output logic [REGFILE_ADDR_WIDTH-1:0]  ID_rs1_addr_o,
    output logic [REGFILE_ADDR_WIDTH-1:0]  ID_rs2_addr_o,

    // ECALL or EBREAK detected
    output logic                           ID_exception_o,

    // pipeline in
    input  logic [REG_DATA_WIDTH-1:0]      IF_pc_i,
    input  logic [REG_DATA_WIDTH-1:0]      IF_instruction_i,
    
    // jump destination forwarding
    input  logic                           EX_rd_wr_en_i,
    input  logic [REGFILE_ADDR_WIDTH-1:0]  EX_rd_addr_i,
    input  logic [REG_DATA_WIDTH-1:0]      EX_alu_result_i,

    // regfile
    input  logic [REGFILE_ADDR_WIDTH-1:0]  WB_rd_addr_i,
    input  logic [REG_DATA_WIDTH-1:0]      WB_rd_wr_data_i,
    input  logic                           WB_rd_wr_en_i
    );
    
// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================

    logic [4:0]  rd_addr;
    logic [4:0]  rs1_addr;
    logic [4:0]  rs2_addr;
    
    logic [31:0] imm1;
    logic [31:0] imm2;
    
    logic [1:0]  alu_source_sel;
    logic [3:0]  alu_ctrl;
    logic [1:0]  branch_op;
    logic        branch_flag;
    logic        mem_wr_en;
    logic        mem_rd_en;
    logic        rd_wr_en;
    logic        memtoreg;
    logic        jump_en;
    logic [3:0]  mem_op;
    logic        exception;

    logic [31:0] branch_regdata;

    


// ===========================================================================
//                              Instantiation   
// ===========================================================================    
    toast_decoder decoder_i(
    .rd_addr_o         (rd_addr           ),
    .rs1_addr_o        (rs1_addr          ),
    .rs2_addr_o        (rs2_addr          ),
    .imm1_o            (imm1              ),
    .imm2_o            (imm2              ),
    .alu_source_sel_o  (alu_source_sel    ),
    .alu_op_o          (alu_ctrl          ),
    .branch_op_o       (branch_op         ),
    .branch_flag_o     (branch_flag       ),
    .mem_wr_en_o       (mem_wr_en         ),
    .mem_rd_en_o       (mem_rd_en         ),
    .rd_wr_en_o        (rd_wr_en          ),
    .memtoreg_o        (memtoreg          ),
    .jump_en_o         (jump_en           ),
    .mem_op_o          (mem_op            ),
    .exception_o       (exception         ),
    .instruction_i     (IF_instruction_i  ),
    .pc_i              (IF_pc_i           )
    );
    
    toast_regfile regfile_i(
    .clk_i             (clk_i             ),
    .resetn_i          (resetn_i          ),
    .rs1_data_o        (ID_rs1_data_o     ),
    .rs2_data_o        (ID_rs2_data_o     ),
    .rs1_addr_i        (ID_rs1_addr_o     ),
    .rs2_addr_i        (ID_rs2_addr_o     ),
    .rd_addr_i         (WB_rd_addr_i      ),
    .rd_wr_data_i      (WB_rd_wr_data_i   ),
    .rd_wr_en_i        (WB_rd_wr_en_i     )
    );
    
    toast_branchgen branchgen_i(
    .branch_dest_o     (ID_pc_dest_o      ),
    .branch_op_i       (ID_branch_op_o    ),
    .pc_i              (ID_pc_o           ),
    .regdata_i         (branch_regdata    ),
    .imm_i             (ID_imm2_o         )
    );
    
    
// ===========================================================================
//                              Implementation    
// ===========================================================================    
    // branchgen forwarding
    always_comb begin
        if((ID_branch_op_o[1] == 1'b1)    &&
           (EX_rd_addr_i == ID_rs1_addr_o) &&
           (EX_rd_wr_en_i == 1'b1))
                branch_regdata = EX_alu_result_i;
        else
            branch_regdata = ID_rs1_data_o;
    end


    // pipeline registers
    always_ff@(posedge clk_i) begin
        // reset state is the same as NOP, all control signals set to 0
        if((resetn_i == 1'b0) || (flush_i == 1'b1)) begin
            ID_pc_o             <= 0;
            ID_alu_source_sel_o <= 0;
            ID_alu_ctrl_o         <= 0;
            ID_branch_op_o      <= 0;
            ID_branch_flag_o    <= 0;
            ID_mem_wr_en_o      <= 0;
            ID_mem_rd_en_o      <= 0;
            ID_rd_wr_en_o       <= 0;
            ID_memtoreg_o       <= 0;
            ID_jump_en_o        <= 0;
            ID_mem_op_o         <= 0;
            ID_rd_addr_o        <= 0;
            ID_rs1_addr_o       <= 0;
            ID_rs2_addr_o       <= 0;
            ID_imm1_o           <= 0;
            ID_imm2_o           <= 0;
            ID_exception_o      <= 0;
        end
        else begin
            // on stall, drop control signals to 0
            if(stall_i == 1'b1) begin
                ID_pc_o             <= ID_pc_o;
                ID_alu_source_sel_o <= ID_alu_source_sel_o;
                ID_alu_ctrl_o       <= ID_alu_ctrl_o;
                ID_branch_op_o      <= ID_branch_op_o;
                ID_branch_flag_o    <= ID_branch_flag_o;
                ID_mem_wr_en_o      <= 0; 
                ID_mem_rd_en_o      <= 0;
                ID_rd_wr_en_o       <= 0;
                ID_memtoreg_o       <= ID_memtoreg_o;
                ID_jump_en_o        <= 0;
                ID_mem_op_o         <= ID_mem_op_o;
                ID_rd_addr_o        <= ID_rd_addr_o;
                ID_rs1_addr_o       <= ID_rs1_addr_o;
                ID_rs2_addr_o       <= ID_rs2_addr_o;
                ID_imm1_o           <= ID_imm1_o;
                ID_imm2_o           <= ID_imm2_o;
                ID_exception_o      <= ID_exception_o;
            end
            else begin
                ID_pc_o             <= IF_pc_i;
                ID_alu_source_sel_o <= alu_source_sel;
                ID_alu_ctrl_o       <= alu_ctrl;
                ID_branch_op_o      <= branch_op;
                ID_branch_flag_o    <= branch_flag;
                ID_mem_wr_en_o      <= mem_wr_en; 
                ID_mem_rd_en_o      <= mem_rd_en;
                ID_rd_wr_en_o       <= rd_wr_en;
                ID_memtoreg_o       <= memtoreg;
                ID_jump_en_o        <= jump_en;
                ID_mem_op_o         <= mem_op;
                ID_rd_addr_o        <= rd_addr;
                ID_rs1_addr_o       <= rs1_addr;
                ID_rs2_addr_o       <= rs2_addr;
                ID_imm1_o           <= imm1;
                ID_imm2_o           <= imm2;
                ID_exception_o      <= exception;
            end
        end  
    end
    
endmodule
