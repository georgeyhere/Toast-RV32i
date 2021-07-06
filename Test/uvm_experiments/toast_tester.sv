`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2021 07:45:05 PM
// Design Name: 
// Module Name: toast_tester
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
import toast_OOP_package ::*;
import RV32I_definitions ::*;


class tester;
    
    
    virtual toast_bfm bfm;
    
    function new (virtual toast_bfm b); // b?
        bfm = b;
    endfunction : new
    
    
    
    protected function instruction_t get_op(); // instruction_t needs to be defined in a package
        bit [1:0] op_sel;
        op_sel = $random;
            case(op_sel)
                0: return inst_NOP;
                1: return inst_LUI;
                default: return inst_LUI;  
            endcase
    endfunction : get_op
    
    
    
    
    protected function bit [31:0] get_instruction(input instruction_t op); 

        bit [4:0] rd  = $urandom_range(0,31);
        bit [4:0] rs1 = $urandom_range(0,31);
        bit [4:0] rs2 = $urandom_range(0,31);
        bit [19:0] imm20 = $urandom_range(0, (2**20 - 1));

                                      
        case(op)
            inst_NOP: return 32'b0;
            inst_LUI: return {imm20, rd, `OPCODE_LUI};  
            default: return 32'b0;
        endcase
    endfunction : get_instruction;
    
    
    
    protected function bit [31:0] get_expected
    
    endtask : get_expected;
    
    task execute();
        bit [31:0]    instruction;
        instruction_t op_sel;
        
        bfm.reset_Toast();
        op_sel = get_op;
        instruction = get_instruction(op_sel);
    endtask : execute



endclass : tester
