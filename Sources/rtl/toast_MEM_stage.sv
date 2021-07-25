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

import toast_def_pkg ::*;
/*
Handles reads and writes to data memory. Data memory is assumed to be
 a true dual-port RAM. 

Misaligned memory access is not supported. 
*/

module toast_MEM_stage

    (
    input  logic             clk_i,
    input  logic             resetn_i,

    // TO DATA MEMORY
    output logic [31:0]           DMEM_addr_o,       // data mem address
    output logic [3:0]            DMEM_wr_byte_en_o, // byte write enables
    output logic [31:0]           DMEM_wr_data_o,    // data mem write data
    output logic                  DMEM_rst_o,        // data mem read port reset
          
    // PIPELINE OUT          
    output logic [31:0]           MEM_dout_o,        // data mem read data, mask applied
    output logic                  MEM_memtoreg_o,    
    output logic [31:0]           MEM_alu_result_o,  // ALU result, passed through
    output logic                  MEM_rd_wr_en_o,    // passed through from EX, used for forwarding/stall logic
    output logic [4:0]            MEM_rd_addr_o,     // passed through from EX
    output logic                  MEM_exception_o,   // triggered on misaligned store

    // FROM DATA MEMORY
    input  logic  [31:0]      DMEM_rd_data_i,    // data mem read data

    // FORWARDING
    input  logic              ForwardM_i,        // forward write data from MEM/WB

    // PIPELINE IN
    input  logic              EX_mem_wr_en_i,    // enables data mem write
    input  logic  [3:0]       EX_mem_op_i,       // select data mem mask, flopped locally for loads 
    input  logic              EX_memtoreg_i,     // passed through, enables WB to regfile
    input  logic  [31:0]      EX_alu_result_i,   // used for memory write/read address
    input  logic  [31:0]      EX_rs2_data_i,     // data to be copied to data mem on store instrn

    input  logic              EX_rd_wr_en_i,     // passed through, enables write to regfile[rd]
    input  logic  [4:0]       EX_rd_addr_i,      // passed through
    input  logic              EX_exception_i     // passed through
    );
    

// ===========================================================================
//                       Parameters, Registers, and Wires
// ===========================================================================    

    // these are asserted if misaligned store detected
    // if asserted, trigger an exception
    logic        misaligned_store; 

    logic [31:0] wr_data;
    logic [3:0]  byte_en;
    logic [3:0]  mem_op;
    logic [1:0]  byte_addr;

