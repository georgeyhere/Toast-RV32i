
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_alu
    `include "toast_definitions.vh"
    (
    output reg  [31:0]     alu_result_o, 
    output reg             test_result_o,

    input  wire [3:0]      alu_ctrl_i,  // controls ALU operation for current instrn
    input  wire [31:0]     alu_op1_i,   // operand 1
    input  wire [31:0]     alu_op2_i    // operand 2
    );

    // shamt -> alu_op2[4:0] 
   
    always@* begin
        // DEFAULT
        alu_result_o = 0;

        case(alu_ctrl_i)
            // arithmetic
            `ALU_ADD:  alu_result_o = alu_op1_i + alu_op2_i;
            `ALU_SUB:  alu_result_o = alu_op1_i - alu_op2_i;
            `ALU_AND:  alu_result_o = alu_op1_i & alu_op2_i;
            `ALU_OR:   alu_result_o = alu_op1_i | alu_op2_i;
            `ALU_XOR:  alu_result_o = alu_op1_i ^ alu_op2_i;
            
            //shifts
            `ALU_SLL:  alu_result_o = alu_op1_i << alu_op2_i[4:0]; 
            `ALU_SRL:  alu_result_o = alu_op1_i >> alu_op2_i[4:0]; 
            `ALU_SRA:  alu_result_o = $signed(alu_op1_i) >>> alu_op2_i[4:0]; 
            
            /*
            // test
            `ALU_SEQ:  alu_result_o = (alu_op1_i == alu_op2_i) ? 1:0; 
            `ALU_SLT:  alu_result_o = ($signed(alu_op1_i) < $signed(alu_op2_i)) ? 1:0; 
            `ALU_SLTU: alu_result_o = (alu_op1_i < alu_op2_i) ? 1:0; 
            */
            default: alu_result_o = 0;
        endcase
    end

    always@* begin
        // DEFAULT
        test_result_o = 0;
        case(alu_ctrl_i) 
            `ALU_SEQ:  test_result_o = (alu_op1_i == alu_op2_i) ? 1:0; 
            `ALU_SLT:  test_result_o = ($signed(alu_op1_i) < $signed(alu_op2_i)) ? 1:0; 
            `ALU_SLTU: test_result_o = (alu_op1_i < alu_op2_i) ? 1:0; 
        endcase
    end
    
endmodule
