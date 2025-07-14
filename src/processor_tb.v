`timescale 1ns / 1ps

module processor(
    input clk,
    input reset,
    output reg [15:0] pc_value,
    output reg [31:0] current_instruction,
    output reg [3:0] current_state
);

    // State definitions
    parameter FETCH      = 4'b0000;
    parameter IDLE_FETCH1 = 4'b0001;
    parameter IDLE_FETCH2 = 4'b0010;
    parameter DECODE     = 4'b0011;
    parameter EXECUTE    = 4'b0100;
    parameter MEMORY     = 4'b0101;
    parameter WRITE_BACK = 4'b0110;
    parameter WRITE_IDLE = 4'b0111;
    parameter HALT       = 4'b1000;
    
    reg [3:0] state;
    reg [15:0] pc;
    reg [31:0] IR;
    
    // Memory interface
    reg [15:0] mem_addr;
    reg [31:0] mem_data_in;
    reg mem_we;
    reg mem_re;
    wire [31:0] mem_data_out;
    
    // Register interface
    reg [7:0] reg_read_addr1;
    reg [7:0] reg_read_addr2;
    reg [7:0] reg_write_addr;
    reg reg_write_en;
    reg reg_read_en;
    reg [31:0] reg_data_in;
    wire [31:0] reg_data_out1;
    wire [31:0] reg_data_out2;
    
    // ALU interface
    wire [31:0] alu_result;
    wire alu_CB;
    wire [31:0] alu_EXT;
    
    // Memory Module
    memory MEM (
        .clk(clk),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .we(mem_we),
        .re(mem_re),
        .data_out(mem_data_out)
    );
    
    // Register Bank
    reg_bank REGS (
        .clk(clk),
        .read_addr1(reg_read_addr1),
        .read_addr2(reg_read_addr2),
        .write_addr(reg_write_addr),
        .write_en(reg_write_en),
        .read_en(reg_read_en),
        .data_in(reg_data_in),
        .data_out1(reg_data_out1),
        .data_out2(reg_data_out2)
    );
    
    // ALU
    alu ALU (
        .Inst(IR),
        .operand1(reg_data_out1),
        .operand2(reg_data_out2),
        .result(alu_result),
        .CB(alu_CB),
        .EXT(alu_EXT)
    );
    
    // State machine
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
            pc <= 0;
            IR <= 0;
            mem_we <= 0;
            mem_re <= 0;
            reg_write_en <= 0;
            reg_read_en <= 0;
        end
        else begin
            case (state)
                FETCH: begin
                    mem_addr <= pc;
                    mem_re <= 1;
                    mem_we <=0;
                    reg_write_en <= 0;
                    reg_read_en <= 0;
                    state <= IDLE_FETCH1;
                end
                
                IDLE_FETCH1: begin
                    state <= IDLE_FETCH2;
                end
                
                IDLE_FETCH2: begin
                    IR <= mem_data_out;
                    pc <= pc + 1;
                    state <= DECODE;
                end
                
                DECODE: begin
                    case (IR[31:24])
                        8'h00: begin //NOP
                            reg_read_en <= 0;
                            reg_write_en <= 0;
                            mem_re <= 0;
                            mem_we <= 0;
                            state <= FETCH;
                        end
                        8'h01: begin // STORE
                            mem_addr <= IR[23:8];
                            reg_read_addr1 <= IR[7:0];
                            reg_read_en <= 1;
                            reg_write_en <= 0;
                            mem_re <= 0;
                            mem_we <= 0;
                            state <= EXECUTE;
                        end
                        
                        8'h02,8'h82: begin // LOAD(DIRECT and INDIRECT)
                            mem_addr <= IR[23:8];
                            reg_write_addr <= IR[7:0];
                            mem_re <= 1;
                            mem_we <= 0;
                            reg_read_en <= 0;
                            reg_write_en <= 0;
                            state <= EXECUTE;
                        end
                        
                        8'h03,8'h04,8'h05,8'h06: begin  //BRANCH and Skip
                            case(IR[31:24])
                                8'h03: begin // Unconditional Branch
                                    pc <= IR[23:8];
                                    state <= FETCH;
                                end
                                8'h04,8'h05,8'h06: begin    // Conditional Branch
                                    reg_read_addr1 <= IR[7:0];
                                    reg_read_en <= 1;
                                    mem_re <= 0;
                                    mem_we <= 0;
                                    reg_write_en <= 0;
                                    state <= EXECUTE;
                                end
                            endcase
                        end
                     
                        8'h07,8'h08,8'h09,8'hA,8'hB,8'hC,8'hD,8'hE,8'hF: begin // ALU ops
                            reg_read_addr1 <= IR[15:8];
                            reg_read_addr2 <= IR[7:0];
                            reg_write_addr <= IR[23:16];
                            reg_read_en <= 1;
                            mem_re <= 0;
                            mem_we <= 0;
                            reg_write_en <= 0;
                            state <= EXECUTE;
                        end
                        
                        8'h16,8'h17,8'h18,8'h19,8'h20,8'h21,8'h22,8'h23: begin // Extended ALU
                            reg_read_addr1 <= IR[15:8];
                            reg_read_addr2 <= IR[15:8];
                            reg_write_addr <= IR[15:8];
                            reg_read_en <= 1;
                            mem_re <= 0;
                            mem_we <= 0;
                            reg_write_en <= 0;
                            state <= EXECUTE;
                        end
                        
                        8'h24: begin // HALT
                            state <= HALT;
                            mem_re <= 0;
                            mem_we <= 0;
                            reg_read_en <= 0;
                            reg_write_en <= 0;
                        end
                        default: 
                            state <= EXECUTE;
                    endcase
                end
                
                EXECUTE: begin
                    case (IR[31:24])
                        8'h01: begin 
                            mem_we <= 1;
                            mem_re <= 0;
                            reg_read_en <= 0;
                            reg_write_en <= 0;
                            state <= MEMORY;
                            
                        end
                        
                        8'h02,8'h82: begin 
                            state <= MEMORY;
                        end
                        
                        8'h04,8'h05,8'h06: begin
                                state <= MEMORY;
                           
                       end
                        
                        8'h07,8'h08,8'h09,8'hA,8'hB,8'hC,8'hD,8'hE,8'hF,8'h16,8'h17,8'h18,8'h19,8'h20,8'h21,8'h22,8'h23: begin
                            reg_write_en <= 1;
                            mem_re <= 0;
                            mem_we <= 0;
                            reg_read_en <= 0;
                            state <= MEMORY;
                        end
                    endcase
                end
                
                MEMORY: begin
                    case (IR[31:24])
                        8'h01: begin 
                            mem_data_in <= reg_data_out1;
                            state <= WRITE_BACK;
                        end
                        
                        8'h02: begin 
                            reg_data_in <= mem_data_out;
                            reg_write_en <= 1;
                            mem_re <= 0;
                            mem_we <= 0;
                            reg_read_en <= 0;
                            state <= WRITE_BACK;
                        end
                        
                        8'h82: begin 
                            mem_addr <= mem_data_out;
                            state <= WRITE_BACK;
                        end
                        
                        8'h04,8'h05,8'h06: begin
                            case(IR[31:24])
                                8'h04: begin
                                if(reg_data_out1 == 32'b0)begin
                                    pc <= IR[23:8];
                                    state <= FETCH;
                                end
                                else
                                    state <= FETCH;
                                end
                                8'h05: begin
                                    if(reg_data_out1 > 32'b0)begin
                                        pc <= IR[23:8];
                                        state <= FETCH;
                                    end
                                else
                                    state <= FETCH;
                                end
                                8'h06: begin
                                if(reg_data_out1 == IR[23:8])begin
                                    pc <= pc+1;
                                    state <= FETCH;
                                end
                                else
                                    state <= FETCH;
                                end
                            endcase
                        end
                        
                        8'h07,8'h08,8'h09,8'hA,8'hB,8'hC,8'hD,8'hE,8'hF,8'h16,8'h17,8'h18,8'h19,8'h20,8'h21,8'h22,8'h23: begin
                            reg_data_in <= alu_result;
                            state <= WRITE_BACK;
                        end
                    endcase
                end
                
                WRITE_BACK: begin
                case(IR[31:24])
                        8'h82: begin 
                            reg_write_en <= 1;
                            state <= WRITE_IDLE;
                        end
                        default: state <= FETCH;
                 endcase
                 
                end
                
                WRITE_IDLE: begin
                    reg_data_in <= mem_data_out;
                    state <= FETCH;
                end
                
                HALT: begin
                    state <= HALT;
                end
            endcase
        end
    end

    // Debug outputs
    always @(posedge clk) begin
        pc_value <= pc;
        current_instruction <= IR;
        current_state <= state;
    end
endmodule
