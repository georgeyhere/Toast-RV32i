`timescale 1ns / 1ps
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
import RV32I_definitions ::*;

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif


module ID_regfile
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
    input                                Clk,
    input                                Reset_n,
    
    input      [REGFILE_ADDR_WIDTH-1 :0] Rs1_addr,
    input      [REGFILE_ADDR_WIDTH-1 :0] Rs2_addr,
    input      [REGFILE_ADDR_WIDTH-1 :0] Rd_addr,
    
    input      [REG_DATA_WIDTH-1 :0]     Rd_wr_data,
    input                                Rd_wr_en,
    
    output     [REG_DATA_WIDTH-1 :0]     Rs1_data,
    output     [REG_DATA_WIDTH-1 :0]     Rs2_data
    );
    
    reg [31:0] Regfile_data [0: REGFILE_DEPTH-1];
    
    assign Rs1_data = Regfile_data[Rs1_addr];
    assign Rs2_data = Regfile_data[Rs2_addr];

    initial begin
        for(int i=0; i<REGFILE_DEPTH; i++) begin
            Regfile_data[i] <= 0;
        end      
    end
    
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            for(int i=0; i<REGFILE_DEPTH; i++) begin
                Regfile_data[i] <= 0;
            end       
        end
        else begin
            if((Rd_wr_en == 1'b1) && (Rd_addr != 0)) begin
                Regfile_data[Rd_addr] <= Rd_wr_data;
            end
            else begin
                Regfile_data <= Regfile_data;
            end
        end
    end
    
endmodule
