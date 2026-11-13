`timescale 1ns/1ps

module tb_soc;

    reg         clk;
    reg         reset;
    reg  [15:0] mmio_rdata;
    wire [7:0]  mmio_addr;
    wire        mmio_we;
    wire [15:0] mmio_wdata;
    wire [127:0] matrix_rows;
    wire [1:0]  flags;
    wire        halt;

    integer checks;
    integer errors;
    integer cycles;

    soc_top #(
        .ROM_FILE("programs/isa_smoke.hex"),
        .RAM_FILE("")
    ) dut (
        .clk(clk),
        .reset(reset),
        .mmio_rdata(mmio_rdata),
        .mmio_addr(mmio_addr),
        .mmio_we(mmio_we),
        .mmio_wdata(mmio_wdata),
        .matrix_rows(matrix_rows),
        .flags(flags),
        .halt(halt)
    );

    always #5 clk = ~clk;

    task check_ram;
        input [9:0]  addr;
        input [15:0] exp;
        begin
            checks = checks + 1;
            if (dut.u_mem.u_ram.mem[addr] !== exp) begin
                errors = errors + 1;
                $display("FAIL SOC RAM[%h]=%h exp %h", addr,
                         dut.u_mem.u_ram.mem[addr], exp);
            end
        end
    endtask

    initial begin
        $dumpfile("sim_build/tb_soc.vcd");
        $dumpvars(0, tb_soc);

        clk = 1'b0;
        reset = 1'b1;
        mmio_rdata = 16'h0000;
        checks = 0;
        errors = 0;
        cycles = 0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        // Ждём HALT, но не бесконечно.
        while ((halt !== 1'b1) && (cycles < 20000)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #1;

        checks = checks + 1;
        if (halt !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL SOC: timeout, halt=%b cycles=%0d", halt, cycles);
        end

        check_ram(10'h100, 16'h0008); // ADD
        check_ram(10'h101, 16'h0002); // SUB
        check_ram(10'h102, 16'h0001); // AND
        check_ram(10'h103, 16'h0007); // OR
        check_ram(10'h104, 16'h0006); // XOR
        check_ram(10'h105, 16'hFFFC); // NOT
        check_ram(10'h106, 16'h000D); // ADDI
        check_ram(10'h107, 16'h000A); // SUBI
        check_ram(10'h108, 16'h000A); // ANDI
        check_ram(10'h109, 16'h0030); // ORI
        check_ram(10'h10A, 16'h003F); // XORI

        check_ram(10'h120, 16'h003F); // BEQ сработал
        check_ram(10'h121, 16'h003F); // BNE сработал
        check_ram(10'h122, 16'h600D); // BEQ не сработал
        check_ram(10'h123, 16'h1234); // JUMP обошёл bad
        check_ram(10'h124, 16'h7777); // CMP + BNE не сработал
        check_ram(10'h125, 16'h8888); // CMP + BEQ не сработал

        check_ram(10'h200, 16'h0006); // STORE indirect
        check_ram(10'h201, 16'h0006); // LOAD/STORE indirect
        check_ram(10'h202, 16'h0006); // LOAD from matrix

        checks = checks + 1;
        if (matrix_rows[15:0] !== 16'h0006) begin
            errors = errors + 1;
            $display("FAIL SOC matrix row0=%h exp 0006", matrix_rows[15:0]);
        end

        if (errors == 0)
            $display("PASS tb_soc: %0d checks, %0d cycles", checks, cycles);
        else
            $display("FAIL tb_soc: %0d errors / %0d checks", errors, checks);

        $finish;
    end

endmodule
