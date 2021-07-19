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
 a single-port RAM.  

Applies a mask to the data going in or out of the memory based on Mem_op
*/

module MEM_top

    (
//*************************************************
    input             Clk,
    input             Reset_n,

//*************************************************
    // DATA MEMORY
    output reg [31:0] mem_addr,          // data mem address
    output reg [31:0] mem_wr_data,       // data mem write data, mask applied
    output reg        mem_wr_en,         // data mem write enable
    output reg        mem_rst,           // data mem read port reset

    // PIPELINE OUT
    output reg [31:0] MEM_dout,          // data mem read data, mask applied
    output reg        MEM_MemToReg,      
    output reg [31:0] MEM_ALU_result,    // ALU result, passed through
    output reg        MEM_RegFile_wr_en,
    output reg [4:0]  MEM_Rd_addr,
    output reg        MEM_Exception,


//*************************************************
    input     [31:0]  mem_rd_data,       // data mem read data

    // PIPELINE IN
    input             EX_Mem_wr_en,
    input             EX_Mem_rd_en,
    input [2:0]       EX_Mem_op,         // selects data mem mask 
    input             EX_MemToReg,
    input [31:0]      EX_ALU_result,
    input [31:0]      EX_Rs2_data,
    input             EX_RegFile_wr_en,
    input [4:0]       EX_Rd_addr,
    input             EX_Exception

//*************************************************
    );

// ===========================================================================
//                       Parameters, Registers, and Wires
// ===========================================================================    
    // these are asserted if misaligned load/store detected
    // if asserted, trigger an exception
    reg misaligned_store_i; 
    reg misaligned_load_i;

    reg [2:0] Mem_op_i;

// ===========================================================================
//                              Implementation    
// ===========================================================================

    //*********************************    
    //        PIPELINE REGISTERS
    //*********************************
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            MEM_MemToReg      <= 0;
            MEM_ALU_result    <= 0;
            MEM_RegFile_wr_en <= 0;
            MEM_Rd_addr       <= 0;
            MEM_Exception     <= 0;
        end
        else begin
            MEM_MemToReg      <= EX_MemToReg;
            MEM_ALU_result    <= EX_ALU_result;
            MEM_RegFile_wr_en <= EX_RegFile_wr_en;
            MEM_Rd_addr       <= EX_Rd_addr;
            MEM_Exception     <= EX_Exception || misaligned_load_i || misaligned_store_i; 
        end
    end
    
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) Mem_op_i <= 0;
        else                Mem_op_i <= EX_Mem_op;
    end
    
    //*********************************    
    //        DATA MEM CONTROL
    //*********************************
    always_comb begin
        mem_addr  = (EX_Mem_rd_en || EX_Mem_wr_en) ? EX_ALU_result : 32'bx;
        mem_wr_en = EX_Mem_wr_en;
        mem_rst   = ~Reset_n;
    end
    

    //*********************************    
    //        DATA MEM STORES
    //*********************************
    always_comb begin
        // DEFAULTS:
        mem_wr_data        = EX_Rs2_data;
        misaligned_store_i = 0;
        case(EX_Mem_op)
            `MEM_SW:         mem_wr_data = EX_Rs2_data;
            `MEM_SB: begin
                // determine which byte to write to based on last two bits of address
                case(EX_ALU_result[1:0]) 
                    2'b00:   mem_wr_data = { {24{EX_Rs2_data[7]}},  EX_Rs2_data[7:0] }; 
                    2'b01:   mem_wr_data = { {24{EX_Rs2_data[15]}}, EX_Rs2_data[15:8]};
                    2'b10:   mem_wr_data = { {24{EX_Rs2_data[23]}}, EX_Rs2_data[23:16]};
                    2'b11:   mem_wr_data = { {24{EX_Rs2_data[31]}}, EX_Rs2_data[31:24]};
                endcase
            end  
            `MEM_SH: begin
                case(EX_ALU_result[1:0])
                    2'b00:   mem_wr_data = { {16{EX_Rs2_data[15]}}, EX_Rs2_data[15:0] };
                    2'b10:   mem_wr_data = { {16{EX_Rs2_data[31]}}, EX_Rs2_data[31:16] };
                    default: misaligned_store_i  = 1;
                endcase 
            end   
        endcase
    end

    //*********************************    
    //        DATA MEM LOADS
    //*********************************
    always_comb begin
        // DEFAULTS:
        MEM_dout          = 0;
        misaligned_load_i = 0;

        case(Mem_op_i)
            `MEM_LB: begin
                case(EX_ALU_result[1:0])
                    2'b00:  MEM_dout = { {24{mem_rd_data[7]}},  mem_rd_data[7:0] }; 
                    2'b01:  MEM_dout = { {24{mem_rd_data[15]}}, mem_rd_data[15:8] }; 
                    2'b10:  MEM_dout = { {24{mem_rd_data[23]}}, mem_rd_data[23:16] }; 
                    2'b11:  MEM_dout = { {24{mem_rd_data[31]}}, mem_rd_data[31:24] }; 
                endcase
            end
            `MEM_LB_U: begin
                case(EX_ALU_result[1:0])
                    2'b00:  MEM_dout = { 24'b0,  mem_rd_data[7:0] }; 
                    2'b01:  MEM_dout = { 24'b0, mem_rd_data[15:8] }; 
                    2'b10:  MEM_dout = { 24'b0, mem_rd_data[23:16] }; 
                    2'b11:  MEM_dout = { 24'b0, mem_rd_data[31:24] }; 
                endcase
            end
            `MEM_LH: begin
                case(EX_ALU_result[1:0])  
                    2'b00:   MEM_dout = { {16{mem_rd_data[15]}}, mem_rd_data[15:0] };
                    2'b10:   MEM_dout = { {16{mem_rd_data[31]}}, mem_rd_data[31:16] };
                    default: misaligned_load_i = 1;
                endcase
            end
            `MEM_LH_U: begin
                case(EX_ALU_result[1:0])
                    2'b00:   MEM_dout = { 16'b0, mem_rd_data[15:0] };
                    2'b10:   MEM_dout = { 16'b0, mem_rd_data[31:16]};
                    default: misaligned_load_i = 1;
                endcase
            end
            `MEM_LW: MEM_dout = mem_rd_data;
        endcase
    end

endmodule
