`timescale 1ns / 1ps

module tb_processor();
    reg clk, reset;
    
    // Debug outputs
    wire [15:0] pc_value;
    wire [31:0] current_instruction;
    wire [3:0] current_state;

    
    processor uut (
        .clk(clk),
        .reset(reset),
        .pc_value(pc_value),
        .current_instruction(current_instruction),
        .current_state(current_state)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset and stimulus
    initial begin
        reset = 1;
        #10
        reset = 0;
        
        #550;
        
        // Check final results
        $display("\nFinal Results:");
        $display("Memory = ", uut.MEM.mem[25]);
        $display("Register R0 = ", uut.REGS.registers[0]);
        $display("Register R1 = ", uut.REGS.registers[1]);
        $display("Register R2 = ", uut.REGS.registers[2]);
      
        if (uut.MEM.mem[25] == 32'h00000004 &&
            uut.REGS.registers[0] == 32'h00000004) 
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
            
        $finish;
    end
endmodule