// ===========================================================================
//                              Implementation    
// ===========================================================================

    //*********************************    
    //          PIPELINE OUT
    //*********************************
    always_ff@(posedge clk_i) begin
        if(resetn_i == 1'b0) begin
            MEM_memtoreg_o      <= 0;
            MEM_alu_result_o    <= 0;
            MEM_rd_wr_en_o <= 0;
            MEM_rd_addr_o       <= 0;
            MEM_exception_o     <= 0;
        end
        else begin
            MEM_memtoreg_o      <= EX_memtoreg_i;
            MEM_alu_result_o    <= EX_alu_result_i;
            MEM_rd_wr_en_o <= EX_rd_wr_en_i;
            MEM_rd_addr_o       <= EX_rd_addr_i;
            MEM_exception_o     <= EX_exception_i || misaligned_store;
        end
    end
    
    
    //*********************************    
    //    DATA MEM CNTRL SIGNALS
    //*********************************
    always_comb begin
        DMEM_addr_o       = {EX_alu_result_i[31:2], 2'b0}; 
        DMEM_rst_o        = ~resetn_i;
        DMEM_wr_byte_en_o = (EX_mem_wr_en_i == 1'b1) ? byte_en : 4'b0;
    end

    
    //*********************************    
    //    DATA MEM WR SOURCE SELECT
    //*********************************
    always_comb begin
        wr_data = (ForwardM_i) ? MEM_alu_result_o : EX_rs2_data_i;
    end


    //*********************************    
    //        DATA MEM STORES
    //*********************************
    always_comb begin
        // DEFAULTS:
        DMEM_wr_data_o        = 32'bx;
        misaligned_store = 0;
        byte_en            = 4'b0;

        case(EX_mem_op_i)

            `MEM_SW: begin
                DMEM_wr_data_o = wr_data;
                byte_en     = 4'b1111;
            end

            `MEM_SB: begin
                // determine which byte to write to based on last two bits of address
                case(EX_alu_result_i[1:0]) 
                    2'b00: begin
                        DMEM_wr_data_o = { {24{1'b0}}, wr_data[7:0] }; 
                        byte_en = 4'b0001;
                    end
                    2'b01: begin
                        DMEM_wr_data_o = { {16{1'b0}}, wr_data[7:0],  { 8{1'b0}} };
                        byte_en = 4'b0010;
                    end
                    2'b10: begin
                        DMEM_wr_data_o = { {8{1'b0}},  wr_data[7:0], {16{1'b0}} };
                        byte_en = 4'b0100;
                    end
                    2'b11: begin
                       DMEM_wr_data_o = { wr_data[7:0], {24{1'b0}} };
                       byte_en = 4'b1000;
                    end
                endcase
            end 

            `MEM_SH: begin
                case(EX_alu_result_i[1:0])
                    2'b00: begin
                       DMEM_wr_data_o = { {16{1'b0}}, wr_data[15:0] };
                       byte_en = 4'b0011;
                    end
                    2'b10: begin
                       DMEM_wr_data_o = { wr_data[15:0], {16{1'b0}} };
                       byte_en = 4'b1100;
                    end
                    default: misaligned_store  = 1;
                endcase 
            end   

        endcase
    end
    

    //*********************************    
    //        DATA MEM LOADS
    //*********************************

    // loads have a one clock latency 
    // need to flop: 1) memory operation and 2) byte address

    // flop mem_op and EX_alu_result_i 
    always_ff @(posedge clk_i) begin
        if(resetn_i == 1'b0) begin
            mem_op    <= 0;
            byte_addr <= 0;
        end else begin
            mem_op    <= EX_mem_op_i; 
            byte_addr <= EX_alu_result_i[1:0];
        end         
    end

    // combinatorial logic to 'snipe' the bits we want
    always_comb begin
        case(mem_op)
            `MEM_LB: begin
                case(byte_addr)
                    2'b00: MEM_dout_o = { {24{DMEM_rd_data_i[7]}},   DMEM_rd_data_i[7:0] }; 
                    2'b01: MEM_dout_o = { {24{DMEM_rd_data_i[15]}},  DMEM_rd_data_i[15:8] }; 
                    2'b10: MEM_dout_o = { {24{DMEM_rd_data_i[23]}},  DMEM_rd_data_i[23:16] }; 
                    2'b11: MEM_dout_o = { {24{DMEM_rd_data_i[31]}},  DMEM_rd_data_i[31:24] }; 
                endcase
            end

            `MEM_LH: begin
                case(byte_addr[1])
                    0: MEM_dout_o = { {16{DMEM_rd_data_i[15]}}, DMEM_rd_data_i[15:0] };
                    1: MEM_dout_o = { {16{DMEM_rd_data_i[31]}}, DMEM_rd_data_i[31:16] };
                endcase
            end

            `MEM_LB_U: begin
                case(byte_addr)
                    2'b00: MEM_dout_o = { {24{1'b0}}, DMEM_rd_data_i[7:0] }; 
                    2'b01: MEM_dout_o = { {24{1'b0}}, DMEM_rd_data_i[15:8] }; 
                    2'b10: MEM_dout_o = { {24{1'b0}}, DMEM_rd_data_i[23:16] }; 
                    2'b11: MEM_dout_o = { {24{1'b0}}, DMEM_rd_data_i[31:24] }; 
                endcase

            end
            `MEM_LH_U: begin
                case(byte_addr[1])
                    0: MEM_dout_o = { {16{1'b0}}, DMEM_rd_data_i[15:0] };
                    1: MEM_dout_o = { {16{1'b0}}, DMEM_rd_data_i[31:16] };
                endcase
            end

            `MEM_LW: begin
                MEM_dout_o = DMEM_rd_data_i;
            end

            default: MEM_dout_o = DMEM_rd_data_i;
        endcase
    end
    
endmodule
