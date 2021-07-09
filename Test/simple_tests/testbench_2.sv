
import   RV32I_definitions::*;
import   testbench_pkg::*;

module tb();

    //`include "C:/Users/George/Desktop/Work/RISCV/Test/testbench.sv"

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
    
    reg [4:0] checker_rd;
    reg [1:0] checker_result;
    reg [3:0] checker_cycles;
    reg       checker_pass = 0;

    wire [31:0] regfile_rd = UUT.ID_inst.RV32I_REGFILE.Regfile_data[checker_rd]; 

    int unsigned m, k;
    int unsigned expected;


    ToastCore UUT(
    .Clk         (Clk),
    .Reset_n     (Reset_n),
    .mem_rd_data (mem_rd_data),
    .mem_addr    (mem_addr),
    .mem_wr_en   (mem_wr_en),
    .mem_rst     (mem_rst)
    );
    
    always#(10) Clk = ~Clk;     


    task LOAD_MEM;
        input [31:0] instruction;
        begin
            UUT.IF_inst.RV32I_IMEM.Instruction_data[pc+4] = instruction;
            pc = pc + 32'd4; 
        end
    endtask // LOAD_MEM


    task test_ADD;
        begin
            $display("ADD Test");
            LOAD_MEM(encode_ADDI)
        end

endmodule