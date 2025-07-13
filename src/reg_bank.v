`timescale 1ns / 1ps

module reg_bank (
    input clk,
    input [7:0] read_addr1,
    input [7:0] read_addr2,
    input [7:0] write_addr,
    input write_en,
    input read_en,
    input [31:0] data_in,
    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);
    reg [31:0] registers [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            registers[i] = 32'h0000;
    end

    always @(posedge clk) begin
        if (write_en) 
            registers[write_addr] <= data_in; 
            
        if (read_en) begin 
            data_out1 <= registers[read_addr1]; 
            data_out2 <= registers[read_addr2];
        end
    end
endmodule
