`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2021 10:49:36 AM
// Design Name: 
// Module Name: MEM_top
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
import RV32I_definitions ::*;
/*
Handles reads and writes to data memory. Data memory is assumed to be
 a true dual-port RAM.  
*/

module MEM_top

    (
    input             Clk,
    input             Reset_n,

    // DATA MEMORY
    output reg [31:0] mem_addr,      // data mem address
    output reg [31:0] mem_wr_data,   // data mem write data, mask applied
    output reg        mem_wr_en,     // data mem write enable
    output reg        mem_rst,       // data mem read port reset
    input     [31:0]  mem_rd_data,   // data mem read data


    // PIPELINE OUT
    output reg [31:0] MEM_dout,          // data mem read data, mask applied
    output reg        MEM_MemToReg,      
    output reg [31:0] MEM_ALU_result,
    output reg        MEM_RegFile_wr_en,
    output reg [4:0]  MEM_Rd_addr,

    // PIPELINE IN
    input             EX_Mem_wr_en,
    input             EX_Mem_rd_en,
    input [2:0]       EX_Mem_op,
    input             EX_MemToReg,
    input [31:0]      EX_ALU_result,
    input [31:0]      EX_Rs2_data,
    input             EX_RegFile_wr_en,
    input [4:0]       EX_Rd_addr
    );
    


    // pipeline register
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            MEM_MemToReg      <= 0;
            MEM_ALU_result    <= 0;
            MEM_RegFile_wr_en <= 0;
            MEM_Rd_addr       <= 0;
        end
        else begin
            MEM_MemToReg      <= EX_MemToReg;
            MEM_ALU_result    <= EX_ALU_result;
            MEM_RegFile_wr_en <= EX_RegFile_wr_en;
            MEM_Rd_addr       <= EX_Rd_addr;
        end
    end
    
    
    // data memory control
    always_comb begin
        mem_addr  = EX_ALU_result;
        mem_wr_en = EX_Mem_wr_en;
        mem_rst   = ~Reset_n;
    end
    
    
    // mask data to be written to data mem
    always_comb begin
        case(EX_Mem_op)
            `MEM_SB:   mem_wr_data = { {24{EX_Rs2_data[1'b0]}}, EX_Rs2_data[7:0] }; 
            `MEM_SH:   mem_wr_data = { {16{EX_Rs2_data[1'b0]}}, EX_Rs2_data[15:0] };
            `MEM_SW:   mem_wr_data = EX_Rs2_data;
            default:   mem_wr_data = EX_Rs2_data;
        endcase
    end
    
    // mask the data read from data mem
    always_comb begin
        case(EX_Mem_op)
            `MEM_LB:   MEM_dout = { {24{mem_rd_data[31]}}, mem_rd_data[7:0] }; 
            `MEM_LH:   MEM_dout = { {16{mem_rd_data[31]}}, mem_rd_data[15:0] };
            `MEM_LB_U: MEM_dout = { {24{mem_rd_data[1'b0]}}, mem_rd_data[7:0] }; 
            `MEM_LH_U: MEM_dout = { {16{mem_rd_data[1'b0]}}, mem_rd_data[15:0] };
            `MEM_LW:   MEM_dout = mem_rd_data;
            default:   MEM_dout = mem_rd_data;
        endcase
    end

endmodule
