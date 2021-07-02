`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2021 05:48:27 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import RV32I_definitions::*;


module testbench();

    reg Clk;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst; 
    
    reg [31:0] instruction;
    reg [31:0] pc;
    
    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;     
    
    task encodeAddi;
	   input [4:0] rs1;
	   input [4:0] rd;
	   input [11:0] immediate;
	   begin
	   	   instruction = {immediate, rs1, 3'b000, rd, `OPCODE_OP_IMM};
	   	   UUT.IF_inst.RV32I_IMEM.Instruction_data[pc >> 2] = instruction;
	   	   pc = pc + 32'd4;
	   end
    endtask
    
    initial begin
        encodeAddi(3, 4, 5);
    end
    
    
endmodule
