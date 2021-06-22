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

module RV32I_ID
    
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
    input             Clk_100MHz,
    input             Reset_n,
    
    input  [31:0]     IF_PC,
    input  [31:0]     IF_Instruction,
    input  [31:0]     WB_Rd_address,
    input  [31:0]     WB_Rd_wr_data,
    input             WB_wr_en,
    
    output reg [REG_DATA_WIDTH-1:0]      ID_PC,
    output                               ID_Rd_wr_en,
    output                               ID_ALU_source_sel,
    output     [ALU_OP_WIDTH-1 :0]       ID_ALU_op,
    output     [REG_DATA_WIDTH-1 :0]     ID_Immediate,
    output                               ID_Branch_en,
    output     [REGFILE_ADDR_WIDTH-1 :0] ID_Rd_address,
    output     [REG_DATA_WIDTH-1 :0]     ID_Rs1_data,
    output     [REG_DATA_WIDTH-1 :0]     ID_Rs2_data
    );
    
    wire [REGFILE_ADDR_WIDTH-1:0] Rs1_address;
    wire [REGFILE_ADDR_WIDTH-1:0] Rs2_address;
    
    ID_control RV32I_CONTROL(
    .IF_Instruction (IF_Instruction),
    .Rd_wr_en       (ID_Rd_wr_en),
    .ALU_source_sel (ID_ALU_source_sel),
    .ALU_op         (ID_ALU_op),
    .Immediate      (ID_Immediate),
    .Branch_en      (ID_Branch_en),
    .Rd_address     (ID_Rd_address),
    .Rs1_address    (Rs1_address), // to regfile
    .Rs2_address    (Rs2_address)  // to regfile
    );
    
    ID_regfile RV32I_REGFILE(
    .Clk_100MHz  (Clk_100MHz),
    .Reset_n     (Reset_n),
    .Rs1_address (Rs1_address), // from control
    .Rs2_address (Rs2_address), // from control
    .Rd_address  (WB_Rd_address),
    .Rd_wr_data  (WB_Rd_wr_data),
    .Rd_wr_en    (WB_wr_en),
    .Rs1_data    (ID_Rs1_data),
    .Rs2_data    (ID_Rs2_data)
    );
    
    initial ID_PC = 32'b0;
    
    always@(posedge Clk_100MHz) begin // propagate PC on each cycle
        if(Reset_n == 1'b0) 
            ID_PC = 32'b0;
        else
            ID_PC <= IF_PC;
    end
    
    
endmodule
