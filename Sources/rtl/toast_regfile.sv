`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2021 10:56:00 AM
// Design Name: 
// Module Name: ID_regfile
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

// synthesized as FFs

module toast_regfile
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH      = `REG_DATA_WIDTH,
          parameter REGFILE_ADDR_WIDTH  = `REGFILE_ADDR_WIDTH
          parameter REGFILE_DEPTH       = `REGFILE_DEPTH
          )
    `else
        #(parameter REG_DATA_WIDTH      = 32,
          parameter REGFILE_ADDR_WIDTH  = 5,
          parameter REGFILE_DEPTH       = 32
          )
    `endif
    
    (
    input   wire logic                        clk_i,
    input   wire logic                        resetn_i,

    output  logic   [REG_DATA_WIDTH-1 :0]     rs1_data_o,
    output  logic   [REG_DATA_WIDTH-1 :0]     rs2_data_o,
    
    input   wire logic   [REGFILE_ADDR_WIDTH-1 :0] rs1_addr_i, 
    input   wire logic   [REGFILE_ADDR_WIDTH-1 :0] rs2_addr_i,
 
    input   wire logic   [REGFILE_ADDR_WIDTH-1 :0] rd_addr_i,    
    input   wire logic   [REG_DATA_WIDTH-1 :0]     rd_wr_data_i,
    input   wire logic                             rd_wr_en_i
    );

    


// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    reg [REG_DATA_WIDTH-1:0] regfile_data [0: REGFILE_DEPTH-1];
    
    
    
// ===========================================================================
//                              Implementation   
// ===========================================================================  
    
    
    // If a register address is about to be written to and the data is needed
    // for the instruction currently in ID, place write data on output bus
    assign rs1_data_o = ((rs1_addr_i == rd_addr_i) &&
                         (rd_wr_en_i == 1'b1))  
                         ? rd_wr_data_i : regfile_data[rs1_addr_i];
    
    assign rs2_data_o = ((rs2_addr_i == rd_addr_i) &&
                         (rd_wr_en_i == 1'b1))     
                         ? rd_wr_data_i : regfile_data[rs2_addr_i];



    // set all registers to 0 on initialization
    initial begin
        for(int i=0; i<REGFILE_DEPTH-1; i++) begin
            regfile_data[i] <= 0;
        end      
    end
    
    // synchronous process for writes
    always_ff@(posedge clk_i) begin
        if(resetn_i == 1'b0) begin
            for(int i=0; i<REGFILE_DEPTH-1; i++) begin
                regfile_data[i] <= 0;
            end       
        end
        else begin
            if((rd_wr_en_i == 1'b1) && (rd_addr_i != 0)) begin
                regfile_data[rd_addr_i] <= rd_wr_data_i;
            end
            else begin
                regfile_data <= regfile_data;
            end
        end
    end
    
endmodule
