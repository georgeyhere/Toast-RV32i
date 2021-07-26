`timescale 1ns / 1ps
`default_nettype none
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


module toast_ID_stage
    `include "toast_definitions.vh"
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
    input  wire                            clk_i,
    input  wire                            resetn_i,
    input  wire                            flush_i,
    input  wire                            stall_i,

    // pipeline out
    output reg   [REG_DATA_WIDTH-1:0]      ID_pc_o,

    // control signals
    output reg   [1:0]                     ID_alu_source_sel_o, // [1] -> op1 [2] -> op2  || gets imm
    output reg   [ALU_OP_WIDTH-1 :0]       ID_alu_ctrl_o,       // alu operation to perform
    output reg   [1:0]                     ID_branch_op_o,      // branch gen operation to perform
    output reg                             ID_branch_flag_o,    // execute branch on ALU 'set' or 'not set'
    output reg                             ID_mem_wr_en_o,      // enable data mem write
    output reg                             ID_mem_rd_en_o,      // indicates data mem load (name misleading)
    output reg                             ID_rd_wr_en_o,       // enable regfile writeback 
    output reg                             ID_memtoreg_o,       // enable regfile writeback from data mem
    output reg                             ID_jump_en_o,        // indicates a jump
    output reg   [3:0]                     ID_mem_op_o,         // selects memory mask for load/store
    
    // branch/jump destination
    output wire  [REG_DATA_WIDTH-1:0]      ID_pc_dest_o,
   
    // ALU operands
    output reg   [REG_DATA_WIDTH-1 :0]     ID_imm1_o,
    output reg   [REG_DATA_WIDTH-1 :0]     ID_imm2_o,
    output wire  [REG_DATA_WIDTH-1 :0]     ID_rs1_data_o,
    output wire  [REG_DATA_WIDTH-1 :0]     ID_rs2_data_o,
  
    // regfile addresses
    output reg   [REGFILE_ADDR_WIDTH-1:0]  ID_rd_addr_o,
    output reg   [REGFILE_ADDR_WIDTH-1:0]  ID_rs1_addr_o,
    output reg   [REGFILE_ADDR_WIDTH-1:0]  ID_rs2_addr_o,

    // ECALL or EBREAK detected
    output reg                             ID_exception_o,

    // pipeline in
    input  wire  [REG_DATA_WIDTH-1:0]      IF_pc_i,
    input  wire  [REG_DATA_WIDTH-1:0]      IF_instruction_i,
    
    // jump destination forwarding
    input  wire                            EX_rd_wr_en_i,
    input  wire  [REGFILE_ADDR_WIDTH-1:0]  EX_rd_addr_i,
    input  wire  [REG_DATA_WIDTH-1:0]      EX_alu_result_i,

    // regfile write
    input  wire  [REGFILE_ADDR_WIDTH-1:0]  WB_rd_addr_i,
    input  wire  [REG_DATA_WIDTH-1:0]      WB_rd_wr_data_i,
    input  wire                            WB_rd_wr_en_i
    );
    
// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================

    wire [4:0]  rd_addr;
    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    
    wire [31:0] imm1;
    wire [31:0] imm2;
    
    wire [1:0]  alu_source_sel;
    wire [3:0]  alu_ctrl;
    wire [1:0]  branch_op;
    wire        branch_flag;
    wire        mem_wr_en;
    wire        mem_rd_en;
    wire        rd_wr_en;
    wire        memtoreg;
    wire        jump_en;
    wire [3:0]  mem_op;
    wire        exception;

    reg  [31:0] branch_regdata;

    


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
    always@* begin
        if((ID_branch_op_o[1] == 1'b1)    &&
           (EX_rd_addr_i == ID_rs1_addr_o) &&
           (EX_rd_wr_en_i == 1'b1))
                branch_regdata = EX_alu_result_i;
        else
            branch_regdata = ID_rs1_data_o;
    end


    // pipeline registers
    always@(posedge clk_i) begin
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
