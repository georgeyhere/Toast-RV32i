`timescale 1ns / 1ps
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


module Branch_gen
    (
    input      [1:0]  Branch_op,
    
    input      [31:0] PC,
    input      [31:0] RegData,
    input      [31:0] Immediate,
    
    output reg [31:0] Branch_dest
    );
    
    // for conditional branch or JAL
    // -> PC destination = PC + Imm
    
    // for JALR
    // -> PC destination = rs1 + Imm
    
    
    
    always_comb begin
        case(Branch_op)
            default:      Branch_dest = 32'bx;
            `PC_RELATIVE: Branch_dest = PC + Immediate;
            `REG_OFFSET:  Branch_dest = RegData + Immediate;
        endcase
    end
    
endmodule
