`timescale 1ns / 1ps
`default_nettype none
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
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_WB_stage

    (
    output reg   [4:0]  WB_rd_addr_o,
    output reg   [31:0] WB_rd_wr_data_o,
    output reg          WB_rd_wr_en_o,

    input  wire  [4:0]  MEM_rd_addr_i,
    input  wire  [31:0] MEM_dout_i,
    input  wire  [31:0] MEM_alu_result_i,
    input  wire         MEM_memtoreg_i,
    input  wire         MEM_rd_wr_en_i   
    );

/*
WB just consists of a mux that controls whether data memory data or ALU result
gets written back to the register file. Not really a real 'stage', just a passthrough really
*/

    always@* begin
        WB_rd_addr_o       = MEM_rd_addr_i;
        WB_rd_wr_data_o    = (MEM_memtoreg_i == 1'b1) ? MEM_dout_i : MEM_alu_result_i;
        WB_rd_wr_en_o      = MEM_rd_wr_en_i;
    end

endmodule
