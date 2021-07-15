`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2021 01:40:44 PM
// Design Name: 
// Module Name: IMEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// IMEM is an asynchronous ROM initialized from the contents of IMEM.data
//
//
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

module IMEM
    
    `ifdef CUSTOM_DEFINE
        #(parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH,  
          parameter IMEM_DATA_DEPTH = `IMEM_DATA_DEPTH)
    `else
        #(parameter IMEM_ADDR_WIDTH = 32,
          parameter IMEM_DATA_DEPTH = 2048)
    `endif
    
    (
    input        [IMEM_ADDR_WIDTH-1 :0] IMEM_address, 
    output reg   [31 :0] Instruction
    );
    
// ===========================================================================
// 			          Parameters, Registers, and Wires
// ===========================================================================    
    reg [31:0] Instruction_data [0:IMEM_DATA_DEPTH-1]; // used to read from .data
    reg [31:0] HexFile          [0:IMEM_DATA_DEPTH-1];

// ===========================================================================
//                              Implementation    
// ===========================================================================
    
    
    initial begin
<<<<<<< Updated upstream
        $readmemh("add.mem", HexFile);
=======
        //$readmemh("add.mem", HexFile);
        //$readmemh("addi.mem", HexFile);
        //$readmemh("and.mem", HexFile);
        $readmemh("auipc.mem", HexFile);
>>>>>>> Stashed changes
        for (int i=0; i<(IMEM_DATA_DEPTH/4); i++) begin
            Instruction_data[i*4] = HexFile[i];
        end
    end
    
    
    
    
    always@* begin
        Instruction = Instruction_data[IMEM_address];
    end
    
endmodule
