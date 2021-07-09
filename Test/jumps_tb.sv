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

    task CHECK_BEQ;
        $display("BEQ Checker Start.");
        for(int i=0; i<16; i++) begin
            @(posedge Clk) begin
                if(UUT.IF_inst.RV32I_PC.EX_PC_Branch == 1'b1) begin
                    if((UUT.IF_inst.IF_PC >= 28) && (regfile_rd1 == regfile_rd2)) begin
                        $display("Branch Taken, BEQ TEST PASS");
                        $display("Rd1: %0d ; Value1: %0d", DATA_Inst.rd1, regfile_rd1); 
                        $display("Rd2: %0d ; Value1: %0d", DATA_Inst.rd2, regfile_rd2); 
                        break;
                    end
                    else begin
                        $display("Branch Taken... TEST FAILED. PC = %0d", UUT.IF_inst.IF_PC);
                    end
                end
                else $display("Branch not yet taken."); 
            end
        end
    endtask 
    
    
    initial begin
        Reset_n = 0;
        pc = 0;
        checker_cycles = 0;
        DATA_Inst = new();
        if (!DATA_Inst.randomize())    // end simulation if it fails to randomize
            $finish;
        m = (DATA_Inst.imm << 20) >> 20; 
        k = ((DATA_Inst.imm - m) >> 12) << 12; 
        $display("m = %0b, k = %0b", m, k);
        
        // load random number into rd
        LOAD_MEM(encode_LUI(DATA_Inst.rd1, k));                    // @4
        LOAD_MEM(encode_ADDI(DATA_Inst.rd1, DATA_Inst.rd1, m));     // @8
        
        // load the same random number into rd+1               
        LOAD_MEM(encode_LUI(DATA_Inst.rd2, k));                    // @12
        LOAD_MEM(encode_ADDI(DATA_Inst.rd2, DATA_Inst.rd2, m));  // @16
         
        LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd1-1, 12));    // @20
        LOAD_MEM(encode_BNE(DATA_Inst.rd1, DATA_Inst.rd2,  12));    // @24
        LOAD_MEM(encode_BEQ(DATA_Inst.rd1, DATA_Inst.rd2,  12));    // @28
        
        #100;
        Reset_n = 1;
        
    end
    
endmodule
