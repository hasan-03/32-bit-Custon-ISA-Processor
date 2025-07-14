`timescale 1ns / 1ps

module alu (
    input [31:0] Inst,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] result,
    output reg CB,
    output reg [31:0] EXT
);
    // Opcode definitions
    parameter NOP  = 8'h00, STORE = 8'h01;
    parameter LOAD  = 8'h02, BUN = 8'h03, BZ = 8'h04, BP = 8'h05, SII = 8'h06;
    parameter ADD   = 8'h07, SUB   = 8'h08;
    parameter MUL   = 8'h09, DIV   = 8'hA;
    parameter AND   = 8'h0B, OR    = 8'h0C;
    parameter XOR   = 8'h0D, NOR    = 8'h0E;
    parameter NAND   = 8'h0F;
    parameter NOT   = 8'h16, INC   = 8'h17;
    parameter DEC   = 8'h18, SR   = 8'h19;
    parameter SL   = 8'h20, AR   = 8'h21;
    parameter CIR   = 8'h22, CIL   = 8'h23;
    parameter HLT   = 8'h24;

    wire [7:0] opcode = Inst[31:24];

    always @(*) begin
        result = 0;
        EXT = 0;
        CB = 0;
        
        case (opcode)
            ADD: {CB, result} = operand1 + operand2;
            SUB: {CB, result} = operand1 - operand2;
            MUL: {EXT, result} = operand1 * operand2;
            DIV: if (operand2 != 0) begin
                    result = operand1 / operand2;
                    EXT = operand1 % operand2;
                end
                else begin
                    result = 0;
                    EXT = 0;
                    CB = 1; 
                end
            AND: result = operand1 & operand2;
            OR:  result = operand1 | operand2;
            XOR: result = operand1 ^ operand2;
            NOR:  result = ~(operand1 | operand2);
            NAND: result = ~(operand1 & operand2);
            NOT: result = ~operand1;
            INC: {CB, result} = operand1 + 1;
            DEC: {CB, result} = operand1 - 1;
            SL:  result = operand1 << 1;
            SR:  result = operand1 >> 1;
            AR:  result = operand1 >>> 1;
            CIR:  result = {operand1[0],operand1[31:1]};
            CIL:  result = {operand1[30:0],operand1[31]}; 
            default: begin  
                result = operand1;
                CB = 0;
                EXT = 0;
            end
        endcase
    end
endmodule
