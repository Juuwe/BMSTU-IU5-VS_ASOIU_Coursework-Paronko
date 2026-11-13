`timescale 1ns/1ps

module Data_RAM #(
    parameter INIT_FILE = ""
)(
    input  wire        clk,
    input  wire [9:0]  addr,
    input  wire        we,
    input  wire [15:0] wd,
    output reg  [15:0] rd
);

    reg [15:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 16'd0;
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wd;
        rd <= mem[addr];
    end

endmodule
