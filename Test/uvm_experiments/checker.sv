`timescale 1ns/1ps

module checker 
	(
		input		 Clk,
		input        Reset_n,

		input		 checker_run,
		input [4:0]  rd,
		input [31:0] expected

		output       pass,
		output       fail, 
		output [4:0] cycles
	);



	reg [4:0] cycle_counter;
	reg       counter_run;

	always@(posedge Clk) begin
		if((Reset_n == 1'b0)||(checker_run == 1'b0)) 
			cycle_counter <= 0;
		else 
			cycle_counter <= (counter_run == 1'b1) ? cycle_counter+1 : cycle_counter;
	end

	always@* begin
		pass = 0;
		fail = 0;
		cycles = 0;
		counter_run = 0;

		if(checker_run == 1'b1) begin
			counter_run = 1;
			cycles = cycle_counter;
			if(UUT.ID_inst.RV32I_REGFILE.Regfile_data[rd] == expected) begin
				counter_run = 0;
				pass = 1;
			else if(cycles == 6) begin
				counter_run = 0;
				fail = 1;
			end
		end
	end

endmodule // checker