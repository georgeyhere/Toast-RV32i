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

    int passed_cnt;
    int failed_cnt;

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

    task TEST_JAL;


    endtask // TASK_JAL


    task TEST_BRANCH;
        input bit    direction;
        input bit    filler;
        input [7:0]  test_id [11:0];

        bit          dice;
        bit   [4:0]  start_addr;
        bit   [31:0] branch_dest;

        int          direction_mp; // direction multiplier
        direction_mp = (direction == 1) ? 1 : -1;


        // INIT_TEST resets the DUT and pc
        INIT_TEST();

        // Load the same random number into rd1 and rd2
        case(test_id)

            "BEQ": begin 
                // load the same number
                LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                LOAD_LI(DATA_Inst.rd2, DATA_Inst.imm);
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));
                $display("BEQ TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.imm);
            end

            "BNE": begin
                // randomly load rd2 with a lower or greater number
                dice = $random;
                case(dice)
                    0: begin // load rd2 greater than rd1
                        LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                        LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_lt_s);
                        $display("BNE TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_lt_s);
                    end
                    1: begin // load rd2 less than rd1
                        LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                        LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_gt_s);
                        $display("BNE TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_gt_s);
                    end
                endcase
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));

            end

            "BLT": begin
                // load rd2 less than rd1
                LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_lt_s);  
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));  
                $display("BLT TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_lt_s);     
            end

            "BGE": begin
                // load rd2 greater than rd1
                LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_gt_s);
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BGE(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                $display("BGE TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_gt_s);   
            end

            "BLTU": begin
                // load rd2 less than rd1
                LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_lt_us);      
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BLTU(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));   
                $display("BLTU TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_lt_us);
            end

            "BGEU": begin
                // load rd2 greater than rd1
                LOAD_LI(DATA_Inst.rd1, DATA_Inst.imm);
                LOAD_LI(DATA_Inst.rd2, DATA_Inst.rd2_gt_us);
                if(filler) begin
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, direction_mp*16));    
                    LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));    
                end
                LOAD_MEM(encode_BGEU(DATA_Inst.rd1, DATA_Inst.rd2,  direction_mp*16));   
                $display("BGEU TEST BEGIN: rd1 = %0d, rd2 = %0d", DATA_Inst.imm, DATA_Inst.rd2_gt_us);
            end

        endcase
        
        
        // Execute and check the test
        // This iteration of the test checks if a branch is taken at a given
        // point in time; a flaw is that it does not check if operands are correct

        checker_rd1 = DATA_Inst.rd1;
        checker_rd2 = DATA_Inst.rd2;
        #100;
        Reset_n = 1;
        if(filler == 1) begin
            #180;
            if(UUT.IF_inst.EX_PC_Branch == 1) begin
                $display("TEST PASSED: BRANCH TAKEN!");
                passed_cnt++;
            end
            else begin
                $display("TEST FAILED: BRANCH NOT TAKEN || TIME: %0t", $time);
                failed_cnt++;
            end
        end
        else begin
            #150;
            if(UUT.IF_inst.EX_PC_Branch == 1) begin
                $display("TEST PASSED: BRANCH TAKEN!");
                passed_cnt++;
            end
            else begin
                $display("TEST FAILED: BRANCH NOT TAKEN || TIME: %0t", $time);
                failed_cnt++;
            end
        end
        $display("Rd1: %0d, %0d || Rd2: %0d, %0d", DATA_Inst.rd1, regfile_rd1, DATA_Inst.rd2, regfile_rd2);
        
        if(regfile_rd2 == regfile_rd1) $display("Rd1 == Rd2");
        else if(regfile_rd2 > regfile_rd1) $display("Rd1 < Rd2");
        else if(regfile_rd2 < regfile_rd1) $display("Rd1 > Rd2");
        $display("----------------------------------------------------------");
        Reset_n = 0;
    endtask // TEST_BRANCH
    
    


    initial begin
        $display("----------------------------------------------------------");

        passed_cnt = 0;
        failed_cnt = 0;
        repeat(10) begin
            TEST_BRANCH(1, 1, "BEQ");
            TEST_BRANCH(1, 1, "BNE");
            TEST_BRANCH(1, 1, "BLT");
            TEST_BRANCH(1, 1, "BGE");
            TEST_BRANCH(1, 1, "BLTU");
            TEST_BRANCH(1, 1, "BGEU");
        end

        $display("%0d Tests Ran, %0d Passed, %0d Failed", (passed_cnt+failed_cnt), passed_cnt, failed_cnt);
    end
    
endmodule
