`timescale 1ns/1ps

`include "C:/Users/George/Desktop/Work/RISCV/Sources/RV32I_definitions.sv"
import   RV32I_definitions::*;

module lui_OOP_tb();

	reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst;
    

    reg [31:0] pc;

    
    reg [4:0] checker_rd;
    reg [1:0] checker_result;
    reg [3:0] checker_cycles;
    
    wire [31:0] regfile_rd = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd]; 

    
    always#(10) Clk=~Clk;
    
//----------------------------------------------------------------------------
//                               Classes:
//----------------------------------------------------------------------------  

    class instn_LUI; 
    	// generates a LUI instruction w/ random non-zero destination and random immediate.
    	randc bit [4:0]  rd;
    	randc bit [19:0] imm;
        bit       [31:0] expected;
        
    	constraint rd_range {rd > 0;    
    						 rd <= 31;} 

    	constraint imm_range {imm <= (2**20 - 1);}
    	
    endclass


//----------------------------------------------------------------------------
//                                Tasks:
//----------------------------------------------------------------------------  
	

    function encode_LUI;
        input  [4:0]  rd;
        input  [19:0] imm;
        begin
            int unsigned instruction;
            instruction = {imm[19:0], rd, `OPCODE_LUI};
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4;
        end
    endfunction

//----------------------------------------------------------------------------
//                            Instantiation:
//----------------------------------------------------------------------------  
    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );

    
//----------------------------------------------------------------------------
//                                Testbench:
//----------------------------------------------------------------------------  

    instn_LUI test_Inst;               // create class object instn_LUI

    initial begin
        Reset_n = 1'b0;
    	pc = 0;                        // set pc = 0

    	test_Inst = new();             // create new test_Inst
    	if (!test_Inst.randomize())    // end simulation if it fails to randomize
    		$finish;
        test_Inst.expected = {test_Inst.imm , {12{1'b0}}};
        
    	checker_rd = test_Inst.rd;     // set the checker rd address
    	encode_LUI(test_Inst.rd, test_Inst.imm);
    	$display("Test started.");

    	#100;

        
    	@(posedge Clk) Reset_n = 1'b1;
    	
    	checker_cycles = 0;
    	$display("Expected-> Rd: %0h ; Value: %32b", test_Inst.rd, test_Inst.expected);
    	for(int j=0; j<6; j++) begin
    	   @(posedge Clk) begin
    				if(regfile_rd == test_Inst.expected ) begin
    				    checker_cycles = checker_cycles;
    					$display("Current    Rd: %0h ; Value: %32b", checker_rd, regfile_rd);
    					$display("Test Passed, Cycles: %0d", checker_cycles);
    					break;
    				end
    				else begin
    				    checker_cycles = checker_cycles+1;
    					$display("Current    Rd: %0h ; Value: %32b", checker_rd, regfile_rd);
    					if(j==5)
    					   $display("Test Timed Out. ; Cycles Elapsed: %0d", checker_cycles);
    					else
    					   $display("Test Continuing ; Cycles Elapsed: %0d", checker_cycles);
    				end
    	   end
    	end
    	
    	/*
    	if(checker_result == 2'b01) 
    		$finish;
    	else if(checker_result == 2'b10)
    		$display("made it here!");
    	*/

    end

endmodule // lui_tb