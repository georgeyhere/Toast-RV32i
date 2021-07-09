`timescale 1ns/1ps

//`include "C:/Users/George/Desktop/Work/RISCV/Sources/RV32I_definitions.sv"

import   RV32I_definitions::*;
import   testbench_pkg::*;

module lui_OOP_tb();

    //`include "C:/Users/George/Desktop/Work/RISCV/Test/testbench.sv"

    reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst; 
    
    bit [31:0] instruction;
    bit [31:0] instruction1;

    reg [31:0] pc;
    
    reg [4:0] checker_rd;
    reg [1:0] checker_result;
    reg [3:0] checker_cycles;
    reg       checker_pass = 0;

    wire [31:0] regfile_rd = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd]; 

    int unsigned m, k;
    int unsigned expected;


    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;     
//----------------------------------------------------------------------------
//                                Tasks:
//----------------------------------------------------------------------------  

    instn_LUI LUI_Inst;           // create class object instn_LUI
    instn_LI   LI_Inst;
    coverage  Cov_Inst = new();



    task LOAD_MEM;
        input [31:0] instruction;
        begin
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask // LOAD_MEM

    task CHECK;
        input [4:0]  rd_addr;
        input [31:0] expected;

        begin
            checker_pass = 0;
            Reset_n = 1'b0;
            #100;
            @(posedge Clk) Reset_n = 1'b1;
            checker_cycles = 0;
            $display("Expected-> Rd: %0h ; Value: %32b", rd_addr, expected);
            for(int j=0; j<10; j++) begin
                @(posedge Clk) begin
                    if(regfile_rd == expected ) begin
                        checker_pass = 1;
                        checker_cycles = checker_cycles;
                        $display("Current    Rd: %0h ; Value: %32b", checker_rd, regfile_rd);
                        $display("Test Passed, Cycles: %0d", checker_cycles);
                        break;
                    end
                    else begin
                        checker_cycles = checker_cycles+1;
                        if(j==9) begin
                           $display("Current    Rd: %0h ; Value: %32b", checker_rd, regfile_rd);
                           $display("TEST FAILED. ; Cycles Elapsed: %0d", checker_cycles);
                        end
                        //else $display("Test Continuing ; Cycles Elapsed: %0d", checker_cycles);    
                    end
                end
            end
        end
    endtask
 
    task TEST_LUI;
        pc = 0;
        LUI_Inst = new();
        if (!LUI_Inst.randomize())    // end simulation if it fails to randomize
            $finish;
        checker_rd = LUI_Inst.rd;
        instruction = (encode_LUI(LUI_Inst.rd, {LUI_Inst.imm[19:0],{12{1'b0}}}));
        LOAD_MEM(instruction);
        $display("Testing LUI...");
        $display("Intruction: %32b", instruction);
        CHECK(LUI_Inst.rd, {LUI_Inst.imm, {12{1'b0}}});
    endtask // task

    task TEST_LI;
        pc = 0;
        LI_Inst = new();
        if (!LI_Inst.randomize())    // end simulation if it fails to randomize
            $finish;
        m = (LI_Inst.imm << 20) >> 20; 
        k = ((LI_Inst.imm - m) >> 12) << 12;
        checker_rd   = LI_Inst.rd;
        instruction  = encode_LUI(LI_Inst.rd, k);
        instruction1 = encode_ADDI(LI_Inst.rd, LI_Inst.rd, m);
        LOAD_MEM(instruction);
        LOAD_MEM(instruction1);
        $display("LI test start.");
        $display("LI %0d, %32b", LI_Inst.rd, LI_Inst.imm);
        $display("Instruction 1: LUI  0x%0d,        %32b", LI_Inst.rd, k);
        $display("Instruction 2: ADDI 0x%0d, 0x%0d, %32b", LI_Inst.rd, LI_Inst.rd, m);
        CHECK(LI_Inst.rd, LI_Inst.imm);
    endtask

    covergroup CovGrp@(posedge checker_pass);
        coverpoint instruction[6:0] 
        {
            bins OPCODE_OP     = {`OPCODE_OP};
            bins OPCODE_OP_IMM = {`OPCODE_OP_IMM};
            bins OPCODE_BRANCH = {`OPCODE_BRANCH};
            bins OPCODE_LUI    = {`OPCODE_LUI};
            bins OPCODE_AUIPC  = {`OPCODE_AUIPC};
            bins OPCODE_JAL    = {`OPCODE_JAL};
            bins OPCODE_JALR   = {`OPCODE_JALR};
            bins OPCODE_LOAD   = {`OPCODE_LOAD};
            bins OPCODE_STORE  = {`OPCODE_STORE};
            bins TRAP          = default;
        }
    endgroup  
    
    
    
//----------------------------------------------------------------------------
//                                Testbench:
//----------------------------------------------------------------------------  
    CovGrp CG_Inst = new();
    
    initial begin
        #100;
        
        TEST_LI;
        
        
        $display("OPCODES Covered = %0.2f %%", CG_Inst.get_coverage());
        $finish;
    end

endmodule // lui_tb