`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 22:30:43
// Design Name: 
// Module Name: riscv_unit
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

module riscv_unit#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)(
    input  logic        clk_i,
    input  logic        resetn_i,
   // input  logic [31:0] int_req_i,
    //output logic  [31:0] PC,
    //output logic [31:0]mem_wd_o,
   // output logic [31:0] data_addr_o,
   // output logic [31:0] instr_addr_o,
   // output logic [31:0] MEM_RD_I,
    //output logic [31:0] int_fin,
    // Входы и выходы периферии
    input  logic [15:0] sw_i,       // Переключатели
    output logic [15:0] led_o      // Светодиоды
    );
    
    logic [31:0] instr_i;
    logic [31:0] mem_rd_i;
    
    //memory protocol
    logic [31:0] data_rdata;
    logic data_req;
    logic data_we;        
    logic [3:0] data_be;   
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic [31:0] mcause;
    logic [31:0] mie;
    logic [31:0] instr_addr_o;
    
    logic         interrupt;
    logic         INT_RST1;
    logic         reg_dev;
    logic [255:0] one_hot_o;
    logic [31:0]  in_1_o;
    logic [31:0]  rd_data;
    logic [31:0]  rd_sw;
    logic [31:0]  rd_led;
    
    
   // assign MEM_RD_I = mem_rd_i;
    
   
    logic stall;
    logic mem_we_o;
    logic mem_req_o;
    logic stall_i; 
    logic sysclk, rst;
    
    assign stall_i = ~stall & mem_req_o;
    
 always_comb begin 
    case(data_addr[31:24])
    8'd0: one_hot_o <= {{253{1'b0}}, 3'b001};
    8'd1: one_hot_o <= {{253{1'b0}}, 3'b010};
    8'd2: one_hot_o <= {{253{1'b0}}, 3'b100};
    endcase
 end
 
  always_comb begin 
    case(data_addr[31:24])
    8'd0: in_1_o <= rd_data;
    8'd1: in_1_o <= rd_sw;
    8'd2: in_1_o <= rd_led;
    endcase
 end
   
    sys_clk_rst_gen divider(.ex_clk_i(clk_i),
                            .ex_areset_n_i(resetn_i),
                            .div_i(10),
                            .sys_clk_o(sysclk),
                            .sys_reset_o(rst)
                            ); 
   
    riscv_core core(.clk_i(sysclk),
                    .rst_i(!rst),
                    
                    // interrupt controller
                    .mcause_i(mcause),
                    .int_i(interrupt),
                    .mie_o(mie),
                    .int_rst_o(INT_RST1),
                    
                    // instruction memory interface
                    .instr_i(instr_i),
                    .instr_addr_o(instr_addr_o),
                    
                    //memory protocol
                    .data_rdata_i(in_1_o),
                    .data_req_o(data_req),
                    .data_we_o(data_we),
                    .data_be_o(data_be),
                    .data_addr_o(data_addr),
                    .data_wdata_o(data_wdata)
                    );
                    
    miriscv_ram rm(
                    .clk_i(sysclk),
                    .rst_n_i(!rst),
                    .instr_rdata_o(instr_i),
                    .instr_addr_i(instr_addr_o),
                    .data_rdata_o(rd_data),
                    .data_req_i(data_req && one_hot_o[0]),
                    .data_we_i(data_we),
                    .data_be_i(data_be),
                    .data_addr_i({8'd0,data_addr[23:0]}),
                    .data_wdata_i(data_wdata)
    );
    interrupt_c in(.clk_i(sysclk),
                   .int_rst_i(INT_RST1),
                   .mie_i(mie),
                   .int_req_i(),                
                   .mcause_o(mcause),
                   .int_o(interrupt),
                   .int_fin_o()       
    );
    sw_sb_ctrl sw(.clk_i(sysclk),
                  .rst_i(rst),
                  .req_i(data_req && one_hot_o[1]),
                  .write_enable_i(data_we),
                  .addr_i({8'd0,data_addr[23:0]}),
                  .write_data_i(data_wdata),
                  .read_data_o(rd_sw),
                  .sw_i(sw_i)
    );
    led_sb_ctrl led(.clk_i(sysclk),
                 .rst_i(rst),
                 .req_i(data_req && one_hot_o[2]),
                 .write_enable_i(data_we),
                 .addr_i({8'd0,data_addr[23:0]}),
                 .write_data_i(data_wdata),
                 .read_data_o(rd_sb),
                 .led_o(led_o)
    );
endmodule

