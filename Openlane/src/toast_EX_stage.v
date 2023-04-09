
// needs to be parameterized
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_EX_stage
    `include "toast_definitions.vh"
    (
    input  wire          clk_i,
    input  wire          resetn_i,
    input  wire          flush_i,  
    output reg           EX_exception_o,

    // pipeline out
    output reg           EX_mem_wr_en_o,     
    output reg           EX_mem_rd_en_o,
    output reg   [3:0]   EX_mem_op_o,
     
    output reg   [31:0]  EX_rs2_data_o,
    output reg           EX_memtoreg_o,
    output reg           EX_rd_wr_en_o,
    output reg   [4:0]   EX_rd_addr_o,
    output reg   [4:0]   EX_rs2_addr_o,

    output reg   [31:0]  EX_alu_result_o,
     
    output reg   [31:0]  EX_pc_dest_o,
    output reg           EX_branch_en_o,      // if asserted loads branch dest to PC

    // pipeline control signals; passed through
    input  wire          ID_mem_wr_en_i,
    input  wire          ID_mem_rd_en_i,
    input  wire  [3:0]   ID_mem_op_i,
    input  wire          ID_memtoreg_i, 
    input  wire          ID_rd_wr_en_i,   
    input  wire  [4:0]   ID_rd_addr_i,
    input  wire  [4:0]   ID_rs2_addr_i,
    
    // for conditional branches
    input  wire  [31:0]  ID_pc_dest_i,     // branch destination from ID
    input  wire  [1:0]   ID_branch_op_i,       // [1] indicates a branch/jump
    input  wire          ID_branch_flag_i,     // indicates to branch on 'set' or 'not set'
    input  wire          ID_jump_en_i,         // indicates a JAL or JALR
    
    // forwarding 
    input  wire  [1:0]   forwardA_i,  
    input  wire  [1:0]   forwardB_i,
    input  wire  [31:0]  WB_rd_wr_data_i,
    
    // ALU control
    input  wire  [1:0]   ID_alu_source_sel_i,  // [op2,op1] if asserted, use imm for operand
    input  wire  [3:0]   ID_alu_ctrl_i,        
    
    
    // ALU operands, muxed into ALU based on control
    input  wire  [31:0]  ID_pc_i,
    input  wire  [31:0]  ID_rs1_data_i,
    input  wire  [31:0]  ID_rs2_data_i,
    input  wire  [31:0]  ID_imm1_i,
    input  wire  [31:0]  ID_imm2_i,

    // exception
    input  wire          ID_exception_i
    );
    

    reg  [31:0] alu_op1, alu_op2;
    wire [31:0] alu_result;
    wire        test_result;
    
    toast_alu alu_i (
    .alu_result_o   (alu_result    ),
    .test_result_o  (test_result   ),
    .alu_ctrl_i     (ID_alu_ctrl_i ),
    .alu_op1_i      (alu_op1       ),
    .alu_op2_i      (alu_op2       )
    );

    // pipeline
    always@(posedge clk_i) begin
        // reset state is the same as NOP, all control signals set to 0
        if((resetn_i == 1'b0) || (flush_i)) begin 
            EX_mem_wr_en_o      <= 0;
            EX_mem_rd_en_o      <= 0;
            EX_mem_op_o         <= 0;
            EX_memtoreg_o       <= 0;
            EX_rd_addr_o        <= 0;
            EX_rd_wr_en_o       <= 0;
            EX_rs2_addr_o       <= 0;
            EX_pc_dest_o        <= (flush_i) ? EX_pc_dest_o : 0;
            EX_rs2_data_o       <= 0;
            EX_exception_o      <= 0;
            EX_alu_result_o     <= 0;
        end
        else begin
            EX_mem_wr_en_o      <= ID_mem_wr_en_i;  
            EX_mem_rd_en_o      <= ID_mem_rd_en_i;  
            EX_mem_op_o         <= ID_mem_op_i;     
            EX_memtoreg_o       <= ID_memtoreg_i;   
            EX_rd_wr_en_o       <= ID_rd_wr_en_i;   
            EX_rd_addr_o        <= ID_rd_addr_i;   
            EX_rs2_addr_o       <= ID_rs2_addr_i;  
            EX_pc_dest_o        <= ID_pc_dest_i;
            EX_rs2_data_o       <= ID_rs2_data_i;   
            EX_exception_o      <= ID_exception_i;  
            EX_alu_result_o     <= alu_result;
        end
    end
    
    
    // ALU source input: op1
    always@* begin
        if(ID_jump_en_i) begin // if JAL or JALR, perform PC+4
            alu_op1 = ID_imm1_i;
        end
        else begin
            case(forwardA_i)
                // no data hazard
                default: begin 
                    alu_op1 = (ID_alu_source_sel_i[1]) ? ID_imm1_i:ID_rs1_data_i;
                end
                
                // ALU op1 forwarded from ALU result of previous cycle
                2'b10: begin
                    alu_op1 = EX_alu_result_o;
                end
                
                // ALU op1 forwarded from read data mem output
                2'b01: begin
                    alu_op1 = WB_rd_wr_data_i;
                end
            endcase
        end
    end
    
    // ALU source input: op2
    always@* begin
        if(ID_jump_en_i == 1) begin // if JAL or JALR, perform PC+4
            alu_op2 = 32'd4;
        end
        else begin
            case(forwardB_i)
                // no data hazard
                default: begin 
                    alu_op2[31:0] = (ID_alu_source_sel_i[0]) ? ID_imm2_i:ID_rs2_data_i;
                end
                
                // ALU op2 forwarded from ALU result of previous cycle
                2'b10: begin
                    alu_op2[31:0] = EX_alu_result_o;
                end
                
                // ALU op2 forwarded from read data mem output
                2'b01: begin
                    alu_op2[31:0] = WB_rd_wr_data_i;
                end
            endcase
        end
    end
    
    
    // branch control
    always@(posedge clk_i) begin
        if(ID_branch_op_i[1]) begin
            if(ID_jump_en_i) begin
                EX_branch_en_o <= 0;
            end
            else begin
                if(ID_branch_flag_i == 1'b0) begin
                    EX_branch_en_o <= (test_result) ? 1:0;            
                end
                else begin
                    EX_branch_en_o <= (test_result) ? 0:1;  
                end
            end 
        end
        else begin
            EX_branch_en_o <= 0;
        end 
    end 

endmodule
