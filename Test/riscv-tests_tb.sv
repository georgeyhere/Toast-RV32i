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
//import   RV32I_definitions::*;

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


module riscvTests_tb();
  
    reg         Clk = 0;
    reg         Reset_n;
    reg  [31:0] IMEM_data;
    reg  [31:0] DMEM_rd_data;

    wire [31:0] IMEM_addr;
    wire [31:0] DMEM_addr;
    wire [3:0]  DMEM_wr_byte_en;
    wire [31:0] DMEM_wr_data;
    wire        DMEM_wr_en;
    wire        DMEM_rst;
    wire        Exception;


    ToastCore UUT(
    .Clk             (Clk),
    .Reset_n         (Reset_n),
    .IMEM_data       (IMEM_data),
    .DMEM_rd_data    (DMEM_rd_data),
    
    .IMEM_addr       (IMEM_addr),
    .DMEM_addr       (DMEM_addr),
    .DMEM_wr_byte_en (DMEM_wr_byte_en),
    .DMEM_wr_data    (DMEM_wr_data),
    .DMEM_wr_en      (DMEM_wr_en),
    .DMEM_rst        (DMEM_rst),
    .Exception       (Exception)
    );
    
    always#(10) Clk = ~Clk;     

    
// ===========================================================================
//                                TEST CONTROL
// ===========================================================================
    
    parameter TEST_TO_RUN   = `S_SW;

    //****************************************
    // PASS CONDITION 1: GP=1 , A7=93, A0=0
    //****************************************
    always@(posedge Clk) begin
        if((UUT.ID_inst.RV32I_REGFILE.Regfile_data[3] == 1) &&   
           (UUT.ID_inst.RV32I_REGFILE.Regfile_data[17] == 93) && 
           (UUT.ID_inst.RV32I_REGFILE.Regfile_data[10] == 0))    
        begin  
            $display("TEST PASSED!!!!!!");
            $finish;
        end
        //************************************************
        // FAIL CONDITION 1: ECALL BEFORE PASS CONDITION 1
        //************************************************
        else if (Exception == 1) begin
            $display("EXCEPTION ASSERTED, TEST FAILED");
            $finish;
        end
    end

    //*********************************
    // FAIL CONDITION 2: TEST TIMEOUT
    //*********************************
    initial begin
        #19995 $display("TIMED OUT, TEST FAILED");
        $finish;
    end


// ===========================================================================
//                              Implementation    
// ===========================================================================    
    reg [8*20:0] tests [0:35] = {
    
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

    // S [33:35]
    "sb.S.mem",
    "sh.S.mem",
    "sw.S.mem"
    };

    parameter MEMORY_DEPTH  = 32'hFFFF;

    //*********************************
    //       SIMULATE MEMORY
    //*********************************

    reg [31:0] MEMORY [0:MEMORY_DEPTH];

    initial begin
        for (int i=0; i<= MEMORY_DEPTH; i=i+1) begin
            MEMORY[i] = 0;
        end
        $readmemh(tests[TEST_TO_RUN], MEMORY);
    end


/*
    $readmemh loads program data into consecutive addresses, however 
    RISC-V uses byte-addressable memory (i.e. a word at every fourth address)
    A workaround is to ignore the lower two bits of the address.
    Do this for both program data and data memory. 
    Note that program memory and data memory are loaded from the same .mem file.
    Data memory begins at 0x2000, this can be changed by editing /Scripts/memgen.sh and
    changing the -Tdata parameter of riscv32-unknown-elf-ld.
*/
    reg [31:0] DBG_MEM;

    always@(posedge Clk, negedge Reset_n) begin
        if(Reset_n == 1'b0) begin
            IMEM_data <= 0;
            DMEM_rd_data <= 0;
        end
        else begin
            IMEM_data <= MEMORY[IMEM_addr[31:2]];
            
            if(DMEM_rst)   DMEM_rd_data <= 0;
            else           DMEM_rd_data <= MEMORY[DMEM_addr[31:2]];
            //else           DMEM_rd_data <= (DMEM_wr_en == 1) ? DMEM_wr_data : MEMORY[DMEM_addr[31:2]];
            
            if(DMEM_wr_en) begin
                if(DMEM_wr_byte_en[0] == 1'b1) MEMORY[DMEM_addr[31:2]][7:0]   <= DMEM_wr_data[7:0];
                if(DMEM_wr_byte_en[1] == 1'b1) MEMORY[DMEM_addr[31:2]][15:8]  <= DMEM_wr_data[15:8];
                if(DMEM_wr_byte_en[2] == 1'b1) MEMORY[DMEM_addr[31:2]][23:16] <= DMEM_wr_data[23:16];
                if(DMEM_wr_byte_en[3] == 1'b1) MEMORY[DMEM_addr[31:2]][31:24] <= DMEM_wr_data[31:24];
            end

            DBG_MEM <= MEMORY[32'h2000];

        end

    end

    initial begin
        Reset_n = 0;
        #100;
        Reset_n = 1;
    end
    
endmodule