
`ifdef CUSTOM_DEFINE
    `include "defines.vh"
`endif

// synthesized as FFs

module toast_regfile
    `include "toast_definitions.vh"
    `ifdef CUSTOM_DEFINE
        #(parameter REG_DATA_WIDTH      = `REG_DATA_WIDTH,
          parameter REGFILE_ADDR_WIDTH  = `REGFILE_ADDR_WIDTH
          parameter REGFILE_DEPTH       = `REGFILE_DEPTH
          )
    `else
        #(parameter REG_DATA_WIDTH      = 32,
          parameter REGFILE_ADDR_WIDTH  = 5,
          parameter REGFILE_DEPTH       = 32
          )
    `endif
    
    (
    input  wire                              clk_i,
    input  wire                              resetn_i,

    output wire    [REG_DATA_WIDTH-1 :0]     rs1_data_o,
    output wire    [REG_DATA_WIDTH-1 :0]     rs2_data_o,
    
    input  wire    [REGFILE_ADDR_WIDTH-1 :0] rs1_addr_i, 
    input  wire    [REGFILE_ADDR_WIDTH-1 :0] rs2_addr_i,
 
    input  wire    [REGFILE_ADDR_WIDTH-1 :0] rd_addr_i,    
    input  wire    [REG_DATA_WIDTH-1 :0]     rd_wr_data_i,
    input  wire                              rd_wr_en_i
    );

    


// ===========================================================================
//                    Parameters, Registers, and Wires
// ===========================================================================    
    reg [REG_DATA_WIDTH-1:0] regfile_data [0: REGFILE_DEPTH-1];
    
    wire unused_reset = resetn_i; // for ram32m synthesis
    
// ===========================================================================
//                              Implementation   
// ===========================================================================  
    
    
    // If a register address is about to be written to and the data is needed
    // for the instruction currently in ID, place write data on output bus
    assign rs1_data_o = ((rs1_addr_i == rd_addr_i) &&
                         (rd_addr_i != 0) &&
                         (rd_wr_en_i))  
                         ? rd_wr_data_i : regfile_data[rs1_addr_i];
    
    assign rs2_data_o = ((rs2_addr_i == rd_addr_i) &&
                         (rd_addr_i != 0) &&
                         (rd_wr_en_i))     
                         ? rd_wr_data_i : regfile_data[rs2_addr_i];

    integer i;

    // set all registers to 0 on initialization
    initial begin
        for(i=0; i<REGFILE_DEPTH-1; i=i+1) begin
            regfile_data[i] <= 0;
        end      
    end
    
    // synchronous process for writes
    always@(posedge clk_i) begin
        
        /*
        // FLIP FLOP SYNTHESIS
        if(resetn_i == 1'b0) begin
            for(i=0; i<REGFILE_DEPTH-1; i=i+1) begin
                regfile_data[i] <= 0;
            end       
        end
        else begin    
            if((rd_wr_en_i) && (rd_addr_i != 0)) begin
                regfile_data[rd_addr_i] <= rd_wr_data_i;
            end 
        end //  END FLIP FLOP SYNTHESIS
        */

        // RAM32M SYNTHESIS
        if((rd_wr_en_i) && (rd_addr_i != 0)) begin
                regfile_data[rd_addr_i] <= rd_wr_data_i;
        end // END RAM32M SYNTHESIS

    end 
    
endmodule
