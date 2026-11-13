`timescale 1ns/1ps

module tb_alu;

    reg  [15:0] a;
    reg  [15:0] b;
    reg  [2:0]  op;
    wire [15:0] y;
    wire        z;
    wire        c;

    integer checks;
    integer errors;

    ALU dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y),
        .z(z),
        .c(c)
    );

    task check;
        input [2:0]  t_op;
        input [15:0] t_a;
        input [15:0] t_b;
        input [15:0] exp_y;
        input        exp_z;
        input        exp_c;
        begin
            op = t_op;
            a  = t_a;
            b  = t_b;
            #1;
            checks = checks + 1;
            if ((y !== exp_y) || (z !== exp_z) || (c !== exp_c)) begin
                errors = errors + 1;
                $display("FAIL ALU op=%0d a=%h b=%h: y=%h exp=%h z=%b exp=%b c=%b exp=%b",
                         t_op, t_a, t_b, y, exp_y, z, exp_z, c, exp_c);
            end
        end
    endtask

    initial begin
        $dumpfile("sim_build/tb_alu.vcd");
        $dumpvars(0, tb_alu);

        checks = 0;
        errors = 0;

        // ADD: 5 + 3 = 8, переноса нет
        check(3'd0, 16'd5, 16'd3, 16'd8, 1'b0, 1'b0);
        // ADD: 0xFFFF + 1 = 0, перенос и Z
        check(3'd0, 16'hFFFF, 16'd1, 16'd0, 1'b1, 1'b1);
        // SUB: 5 - 3 = 2, A >= B => C = 1 (нет заёма)
        check(3'd1, 16'd5, 16'd3, 16'd2, 1'b0, 1'b1);
        // SUB: 3 - 5 = 0xFFFE, A < B => C = 0
        check(3'd1, 16'd3, 16'd5, 16'hFFFE, 1'b0, 1'b0);
        // SUB: 5 - 5 = 0, Z = 1, C = 1
        check(3'd1, 16'd5, 16'd5, 16'd0, 1'b1, 1'b1);
        // AND / OR / XOR
        check(3'd2, 16'hF0F0, 16'h0FF0, 16'h00F0, 1'b0, 1'b0);
        check(3'd3, 16'hF0F0, 16'h0FF0, 16'hFFF0, 1'b0, 1'b0);
        check(3'd4, 16'hF0F0, 16'h0FF0, 16'hFF00, 1'b0, 1'b0);
        // NOT: ~0 = 0xFFFF; ~0xFFFF = 0
        check(3'd5, 16'h0000, 16'h0000, 16'hFFFF, 1'b0, 1'b0);
        check(3'd5, 16'hFFFF, 16'h0000, 16'h0000, 1'b1, 1'b0);

        if (errors == 0)
            $display("PASS tb_alu: %0d checks", checks);
        else
            $display("FAIL tb_alu: %0d errors / %0d checks", errors, checks);

        $finish;
    end

endmodule
