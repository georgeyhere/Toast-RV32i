`timescale 1ns / 1ps
    
	module Forwarding
	      
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
		output reg [1:0]                    ForwardA,
		output reg [1:0]                    ForwardB,   
		
		input      [1:0]                    ID_ALU_source_sel,
		
		input      [REGFILE_ADDR_WIDTH-1:0] ID_Rs1_addr,
		input      [REGFILE_ADDR_WIDTH-1:0] ID_Rs2_addr,
		input      [REGFILE_ADDR_WIDTH-1:0] ID_Rd_addr,
		input      [REGFILE_ADDR_WIDTH-1:0] EX_Rd_addr,
		input      [REGFILE_ADDR_WIDTH-1:0] MEM_Rd_addr,          
		
		input                               EX_RegFile_wr_en,
		input                               MEM_RegFile_wr_en
		);
   
    
		/*
		Check ID_ALU_source_sel : is an ALU operand going to be an immediate?
		  -> YES: don't forward
		  -> NO:  perform checks
		
		ForwardA Truth Table:
		---------------------
		00 -> ALU op1 comes from register file  (no hazard)
		10 -> ALU op1 forwarded from ALU result (EX hazard)
		01 -> ALU op1 forwarded from data memory or earlier ALU result (MEM hazard)
		
		ForwardB Truth Table:
		---------------------
		00 -> ALU op2 comes from register file
		10 -> ALU op2 forwarded from ALU result (EX hazard)
		01 -> ALU op2 forwarded from data memory or earlier ALU result (MEM hazard)
		*/
        
        
        // Forward A combinatorial logic
        always_comb begin
        //always_ff @(posedge Clk) begin
            /*
                EX HAZARD
            - 
            */
            if ( (EX_RegFile_wr_en == 1'b1) &&     
                 (EX_Rd_addr       != 0   ) &&
                 (EX_Rd_addr       == ID_Rs1_addr) &&
                 (ID_ALU_source_sel[1] != 1)
                )
                ForwardA = 2'b10;
            else 
            // MEM hazard 
            if ( (MEM_RegFile_wr_en == 1'b1) &&
                 (MEM_Rd_addr       != 0   ) &&
                 ~ ( (EX_RegFile_wr_en  == 1'b1) &&
                     (EX_Rd_addr        != 0)    &&
                     (EX_Rd_addr        == ID_Rs1_addr)) &&
                 (MEM_Rd_addr       == ID_Rs1_addr)&&
                 (ID_ALU_source_sel[1] != 1)         
                )
                ForwardA = 2'b01;
            else
                ForwardA = 2'b0;         		  
		end
        
        always_comb begin
            /*
                EX HAZARD
            - 
            */
            if ( (EX_RegFile_wr_en == 1'b1) &&     
                 (EX_Rd_addr       != 0   ) &&
                 (EX_Rd_addr       == ID_Rs2_addr) &&
                 (ID_ALU_source_sel[0] != 1)
                )
                ForwardB = 2'b10;
            else 
            // MEM hazard 
            if ( (MEM_RegFile_wr_en == 1'b1) &&
                 (MEM_Rd_addr       != 0   ) &&
                 ~ ( (EX_RegFile_wr_en  == 1'b1) && (EX_Rd_addr != 0) && (EX_Rd_addr == ID_Rs2_addr))
                 && (MEM_Rd_addr == ID_Rs2_addr) &&
                 (ID_ALU_source_sel[0] != 1)
               ) 
                ForwardB = 2'b01;
            else
                ForwardB = 2'b0;         
        end
        
endmodule