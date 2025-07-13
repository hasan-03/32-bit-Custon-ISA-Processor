`timescale 1ns / 1ps

module memory (
    input clk,
    input [15:0] addr,
    input [31:0] data_in,
    input we,
    input re,
    output reg [31:0] data_out
);
    reg [31:0] mem [0:4095];
    integer i;

    always @(posedge clk) begin
        if (we) 
            mem[addr] <= data_in;
        if (re)
            data_out <= mem[addr]; 
    end
    
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 32'b0;
        
        // Instruction
        // Sample example 
      mem[0] = 32'h02001400;  // load M[20]->R0
      mem[1] = 32'h02001501;  // load M[21]->R1
      mem[2] = 32'h05000000;  // Skip next instruction if R0>0
      mem[3] = 32'h0B020100;  // AND(R0,R1)->R2
      mem[4] = 32'h01001902;  // Store M[19]<-R2
      mem[5] = 32'h24000000;  // HLT
        
        // Data section
        mem[20] = 32'h00000010; 
        mem[21] = 32'h00000011; 
        mem[22] = 32'h00000001; 
        mem[23] = 32'h00000002;
        mem[24] = 32'h00000005; 
    end

    
endmodule

