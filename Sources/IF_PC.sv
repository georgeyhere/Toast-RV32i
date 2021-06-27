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
    input                            Clk, 
    input                            Reset_n,       // synchronous active-low reset
    
    input      [IMEM_ADDR_WIDTH-1:0] PC_Branch,     // from MEM, branch destination address 
    input                            PC_Source_sel, // select next PC or branch destination address
    input                            PC_Stall,      // stall PC
      
    output reg [IMEM_ADDR_WIDTH-1:0] PC_Out         // PC address
    );

    

// ===========================================================================
//                              Implementation    
// ===========================================================================     
    initial begin
        PC_Out <= 0;
    end
    
    always@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            PC_Out <= 0;
        end
        else begin
            if(PC_Stall == 1'b1) begin
                PC_Out <= PC_Out;
            end
            else begin
                if(PC_Source_sel == 1'b1) begin 
                    PC_Out <= PC_Branch;        // if source sel asserted, branch
                end
                else begin
                    PC_Out <= PC_Out + 1;    // else increment PC on posedge clk
                end
            end 
        end
    end
    
endmodule
