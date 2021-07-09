`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2021 11:05:50 AM
// Design Name: 
// Module Name: jumps_tb
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
import   RV32I_definitions::*;
import   testbench_pkg::*;

module jumps_tb();
    
    
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
    
    reg [3:0] checker_cycles;
    reg [4:0] checker_rd1, checker_rd2;
    
    
    wire [31:0] regfile_rd1 = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd1]; 
    wire [31:0] regfile_rd2 = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd2]; 

    int unsigned m, k;
    int unsigned expected;

    int temp;

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
    get_branch_data  DATA_Inst;
    coverage  Cov_Inst = new();



    task LOAD_MEM;
        input [31:0] instruction;
        begin
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask // LOAD_MEM

    task CLEAR_MEM;
        begin
            for(int i=0; i<10; i++) begin
                UUT.IF_inst.RV32I_IMEM.Instruction_data[i*4] = 0;
            end
        end
    endtask // CLEAR_MEM

    task INIT_TEST;
        Reset_n = 0;
        pc = 0;
        checker_cycles = 0;
        DATA_Inst = new();
        CLEAR_MEM();

        if (!DATA_Inst.randomize())    // end simulation if it fails to randomize
            $finish;
    endtask

    task LOAD_LI;
        input [4:0] rd;
        input [31:0] imm;
        int unsigned m, k;
        m = (imm << 20) >> 20; 
        k = ((imm - m) >> 12) << 12;
        LOAD_MEM(encode_LUI(rd, k));                    
        LOAD_MEM(encode_ADDI(rd, rd, m));    
    endtask

    task TEST_BEQ;
        input bit direction;
        input bit filler;

        // INIT_TEST resets the DUT and pc
        INIT_TEST();

        // Load the same random number into rd1 and rd2
        LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
        LOAD_LI(DATA_Inst.rd2, DATA_Inst.imm);

        if(filler == 1) begin
            LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, 16));    // @20
            LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  16));     // @24
            $display("BEQ TEST @IMEM 28: Time = %0t", $time);
            if(direction == 1) begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  16));  // @28
                $display("Branching forwards. Expected PC = 28+16 = 44");
            end
            else begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  -16));    // @28
                $display("Branching backwards. Expected PC = 28-16 = 12");
            end
        end
        else begin
            $display("BEQ TEST @IMEM 20: Time = %0t", $time);
            if(direction == 1) begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  16));
                $display("Branching forwards. Expected PC = 20+16 = 36");
            end
            else begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  -16)); 
                $display("Branching backwards. Expected PC = 20-16 = 4");
            end
        end     
        
        // Execute and check the test
        // This iteration of the test checks if a branch is taken at a given
        // point in time; a flaw is that it does not check if operands are correct
        #100;
        Reset_n = 1;
        if(filler == 1) begin
            #175;
            if(UUT.IF_inst.EX_PC_Branch == 1) $display("TEST PASSED: BRANCH TAKEN!");
            else $display("TEST FAILED: BRANCH NOT TAKEN");
        end
        else begin
            #145;
            if(UUT.IF_inst.EX_PC_Branch == 1) $display("TEST PASSED: BRANCH TAKEN!");
            else $display("TEST FAILED: BRANCH NOT TAKEN");
        end
        Reset_n = 0;
    endtask // TEST_BEQ
    
    task TEST_BNE;
        input bit direction;
        input bit filler;

        // INIT_TEST resets the DUT and pc
        INIT_TEST();

        // Load the same random number into rd1 and rd2
        LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
        LOAD_LI(DATA_Inst.rd2, DATA_Inst.imm);

        if(filler == 1) begin
            LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, 16));    // @20
            LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  16));     // @24
            $display("BEQ TEST @IMEM 28: Time = %0t", $time);
            if(direction == 1) begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  16));  // @28
                $display("Branching forwards. Expected PC = 28+16 = 44");
            end
            else begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  -16));    // @28
                $display("Branching backwards. Expected PC = 28-16 = 12");
            end
        end
        else begin
            $display("BEQ TEST @IMEM 20: Time = %0t", $time);
            if(direction == 1) begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  16));
                $display("Branching forwards. Expected PC = 20+16 = 36");
            end
            else begin
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  -16)); 
                $display("Branching backwards. Expected PC = 20-16 = 4");
            end
        end     
        
        // Execute and check the test
        // This iteration of the test checks if a branch is taken at a given
        // point in time; a flaw is that it does not check if operands are correct
        #100;
        Reset_n = 1;
        if(filler == 1) begin
            #175;
            if(UUT.IF_inst.EX_PC_Branch == 1) $display("TEST PASSED: BRANCH TAKEN!");
            else $display("TEST FAILED: BRANCH NOT TAKEN");
        end
        else begin
            #145;
            if(UUT.IF_inst.EX_PC_Branch == 1) $display("TEST PASSED: BRANCH TAKEN!");
            else $display("TEST FAILED: BRANCH NOT TAKEN");
        end
        Reset_n = 0;
    endtask // TEST_BEQ


    initial begin
        TEST_BEQ(1, 1);
        TEST_BEQ(1, 0);

    end
    
endmodule
