`timescale 1ns / 1ps
`default_nettype none
    
	module toast_forwarder
	      
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
		output logic [1:0]                    forwardA_o,
		output logic [1:0]                    forwardB_o,   
		output logic                          forwardM_o,

		input  wire logic [1:0]                    ID_alu_source_sel_i,
		 
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] ID_rs1_addr_i,
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] ID_rs2_addr_i,
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] ID_rd_addr_i,
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] EX_rd_addr_i,
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] EX_rs2_addr_i,
		input  wire logic [REGFILE_ADDR_WIDTH-1:0] MEM_rd_addr_i,                 
 
		input  wire logic                          EX_rd_wr_en_i,
		input  wire logic                          MEM_rd_wr_en_i
		);
   
    
		/*
		Check ID_alu_source_sel_i : is an ALU operand going to be an immediate?
		  -> YES: don't forward
		  -> NO:  perform checks
		
		ForwardA_o Truth Table:
		---------------------
		00 -> ALU op1 comes from register file  (no hazard)
		10 -> ALU op1 forwarded from ALU result (EX hazard)
		01 -> ALU op1 forwarded from data memory or earlier ALU result (MEM hazard)
		
		ForwardB_o Truth Table:
		---------------------
		00 -> ALU op2 comes from register file
		10 -> ALU op2 forwarded from ALU result (EX hazard)
		01 -> ALU op2 forwarded from data memory or earlier ALU result (MEM hazard)
		*/
        
        
        // Forward A combinatorial logic
        always_comb begin
        //always_ff @(posedge Clk) begin

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
        
        always_comb begin

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


        /*
		Stores copy a register value to data mem.

		1) Is there a regfile write in MEM?
		2) Does EX_rs2_addr_i == MEM_rd_addr_i ?
			-> forward from MEM_ALU_Result

        */

        always_comb begin
        		if ( 
        			 (MEM_rd_wr_en_i == 1'b1) &&
        			 (EX_rs2_addr_i == MEM_rd_addr_i) &&
        			 (MEM_rd_addr_i != 0) 
        		   )
        		    forwardM_o = 1; // forward from MEM_ALU_result
        		else
        			forwardM_o = 0;
        end
        
endmodule