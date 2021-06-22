`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 05:54:41 PM
// Design Name: 
// Module Name: IF_ID_tb
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


module IF_ID_tb();
    
    reg Clk_100MHz = 0;
    reg Reset_n;
    
    reg [31:0] MEM_PC_branch_dest;
    reg        MEM_PC_source_sel;
    reg        ID_PC_stall;
    
    reg [7:0] Instruction_data [0:1023];
    
    wire [31:0] ID_PC;
    wire        ID_Rd_wr_en;
    wire        ID_ALU_source_sel;
    wire [3:0]  ID_ALU_op;
    wire [31:0] ID_Immediate;
    wire        ID_Branch_en;
    wire [4:0]  ID_Rd_address;
    wire [31:0] ID_Rs1_data;
    wire [31:0] ID_Rs2_data;

    IF_ID_top UUT(
    .Clk_100MHz(Clk_100MHz),
    .Reset_n(Reset_n),
    .MEM_PC_branch_dest(MEM_PC_branch_dest),
    .MEM_PC_source_sel(MEM_PC_source_sel),
    .ID_PC_stall(ID_PC_stall),
    
    .ID_PC(ID_PC),
    .ID_Rd_wr_en(ID_Rd_wr_en),
    .ID_ALU_source_sel(ID_ALU_source_sel),
    .ID_ALU_op(ID_ALU_op),
    .ID_Immediate(ID_Immediate),
    .ID_Branch_en(ID_Branch_en),
    .ID_Rd_address(ID_Rd_address),
    .ID_Rs1_data(ID_Rs1_data),
    .ID_Rs2_data(ID_Rs2_data)
    );
    
    parameter CLK_PERIOD = 10;
    
    always#(CLK_PERIOD/2) begin
        Clk_100MHz = ~Clk_100MHz;
    end
    
    always@(posedge Clk_100MHz) begin
        if(Reset_n != 1'b0) begin
            $display("Time = %0t : Reset_n = %0b | ID_PC = %0d ", $time, Reset_n, ID_PC);
            $display("\t ID_ALU_op = %4b | ID_ALU_source_sel = %1b |  ID_Branch_en = %0b | ID_Immediate = %32b", ID_ALU_op, ID_ALU_source_sel, ID_Branch_en, ID_Immediate);
            $display("\t \t ID_Rs1_data = %0d | ID_Rs2_data = %0d | ID_Rd_address = %0d", ID_Rs1_data, ID_Rs2_data, ID_Rd_address);
        end
        if(ID_PC == 9) begin
            $finish;
        end
    end
    
    initial begin
        Reset_n = 0;
        #100;
        Reset_n = 1;
    end
   
endmodule
