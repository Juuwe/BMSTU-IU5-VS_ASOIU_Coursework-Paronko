`timescale 1ns/1ps

module Memory_Top #(
    parameter ROM_FILE = "",
    parameter RAM_FILE = ""
)(
    input  wire         clk,
    input  wire         reset,

    input  wire [9:0]   instr_addr,
    output wire [31:0]  instr_data,

    input  wire [15:0]  data_addr,
    input  wire         data_we,
    input  wire [15:0]  data_wdata,
    output wire [15:0]  data_rdata,

    input  wire [15:0]  mmio_rdata,
    output wire [7:0]   mmio_addr,
    output wire         mmio_we,
    output wire [15:0]  mmio_wdata,

    output wire [127:0] matrix_rows
);

    // Карта данных:
    //   0x0000-0x03FF  RAM (1024 x 16)
    //   0x1000-0x1007  LED-матрица 8x8 (8 x 16)
    //   0xF000-0xF0FF  MMIO (256 адресов)
    wire sel_ram    = (data_addr[15:10] == 6'd0);
    wire sel_matrix = (data_addr[15:3]  == 13'h0200);
    wire sel_mmio   = (data_addr[15:8]  == 8'hF0);

    wire [15:0] ram_rdata;
    wire [15:0] matrix_rdata;

    wire ram_we    = data_we && sel_ram;
    wire matrix_we = data_we && sel_matrix;

    assign mmio_addr  = data_addr[7:0];
    assign mmio_we    = data_we && sel_mmio;
    assign mmio_wdata = data_wdata;

    assign data_rdata = sel_ram    ? ram_rdata :
                        sel_matrix ? matrix_rdata :
                        sel_mmio   ? mmio_rdata :
                                     16'd0;

    Instruction_ROM #(
        .INIT_FILE(ROM_FILE)
    ) u_rom (
        .clk(clk),
        .addr(instr_addr),
        .data(instr_data)
    );

    Data_RAM #(
        .INIT_FILE(RAM_FILE)
    ) u_ram (
        .clk(clk),
        .addr(data_addr[9:0]),
        .we(ram_we),
        .wd(data_wdata),
        .rd(ram_rdata)
    );

    Video_Memory u_video (
        .clk(clk),
        .reset(reset),
        .addr(data_addr[2:0]),
        .we(matrix_we),
        .wd(data_wdata),
        .rd(matrix_rdata),
        .rows(matrix_rows)
    );

endmodule
