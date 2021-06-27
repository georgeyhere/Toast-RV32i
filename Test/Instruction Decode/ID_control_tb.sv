`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2021 12:15:44 PM
// Design Name: 
// Module Name: ID_control_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// - *basic* tests for ID_control

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import RV32I_encoding::*;
import RV32I_definitions::*;

module ID_control_tb();
    
    reg        Clk = 0;
    reg        Reset_n = 0;
    
    reg [31:0] IF_Instruction;
    reg        Stall;
    
    reg [4:0]  Rd_address, Rs1_address, Rs2_address;
    reg [31:0] Immediate_1, Immediate_2;
    
    reg [1:0]  ALU_source_sel;
    reg [3:0]  ALU_op;
    reg        Branch_en, Mem_wr_en, Mem_rd_en, RegFile_wr_en, MemToReg;
///////////////////////////////////////////////////////////////////////////    
    ID_control UUT(
    .Clk            (Clk),
    .Reset_n        (Reset_n),
    .IF_Instruction (IF_Instruction),
    .IF_PC          (32'd69),
    .Stall          (Stall),
    
    .Rd_address     (Rd_address),
    .Rs1_address    (Rs1_address),
    .Rs2_address    (Rs2_address),
    
    .Immediate_1    (Immediate_1),
    .Immediate_2    (Immediate_2),
    
    .ALU_source_sel (ALU_source_sel),
    .ALU_op         (ALU_op),
    .Branch_en      (Branch_en),
    .Mem_wr_en      (Mem_wr_en),
    .Mem_rd_en      (Mem_rd_en),
    .RegFile_wr_en  (RegFile_wr_en),
    .MemToReg       (MemToReg)
    );
    
    parameter CLK_PERIOD = 20;
    always#(CLK_PERIOD/2) Clk=~Clk;
    
////////////////////////////////////////////////////////////////////////////
  
    task ADD_test(input [4:0] rd, rs1, rs2);
        begin 
            $display("Testing ADD.");
            @(posedge Clk) 
                IF_Instruction = ADD_gen (rd, rs1, rs2);
            @(posedge Clk);
            @(negedge Clk) begin
                if((Rd_address == rd) & (Rs1_address == rs1) & (Rs2_address == rs2) &
                   (ALU_source_sel == 2'b0) & (ALU_op == `ALU_ADD) & 
                   (Branch_en == 0) &
                   (Mem_wr_en == 0) & 
                   (Mem_rd_en == 0) & 
                   (RegFile_wr_en == 1) & 
                   (MemToReg == 0))
                    $display("Test Pass!!");
                else
                    $display("ADD FAILED :(");
            end    
        end       
    endtask

    task SRAI_test(input [4:0] rd, rs1, shamt);
        begin
            $display("Testing SRAI.");
            @(posedge Clk) begin
                IF_Instruction = SRAI_gen(rd, rs1, shamt);
            end
            @(posedge Clk);
            @(negedge Clk) begin
                if((Rd_address == rd) & (Rs1_address == rs1)  &
                   (ALU_source_sel == 2'b01) & (ALU_op == `ALU_SRA) & 
                   (Immediate_2 ==  {{20{IF_Instruction[31]}}, IF_Instruction[31:20]}) &
                   (Branch_en == 0) &
                   (Mem_wr_en == 0) & 
                   (Mem_rd_en == 0) & 
                   (RegFile_wr_en == 1) & 
                   (MemToReg == 0))
                    $display("Test Pass!!");
                else
                    $display("SRAI FAILED :("); 
            end
        end
    endtask
    
    task SRLI_test(input [4:0] rd, rs1, shamt);
        begin
            $display("Testing SRLI.");
            //@(posedge Clk) begin
                IF_Instruction = SRLI_gen(rd, rs1, shamt);
            //end
            @(posedge Clk);
            @(negedge Clk) begin
                if((Rd_address == rd) & (Rs1_address == rs1)  &
                   (ALU_source_sel == 2'b01) & (ALU_op == `ALU_SRL) & 
                   (Immediate_2 ==  {{20{IF_Instruction[31]}}, IF_Instruction[31:20]}) &
                   (Branch_en == 0) &
                   (Mem_wr_en == 0) & 
                   (Mem_rd_en == 0) & 
                   (RegFile_wr_en == 1) & 
                   (MemToReg == 0))
                    $display("Test Pass!!");
                else
                    $display("SRLI FAILED :("); 
            end
        end
    endtask
    
    initial begin
        $display("**********************************************");
        $display("*************** TEST BEGIN *******************");
        $display("**********************************************");
        Reset_n = 0;
        IF_Instruction = 0;
        Stall = 0;
        #100;
        Reset_n = 1;
        #10;
        ADD_test(30, 1, 2);
        SRAI_test(9, 16, 3);
        @(posedge Clk) Stall = 1;
        @(posedge Clk) Stall = 0;
        SRLI_test(30, 8, 8);
        
        ADD_test(4, 9, 10);
        ADD_test(11, 12, 13);
        
        
        $display("**********************************************");
        $display("************** TEST COMPLETE *****************");
        $display("**********************************************");
    end

endmodule
