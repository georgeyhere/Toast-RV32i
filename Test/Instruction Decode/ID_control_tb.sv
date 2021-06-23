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
    
    reg [31:0] IF_Instruction;
    reg        Pipe_stall;
    
    reg [63:0] testVector_Imm;
    reg [5:0]  testVector_ALU;
    reg [4:0]  testVector_Pipe_cntrl;
    reg [14:0] testVector_Regfile;
    
///////////////////////////////////////////////////////////////////////////    
    ID_control UUT(
    .IF_Instruction (IF_Instruction),
    .IF_PC          (32'd69),
    .Pipe_stall     (Pipe_stall),
    
    .Immediate_1    (testVector_Imm[63:32]),
    .Immediate_2    (testVector_Imm[31:0]),
    
    .ALU_source_sel (testVector_ALU[5:4]),
    .ALU_op         (testVector_ALU[3:0]),
    
    .Branch_en      (testVector_Pipe_cntrl[4]),
    .Mem_wr_en      (testVector_Pipe_cntrl[3]),
    .Mem_rd_en      (testVector_Pipe_cntrl[2]),
    .RegFile_wr_en  (testVector_Pipe_cntrl[1]),
    .MemToReg       (testVector_Pipe_cntrl[0]),
    
    .Rd_address     (testVector_Regfile[14:10]),
    .Rs1_address    (testVector_Regfile[9:5]),
    .Rs2_address    (testVector_Regfile[4:0])
    );
////////////////////////////////////////////////////////////////////////////
  
    task ADD_test(input [4:0] rd, rs1, rs2);
        begin 
            $display("Testing ADD.");
            #1;
            IF_Instruction = ADD_gen (rd, rs1, rs2);
            #1;
            if((testVector_ALU[5:4]   == 2'b0) & 
               (testVector_ALU[3:0]   == `ALU_ADD) & 
               (testVector_Pipe_cntrl == 5'b00010) & 
               (testVector_Regfile    == {rd, rs1, rs2}) 
              )
                $display("ADD Test Passed.");
            else
                $display("ADD Test Failed!!!!!!!!");
        end
    endtask 
    task SUB_test(input [4:0] rd, rs1, rs2);
        begin 
            #1;
            $display("Testing SUB.");
            IF_Instruction = SUB_gen (rd, rs1, rs2);
            #1;
            if((testVector_ALU[5:4]   == 2'b0) & 
               (testVector_ALU[3:0]   == `ALU_SUB) & 
               (testVector_Pipe_cntrl == 5'b00010) & 
               (testVector_Regfile    == {rd, rs1, rs2}) 
              )
                $display("SUB Test Passed.");
            else
                $display("SUB Test Failed!!!!!!!!");
        end
    endtask
    task SLL_test(input [4:0] rd, rs1, rs2);
        begin 
            #1;
            $display("Testing SLL.");
            IF_Instruction = SLL_gen (rd, rs1, rs2);
            #1;
            if((testVector_ALU[5:4]   == 2'b0) & 
               (testVector_ALU[3:0]   == `ALU_SLL) & 
               (testVector_Pipe_cntrl == 5'b00010) & 
               (testVector_Regfile    == {rd, rs1, rs2}) 
              )
                $display("SLL Test Passed.");
            else
                $display("SLL Test Failed!!!!!!!!");
        end
    endtask 
    task SLLI_test(input [4:0] rd, rs1, rs2);
        begin 
            #1;
            $display("Testing SLLI.");
            IF_Instruction = SLLI_gen (rd, rs1, rs2);
            #1;
            if((testVector_ALU[5:4]   == 2'b01) & 
               (testVector_ALU[3:0]   == `ALU_SLL) & 
               (testVector_Pipe_cntrl == 5'b00010) & 
               (testVector_Regfile    == {rd, rs1, rs2}) &
               (testVector_Imm[31:0]  == { {20{1'b0}}, IF_Instruction[31:20] })
              )
                $display("SLLI Test Passed.");
            else
                $display("SLLI Test Failed!!!!!!!!");
        end
    endtask 



    initial begin
        $display("**********************************************");
        $display("*************** TEST BEGIN *******************");
        $display("**********************************************");
        IF_Instruction = 0;
        Pipe_stall = 0;
        #100;
       
        ADD_test(30, 1, 2);
        #10;
        SUB_test(19, 5, 6);
        #10;
        SLL_test(15, 19, 30);
        #10;
        SLLI_test(2, 22, 18);
        
        
        $display("**********************************************");
        $display("************** TEST COMPLETE *****************");
        $display("**********************************************");
    end

endmodule
