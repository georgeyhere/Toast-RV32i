`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 05:43:46 PM
// Design Name: 
// Module Name: IF_ID_top
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

module IF_ID_top

    (
    input            Clk_100MHz,
    input            Reset_n,
    
    input [31:0]     MEM_PC_branch_dest,
    input            MEM_PC_source_sel,
    input            ID_PC_stall,
    
    output [31:0]    ID_PC,
    output           ID_Rd_wr_en,
    output           ID_ALU_source_sel,
    output [3:0]     ID_ALU_op,
    output [31:0]    ID_Immediate, 
    output           ID_Branch_en,
    output [4:0]     ID_Rd_address,
    output [31:0]    ID_Rs1_data,
    output [31:0]    ID_Rs2_data
    );
    
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
    
    wire [31:0] WB_Rd_address;
    wire [31:0] WB_Rd_wr_data;
    wire        WB_wr_en;
    
    
    RV32I_IF IF_inst(
    .Clk_100MHz(Clk_100MHz),
    .Reset_n(Reset_n),
    .MEM_PC_branch_dest(MEM_PC_branch_dest),
    .MEM_PC_source_sel(MEM_PC_source_sel),
    .ID_PC_stall(ID_PC_stall),
    .IF_PC(IF_PC),
    .IF_Instruction(IF_Instruction)
    );
    
    RV32I_ID ID_inst(
    .Clk_100MHz(Clk_100MHz),
    .Reset_n(Reset_n),
    .IF_PC(IF_PC),
    .IF_Instruction(IF_Instruction),
    .WB_Rd_address(32'd32),
    .WB_Rd_wr_data(32'd420),
    .WB_wr_en(1'b0),
    .ID_PC(ID_PC),
    .ID_Rd_wr_en(ID_Rd_wr_en),
    .ID_ALU_source_sel(ID_ALU_source_sel),
    .ID_ALU_op(ID_ALU_op),
    .ID_Immediate(ID_Immediate),
    .ID_Branch_en(ID_Branch_en),
    .ID_Rd_address(ID_Rd_address),
    .ID_Rs1_data(ID_Rs1_data),
    .ID_Rs2_data(ID_Rs2_data)
    );
    
endmodule
