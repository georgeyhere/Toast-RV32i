`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2021 12:43:37 PM
// Design Name: 
// Module Name: WB_top
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


module toast_WB_stage

    (
    output logic [4:0]  WB_rd_addr_o,
    output logic [31:0] WB_rd_wr_data_o,
    output logic        WB_rd_wr_en_o,

    input  logic [4:0]  MEM_rd_addr_i,
    input  logic [31:0] MEM_dout_i,
    input  logic [31:0] MEM_alu_result_i,
    input  logic        MEM_memtoreg_i,
    input  logic        MEM_rd_wr_en_i   
    );

    /*
    WB just consists of a mux that controls whether data memory data or ALU result
    gets written back to the register file.
    */

    always_comb begin
        WB_rd_addr_o       = MEM_rd_addr_i;
        WB_rd_wr_data_o    = (MEM_memtoreg_i == 1'b1) ? MEM_dout_i : MEM_alu_result_i;
        WB_rd_wr_en_o      = MEM_rd_wr_en_i;
    end

endmodule
