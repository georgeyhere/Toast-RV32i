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
    output reg                     Stall,
	
 	output reg                     IF_ID_Flush,    // flush IF and ID in case of branch or jump taken
 	output reg                     EX_Flush,       // flush EX if branch taken
	
    input                          Clk,
    input                          Reset_n,

	input [31:0]                   IF_Instruction, // used to check for Data hazard

	input						               ID_Mem_rd_en,
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
    
    wire [6:0] opcode = IF_Instruction[6:0];

    always_comb begin
        Stall = 0;

        if(ID_Mem_rd_en == 1) begin
            if( (opcode == `OPCODE_OP) ||       // register-register opcodes
                (opcode == `OPCODE_BRANCH) ||
                (opcode == `OPCODE_STORE) ) 
            begin
                if( (ID_Rd_addr == IF_Instruction[19:15]) || (ID_Rd_addr == IF_Instruction[24:20]) ) 
                     Stall = 1;
                else 
                     Stall = 0;
            end
    
            else if( (opcode == `OPCODE_OP_IMM) ||
                     (opcode == `OPCODE_LOAD) ) 
            begin
                if(ID_Rd_addr == IF_Instruction[19:15]) 
                    Stall = 1;
                else 
                    Stall = 0;
            end
            else Stall = 0;
        end
        else Stall = 0;
    end

   /*
    assign Stall = (  (IF_Instruction != 32'h00000013) &&  // 32'h13 is a NOP
                      (ID_Mem_rd_en == 1) && 
                      (((IF_Instruction[6:0] == `OPCODE_OP) || (IF_Instruction[6:0] == `OPCODE_BRANCH) || (IF_Instruction[6:0] == `OPCODE_STORE)) &&
                      ((ID_Rd_addr == IF_Instruction[19:15]) || (ID_Rd_addr == IF_Instruction[24:20])) ) ||

                     (((IF_Instruction[6:0] == `OPCODE_OP_IMM) || (IF_Instruction[6:0] == `OPCODE_LOAD)) &&

                       (ID_Rd_addr == IF_Instruction[19:15]))) ? 1:0;
    
    */
   
                    
    /*
    CONTROL HAZARD DETECTION FOR BRANCH:
    
    -> if a branch or jump is taken, the pipeline needs to be flushed.
    -> it is unknown whether a branch or jump is taken until the end of EX stage.
    -> if a branch is taken, IF, ID, and EX need to be flushed. 
    -> if a jump is taken, only IF and ID need to be flushed.       
    Checks for the following conditions:
    
    
    */
    
    
    always_comb begin
        if(EX_PC_Branch == 1) EX_Flush = 1;
        else                  EX_Flush = 0;
    end
    
    reg IF_ID_Flush_1;
    always_comb begin
        if((EX_PC_Branch == 1) || (ID_Jump == 1)) IF_ID_Flush_1 = 1;
        else                                      IF_ID_Flush_1 = 0;
    end

    reg IF_ID_Flush_2;
    always@(posedge Clk) begin
        IF_ID_Flush_2 <= (EX_PC_Branch == 1) ? IF_ID_Flush_1 : 0;
    end

    assign IF_ID_Flush = (IF_ID_Flush_1 || IF_ID_Flush_2);
    
endmodule