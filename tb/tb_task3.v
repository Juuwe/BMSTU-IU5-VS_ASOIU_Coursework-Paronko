`timescale 1ns/1ps

module tb_task3;

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
        .ROM_FILE("programs/task3.hex"),
        .RAM_FILE("programs/task3.ram.hex")
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
                $display("FAIL TASK3 RAM[%h]=%h exp %h", addr,
                         dut.u_mem.u_ram.mem[addr], exp);
            end
        end
    endtask

    initial begin
        $dumpfile("sim_build/tb_task3.vcd");
        $dumpvars(0, tb_task3);

        clk = 1'b0;
        reset = 1'b1;
        mmio_rdata = 16'h0000;
        checks = 0;
        errors = 0;
        cycles = 0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        while ((halt !== 1'b1) && (cycles < 20000)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #1;

        checks = checks + 1;
        if (halt !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL TASK3: timeout, halt=%b cycles=%0d", halt, cycles);
        end

        // Массив после in-place обработки.
        check_ram(10'h000, 16'h0001);
        check_ram(10'h001, 16'h0000);
        check_ram(10'h002, 16'h0002);
        check_ram(10'h003, 16'h0000);
        check_ram(10'h004, 16'h0000);
        check_ram(10'h005, 16'h0005);
        check_ram(10'h006, 16'h0000);
        check_ram(10'h007, 16'h0007);
        check_ram(10'h008, 16'h0008);
        check_ram(10'h009, 16'h0009);

        // Длина не должна измениться.
        check_ram(10'h0FF, 16'h000A);

        // За пределами массива — нули.
        check_ram(10'h00A, 16'h0000);

        // Второй прогон: другой массив и другая длина.
        reset = 1'b1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        dut.u_mem.u_ram.mem[10'h000] = 16'h0003;
        dut.u_mem.u_ram.mem[10'h001] = 16'h0003;
        dut.u_mem.u_ram.mem[10'h002] = 16'h0004;
        dut.u_mem.u_ram.mem[10'h003] = 16'h0004;
        dut.u_mem.u_ram.mem[10'h004] = 16'h0005;
        dut.u_mem.u_ram.mem[10'h005] = 16'h0000;
        dut.u_mem.u_ram.mem[10'h0FF] = 16'h0005;
        reset = 1'b0;
        cycles = 0;

        while ((halt !== 1'b1) && (cycles < 20000)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        #1;

        checks = checks + 1;
        if (halt !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL TASK3 second: timeout, halt=%b cycles=%0d", halt, cycles);
        end

        check_ram(10'h000, 16'h0003);
        check_ram(10'h001, 16'h0000);
        check_ram(10'h002, 16'h0004);
        check_ram(10'h003, 16'h0000);
        check_ram(10'h004, 16'h0005);
        check_ram(10'h0FF, 16'h0005);

        if (errors == 0)
            $display("PASS tb_task3: %0d checks, %0d cycles", checks, cycles);
        else
            $display("FAIL tb_task3: %0d errors / %0d checks", errors, checks);

        $finish;
    end

endmodule
