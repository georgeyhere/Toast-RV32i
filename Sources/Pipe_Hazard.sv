`timescale 1ns / 1ps

import RV32I_definitions ::*;

module Hazard_detection

	`ifdef CUSTOM_DEFINE
		#(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH,
		  parameter REGFILE_ADDR_WIDTH = `REGFILE_ADDR_WIDTH
		  )
	`else 
		#(parameter REG_DATA_WIDTH  = 32,
		  parameter REGFILE_ADDR_WIDTH  = 5
		 )
    `endif

	(
	output                         Stall,          // pipeline stall, used for Data hazard
 	output reg                     IF_ID_Flush,    // flush IF and ID in case of branch or jump taken
 	output reg                     EX_Flush,       // flush EX if branch taken
	
	input [31:0]                   IF_Instruction, // used to check for Data hazard

	input						   ID_Mem_rd_en,
	input [REGFILE_ADDR_WIDTH-1:0] ID_Rd_addr, 
    
    input                          EX_PC_Branch,
    input                          ID_Jump

	);
    
    /*
    DATA LOAD HAZARD DETECTION
    
    Checks for the following conditions:
    1) is a load instruction present in ID pipeline reg?
    2a) does the next instruction (in IF pipeline reg) read any registers?
    2b) are any of the registers to be read dependent on the load?
    
    if all true, stall the pipeline.
    
    IF_Rs1_addr    = Instruction[19:15];
    IF_Rs2_addr    = Instruction[24:20];
    */
    
   
    assign Stall = ( (ID_Mem_rd_en == 1) && (((IF_Instruction == `OPCODE_OP) || (IF_Instruction == `OPCODE_BRANCH) || (IF_Instruction == `OPCODE_STORE)) &&
                      ((ID_Rd_addr == IF_Instruction[19:15]) || (ID_Rd_addr == IF_Instruction[24:20])) ) ||
                     (((IF_Instruction == `OPCODE_OP_IMM) || (IF_Instruction == `OPCODE_LOAD)) &&
                       (ID_Rd_addr == IF_Instruction[19:15]))) ? 1:0;
    
   
   
                    
    /*
    CONTROL HAZARD DETECTION FOR BRANCH:
    
    -> if a branch or jump is taken, the pipeline needs to be flushed.
    -> it is unknown whether a branch or jump is taken until the end of EX stage.
    -> if a branch is taken, IF, ID, and EX need to be flushed. 
    -> if a jump is taken, only IF and ID need to be flushed.       
    Checks for the following conditions:
    
    
    */
    always_comb begin
        if((EX_PC_Branch == 1) || (ID_Jump == 1)) IF_ID_Flush = 1;
        else                                      IF_ID_Flush = 0;
    end
    
    always_comb begin
        if(EX_PC_Branch == 1) EX_Flush = 1;
        else                  EX_Flush = 0;
    end
    
    //assign IF_ID_Flush = ((EX_PC_Branch == 1) || (ID_Jump == 1)) ? 1:0;
    //assign EX_Flush    = (EX_PC_Branch == 1) ? 1:0;
    
endmodule