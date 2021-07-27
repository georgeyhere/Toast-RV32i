`timescale 1ns / 1ps
`default_nettype none
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
`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

module toast_IF_stage
    `include "toast_definitions.vh"
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH)
    `else
        #(parameter REG_DATA_WIDTH = 32,
          parameter IMEM_ADDR_WIDTH = 32)
    `endif

    (
    input  wire                             clk_i,
    input  wire                             resetn_i,

    output reg   [IMEM_ADDR_WIDTH-1:0]      IMEM_addr_o,  
    output reg   [REG_DATA_WIDTH-1:0]       IF_instruction_o,
    output reg   [REG_DATA_WIDTH-1:0]       IF_pc_o,           // PC of IF_instruction_o  
  
    input  wire  [REG_DATA_WIDTH-1:0]       IMEM_data_i,       // instruction fetched from IMEM
   
    input  wire                             EX_branch_en_i,    // indicates branch taken (EX)
    input  wire  [REG_DATA_WIDTH-1:0]       EX_pc_dest_i,      // branch dest 
   
    input  wire                             ID_jump_en_i,      // jump taken (ID)
    input  wire  [REG_DATA_WIDTH-1:0]       ID_pc_dest_i,      // jump dest
 
    input  wire                             stall_i,        
    input  wire                             flush_i  
    );


// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    reg  [31:0]  pc_next;

// ===========================================================================
//                              Implementation    
// ===========================================================================    


    // logic to get next PC
    always@* begin
        if      (ID_jump_en_i == 1)    pc_next = ID_pc_dest_i;
        else if (EX_branch_en_i == 1)  pc_next = EX_pc_dest_i;
        else if (stall_i == 1)         pc_next = IMEM_addr_o - 4;
        else                           pc_next = IMEM_addr_o + 4;
    end

    // align fetched instructions with addr by flopping IMEM_addr
    always@(posedge clk_i) begin
        if(resetn_i == 1'b0) begin
            IMEM_addr_o      <= 0;
            IF_pc_o          <= 0;
            
        end
        else begin
            IMEM_addr_o      <= pc_next;
            IF_pc_o          <= (stall_i == 1'b1) ? IF_pc_o : IMEM_addr_o;
            
        end  
    end


    // flush and stall logic
    always@* begin
        if(flush_i == 1'b1) begin
            IF_instruction_o = 0;
        end else begin
            IF_instruction_o = IMEM_data_i;          
        end
    end

endmodule
