`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2021 07:49:30 PM
// Design Name: 
// Module Name: EX_Branch_gen
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

module toast_branchgen
    `include "toast_definitions.vh"
    (
    output reg  [31:0] branch_dest_o,

    input  wire [1:0]  branch_op_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] regdata_i,
    input  wire [31:0] imm_i
    );
    
    /*
     for conditional branch or JAL
     -> PC destination = PC + Imm
    
     for JALR
     -> PC destination = rs1 + Imm
    */
    
    always@* begin
        branch_dest_o = 0;
        case(branch_op_i)
            `PC_RELATIVE: branch_dest_o = pc_i      + $signed(imm_i);
            `REG_OFFSET:  branch_dest_o = regdata_i + $signed(imm_i);
        endcase
    end
    
endmodule
