`timescale 1ns/1ps

module CPU_Core(
    input  wire        clk,
    input  wire        reset,

    output wire [9:0]  instr_addr,
    input  wire [31:0] instr_data,

    output wire [15:0] data_addr,
    output wire        data_we,
    output wire [15:0] data_wdata,
    input  wire [15:0] data_rdata,

    output wire [1:0]  flags,
    output wire        halt
);

    // ir[31:0]: старшие биты 21-битного immediate (ir[20:16]) для 16-битного
    // АЛУ не нужны: значение уже усечено до 16 бит. Подавляем предупреждение
    // осознанно, чтобы не добавлять фиктивную логику.
    /* verilator lint_off UNUSEDSIGNAL */
    reg  [31:0] ir;
    /* verilator lint_on UNUSEDSIGNAL */
    wire [9:0]  pc;

    wire [2:0] rd  = ir[26:24];
    wire [2:0] rs1 = ir[23:21];
    wire [2:0] rs2 = ir[20:18];

    wire [15:0] imm16 = ir[15:0]; // младшие 16 бит 21-битного immediate

    wire [2:0] ra2;
    wire [15:0] rs1_data;
    wire [15:0] rs2_data;
    wire [15:0] alu_b;
    wire [15:0] alu_y;
    wire [15:0] wb_data;

    wire [2:0] alu_op;
    wire       alu_b_sel;
    wire       reg_we;
    wire       wb_sel;
    wire       rs2_sel;
    wire       addr_we;
    wire       mem_we;
    wire       z_we;
    wire       c_we;

    wire       ir_we;
    wire       pc_inc;
    wire       pc_load;

    wire       alu_z;
    wire       alu_c;
    reg        flag_z;
    reg        flag_c;

    reg [15:0] addr_reg;

    assign instr_addr = pc;
    assign data_addr  = addr_reg;
    assign data_we    = mem_we;
    assign data_wdata = rs2_data;
    assign ra2        = rs2_sel ? rd : rs2;
    assign alu_b      = alu_b_sel ? imm16 : rs2_data;
    assign wb_data    = wb_sel ? data_rdata : alu_y;
    assign flags      = {flag_z, flag_c};

    Register_File u_regfile (
        .clk(clk),
        .reset(reset),
        .ra1(rs1),
        .ra2(ra2),
        .wa(rd),
        .wd(wb_data),
        .we(reg_we),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    ALU u_alu (
        .a(rs1_data),
        .b(alu_b),
        .op(alu_op),
        .y(alu_y),
        .z(alu_z),
        .c(alu_c)
    );

    Program_Counter u_pc (
        .clk(clk),
        .reset(reset),
        .inc(pc_inc),
        .load(pc_load),
        .target(ir[9:0]),
        .pc(pc)
    );

    Control_Unit u_control (
        .clk(clk),
        .reset(reset),
        .opcode(ir[31:27]),
        .z(flag_z),
        .ir_we(ir_we),
        .pc_inc(pc_inc),
        .pc_load(pc_load),
        .reg_we(reg_we),
        .wb_sel(wb_sel),
        .alu_op(alu_op),
        .alu_b_sel(alu_b_sel),
        .rs2_sel(rs2_sel),
        .addr_we(addr_we),
        .mem_we(mem_we),
        .z_we(z_we),
        .c_we(c_we),
        .halt(halt)
    );

    always @(posedge clk) begin
        if (reset)
            ir <= 32'd0;
        else if (ir_we)
            ir <= instr_data;
    end

    always @(posedge clk) begin
        if (reset)
            addr_reg <= 16'd0;
        else if (addr_we)
            addr_reg <= alu_y;
    end

    always @(posedge clk) begin
        if (reset) begin
            flag_z <= 1'b0;
            flag_c <= 1'b0;
        end else begin
            if (z_we)
                flag_z <= alu_z;
            if (c_we)
                flag_c <= alu_c;
        end
    end

endmodule
