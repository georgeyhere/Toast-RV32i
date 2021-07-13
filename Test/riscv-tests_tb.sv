`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2021 10:15:58 AM
// Design Name: 
// Module Name: riscv-tests_tb
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
import   RV32I_definitions::*;
import   testbench_pkg::*;


module riscvTests_tb();
  
    reg Clk = 0;
    reg Reset_n;
    reg [31:0] mem_rd_data = 0;
    wire [31:0] mem_addr;
    wire [31:0] mem_wr_data;
    wire        mem_wr_en;
    wire        mem_rst; 
    
    bit [31:0] instruction;
    bit [31:0] instruction1;

    reg [31:0] pc;
    
    reg [3:0] checker_cycles;
    reg [4:0] checker_rd1, checker_rd2;
    
    
    wire [31:0] regfile_rd1 = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd1]; 
    wire [31:0] regfile_rd2 = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd2]; 

    int unsigned m, k;
    int unsigned expected;

    int passed_cnt;
    int failed_cnt;

    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;     
    
    initial begin
        $dumpfile("add.vcd");
        $dumpvars(2, UUT);
    end
    
    initial begin
        Reset_n = 0;
        #100;
        Reset_n = 1;
    end
    
endmodule
