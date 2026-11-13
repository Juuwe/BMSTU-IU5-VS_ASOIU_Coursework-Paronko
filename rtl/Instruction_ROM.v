`timescale 1ns/1ps

module Instruction_ROM #(
    parameter INIT_FILE = ""
)(
    input  wire        clk,
    input  wire [9:0]  addr,
    output reg  [31:0] data
);

    reg [31:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h0000_0000; // HALT
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule
