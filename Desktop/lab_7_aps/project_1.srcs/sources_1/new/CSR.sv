`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2023 18:14:25
// Design Name: 
// Module Name: CSR
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


module CSR(
    input  logic        clk,
    input  logic [31:0] mcause,
    input  logic [31:0] PC,
    input  logic [11:0] A,
    input  logic [31:0] WD,
    input  logic [2:0]  OP,
    output logic [31:0] mie, 
    output logic [31:0] mtvec,
    output logic [31:0] mepc,
    output logic [31:0] RD
 );
 logic [31:0] o_4_1;
 logic [31:0] pr_to_040;
 logic [31:0] pr_to_042;
 logic [31:0] pr_to_mepc;
 logic [31:0] mie_o;
 logic [31:0]mcause_reg;
 logic en_mie;
 logic en_mtvec;
 logic en_040;
 logic en_mepc;
 logic en_042;
   
always_comb begin
   case(OP[1:0])
   2'b00: o_4_1 <= 32'b0;
   2'b01: o_4_1 <= WD;
   2'b10: o_4_1 <= ~WD && RD;
   2'b11: o_4_1 <= WD || RD;
   endcase
end
 
always_comb begin
en_mie <= 0;
en_mtvec <= 0;
en_040 <= 0;
en_mepc <= 0;
en_042 <= 0;
   case(A)
   12'h004:en_mie <= OP[1] || OP[0];
   12'h005:en_mtvec <= OP[1] || OP[0];
   12'h040:en_040 <= OP[1] || OP[0];
   12'h041:en_mepc <= OP[1] || OP[0];
   12'h042:en_042 <= OP[1] || OP[0];
   endcase
end

    always_comb begin
        case(OP[2])
            1: pr_to_mepc <= PC;
            0: pr_to_mepc <= o_4_1;
        endcase
    end
    
    always_comb begin
        case(OP[2])
            1: pr_to_042 <= mcause;
            0: pr_to_042 <= o_4_1;
        endcase
    end

always_ff @(posedge clk) begin
   if(en_mie) mie <= o_4_1;
   if(en_mtvec) mtvec <= o_4_1;
   if(en_040) pr_to_040 <= o_4_1;
   if(en_mepc || OP[2]) mepc <=  pr_to_mepc;
   if(en_042 || OP[2]) mcause_reg <= pr_to_042;
end
always_comb begin
   case(A)
   12'h004: RD <= mie;
   12'h005: RD <= mtvec;
   12'h040: RD <= pr_to_040;
   12'h041: RD <= mepc;
   12'h042: RD <= mcause_reg;
   endcase
end

endmodule
