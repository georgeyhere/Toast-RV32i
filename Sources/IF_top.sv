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
          parameter IMEM_ADDR_WIDTH = 32,
          parameter IMEM_DATA_DEPTH = 1024)
    `endif

    (
    input                        Clk,
    input                        Reset_n,
   
    input  [IMEM_ADDR_WIDTH-1:0] EX_PC_Branch_dest,
    input                        EX_PC_Source_sel,
    input                        IF_Stall,
   
    output [IMEM_ADDR_WIDTH-1:0] IF_PC,
    output [REG_DATA_WIDTH-1:0]  IF_Instruction            
    );
    
    PC RV32I_PC (
    .Clk           (Clk),
    .Reset_n       (Reset_n),
    .PC_Branch     (EX_PC_Branch_dest),
    .PC_Source_sel (EX_PC_Source_sel),
    .PC_Stall      (IF_Stall),
    .PC_Out        (IF_PC)
    );
    
    IMEM RV32I_IMEM (
    .IMEM_address  (IF_PC),
    .Instruction   (IF_Instruction)
    );
    
endmodule
