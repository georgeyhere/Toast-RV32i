`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2021 01:23:25 PM
// Design Name: 
// Module Name: PC
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

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

module PC

    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH = `REG_DATA_WIDTH,
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH)  
    `else
        #(parameter REG_DATA_WIDTH = 32,
          parameter IMEM_ADDR_WIDTH = 32)
    `endif
    
    (
    input                            Clk_100MHz, 
    input                            Reset_n,       // synchronous active-low reset
    
    input      [IMEM_ADDR_WIDTH-1:0] PC_branch,     // from MEM, branch destination address 
    input                            PC_source_sel, // select next PC or branch destination address
    input                            PC_stall,      // stall PC
      
    output reg [IMEM_ADDR_WIDTH-1:0] PC_out         // PC address
    );

    

// ===========================================================================
//                              Implementation    
// ===========================================================================     
    initial begin
        PC_out <= 0;
    end
    
    always@(posedge Clk_100MHz) begin
        if(Reset_n == 1'b0) begin
            PC_out <= 0;
        end
        else begin
            if(PC_stall == 1'b1) begin
                PC_out <= PC_out;
            end
            else begin
                if(PC_source_sel == 1'b1) begin 
                    PC_out <= PC_branch;        // if source sel asserted, branch
                end
                else begin
                    PC_out <= PC_out + 4;    // else increment PC on posedge clk
                end
            end 
        end
    end
    
endmodule
