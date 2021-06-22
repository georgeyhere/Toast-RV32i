`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 02:18:08 PM
// Design Name: 
// Module Name: ALU_tb
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

module ALU_tb();

    reg  [3:0]   ALU_op;
    reg  [31:0]  ALU_op1;
    reg  [31:0]  ALU_op2;
    
    wire [31:0] ALU_result;
    
    reg  [31:0]  Expected;
    
    EX_ALU DUT (
    .ALU_op    (ALU_op),
    .ALU_op1   (ALU_op1),
    .ALU_op2   (ALU_op2),
    .ALU_result(ALU_result)
    );
    
    task test_ADD;
        input [31:0] op1;
        input [31:0] op2;
        begin
            Expected = op1 + op2;
            $display("ADD Test: Op1 = %0d , Op2 = %0d || EXPECTED RESULT: %0d" , op1, op2, Expected);
            ALU_op1 = op1;
            ALU_op2 = op2;
            ALU_op  = `ALU_ADD;
            if(ALU_result == Expected) $display("ADD Test: ACTUAL RESULT = %0d || PASS", ALU_result);
            else $display("ADD Test: ACTUAL RESULT = &0d || FAIL", ALU_result);
        end
    endtask
    
   
    
endmodule
