import RV32I_definitions ::*;

module IF_tb();
    
    bit Clk_100MHz;
    bit Reset_n;
    
    reg  [31:0] MEM_PC_branch_dest;
    reg         MEM_PC_source_sel;
    reg         ID_PC_stall;
    
    reg  [31:0] IF_PC_R;
    
    wire [31:0] IF_PC;
    wire [31:0] IF_Instruction;
    
    parameter CLK_PERIOD = 10;
    
    always#(CLK_PERIOD/2) begin
        Clk_100MHz = ~Clk_100MHz;
    end
    
    RV32I_IF DUT(
    .Clk_100MHz(Clk_100MHz),
    .Reset_n(Reset_n),
    .MEM_PC_branch_dest(MEM_PC_branch_dest),
    .MEM_PC_source_sel(MEM_PC_source_sel),
    .ID_PC_stall(ID_PC_stall),
    .IF_PC(IF_PC),
    .IF_Instruction(IF_Instruction)
    );
    
    task Execute_branch;
        input [31:0] Branch_destination;
        input        Stall;
        begin
            @(posedge Clk_100MHz) begin
                if(Stall == 1'b1) begin
                    MEM_PC_source_sel      = 1;
                    ID_PC_stall            = 1;
                    MEM_PC_branch_dest     = Branch_destination;
                    IF_PC_R                = IF_PC;
                    $display("Branching to %0d, with stall", Branch_destination);
                end
                else begin
                    MEM_PC_source_sel      = 1;
                    ID_PC_stall            = 0;
                    MEM_PC_branch_dest     = Branch_destination;
                    $display("Branching to %0d, no stall", Branch_destination);
                end
            end
            @(negedge Clk_100MHz) begin
                if(Stall == 1'b1) begin
                    if(IF_PC == IF_PC_R)
                        $display("PC = %0d | Stall Successful!", Branch_destination);
                    else
                        $display("PC = %0d | Stall Failed!", Branch_destination);
                end
                else begin
                    if(IF_PC == Branch_destination)
                        $display("New PC = %0d | Branch Successful!", Branch_destination);
                    else
                        $display("New PC = %0d | Branch Failed!", Branch_destination);
                end
            end
            @(posedge Clk_100MHz) begin
                MEM_PC_source_sel = 0;
                ID_PC_stall = 0;
                MEM_PC_branch_dest = 0;
                IF_PC_R = 0;
            end
        end
    endtask
    
    initial begin
        Clk_100MHz    = 0;
        Reset_n       = 0;
        MEM_PC_source_sel = 0;
        MEM_PC_branch_dest     = 0;
        ID_PC_stall      = 0;
        IF_PC_R      = 0;
        #100;
        @(posedge Clk_100MHz);
        @(posedge Clk_100MHz);
        Reset_n = 1;
        
        
    end

endmodule