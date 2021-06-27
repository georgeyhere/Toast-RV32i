

import RV32I_definitions ::*

module Hazard_detection

	`ifdef CUSTOM_DEFINE
		#(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH,
		  parameter REGFILE_ADDR_WIDTH = `REGFILE_ADDR_WIDTH
		  )
	`else 
		#(parameter REG_DATA_WIDTH  = 32,
		  parameter REGFILE_ADDR_WIDTH  = 5
		 )


	(
		input [REGFILE_ADDR_WIDTH-1:0] ID_Rs1_address,
		input [REGFILE_ADDR_WIDTH-1:0] ID_Rs2_address,

		input						   EX_Mem_rd_en,
		input						   EX_Rd_address, 

 		output						   Pipe_stall
	);


	always_comb begin
		stall = 0; // default

		if( (EX_Mem_rd_en == 1'b1) & ((EX_Rd_address == ID_Rs1_address) | (EX_Rd_address == ID_Rs2_address)) )
			Pipe_stall = 1;
		else
			Pipe_stall = 0;

	end 
