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
import RV32I_definitions ::*;

`ifdef CUSTOM_DEFINE
    `include "../defines.vh"
`endif

module IF_top
    
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH
          parameter IMEM_ADDR_WIDTH = `ADDR_DATA_WIDTH,  
          parameter IMEM_DATA_DEPTH = `IMEM_DATA_DEPTH)
    `else
        #(parameter REG_DATA_WIDTH = 32,
          parameter IMEM_ADDR_WIDTH = 10,
          parameter IMEM_DATA_DEPTH = 1024)
    `endif

    (
//*************************************************
    input                        Clk,
    input                        Reset_n,

//*************************************************
    input  [31:0]                IMEM_data,

    input  [31:0]                EX_PC_Branch_dest,
    input                        EX_PC_Branch,
   
    input  [31:0]                ID_PC_dest,
    input                        ID_Jump,
    
    input                        IF_Stall,
    input                        IF_Flush,

//*************************************************   
    output reg [31:0]            IMEM_addr,
    output reg [31:0]            IF_PC,
    output reg [31:0]            IF_Instruction     

//*************************************************
    );


// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    wire [31:0]  Instruction;
    wire [31:0]  IMEM_addr_i;

    reg [31:0] PC_Next;
// ===========================================================================
//                              Instantiation    
// ===========================================================================    
    /*
    PC RV32I_PC (
    .Clk               (Clk),
    .Reset_n           (Reset_n),
    .PC_Stall          (IF_Stall),
    .ID_Jump           (ID_Jump),
    .ID_PC_dest        (ID_PC_dest),
    .EX_PC_Branch      (EX_PC_Branch),
    .EX_PC_Branch_dest (EX_PC_Branch_dest),
    .PC_Out            (IMEM_addr)
    );
    */
// ===========================================================================
//                              Implementation    
// ===========================================================================    
    /*
--------------------------------------------------

IMEM_addr placed      Instrn corresponding
 on output bus        to Cycle 1 IMEM_addr
                      placed on IMEM_data
                        
                      IF_PC gets IMEM_addr
                          of Cycle 1

    Cycle 1:                Cycle 2:
--------------------------------------------------
    */


    always_comb begin
        if(ID_Jump == 1)            PC_Next = ID_PC_dest;
        else if (EX_PC_Branch == 1) PC_Next = EX_PC_Branch_dest;
        else if (IF_Stall == 1)     PC_Next = IMEM_addr - 4;
        else                        PC_Next = IMEM_addr + 4;
    end

    // align fetched instructions with addr by flopping IMEM_addr
    always_ff@(posedge Clk) begin
        if(Reset_n == 1'b0) begin
            IMEM_addr <= 0;
            IF_PC     <= 0;
        end
        else begin
            IMEM_addr <= PC_Next;
            IF_PC     <= (IF_Stall) ? IF_PC:IMEM_addr; 
        end  
    end

    // if flush is asserted insert a nop
    always_comb begin
        if(IF_Flush == 1'b1) begin
            IF_Instruction = 0;
        end
        else begin
            if(IF_Stall == 1'b1) begin
                IF_Instruction = IF_Instruction;
            end
            else begin
                IF_Instruction = IMEM_data;
            end               
        end
    end
endmodule
