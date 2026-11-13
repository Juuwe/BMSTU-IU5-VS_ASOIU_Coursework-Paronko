`timescale 1ns/1ps

module Video_Memory(
    input  wire        clk,
    input  wire        reset,
    input  wire [2:0]  addr,
    input  wire        we,
    input  wire [15:0] wd,
    output reg  [15:0] rd,
    output wire [127:0] rows
);

    reg [15:0] mem [0:7];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                mem[i] <= 16'd0;
            rd <= 16'd0;
        end else begin
            if (we)
                mem[addr] <= wd;
            rd <= mem[addr];
        end
    end

    assign rows = {
        mem[7], mem[6], mem[5], mem[4],
        mem[3], mem[2], mem[1], mem[0]
    };

endmodule
