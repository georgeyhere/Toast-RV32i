



	module Forwarding
		`ifdef CUSTOM_DEFINE
		#(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH,
		  parameter REGFILE_ADDR_WIDTH = `REGFILE_ADDR_WIDTH
		  )
		`else 
		#(parameter REG_DATA_WIDTH  = 32,
		  parameter REGFILE_ADDR_WIDTH  = 5
		 )

		(

		input                          MEM_RegFile_wr_en,

		input [REGFILE_ADDR_WIDTH-1:0] MEM_Rd_address,
		input [REGFILE_ADDR_WIDTH-1:0] EX_Rs1_address,
		input [REGFILE_ADDR_WIDTH-1:0] EX_Rs2_address,
		input [REGFILE_ADDR_WIDTH-1:0] WB_Rd_address,

		output [1:0]                   ForwardA,
		output [1:0]                   ForwardB     
		);

		/*
		ForwardA Truth Table:
		---------------------
		00 -> ALU op1 comes from register file  (ID)
		10 -> ALU op1 forwarded from ALU result (EX)
		01 -> ALU op1 forwarded from data memory or earlier ALU result (MEM)
		
		ForwardB Truth Table:
		---------------------
		00 -> ALU op2 comes from register file
		10 -> ALU op2 forwarded from ALU result (EX)
		01 -> ALU op2 forwarded from data memory or earlier ALU result (MEM)
		*/

		always_comb begin

			if( (MEM_RegFile_wr_en == 1'b1) & (MEM_Rd_address != 0) & (MEM_Rd_address == EX_Rs1_address) ) 
				ForwardA = 2'b10;
			else if ()
		end


		always_comb begin

			if ( (MEM_RegFile_wr_en == 1'b1) & (MEM_Rd_address != 0) & (MEM_Rd_address == EX_Rs2_address) )
				ForwardB = 2'b10;
		
		end
