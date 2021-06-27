`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2021 07:36:05 PM
// Design Name: 
// Module Name: EX_top
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


module RV32I_EX


    (
    input             Clk,
    input             Reset_n,
    
    input      [1:0]  ID_Branch_op,   // [1] indicates a branch/jump
    input             ID_Branch_flag, // indicates to branch on 'set' or 'not set'
    input             ID_Jump,        // indicates a jump
 
    input      [1:0]  ForwardA,
    input      [1:0]  ForwardB,
 
    input      [1:0]  ID_ALU_source_sel,
    input      [3:0]  ID_ALU_op,
 
    input      [31:0] ID_PC,
    input      [31:0] ID_Rs1_data,
    input      [31:0] ID_Rs2_data,
    input      [31:0] ID_Immediate_1,
    input      [31:0] ID_Immediate_2, // used for branch gen 
    
    output reg [31:0] EX_ALU_result,
    output reg [31:0] EX_PC_Branch_dest,
    output reg        EX_PC_source_sel // if asserted loads branch dest to PC
    );
    
    reg [31:0] ALU_op1, ALU_op2;
    wire [31:0] ALU_result;
    
    EX_Branch_gen Branch_gen_inst (
    .Reset_n     (Reset_n),
    .Branch_op   (ID_Branch_op),
    .PC          (ID_PC),
    .RegData     (ID_Rs1_data),
    .Immediate   (ID_Immediate_2),
    .Branch_dest (EX_PC_Branch_dest)
    );
    
    EX_ALU ALU_inst(
    .ALU_op     (ID_ALU_op),
    .ALU_op1    (ALU_op1),
    .ALU_op2    (ALU_op2),
    .ALU_result (ALU_result) 
    );
    
    
    
    wire branch_jump;
    assign branch_jump = ID_Jump | ID_Branch_op[1];
    
    // pipeline
    always_ff@(posedge Clk) begin
        EX_ALU_result <= ALU_result;
    end
    
    
    // ALU source input
    always_comb begin
        if(ID_Jump == 1) begin  // if JAL or JALR, perform PC+1
            ALU_op1 = ID_Immediate_1;
            ALU_op2 = 32'd1;
        end
        else begin
            case(ID_ALU_source_sel)
            
                default: begin
                    ALU_op1 = ID_Rs1_data;
                    ALU_op2 = ID_Rs2_data;
                end
                
                2'b01: begin
                    ALU_op1 = ID_Rs1_data;
                    ALU_op2 = ID_Immediate_2;
                end
                
                2'b10: begin
                    ALU_op1 = ID_Immediate_1;
                    ALU_op2 = ID_Rs2_data;
                end
                
                2'b11: begin
                    ALU_op1 = ID_Immediate_1;
                    ALU_op2 = ID_Immediate_2;
                end
            endcase
        end
    end
    
    
    // branch control
    always_comb begin
        if(branch_jump == 1'b1) begin
            if(ID_Jump == 1'b1) begin
                EX_PC_source_sel = 1;
            end
            else begin
                if(ID_Branch_flag == 1'b0) begin
                    EX_PC_source_sel = (ALU_result == 1) ? 1:0;            
                end
                else begin
                    EX_PC_source_sel = (ALU_result == 1) ? 0:1;  
                end
            end // end if(ID_Jump)
        end
        else begin
            EX_PC_source_sel = 0;
        end // end if(branch_jump)
    end // end always_ff
    
endmodule
