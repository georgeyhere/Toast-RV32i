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

module RV32I_IF
    
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
   
    input  [31:0]                EX_PC_Branch_dest,
    input                        EX_PC_Branch,
    
    input  [31:0]                ID_PC_dest,
    input                        ID_Jump,
    
    input                        IF_Stall,
    input                        IF_Flush,
   
    output [IMEM_ADDR_WIDTH-1:0] IF_PC,
    output [REG_DATA_WIDTH-1:0]  IF_Instruction,
    
    output [4:0]                 IF_Rs1_addr,
    output [4:0]                 IF_Rs2_addr            
    );
    
    wire [REG_DATA_WIDTH-1:0]  Instruction;
    
    PC RV32I_PC (
    .Clk              (Clk),
    .Reset_n          (Reset_n),
    .PC_Stall         (IF_Stall),
    .ID_Jump          (ID_Jump),
    .ID_PC_dest       (ID_PC_dest),
    .EX_PC_Branch     (EX_PC_Branch),
    .EX_PC_Branch_dest(EX_PC_Branch_dest)
    );
    
    IMEM RV32I_IMEM (
    .IMEM_address  (IF_PC),
    .Instruction   (Instruction)
    );
    
    // if a branch/jump is taken, flush the current instruction
    assign IF_Instruction = (IF_Flush == 1'b1) ? 0:Instruction;
    assign IF_Rs1_addr = (IF_Flush == 1'b1) ? 0:IF_Instruction[19:15];
    assign IF_Rs2_addr = (IF_Flush == 1'b1) ? 0:IF_Instruction[24:20];
    
    
    
endmodule
