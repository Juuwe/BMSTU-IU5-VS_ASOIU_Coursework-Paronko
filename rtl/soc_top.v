`timescale 1ns/1ps

module soc_top #(
    parameter ROM_FILE = "",
    parameter RAM_FILE = ""
)(
    input  wire         clk,
    input  wire         reset,

    input  wire [15:0]  mmio_rdata,
    output wire [7:0]   mmio_addr,
    output wire         mmio_we,
    output wire [15:0]  mmio_wdata,

    output wire [127:0] matrix_rows,
    output wire [1:0]   flags,
    output wire         halt
);

    wire [9:0]  instr_addr;
    wire [31:0] instr_data;

    wire [15:0] data_addr;
    wire        data_we;
    wire [15:0] data_wdata;
    wire [15:0] data_rdata;

    CPU_Core u_cpu (
        .clk(clk),
        .reset(reset),
        .instr_addr(instr_addr),
        .instr_data(instr_data),
        .data_addr(data_addr),
        .data_we(data_we),
        .data_wdata(data_wdata),
        .data_rdata(data_rdata),
        .flags(flags),
        .halt(halt)
    );

    Memory_Top #(
        .ROM_FILE(ROM_FILE),
        .RAM_FILE(RAM_FILE)
    ) u_mem (
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

endmodule
