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

Misaligned memory access is not supported. 
*/

module MEM_top

    (
//*************************************************
    input             Clk,
    input             Reset_n,

//*************************************************
    // DATA MEMORY
    output reg [31:0] mem_addr,          // data mem address
    output reg [3:0]  mem_wr_byte_en,   // byte write enables
    output reg [31:0] mem_wr_data,       // data mem write data
    output reg        mem_rst,           // data mem read port reset

    // PIPELINE OUT
    output reg [31:0] MEM_dout,          // data mem read data, mask applied
    output reg        MEM_MemToReg,      
    output reg [31:0] MEM_ALU_result,    // ALU result, passed through
    output reg        MEM_RegFile_wr_en,
    output reg [4:0]  MEM_Rd_addr,
    output reg        MEM_Exception,


//*************************************************
    input [31:0]      mem_rd_data,       // data mem read data

    // FORWARDING
    input             ForwardM,
    input [31:0]      WB_Rd_data,

    // PIPELINE IN
    input             EX_Mem_wr_en,
    input [3:0]       EX_Mem_op,         // selects data mem mask 
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

    // these are asserted if misaligned store detected
    // if asserted, trigger an exception
    reg misaligned_store_i; 

    reg [31:0] wr_data_i;
    reg [3:0]  byte_en;
// ===========================================================================
//                              Implementation    
// ===========================================================================

    //*********************************    
    //          PIPELINE OUT
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
            MEM_Exception     <= EX_Exception || misaligned_store_i;
        end
    end
    
    
    //*********************************    
    //    DATA MEM CNTRL SIGNALS
    //*********************************
    always_comb begin
        mem_addr       = {EX_ALU_result[31:2], 2'b0}; 
        mem_rst        = ~Reset_n;
        mem_wr_byte_en = (EX_Mem_wr_en == 1'b1) ? byte_en : 4'b0;
    end

    
    //*********************************    
    //    DATA MEM WR SOURCE SELECT
    //*********************************
    always_comb begin
        wr_data_i = (ForwardM) ? MEM_ALU_result : EX_Rs2_data;
    end


    //*********************************    
    //        DATA MEM STORES
    //*********************************
    always_comb begin
        // DEFAULTS:
        mem_wr_data        = 32'bx;
        misaligned_store_i = 0;
        byte_en            = 4'b0;

        case(EX_Mem_op)

            `MEM_SW: begin
                mem_wr_data = wr_data_i;
                byte_en     = 4'b1111;
            end

            `MEM_SB: begin
                // determine which byte to write to based on last two bits of address
                case(EX_ALU_result[1:0]) 
                    2'b00: begin
                        mem_wr_data = { {24{1'b0}}, wr_data_i[7:0] }; 
                        byte_en = 4'b0001;
                    end
                    2'b01: begin
                        mem_wr_data = { {16{1'b0}}, wr_data_i[7:0],  { 8{1'b0}} };
                        byte_en = 4'b0010;
                    end
                    2'b10: begin
                        mem_wr_data = { {8{1'b0}},  wr_data_i[7:0], {16{1'b0}} };
                        byte_en = 4'b0100;
                    end
                    2'b11: begin
                       mem_wr_data = { wr_data_i[7:0], {24{1'b0}} };
                       byte_en = 4'b1000;
                    end
                endcase
            end 

            `MEM_SH: begin
                case(EX_ALU_result[1:0])
                    2'b00: begin
                       mem_wr_data = { {16{1'b0}}, wr_data_i[15:0] };
                       byte_en = 4'b0011;
                    end
                    2'b10: begin
                       mem_wr_data = { wr_data_i[15:0], {16{1'b0}} };
                       byte_en = 4'b1100;
                    end
                    default: misaligned_store_i  = 1;
                endcase 
            end   

        endcase
    end
    
    //*********************************    
    //        DATA MEM LOADS
    //*********************************
    always_comb begin

        case(EX_Mem_op)
            `MEM_LB: begin
                case(EX_ALU_result[1:0])
                    2'b00: MEM_dout = { {24{mem_rd_data[7]}},   mem_rd_data[7:0] }; 
                    2'b01: MEM_dout = { {24{mem_rd_data[15]}},  mem_rd_data[15:8] }; 
                    2'b10: MEM_dout = { {24{mem_rd_data[23]}},  mem_rd_data[23:16] }; 
                    2'b11: MEM_dout = { {24{mem_rd_data[31]}},  mem_rd_data[31:24] }; 
                endcase
            end

            `MEM_LH: begin
                case(EX_ALU_result[1])
                    0: MEM_dout = { {16{mem_rd_data[15]}}, mem_rd_data[15:0] };
                    1: MEM_dout = { {16{mem_rd_data[31]}}, mem_rd_data[31:16] };
                endcase
            end

            `MEM_LB_U: begin
                case(EX_ALU_result[1:0])
                    2'b00: MEM_dout = { {24{1'b0}}, mem_rd_data[7:0] }; 
                    2'b01: MEM_dout = { {24{1'b0}}, mem_rd_data[15:8] }; 
                    2'b10: MEM_dout = { {24{1'b0}}, mem_rd_data[23:16] }; 
                    2'b11: MEM_dout = { {24{1'b0}}, mem_rd_data[31:24] }; 
                endcase

            end
            `MEM_LH_U: begin
                case(EX_ALU_result[1])
                    0: MEM_dout = { {16{1'b0}}, mem_rd_data[15:0] };
                    1: MEM_dout = { {16{1'b0}}, mem_rd_data[31:16] };
                endcase
            end

            `MEM_LW: begin
                MEM_dout = mem_rd_data;
            end

            default: MEM_dout = mem_rd_data;
        endcase
    end
    
endmodule
