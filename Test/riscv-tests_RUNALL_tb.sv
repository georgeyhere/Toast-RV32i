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

    parameter TEST_TO_RUN   = `RR_ADD;

    reg         Clk = 0;
    reg         Reset_n;
    reg  [31:0] IMEM_data;
    reg  [31:0] DMEM_rd_data;

    wire [31:0] IMEM_addr;
    wire [31:0] DMEM_addr;
    wire [31:0] DMEM_wr_data;
    wire        DMEM_wr_en;
    wire        DMEM_rst;
    wire        Exception;


    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .IMEM_data   (IMEM_data),
    .DMEM_rd_data(DMEM_rd_data),

    .IMEM_addr   (IMEM_addr),
    .DMEM_addr   (DMEM_addr),
    .DMEM_wr_data(DMEM_wr_data),
    .DMEM_wr_en  (DMEM_wr_en),
    .DMEM_rst    (DMEM_rst),
    .Exception   (Exception)
    );
    
    always#(10) Clk = ~Clk;     

    
// ===========================================================================
//                                TEST CONTROL
// ===========================================================================
    reg        pass;
    reg        fail_exception;
    reg        fail_timeout;
    reg [63:0] cycle_count;

    //****************************************
    // PASS CONDITION 1: GP=1 , A7=93, A0=0
    //****************************************

    /*
    always@(posedge Clk) begin
        if((UUT.ID_inst.RV32I_REGFILE.Regfile_data[3] == 1) &&   
           (UUT.ID_inst.RV32I_REGFILE.Regfile_data[17] == 93) && 
           (UUT.ID_inst.RV32I_REGFILE.Regfile_data[10] == 0))    
        begin  
            $display("TEST PASSED!!!!!!");
            pass = 1;
        end
        //************************************************
        // FAIL CONDITION 1: ECALL BEFORE PASS CONDITION 1
        //************************************************
        else if (Exception == 1) begin
            $display("EXCEPTION ASSERTED, TEST FAILED");
            fail_exception = 0;
        end
    end
    */
    
    

    task CHECK;
        for(int j=0; j<1999; j=j+1) begin
            @(posedge Clk) begin

                //****************************************
                // PASS CONDITION: GP=1 , A7=93, A0=0
                //****************************************
                if((UUT.ID_inst.RV32I_REGFILE.Regfile_data[3] == 1) &&   
                   (UUT.ID_inst.RV32I_REGFILE.Regfile_data[17] == 93) && 
                   (UUT.ID_inst.RV32I_REGFILE.Regfile_data[10] == 0))    
                begin            
                    $display("TEST PASSED!!!!!! Cycles Elapsed: %0d", j);
                    break;
                end

                //************************************************
                // FAIL CONDITION 1: ECALL, NO PASS CONDITION 
                //************************************************
                else if (Exception == 1) begin
                    $display("EXCEPTION ASSERTED, TEST FAILED. Cycles Elapsed: %0d", j);
                    break;
                end

                //*********************************
                // FAIL CONDITION 2: TEST TIMEOUT
                //*********************************
                else if(j == 1998) begin
                    cycle_count  <= cycle_count;
                    $display("TIMED OUT, TEST FAILED. Cycles Elapsed: %0d", j);
                    break;
                end
            end
        end
    endtask // CHECK



// ===========================================================================
//                              Implementation    
// ===========================================================================    
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

    

    //*********************************
    //       SIMULATE MEMORY
    //*********************************
    parameter MEMORY_DEPTH  = 32'hFFFF;
    reg [31:0] MEMORY [0:MEMORY_DEPTH];

/*
    $readmemh loads program data into consecutive addresses, however 
    RISC-V uses byte-addressable memory (i.e. a word at every fourth address)

    A workaround is to ignore the lower two bits of the address.
    Do this for both program data and data memory. 

    Note that program memory and data memory are loaded from the same .mem file.
    Data memory begins at 0x2000, this can be changed by editing /Scripts/memgen.sh and
    changing the -Tdata parameter of riscv32-unknown-elf-ld.
*/

/*
    initial begin
        for (int i=0; i<= MEMORY_DEPTH; i=i+1) begin
            MEMORY[i] = 0;
        end
        $readmemh(tests[TEST_TO_RUN], MEMORY);
    end
*/
    always@(posedge Clk, negedge Reset_n) begin
        if(Reset_n == 1'b0) begin
            IMEM_data <= 0;
            DMEM_rd_data <= 0;
        end
        else begin
            IMEM_data <= MEMORY[IMEM_addr[31:2]];
            
            if(DMEM_rst)   DMEM_rd_data <= 0;
            else           DMEM_rd_data <= MEMORY[DMEM_addr[31:2]];
            
            if(DMEM_wr_en) MEMORY[DMEM_addr[31:2]] <= DMEM_wr_data;
        end

    end

    //*********************************
    //             TASKS:
    //*********************************
    task LOAD_TEST;
        input int testSel;
        begin
            #10;
            Reset_n        <= 0;
            #10;
            for (int i=0; i<= MEMORY_DEPTH; i=i+1) begin
                MEMORY[i] <= 0;
            end

            $readmemh(tests[testSel], MEMORY);
            #100;

            Reset_n <= 1;
        end
    endtask // LOAD_TEST




    integer x;

    initial begin
        Reset_n        <= 0;
        pass           <= 0;
        fail_exception <= 0;
        fail_timeout   <= 0;

        #100;
        $display("Running Register-Register Unit Tests.");
        for(x=0; x<=9; x=x+1) begin

            Reset_n = 0;
            $readmemh(tests[x], MEMORY);
            #100;

            case(x)
                `RR_ADD: begin

                 end

                `RR_SUB: begin

                end

                `RR_AND: begin

                end

                `RR_OR: begin

                end

                `RR_XOR: begin

                end

                `RR_SLT: begin

                end

                `RR_SLTU: begin

                end

                `RR_SLL: begin

                end

                `RR_SRL: begin

                end

                `RR_SRA: begin

                end
            endcase

            Reset_n = 1;
            CHECK();
        end
        $finish;

    end
    
endmodule
