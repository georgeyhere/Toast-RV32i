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

// Register-Register
`define RR_ADD   0
`define RR_SUB   1
`define RR_AND   2
`define RR_OR    3
`define RR_XOR   4
`define RR_SLT   5
`define RR_SLTU  6
`define RR_SLL   7
`define RR_SRL   8
`define RR_SRA   9
 
 // Register-Immediate
`define I_ADDI   10
`define I_ANDI   11
`define I_ORI    12
`define I_XORI   13
`define I_SLTI   14
`define I_SLLI   15
`define I_SRLI   16
`define I_SRAI   17
 
 // Conditional Branches
`define B_BEQ    18
`define B_BNE    19
`define B_BLT    20
`define B_BGE    21
`define B_BLTU   22
`define B_BGEU   23

// Upper Immediate
`define UI_LUI   24
`define UI_AUIPC 25

// Jumps
`define J_JAL    26
`define J_JALR   27

// Loads
`define L_LB     28
`define L_LH     29
`define L_LW     30
`define L_LBU    31
`define L_LHU    32

// Stores
`define S_SB     33
`define S_SH     34
`define S_SW     35
`define S_SBU    36
`define S_SHU    37


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
    
    reg [8*20:0] tests [0:37] = {
    
    // R-R [0:9] 
    "add.S.mem",
    "sub.S.mem",
    "and.S.mem",
    "or.S.mem",
    "xor.S.mem",
    "slt.S.mem",
    "sltu.S.mem",
    "sll.S.mem",
    "srl.S.mem",
    "sra.S.mem",

    // R-I [10:17]
    "addi.S.mem",
    "andi.S.mem",
    "ori.S.mem",
    "xori.S.mem",
    "slti.S.mem",
    "slli.S.mem",
    "srli.S.mem",
    "srai.S.mem",

    // CB [18:23]
    "beq.S.mem",
    "bne.S.mem",
    "blt.S.mem",
    "bge.S.mem",
    "bltu.S.mem",
    "bgeu.S.mem",

    // UI [24:25]
    "lui.S.mem",
    "auipc.S.mem",

    // J [26:27]
    "jal.S.mem",
    "jalr.S.mem",

    // L [28:32]
    "lb.S.mem",
    "lh.S.mem",
    "lw.S.mem",
    "lbu.S.mem",
    "lhu.S.mem",

    // S [33:37]
    "sb.S.mem",
    "sh.S.mem",
    "sw.S.mem",
    "sbu.S.mem",
    "shu.S.mem"
    };


    parameter IMEM_DEPTH    = 2047;
    parameter PROGMEM_DEPTH = 2047;
    parameter DMEM_DEPTH    = 2047;

    reg [31:0] IMEM    [0:IMEM_DEPTH];
    reg [31:0] PROGMEM [0:PROGMEM_DEPTH];
    reg [31:0] DMEM    [0:DMEM_DEPTH];

    initial begin
    // !!!!! EDIT THIS LINE FOR DIFFERENT TESTS !!!!!!!
        $readmemh(tests[`I_SLLI], PROGMEM);
        for(int i=0; i<=IMEM_DEPTH/4; i=i+1) IMEM[i*4] = PROGMEM[i];
    end

    initial begin
        for(int j=0; j<=DMEM_DEPTH; j=j+1) begin
            DMEM[j] = 32'b0;
        end
    end


    always@(posedge Clk) IMEM_data <= IMEM[IMEM_addr];

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
