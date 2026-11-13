`timescale 1ns/1ps

module Program_Counter(
    input  wire        clk,
    input  wire        reset,
    input  wire        inc,
    input  wire        load,
    input  wire [9:0]  target,
    output reg  [9:0]  pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= 10'd0;
        else if (load)
            pc <= target;
        else if (inc)
            pc <= pc + 10'd1;
    end

endmodule
