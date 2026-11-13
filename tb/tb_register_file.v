`timescale 1ns/1ps

module tb_register_file;

    reg         clk;
    reg         reset;
    reg  [2:0]  ra1;
    reg  [2:0]  ra2;
    reg  [2:0]  wa;
    reg  [15:0] wd;
    reg         we;
    wire [15:0] rd1;
    wire [15:0] rd2;

    integer checks;
    integer errors;

    Register_File dut (
        .clk(clk),
        .reset(reset),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .we(we),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk;

    task expect_read;
        input [2:0]  t_ra1;
        input [2:0]  t_ra2;
        input [15:0] exp_rd1;
        input [15:0] exp_rd2;
        begin
            ra1 = t_ra1;
            ra2 = t_ra2;
            #1;
            checks = checks + 1;
            if ((rd1 !== exp_rd1) || (rd2 !== exp_rd2)) begin
                errors = errors + 1;
                $display("FAIL RF ra1=%0d ra2=%0d: rd1=%h exp=%h rd2=%h exp=%h",
                         t_ra1, t_ra2, rd1, exp_rd1, rd2, exp_rd2);
            end
        end
    endtask

    initial begin
        $dumpfile("sim_build/tb_register_file.vcd");
        $dumpvars(0, tb_register_file);

        clk = 1'b0;
        reset = 1'b1;
        ra1 = 3'd0;
        ra2 = 3'd0;
        wa = 3'd0;
        wd = 16'd0;
        we = 1'b0;
        checks = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        // Запись R1 = 0x1234.
        wa = 3'd1;
        wd = 16'h1234;
        we = 1'b1;
        @(posedge clk);
        #1;
        we = 1'b0;
        expect_read(3'd1, 3'd0, 16'h1234, 16'h0000);

        // Запись в R0 должна игнорироваться.
        wa = 3'd0;
        wd = 16'hFFFF;
        we = 1'b1;
        @(posedge clk);
        #1;
        we = 1'b0;
        expect_read(3'd0, 3'd1, 16'h0000, 16'h1234);

        // Второй регистр.
        wa = 3'd2;
        wd = 16'hABCD;
        we = 1'b1;
        @(posedge clk);
        #1;
        we = 1'b0;
        expect_read(3'd2, 3'd1, 16'hABCD, 16'h1234);

        // Синхронный сброс очищает регистры.
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
        expect_read(3'd1, 3'd2, 16'h0000, 16'h0000);

        if (errors == 0)
            $display("PASS tb_register_file: %0d checks", checks);
        else
            $display("FAIL tb_register_file: %0d errors / %0d checks", errors, checks);

        $finish;
    end

endmodule
