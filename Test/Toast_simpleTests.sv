

`timescale 1ns / 1ps


import RV32I_definitions::*;
import Toast_IMEM_loads::*;

package Toast_simpleTests;





//-------------------------------------------------------------
// Prerequisite tests - LUI, ADDI 
/*
- these tests must be passed first 
- LUI and ADDI are the only two instructions needed to replicate
  pseudo-instruction LI, which will make it much easier to run 
  other tests.
*/
//-------------------------------------------------------------

	task test_LUI;
		input [4:0]  rd;
		input [19:0] imm;
		begin
			encode_LUI(rd, imm);
		end
	endtask

	task execute_LI;
        input [4:0]  rd;
        input [31:0] imm;
        begin
            int m = (imm << 20) >> 20;       // sign extend low 12 bits
            int k = ((imm - m) >> 12) << 12; // the 20 high bits
            $display("Pseudo-instruction LI beginning.");
            $display("Imm = %32b ; k = %32b ; m = %32b", imm, m, k);
            encode_LUI(rd, k);	    // load upper 20 bits w/ LUI
            encode_ADDI(rd, rd, m); // add in lower 12 bits w/ ADDI
            // TODO- check result
        end
    endtask // execute_LI


//-------------------------------------------------------------
// Arithmetic tests
//-------------------------------------------------------------
	
	




endpackage // Toast_simpleTests