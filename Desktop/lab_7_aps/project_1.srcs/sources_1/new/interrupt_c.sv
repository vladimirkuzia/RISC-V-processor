`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2023 18:44:02
// Design Name: 
// Module Name: interrupt_c
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


//module interrupt_c(
//input logic         clk,
//input logic  [31:0] mie,
//input logic  [31:0] int_req,
//input logic         INT_RST,

//output logic        INT_O,
//output logic [31:0] int_fin,
//output logic [31:0] mcause
//);

//logic [4:0] DC;
//logic [31:0] DC_out;
//logic       en;

//always_ff @(posedge clk) begin
//    if(INT_RST) begin 
//    DC <= 0;
//    end else if (!en) begin
//    DC <= DC + 5'b00001;
//    end else begin DC <= DC;
//  end
//end

//assign mcause = {27'h4000000, DC};

//always_comb begin
//DC_out <= 32'd1 << DC;
//end

module interrupt_c(
    input logic clk_i,
    input logic int_rst_i,
    
    input logic [31:0] mie_i,
    input logic [31:0] int_req_i,
    
    output logic [31:0] mcause_o,
    output logic int_o,
    output logic [31:0] int_fin_o
    );
    
    logic [4:0] count = 0;
    logic [31:0] dc_out;
    logic [31:0] req_mie;
    logic [31:0] dc_int;
    logic int_d;
    logic int_q;
    //counter
    
    always_ff @(posedge clk_i) begin
        if ( int_rst_i ) begin 
            count <= 0;
            
        end else begin
            if (!int_d ) begin
                count <= count + 1;
            end
        end
    end
    // decoder
    always_comb begin
        dc_out <= 32'b1 << count;
    end
    //int req
    assign req_mie = int_req_i & mie_i;
    //int signal
    assign dc_int = req_mie & dc_out;
    // in register int
    assign int_d = | dc_int;
    //register int
    always_ff @(posedge clk_i) begin
        if (int_rst_i) begin
            int_q <= 0;
        end else begin
            int_q <= int_d;
        end
    end
    // interrupt output
    assign int_o = int_q ^ int_d;
    // interrupt finish
    always_comb begin
        for (int i = 0; i < 32; i ++)
        int_fin_o[i] <= dc_int[i] & int_rst_i;
    end
    // mcause output
    assign mcause_o = {27'h0, count};
endmodule


