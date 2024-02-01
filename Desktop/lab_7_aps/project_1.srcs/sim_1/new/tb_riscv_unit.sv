`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIET
// Engineer: Nikita Bulavin
// 
// Create Date:    
// Design Name: 
// Module Name:    tb_riscv_unit
// Project Name:   RISCV_practicum
// Target Devices: Nexys A7-100T
// Tool Versions: 
// Description: tb for datapath
// 
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module tb_riscv_unit();

    reg clk_i;
    reg rst_i;
    //wire [31:0] PC;
    wire [31:0] mem_wd_o;
    wire [31:0] data_addr_o;
    wire [31:0] instr_addr_o;
    wire [31:0] MEM_RD_I;
    
    riscv_unit unit(
    clk_i,
    rst_i,
    //PC,
    mem_wd_o,
    data_addr_o,
    instr_addr_o,
    MEM_RD_I
    );

    initial clk_i = 0;
    always #10 clk_i = ~clk_i;
    initial begin
        $display( "\nStart test: \n\n==========================\nCLICK THE BUTTON 'Run All'\n==========================\n"); $stop();
        rst_i = 1;
        #20;
        rst_i = 0;
        #500;
        $display("\n The test is over \n See the internal signals of the module on the waveform \n");
        $finish;
    end

stall: assert property (
  @(posedge clk_i)
  disable iff ( rst_i )
  (unit.mem_req_o) |-> (unit.stall_i) |-> ##1 (!unit.stall_i & unit.mem_req_o)
  
)else $error("\n================================================\nThe realisation of the STALL signal is INCORRECT\n================================================\n");

endmodule