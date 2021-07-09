`timescale 1ns/1ps

import RV32I_definitions::*;
import Toast_IMEM_loads::*;

module lui_tb();

	reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst;
    

    reg       checker_run;
    reg [4:0] checker_rd;
    reg       checker_expected;

    wire [31:0] regfile_rd = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd]; 

    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );

    checker CHECK(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .pass        (pass),
    .fail        (fail),
    .cycles      (cycles),
    .checker_run (checker_run),
    .rd          (checker_rd),
    .expected    (checker_expected)
    );



    
    
    initial begin
    	encode_LUI(3, 20'hFF);

    	Reset_n <= 0;
    	#100;
    	Reset_n <= 1;

    	@(posedge Clk) begin
    		checker_run <= 1;
    		checker_rd  <= 3;
    		checker_expected <= 20'hFF;
    	end
    	
    	if(pass == 1) begin
    		$display("rd = %4d ; value = %32b ; cycles = %4d", checker_rd, regfile_rd, cycles);
    		$display("LUI test passed.");
    		checker_run = 0;
    	end
    	else if(fail == 1) begin
    		$display("rd = %4d ; value = %32b ; cycles = %4d", checker_rd, regfile_rd, cycles);
    		$display("LUI test failed.")
    		checker_run = 0;
    		$fatal;
    	end


    end