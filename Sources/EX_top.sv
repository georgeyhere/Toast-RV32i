`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2021 07:36:05 PM
// Design Name: 
// Module Name: EX_top
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


module EX_top


    (
    input             Clk,
    input             Reset_n,
    
    //*************************************************
    // Pipeline 
    
    output reg        EX_Mem_wr_en,
    output reg        EX_Mem_rd_en,
    output reg [2:0]  EX_Mem_op,
    output reg [31:0] EX_Rs2_data,
    output reg        EX_MemToReg,
    
    output reg [31:0] EX_ALU_result,
    
    output reg [31:0] EX_PC_Branch_dest,
    output reg        EX_PC_Branch,      // if asserted loads branch dest to PC
    
    output reg        EX_RegFile_wr_en,
    output reg [4:0]  EX_Rd_addr,
    
    //*************************************************
    input             EX_Flush,
    
    input             ID_Mem_wr_en,
    input             ID_Mem_rd_en,
    input      [2:0]  ID_Mem_op,
    input             ID_MemToReg, 
    
    input      [31:0] ID_PC_dest,
    
    
    input      [1:0]  ID_Branch_op,   // [1] indicates a branch/jump
    input             ID_Branch_flag, // indicates to branch on 'set' or 'not set'
    input             ID_Jump,        // indicates a jump
    
    input      [1:0]  ForwardA,
    input      [1:0]  ForwardB,
    input      [31:0] WB_Rd_data,
 
    input      [1:0]  ID_ALU_source_sel,
    input      [3:0]  ID_ALU_op,
    
    input             ID_RegFile_wr_en,
    input      [4:0]  ID_Rd_addr,
    
    input      [31:0] ID_PC,
    input      [31:0] ID_Rs1_data,
    input      [31:0] ID_Rs2_data,
    input      [31:0] ID_Immediate_1,
    input      [31:0] ID_Immediate_2 // used for branch gen 
    );
    
    reg  [31:0] ALU_op1, ALU_op2;
    wire [31:0] ALU_result;
    
    reg         PC_source_sel;
    
    
    EX_ALU ALU_inst(
    .ALU_op     (ID_ALU_op),
    .ALU_op1    (ALU_op1),
    .ALU_op2    (ALU_op2),
    .ALU_result (ALU_result) 
    );
    

    // pipeline
    always_ff@(posedge Clk) begin
        // reset state is the same as NOP, all control signals set to 0
        if((Reset_n == 1'b0) || (EX_Flush == 1'b1)) begin 
            EX_Mem_wr_en      <= 0;
            EX_Mem_rd_en      <= 0;
            EX_Mem_op         <= 0;
            EX_MemToReg       <= 0;
            EX_Rd_addr        <= 0;
            EX_ALU_result     <= 0;
            EX_PC_Branch_dest <= 0;
            EX_PC_Branch      <= 0;
            EX_RegFile_wr_en  <= 0;
            EX_Rs2_data       <= 0;
        end
        else begin
            EX_Mem_wr_en      <= ID_Mem_wr_en;
            EX_Mem_rd_en      <= ID_Mem_rd_en;
            EX_Mem_op         <= ID_Mem_op;
            EX_MemToReg       <= ID_MemToReg;
            EX_RegFile_wr_en  <= ID_RegFile_wr_en;
            EX_Rd_addr        <= ID_Rd_addr;
            EX_PC_Branch_dest <= ID_PC_dest;
            EX_ALU_result     <= ALU_result;
            EX_PC_Branch      <= PC_source_sel;
            EX_Rs2_data       <= ID_Rs2_data;
        end
    end
    
    
    // ALU source input: op1
    always_comb begin
        if(ID_Jump == 1) begin // if JAL or JALR, perform PC+1
            ALU_op1 = ID_Immediate_1;
        end
        else begin
            case(ForwardA)
                // no data hazard
                default: begin 
                    ALU_op1 = (ID_ALU_source_sel[1] == 1'b1) ? ID_Immediate_1:ID_Rs1_data;
                end
                
                // ALU op1 forwarded from ALU result of previous cycle
                2'b10: begin
                    ALU_op1 = EX_ALU_result;
                end
                
                // ALU op1 forwarded from read data mem output
                2'b01: begin
                    ALU_op1 = WB_Rd_data;
                end
            endcase
        end
    end
    
    // ALU source input: op2
    always_comb begin
        if(ID_Jump == 1) begin // if JAL or JALR, perform PC+1
            ALU_op2 = 32'd1;
        end
        else begin
            case(ForwardB)
                // no data hazard
                default: begin 
                    ALU_op2 = (ID_ALU_source_sel[0] == 1'b1) ? ID_Immediate_2:ID_Rs2_data;
                end
                
                // ALU op2 forwarded from ALU result of previous cycle
                2'b10: begin
                    ALU_op2 = EX_ALU_result;
                end
                
                // ALU op2 forwarded from read data mem output
                2'b01: begin
                    ALU_op2 = WB_Rd_data;
                end
            endcase
        end
    end
    
    
    // branch control
    always_comb begin
        if(ID_Branch_op[1] == 1'b1) begin
            if(ID_Jump == 1'b1) begin
                PC_source_sel = 1;
            end
            else begin
                if(ID_Branch_flag == 1'b0) begin
                    PC_source_sel = (ALU_result == 1) ? 1:0;            
                end
                else begin
                    PC_source_sel = (ALU_result == 1) ? 0:1;  
                end
            end // end if(ID_Jump)
        end
        else begin
            PC_source_sel = 0;
        end // end if(branch_jump)
    end // end always_ff
    
endmodule