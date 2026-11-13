`timescale 1ns/1ps

module Register_File(
    input  wire        clk,
    input  wire        reset,
    input  wire [2:0]  ra1,
    input  wire [2:0]  ra2,
    input  wire [2:0]  wa,
    input  wire [15:0] wd,
    input  wire        we,
    output wire [15:0] rd1,
    output wire [15:0] rd2
);

    reg [15:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'd0;
        end else if (we && wa != 3'd0) begin
            regs[wa] <= wd;
        end
    end

    // R0 всегда читается как 0, запись в него игнорируется.
    assign rd1 = (ra1 == 3'd0) ? 16'd0 : regs[ra1];
    assign rd2 = (ra2 == 3'd0) ? 16'd0 : regs[ra2];

endmodule
