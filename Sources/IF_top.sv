`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2021 01:51:21 PM
// Design Name: 
// Module Name: RV32I_IF
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

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

module IF_top
    
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH,  
          parameter IMEM_DATA_DEPTH = `IMEM_DATA_DEPTH)
    `else
        #(parameter REG_DATA_WIDTH = 32,
          parameter IMEM_ADDR_WIDTH = 10,
          parameter IMEM_DATA_DEPTH = 1024)
    `endif

    (
    input                        Clk,
    input                        Reset_n,
    
    input                        instr_valid,
    input      [31:0]            instr,
   
    output     [31:0]            IF_PC,
    output reg [31:0]            IF_Instruction     
    );
    
    wire [31:0]  Instruction;
    
    PC RV32I_PC (
    .Clk              (Clk),
    .Reset_n          (Reset_n),
    .PC_Stall         (IF_Stall),
    .ID_Jump          (ID_Jump),
    .ID_PC_dest       (ID_PC_dest),
    .EX_PC_Branch     (EX_PC_Branch),
    .EX_PC_Branch_dest(EX_PC_Branch_dest),
    .PC_Out           (IF_PC)
    );
    
    always@(posedge Clk)
    
    
    
endmodule
