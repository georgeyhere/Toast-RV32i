`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2021 07:34:15 PM
// Design Name: 
// Module Name: toast_bfm
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


interface toast_bfm;
    
    bit Clk;
    bit Reset_n;
    bit [31:0] pc;
    
    initial begin
        Clk = 0;
        pc = 0;
        forever begin
            #10;
            Clk = ~Clk;
        end
    end
    
    task reset_Toast();
        Reset_n = 1'b0;
        pc = 0;
        @(negedge Clk);
        @(negedge Clk);
        Reset_n = 1'b1;
    endtask : reset_Toast
    
    
endinterface
