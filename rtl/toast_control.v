`timescale 1ns / 1ps
`default_nettype none
// toast_control
//
// This module handles forwarding and hazard detection.

`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_control 
    `include "toast_definitions.vh"

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
    	input  wire                           clk_i,
    	input  wire                           resetn_i,
 
    	// forwarding outputs 
    	output reg  [1:0]                     forwardA_o,       // forwarding control ALU operand1
		output reg  [1:0]                     forwardB_o,       // forwarding control ALU operand2
		output reg                            forwardM_o,       // forwarding control for data mem writes
  
		// hazard detection outputs  
		output reg                            stall_o,          // pipeline stall signal
 		output wire                           IF_ID_flush_o,    // flush IF and ID in case of branch or jump taken
 		output reg                            EX_flush_o,       // flush EX if branch taken
  
 		// inputs for forwarding  
		input  wire [1:0]                     ID_alu_source_sel_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  ID_rs1_addr_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  ID_rs2_addr_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  ID_rd_addr_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  EX_rd_addr_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  EX_rs2_addr_i,
		input  wire [REGFILE_ADDR_WIDTH-1:0]  MEM_rd_addr_i,                 
		input  wire                           EX_rd_wr_en_i,
		input  wire                           MEM_rd_wr_en_i,
 
		// inputs for hazard detection
 		input  wire [31:0]                    IF_instruction_i, // used to check for Data hazard
	    input  wire 						  ID_mem_rd_en_i,   // is an ID instrn a load?   
        input  wire                           EX_branch_en_i,
        input  wire                           ID_jump_en_i
    );



// ALU operand forwarding: 
//	1) no forwarding, operand will come from regfile
//  2) forward operand from prior ALU result 
//  3) forward operand from MEM stage output
//
// 	Check ID_alu_source_sel_i : is an ALU operand going to be an immediate?
//		  -> YES: don't forward
//		  -> NO:  perform checks
//		
//    ForwardA_o Truth Table:
//    ---------------------
//    00 -> ALU op1 comes from register file  (no hazard)
//    10 -> ALU op1 forwarded from ALU result (EX hazard)
//    01 -> ALU op1 forwarded from data memory or earlier ALU result (MEM hazard)
//    
//    ForwardB_o Truth Table:
//    ---------------------
//    00 -> ALU op2 comes from register file
//    10 -> ALU op2 forwarded from ALU result (EX hazard)
//    01 -> ALU op2 forwarded from data memory or earlier ALU result (MEM hazard)
//	    
    // Forward A combinatorial logic
    always@* begin

        // EX HAZARD
        // -> forward from EX_ALU_result to op1
        if ( (EX_rd_wr_en_i == 1'b1) &&     
             (EX_rd_addr_i       != 0   ) &&
             (EX_rd_addr_i       == ID_rs1_addr_i) &&
             (ID_alu_source_sel_i[1] != 1)
            )
            forwardA_o = 2'b10; 
        else 

        // WB hazard 
        // -> forward from WB_Rd_data to op1
        if ( (MEM_rd_wr_en_i == 1'b1) &&
             (MEM_rd_addr_i       != 0   ) &&
             ~ ( (EX_rd_wr_en_i  == 1'b1) &&
                 (EX_rd_addr_i        != 0)    &&
                 (EX_rd_addr_i        == ID_rs1_addr_i)) &&
             (MEM_rd_addr_i       == ID_rs1_addr_i)&&
             (ID_alu_source_sel_i[1] != 1)         
            )
            forwardA_o = 2'b01; 
        else
            forwardA_o = 2'b0;         		  
	end
    
    always@* begin

        // EX HAZARD
        // -> forward from EX_ALU_result to op2
        if ( (EX_rd_wr_en_i == 1'b1) &&     
             (EX_rd_addr_i       != 0   ) &&
             (EX_rd_addr_i       == ID_rs2_addr_i) &&
             (ID_alu_source_sel_i[0] != 1)
            )
            forwardB_o = 2'b10;
        else 

        // WB hazard 
        // -> forward from WB_Rd_data to op2
        if ( (MEM_rd_wr_en_i == 1'b1) &&
             (MEM_rd_addr_i       != 0   ) &&
             ~ ( (EX_rd_wr_en_i  == 1'b1) && (EX_rd_addr_i != 0) && (EX_rd_addr_i == ID_rs2_addr_i))
             && (MEM_rd_addr_i == ID_rs2_addr_i) &&
             (ID_alu_source_sel_i[0] != 1)
           ) 
            forwardB_o = 2'b01;
        else
            forwardB_o = 2'b0;         
    end


//  Memory write forwarding:
//  1) no forwarding, write value of rs2 to data mem
//  2) forward data from prior MEM stage output 

    always@* begin
    		if ( 
    			 (MEM_rd_wr_en_i == 1'b1) &&
    			 (EX_rs2_addr_i == MEM_rd_addr_i) &&
    			 (MEM_rd_addr_i != 0) 
    		   )
    		    forwardM_o = 1; // forward from MEM_ALU_result
    		else
    			forwardM_o = 0;
    end


// Data Load Hazard Detection
//     
//   Checks for the following conditions:
//   1) is a load instruction present in ID pipeline reg?
//   2a) does the next instruction (in IF pipeline reg) read any registers?
//   2b) are any of the registers to be read dependent on the load?
//   
//   if all true, stall the pipeline.
//   
//   IF_Rs1_addr    = Instruction[19:15];
//   IF_Rs2_addr    = Instruction[24:20];

    wire [6:0] opcode = IF_instruction_i[6:0]; // internal 
    always@* begin
        if(ID_mem_rd_en_i == 1) begin
            if( ( (opcode == `OPCODE_OP) || (opcode == `OPCODE_BRANCH) || (opcode == `OPCODE_STORE) ) &&
                ( (ID_rd_addr_i == IF_instruction_i[19:15]) || (ID_rd_addr_i == IF_instruction_i[24:20]) )
              )     
            begin
                stall_o = 1;
            end else if( ( (opcode == `OPCODE_OP_IMM) ||(opcode == `OPCODE_LOAD) )  &&
                         ( (ID_rd_addr_i == IF_instruction_i[19:15]) )
                       )
            begin
                stall_o = 1;
            end     
            else stall_o = 0;   
        end
        else stall_o = 0;
    end


// Control Hazard Detection:
//     
//   -> if a branch or jump is taken, the pipeline needs to be flushed for two cycles.
//       -> a flush is defined as setting all control signals to 0, effectively
//          replacing whatever instructions were being processed with NOP
// 
//   -> it is unknown whether a branch or jump is taken until the end of EX stage.
//   -> if a branch is taken, IF, ID, and EX need to be flushed.
//   -> if a jump is taken, only IF and ID need to be flushed.    

	reg IF_ID_Flush1; // internal 1
    reg IF_ID_Flush2; // internal 2


    assign IF_ID_flush_o = (IF_ID_Flush1 || IF_ID_Flush2);

    always@* begin
        if((EX_branch_en_i == 1) || (ID_jump_en_i == 1)) 
        	IF_ID_Flush1 = 1;
        else                                      
        	IF_ID_Flush1 = 0;
    end
    
    always@(posedge clk_i) begin
        if(resetn_i == 1'b0) 
        	IF_ID_Flush2 <= 0;
        else                 
        	IF_ID_Flush2 <= IF_ID_Flush1;
        
    end

    // Flush EX if a branch is taken
    always@* begin
    	EX_flush_o = (EX_branch_en_i == 1) ? 1:0;
    end


endmodule