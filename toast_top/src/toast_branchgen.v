
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

module toast_branchgen
    `include "toast_definitions.vh"
    (
    output reg  [31:0] pc_dest_o,

    // control, [1] -> JALR ;  [0] -> JAL, Cond. branch
    input  wire [1:0]  ID_branch_op_i,

    // forwarding inputs
    input  wire [4:0]  ID_rs1_addr_i,
    input  wire [4:0]  EX_rd_addr_i,
    input  wire        EX_rd_wr_en_i,
    
    // operands for pc-relative and reg-offset targets
    input  wire [31:0] ID_pc_i,
    input  wire [31:0] ID_rs1_data_i,
    input  wire [31:0] ID_imm2_i,
    input  wire [31:0] EX_alu_result_i
    );
    
    
    reg  [31:0] regdata;

    // Similarly to how the ID, EX, and MEM stages have some form of 
    // forwarding, branch gen requires it as well.
    // 
    // if:
    // -> a jump target is register offset (JALR)
    // -> there is an instruction in EX that writes to ID_rs1
    // Forward the register data from the EX alu result.

    always@* begin
        if((ID_branch_op_i[1]) &&
           (EX_rd_addr_i == ID_rs1_addr_i) &&
           (EX_rd_wr_en_i))
            regdata = EX_alu_result_i;
        else 
            regdata = ID_rs1_data_i;
    end


    always@* begin
        pc_dest_o = 0;
        case(ID_branch_op_i)
            `PC_RELATIVE: pc_dest_o = ID_pc_i + $signed(ID_imm2_i);
            `REG_OFFSET:  pc_dest_o = regdata + $signed(ID_imm2_i);
        endcase
    end
    
endmodule
