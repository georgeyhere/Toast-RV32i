`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2021 12:22:13 PM
// Design Name: 
// Module Name: Formal_ID_top
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
/////////////////////////////////////////////////////////////////////////////////


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
    input                                 Clk,
    input                                 Reset_n,
    
    input                                 instr_valid,
    input      [31:0]                     instr,
    
`ifdef RISCV_FORMAL
    // instruction metadeta
    output reg                            rvfi_valid,
    output reg [63:0]                     rvfi_order,
    output reg [31:0]                     rvfi_isn,
    output reg                            rvfi_trap,
    output reg                            rvfi_halt,
    output reg                            rvfi_intr,
    output reg                            rvfi_mode,
    output reg                            rvfi_ixl,

    // integer register read/write
    output reg [4:0]                      rvfi_rs1_addr,
    output reg [4:0]                      rvfi_rs2_addr,
    output reg [31:0]                     rvfi_rs1_rdata,
    output reg [31:0]                     rvfi_rs2_rdata,
    output reg [4:0]                      rvfi_rd_addr,
    output reg [31:0]                     rvfi_rd_wdata,

    // program counter
    //output reg [31:0]                     rvfi_pc_rdata,
    //output reg [31:0]                     rvfi_pc_wdata,
`endif


    );
    

    wire [4:0] Rd_addr;
    wire [4:0] Rs1_addr;
    wire [4:0] Rs2_addr;
    
    wire [31:0] Immediate_1, Immediate_2;
    wire [31:0] Rs1_data, Rs2_data;
    
    wire       trap;
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


`ifdef RISCV_FORMAL
    always@(posedge Clk) begin

        rvfi_valid <= IF_valid;
        rvfi_order <= Reset_n ? (rvfi_order + rvfi_valid) : 0;

        rvfi_isn       <= IF_Instruction;
        rvfi_trap      <= trap;
        rvfi_halt      <= trap;
        rvfi_intr      <= 1'b0;
        rvfi_mode      <= 0;
        rvfi_ixl       <= 1;


        rvfi_rs1_addr  <= ID_Rs1_addr;
        rvfi_rs2_addr  <= ID_Rs2_addr;
        rvfi_rd_addr   <= ID_Rd_addr;
        rvfi_rs1_rdata <= ID_Rs1_data;
        rvfi_rs2_rdata <= ID_Rs2_data;

    end
`endif

	
	.ID_top ID_inst(
		.Clk               (Clk),
		.Reset_n           (Reset_n),
		.IF_valid          (IF_valid),
		.IF_PC             (IF_PC),
		.IF_Instruction    (IF_Instruction),
		.ID_Stall          (ID_Stall),
		.ID_Flush          (ID_Flush),
		.WB_Rd_addr        (WB_Rd_addr),
		.WB_Rd_data        (WB_Rd_data),
		.WB_RegFile_wr_en  (WB_RegFile_wr_en),
		.trap              (trap),
		.ID_PC             (ID_PC),
		.ID_ALU_source_sel (ID_ALU_source_sel),
		.ID_ALU_op         (ID_ALU_op),
		.ID_Branch_op      (ID_Branch_op),
		.ID_Branch_flag    (ID_Branch_flag),
		.ID_Mem_wr_en      (ID_Mem_wr_en),
		.ID_RegFile_wr_en  (ID_RegFile_wr_en),
		.ID_MemToReg       (ID_MemToReg),
		.ID_Jump           (ID_Jump),
		.ID_Mem_op         (ID_Mem_op),
		.ID_PC_dest        (ID_PC_dest),
		.ID_Immediate_1    (ID_Immediate_1),
		.ID_Immediate_2    (ID_Immediate_2),
		.ID_Rs1_data       (ID_Rs1_data),
		.ID_Rs2_data       (ID_Rs2_data),
		.ID_Rd_addr        (ID_Rd_addr),
		.ID_Rs1_addr       (ID_Rs1_addr),
		.ID_Rs2_addr       (ID_Rs2_addr)
	);
    
    
    
    
    
endmodule