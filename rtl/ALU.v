`timescale 1ns/1ps

module ALU(
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [2:0]  op,
    output reg  [15:0] y,
    output reg         z,
    output reg         c
);

    localparam [2:0] OP_ADD = 3'd0;
    localparam [2:0] OP_SUB = 3'd1;
    localparam [2:0] OP_AND = 3'd2;
    localparam [2:0] OP_OR  = 3'd3;
    localparam [2:0] OP_XOR = 3'd4;
    localparam [2:0] OP_NOT = 3'd5;

    reg [16:0] wide;

    always @* begin
        wide = 17'd0;
        y    = 16'd0;
        c    = 1'b0;

        case (op)
            OP_ADD: begin
                wide = {1'b0, a} + {1'b0, b};
                y    = wide[15:0];
                c    = wide[16];
            end
            OP_SUB: begin
                wide = {1'b0, a} - {1'b0, b};
                y    = wide[15:0];
                // По ЛР3: C = 1, если A >= B (нет заёма).
                c    = ~wide[16];
            end
            OP_AND: y = a & b;
            OP_OR:  y = a | b;
            OP_XOR: y = a ^ b;
            OP_NOT: y = ~a;
            default: y = 16'd0;
        endcase

        z = (y == 16'd0);
    end

endmodule
