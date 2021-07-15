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

`define RVTEST_ADD   1
`define RVTEST_ADDI  2
`define RVTEST_AND   3
`define RVTEST_AUIPC 4

module riscvTests_tb();
  
    reg         Clk = 0;
    reg         Reset_n;
    reg  [31:0] IMEM_data;
    reg  [31:0] DMEM_rd_data;

    wire [31:0] IMEM_addr;
    wire [31:0] DMEM_addr;
    wire [31:0] DMEM_wr_data;
    wire        DMEM_wr_en;
    wire        DMEM_rst;


    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .IMEM_data   (IMEM_data),
    .DMEM_rd_data(DMEM_rd_data),

    .IMEM_addr   (IMEM_addr),
    .DMEM_addr   (DMEM_addr),
    .DMEM_wr_data(DMEM_wr_data),
    .DMEM_wr_en  (DMEM_wr_en),
    .DMEM_rst    (DMEM_rst)
    );
    
    always#(10) Clk = ~Clk;     
    
    always@(posedge Clk) begin
        if(UUT.IF_inst.IF_Instruction == 32'hc0001073) begin
            $finish; // finish if encounter an unimp, indicating end of test
        end
    end
    
    reg [8*20:0] tests [0:3] = {
    "add.mem",
    "addi.mem",
    "and.mem",
    "auipc.mem"
    };


    parameter IMEM_DEPTH    = 2047;
    parameter PROGMEM_DEPTH = 2047;
    parameter DMEM_DEPTH    = 2047;

    reg [31:0] IMEM    [0:IMEM_DEPTH];
    reg [31:0] PROGMEM [0:PROGMEM_DEPTH];
    reg [31:0] DMEM    [0:DMEM_DEPTH];

    initial begin
        $readmemh(tests[`RVTEST_ADD], PROGMEM);
        for(int i=0; i<=IMEM_DEPTH/4; i=i+1) begin
            PROGMEM[i*4] = PROGMEM[i];
        end
    end

    initial begin
        for(int j=0; j<=DMEM_DEPTH; j=j+1) begin
            DMEM[j] = 32'b0;
        end
    end


    always@(posedge Clk) IMEM_data = IMEM[IMEM_addr];

    always@(posedge Clk) begin
        if((DMEM_rst == 1) || (Reset_n == 0)) DMEM_rd_data <= 0;
        else begin
            DMEM_rd_data <= DMEM[DMEM_addr];
            if(DMEM_wr_en == 1'b1) DMEM[DMEM_addr] = DMEM_rd_data;
        end
    end


    initial begin
        Reset_n = 0;
        #100;
        Reset_n = 1;
    end
    
endmodule
