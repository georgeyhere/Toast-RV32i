`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2021 01:51:21 PM
// Design Name: 
// Module Name: RV32I_IF
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

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

module toast_IF_stage
    
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH)
    `else
        #(parameter REG_DATA_WIDTH = 32,
          parameter IMEM_ADDR_WIDTH = 32)
    `endif

    (
    input  logic                            clk_i,
    input  logic                            resetn_i,

    output logic [IMEM_ADDR_WIDTH-1:0]      IMEM_addr_o,  
    output logic [REG_DATA_WIDTH-1:0]       IF_instruction_o,
    output logic [REG_DATA_WIDTH-1:0]       IF_pc_o,           // PC of IF_instruction_o  

    input  logic [REG_DATA_WIDTH-1:0]       IMEM_data_i,    // instruction fetched from IMEM
 
    input  logic                            EX_branch_en_i,    // indicates branch taken (EX)
    input  logic [REG_DATA_WIDTH-1:0]       EX_pc_dest_i,  // branch dest 
 
    input  logic                            ID_jump_en_i,      // jump taken (ID)
    input  logic [REG_DATA_WIDTH-1:0]       ID_pc_dest_i,    // jump dest
 
    input  logic                            stall_i,        
    input  logic                            flush_i  
    );


// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    logic [31:0]  pc_next;
    logic [31:0]  prev_instruction;

// ===========================================================================
//                              Implementation    
// ===========================================================================    


    // logic to get next PC
    always_comb begin
        if      (ID_jump_en_i == 1)    pc_next = ID_pc_dest_i;
        else if (EX_branch_en_i == 1)  pc_next = EX_pc_dest_i;
        else if (stall_i == 1)         pc_next = IMEM_addr_o - 4;
        else                           pc_next = IMEM_addr_o + 4;
    end

    // align fetched instructions with addr by flopping IMEM_addr
    always_ff@(posedge clk_i) begin
        if(resetn_i == 1'b0) begin
            IMEM_addr_o      <= 0;
            IF_pc_o          <= 0;
            prev_instruction <= 0;
        end
        else begin
            IMEM_addr_o      <= pc_next;
            IF_pc_o          <= (stall_i == 1'b1) ? IF_pc_o : IMEM_addr_o; 
            prev_instruction <= IF_instruction_o;
        end  
    end

    // flush and stall logic
    always_comb begin
        if(flush_i == 1'b1) begin
            IF_instruction_o = 0;
        end else if(stall_i == 1'b1) begin
            IF_instruction_o = prev_instruction;
        end else begin
            IF_instruction_o = IMEM_data_i;          
        end
    end

endmodule
