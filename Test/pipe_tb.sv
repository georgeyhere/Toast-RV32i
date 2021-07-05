`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2021 05:25:57 PM
// Design Name: 
// Module Name: pipe_tb
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

import RV32I_definitions ::*;
import RV32I_encoding ::*;
/*
Rudimentary testbench to confirm control signals are percolating
through pipeline at correct timing and catch glaring issues.
*/

module pipe_tb();
    
    reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst;
    
    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;
    //int fileset   = $fopen("C:/Users/George/Desktop/Work/RISCV_Project/RISCV_Project.sim/sim_1/behav/xsim/IMEM.txt", "w");   
    
    reg [31:0] pc;
    reg [31:0] instruction;
    
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
      /*
        //$fdisplay(fileset, "%8b", 0);
        //$fclose(fileset);
        ADDI_gen(5, 0, 12'd1);
        ADDI_gen(6, 0, 12'd1);
        ADDI_gen(8, 5, 12'd10);
        ADDI_gen(9, 6, 12'd11);
        BEQ_gen(8, 9, 50); // branch not taken
        BEQ_gen(5, 6, 2);  // branch taken
      */     
        pc = 0;
        encodeAddi(3,4,5);
        
        
        Reset_n = 0;
        #100;
        Reset_n = 1;
        #10;
        
        
        
    end
    
endmodule
