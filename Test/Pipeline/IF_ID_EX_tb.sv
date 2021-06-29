`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2021 01:04:33 PM
// Design Name: 
// Module Name: IF_ID_EX_tb
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

import RV32I_encoding::*;
import RV32I_definitions::*;

module IF_ID_EX_tb();
    
    reg         Clk = 0;
    reg         Reset_n = 0;
    
    wire [31:0] EX_ALU_result;
///////////////////////////////////////////////////////////////////////////    
    
    IF_ID_EX_top DUT(
    .Clk           (Clk),
    .Reset_n       (Reset_n),
    .EX_ALU_result (EX_ALU_result)
    );
    
    
    
    parameter CLK_PERIOD = 20;
    always#(CLK_PERIOD/2) Clk=~Clk;
    
////////////////////////////////////////////////////////////////////////////
  
    
    
    initial begin
        ADDI_gen(5, 0, 12'd1);
        ADDI_gen(6, 0, 12'd2);
        ADD_gen (7, 5, 6);
        
        
        $display("**********************************************");
        $display("*************** TEST BEGIN *******************");
        $display("**********************************************");
        Reset_n = 0;
        #100;
        Reset_n = 1;
        #10;
        
        
        
        $display("**********************************************");
        $display("************** TEST COMPLETE *****************");
        $display("**********************************************");
    end

endmodule

