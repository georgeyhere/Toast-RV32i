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
//************************************************* 
    input                          Clk,
    input                          Reset_n,

//*************************************************
    output reg                     Stall,          // pipeline stall signal
	
 	output                         IF_ID_Flush,    // flush IF and ID in case of branch or jump taken
 	output reg                     EX_Flush,       // flush EX if branch taken

//*************************************************
	input [31:0]                   IF_Instruction, // used to check for Data hazard

	input						   ID_Mem_rd_en,   // is an ID instrn a load?
	input [REGFILE_ADDR_WIDTH-1:0] ID_Rd_addr,     
    
    input                          EX_PC_Branch,
    input                          ID_Jump,

    input                          DMEM_wr_en

//*************************************************
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
    
    wire [6:0] opcode_i = IF_Instruction[6:0]; // internal 

    wire [4:0] DBG_IF_Rs1 = IF_Instruction[19:15];
    wire [4:0] DBG_IF_Rs2 = IF_Instruction[24:20];

    always_comb begin
        //Stall = (DMEM_wr_en == 1) ? 1:0;

        if(ID_Mem_rd_en == 1) begin
            if( (opcode_i == `OPCODE_OP) ||       // register-register opcodes
                (opcode_i == `OPCODE_BRANCH) ||
                (opcode_i == `OPCODE_STORE) ) 
            begin
                if( (ID_Rd_addr == IF_Instruction[19:15]) || (ID_Rd_addr == IF_Instruction[24:20]) ) 
                    Stall = 1;
            end
    
            else if( (opcode_i == `OPCODE_OP_IMM) ||
                     (opcode_i == `OPCODE_LOAD) ) 
            begin
                if(ID_Rd_addr == IF_Instruction[19:15]) 
                    Stall = 1;
            end
        end
        else Stall = 0;
    end
                
    /*
    CONTROL HAZARD DETECTION FOR BRANCH:
    
    -> if a branch or jump is taken, the pipeline needs to be flushed for two cycles.
        -> a flush is defined as setting all control signals to 0, effectively
           replacing whatever instructions were being processed with NOP

    -> it is unknown whether a branch or jump is taken until the end of EX stage.
    -> if a branch is taken, IF, ID, and EX need to be flushed.
    -> if a jump is taken, only IF and ID need to be flushed.       
    */
    
    reg IF_ID_Flush1_i; // internal 1
    reg IF_ID_Flush2_i; // internal 2

    assign IF_ID_Flush = (IF_ID_Flush1_i || IF_ID_Flush2_i);
    
    
    always_comb begin
        if((EX_PC_Branch == 1) || (ID_Jump == 1)) IF_ID_Flush1_i = 1;
        else                                      IF_ID_Flush1_i = 0;
    end

    
    always@(posedge Clk) begin
        if(Reset_n == 1'b0) IF_ID_Flush2_i <= 0;
        else                IF_ID_Flush2_i <= IF_ID_Flush1_i;
        
    end

    always_comb begin
        if(EX_PC_Branch == 1) EX_Flush = 1;
        else                  EX_Flush = 0;
    end
    
    
endmodule