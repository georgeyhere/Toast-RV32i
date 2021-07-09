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


module WB_top

    (
    output  [4:0]  WB_Rd_addr,
    output  [31:0] WB_Rd_data,
    output         WB_RegFile_wr_en,

    input      [4:0]  MEM_Rd_addr,
    input      [31:0] MEM_dout,
    input      [31:0] MEM_ALU_result,
    input             MEM_MemToReg,
    input             MEM_RegFile_wr_en   
    );

    assign WB_Rd_addr       = MEM_Rd_addr;
    assign WB_Rd_data       = (MEM_MemToReg == 1'b1) ? MEM_dout : MEM_ALU_result;
    assign WB_RegFile_wr_en = MEM_RegFile_wr_en;
    /*
    always_comb begin
        WB_Rd_addr       = MEM_Rd_addr;
        WB_Rd_data       = (MEM_MemToReg == 1'b1) ? MEM_dout : MEM_ALU_result;
        WB_RegFile_wr_en = MEM_RegFile_wr_en;
    end
    */

endmodule
