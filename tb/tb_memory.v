`timescale 1ns/1ps

module tb_memory;

    reg         clk;
    reg         reset;
    reg  [9:0]  instr_addr;
    wire [31:0] instr_data;
    reg  [15:0] data_addr;
    reg         data_we;
    reg  [15:0] data_wdata;
    wire [15:0] data_rdata;
    reg  [15:0] mmio_rdata;
    wire [7:0]  mmio_addr;
    wire        mmio_we;
    wire [15:0] mmio_wdata;
    wire [127:0] matrix_rows;

    integer checks;
    integer errors;

    Memory_Top dut (
        .clk(clk),
        .reset(reset),
        .instr_addr(instr_addr),
        .instr_data(instr_data),
        .data_addr(data_addr),
        .data_we(data_we),
        .data_wdata(data_wdata),
        .data_rdata(data_rdata),
        .mmio_rdata(mmio_rdata),
        .mmio_addr(mmio_addr),
        .mmio_we(mmio_we),
        .mmio_wdata(mmio_wdata),
        .matrix_rows(matrix_rows)
    );

    always #5 clk = ~clk;

    task check_read;
        input [15:0] addr;
        input [15:0] exp;
        begin
            data_addr = addr;
            data_we = 1'b0;
            @(posedge clk);
            #1;
            checks = checks + 1;
            if (data_rdata !== exp) begin
                errors = errors + 1;
                $display("FAIL MEM read addr=%h: %h exp %h", addr, data_rdata, exp);
            end
        end
    endtask

    task write_word;
        input [15:0] addr;
        input [15:0] value;
        begin
            data_addr = addr;
            data_wdata = value;
            data_we = 1'b1;
            @(posedge clk);
            #1;
            data_we = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("sim_build/tb_memory.vcd");
        $dumpvars(0, tb_memory);

        clk = 1'b0;
        reset = 1'b1;
        instr_addr = 10'd0;
        data_addr = 16'd0;
        data_we = 1'b0;
        data_wdata = 16'd0;
        mmio_rdata = 16'h5678;
        checks = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        // ROM пуст -> HALT (0), синхронный выход.
        instr_addr = 10'd0;
        @(posedge clk);
        #1;
        checks = checks + 1;
        if (instr_data !== 32'h0000_0000) begin
            errors = errors + 1;
            $display("FAIL MEM ROM empty: %h", instr_data);
        end

        // RAM.
        write_word(16'h0010, 16'hABCD);
        check_read(16'h0010, 16'hABCD);

        // Видеопамять / LED-матрица.
        write_word(16'h1000, 16'h00A5);
        check_read(16'h1000, 16'h00A5);
        checks = checks + 1;
        if (matrix_rows[15:0] !== 16'h00A5) begin
            errors = errors + 1;
            $display("FAIL MEM matrix row0: %h exp 00A5", matrix_rows[15:0]);
        end

        // MMIO: запись и чтение.
        data_addr = 16'hF010;
        data_wdata = 16'h1234;
        data_we = 1'b1;
        #1;
        checks = checks + 1;
        if ((mmio_we !== 1'b1) || (mmio_addr !== 8'h10) || (mmio_wdata !== 16'h1234)) begin
            errors = errors + 1;
            $display("FAIL MEM MMIO write: we=%b addr=%h wdata=%h",
                     mmio_we, mmio_addr, mmio_wdata);
        end
        data_we = 1'b0;
        data_addr = 16'hF010;
        #1;
        checks = checks + 1;
        if (data_rdata !== 16'h5678) begin
            errors = errors + 1;
            $display("FAIL MEM MMIO read: %h exp 5678", data_rdata);
        end

        // Неотображённый адрес: чтение 0.
        check_read(16'h2000, 16'h0000);

        if (errors == 0)
            $display("PASS tb_memory: %0d checks", checks);
        else
            $display("FAIL tb_memory: %0d errors / %0d checks", errors, checks);

        $finish;
    end

endmodule
