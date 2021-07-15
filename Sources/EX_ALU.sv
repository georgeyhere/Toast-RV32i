`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 01:21:19 PM
// Design Name: 
// Module Name: EX_alu
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

module EX_ALU

    (
//*************************************************
    input      [3:0]      ALU_op,    // controls ALU operation for current instrn
    input      [31:0]     ALU_op1,   // operand 1
    input      [31:0]     ALU_op2,   // operand 2
    
//*************************************************
    output reg [31:0]     ALU_result 

//*************************************************
    );

    
    wire [4:0] shift_i;            // internal shift amount
    assign shift_i = ALU_op2[4:0]; // shifts are based on lower five bits of op2
    
    always_comb begin
        case(ALU_op)
            // arithmetic
            `ALU_ADD:  ALU_result = ALU_op1 + ALU_op2;
            `ALU_SUB:  ALU_result = ALU_op1 - ALU_op2;
            `ALU_AND:  ALU_result = ALU_op1 & ALU_op2;
            `ALU_OR:   ALU_result = ALU_op1 | ALU_op2;
            `ALU_XOR:  ALU_result = ALU_op1 ^ ALU_op2;
            
            //shifts
            `ALU_SLL:  ALU_result = ALU_op1 << shift_i; // logical shift left, shifts in 0s
            `ALU_SRL:  ALU_result = ALU_op1 >> shift_i; // logical shift right, shifts in 0s
            `ALU_SRA:  ALU_result = $signed(ALU_op1) >>> shift_i; // arithmetic shift right, shifts in 1s
            
            // test
            `ALU_SEQ:  ALU_result = (ALU_op1 == ALU_op2) ? 1:0; // set if op1 == op2 
            `ALU_SLT:  ALU_result = ($signed(ALU_op1) < $signed(ALU_op2)) ? 1:0; // set if op1 less than op2, signed
            `ALU_SLTU: ALU_result = (ALU_op1 < ALU_op2) ? 1:0; // set if op1 less than op2, unsigned
       
            default: ALU_result = 0;
        endcase
    end
    
    
    
endmodule
