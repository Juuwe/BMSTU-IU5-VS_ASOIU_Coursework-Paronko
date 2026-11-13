`timescale 1ns/1ps

module Control_Unit(
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  opcode,
    input  wire        z,
    output reg         ir_we,
    output reg         pc_inc,
    output reg         pc_load,
    output reg         reg_we,
    output reg         wb_sel,
    output reg  [2:0]  alu_op,
    output reg         alu_b_sel,
    output reg         rs2_sel,
    output reg         addr_we,
    output reg         mem_we,
    output reg         z_we,
    output reg         c_we,
    output wire        halt
);

    // Состояния FSM Мура. Выходы зависят только от state_q.
    localparam [4:0] S_FETCH      = 5'd0;
    localparam [4:0] S_DECODE     = 5'd1;
    localparam [4:0] S_ADD        = 5'd2;
    localparam [4:0] S_SUB        = 5'd3;
    localparam [4:0] S_AND        = 5'd4;
    localparam [4:0] S_OR         = 5'd5;
    localparam [4:0] S_XOR        = 5'd6;
    localparam [4:0] S_NOT        = 5'd7;
    localparam [4:0] S_CMP        = 5'd8;
    localparam [4:0] S_ADDI       = 5'd9;
    localparam [4:0] S_SUBI       = 5'd10;
    localparam [4:0] S_ANDI       = 5'd11;
    localparam [4:0] S_ORI        = 5'd12;
    localparam [4:0] S_XORI       = 5'd13;
    localparam [4:0] S_CMPI       = 5'd14;
    localparam [4:0] S_LOAD_ADDR  = 5'd15;
    localparam [4:0] S_LOAD_WB    = 5'd16;
    localparam [4:0] S_STORE_ADDR = 5'd17;
    localparam [4:0] S_STORE_WR   = 5'd18;
    localparam [4:0] S_JUMP       = 5'd19;
    localparam [4:0] S_BEQ        = 5'd20;
    localparam [4:0] S_BNE        = 5'd21;
    localparam [4:0] S_TAKEN      = 5'd22;
    localparam [4:0] S_NEXT       = 5'd23;
    localparam [4:0] S_NOP        = 5'd24;
    localparam [4:0] S_HALT       = 5'd25;
    localparam [4:0] S_FETCH_WAIT = 5'd26;
    localparam [4:0] S_LOAD_WAIT  = 5'd27;

    localparam [4:0] OP_HALT = 5'h00;
    localparam [4:0] OP_ADD  = 5'h01;
    localparam [4:0] OP_SUB  = 5'h02;
    localparam [4:0] OP_AND  = 5'h03;
    localparam [4:0] OP_OR   = 5'h04;
    localparam [4:0] OP_XOR  = 5'h05;
    localparam [4:0] OP_NOT  = 5'h06;
    localparam [4:0] OP_LOAD = 5'h07;
    localparam [4:0] OP_STORE= 5'h08;
    localparam [4:0] OP_JUMP = 5'h09;
    localparam [4:0] OP_BEQ  = 5'h0A;
    localparam [4:0] OP_BNE  = 5'h0B;
    localparam [4:0] OP_CMP  = 5'h0C;
    localparam [4:0] OP_ADDI = 5'h0D;
    localparam [4:0] OP_SUBI = 5'h0E;
    localparam [4:0] OP_ANDI = 5'h0F;
    localparam [4:0] OP_ORI  = 5'h10;
    localparam [4:0] OP_XORI = 5'h11;
    localparam [4:0] OP_CMPI = 5'h12;
    localparam [4:0] OP_NOP  = 5'h13;
    localparam [4:0] OP_COLLISION_CHK = 5'h1F; // семантика будет добавлена позже

    localparam [2:0] ALU_ADD = 3'd0;
    localparam [2:0] ALU_SUB = 3'd1;
    localparam [2:0] ALU_AND = 3'd2;
    localparam [2:0] ALU_OR  = 3'd3;
    localparam [2:0] ALU_XOR = 3'd4;
    localparam [2:0] ALU_NOT = 3'd5;

    reg [4:0] state_q;
    reg [4:0] next_state;

    assign halt  = (state_q == S_HALT);

    always @(posedge clk) begin
        if (reset)
            state_q <= S_FETCH;
        else
            state_q <= next_state;
    end

    always @* begin
        next_state = S_HALT;

        case (state_q)
            S_FETCH: next_state = S_FETCH_WAIT;
            S_FETCH_WAIT: next_state = S_DECODE;

            S_DECODE: begin
                case (opcode)
                    OP_HALT:  next_state = S_HALT;
                    OP_ADD:   next_state = S_ADD;
                    OP_SUB:   next_state = S_SUB;
                    OP_AND:   next_state = S_AND;
                    OP_OR:    next_state = S_OR;
                    OP_XOR:   next_state = S_XOR;
                    OP_NOT:   next_state = S_NOT;
                    OP_LOAD:  next_state = S_LOAD_ADDR;
                    OP_STORE: next_state = S_STORE_ADDR;
                    OP_JUMP:  next_state = S_JUMP;
                    OP_BEQ:   next_state = S_BEQ;
                    OP_BNE:   next_state = S_BNE;
                    OP_CMP:   next_state = S_CMP;
                    OP_ADDI:  next_state = S_ADDI;
                    OP_SUBI:  next_state = S_SUBI;
                    OP_ANDI:  next_state = S_ANDI;
                    OP_ORI:   next_state = S_ORI;
                    OP_XORI:  next_state = S_XORI;
                    OP_CMPI:  next_state = S_CMPI;
                    OP_NOP:   next_state = S_NOP;
                    OP_COLLISION_CHK: next_state = S_HALT; // зарезервировано
                    default:  next_state = S_HALT;
                endcase
            end

            S_ADD, S_SUB, S_AND, S_OR, S_XOR, S_NOT,
            S_CMP, S_ADDI, S_SUBI, S_ANDI, S_ORI, S_XORI, S_CMPI:
                next_state = S_FETCH;

            S_LOAD_ADDR:  next_state = S_LOAD_WAIT;
            S_LOAD_WAIT:  next_state = S_LOAD_WB;
            S_LOAD_WB:    next_state = S_FETCH;
            S_STORE_ADDR: next_state = S_STORE_WR;
            S_STORE_WR:   next_state = S_FETCH;
            S_JUMP:       next_state = S_FETCH;

            S_BEQ: next_state = z ? S_TAKEN : S_NEXT;
            S_BNE: next_state = z ? S_NEXT : S_TAKEN;

            S_TAKEN: next_state = S_FETCH;
            S_NEXT:  next_state = S_FETCH;
            S_NOP:   next_state = S_FETCH;
            S_HALT:  next_state = S_HALT;

            default: next_state = S_HALT;
        endcase
    end

    always @* begin
        ir_we     = 1'b0;
        pc_inc    = 1'b0;
        pc_load   = 1'b0;
        reg_we    = 1'b0;
        wb_sel    = 1'b0;
        alu_op    = ALU_ADD;
        alu_b_sel = 1'b0;
        rs2_sel   = 1'b0;
        addr_we   = 1'b0;
        mem_we    = 1'b0;
        z_we      = 1'b0;
        c_we      = 1'b0;

        case (state_q)
            S_FETCH: begin
                pc_inc = 1'b1;
            end

            S_FETCH_WAIT: begin
                ir_we = 1'b1;
            end

            S_ADD: begin
                reg_we = 1'b1;
                alu_op = ALU_ADD;
                z_we   = 1'b1;
                c_we   = 1'b1;
            end

            S_SUB: begin
                reg_we = 1'b1;
                alu_op = ALU_SUB;
                z_we   = 1'b1;
                c_we   = 1'b1;
            end

            S_AND: begin
                reg_we = 1'b1;
                alu_op = ALU_AND;
                z_we   = 1'b1;
            end

            S_OR: begin
                reg_we = 1'b1;
                alu_op = ALU_OR;
                z_we   = 1'b1;
            end

            S_XOR: begin
                reg_we = 1'b1;
                alu_op = ALU_XOR;
                z_we   = 1'b1;
            end

            S_NOT: begin
                reg_we = 1'b1;
                alu_op = ALU_NOT;
                z_we   = 1'b1;
            end

            S_CMP: begin
                alu_op = ALU_SUB;
                z_we   = 1'b1;
                c_we   = 1'b1;
            end

            S_ADDI: begin
                reg_we    = 1'b1;
                alu_op    = ALU_ADD;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
                c_we      = 1'b1;
            end

            S_SUBI: begin
                reg_we    = 1'b1;
                alu_op    = ALU_SUB;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
                c_we      = 1'b1;
            end

            S_ANDI: begin
                reg_we    = 1'b1;
                alu_op    = ALU_AND;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
            end

            S_ORI: begin
                reg_we    = 1'b1;
                alu_op    = ALU_OR;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
            end

            S_XORI: begin
                reg_we    = 1'b1;
                alu_op    = ALU_XOR;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
            end

            S_CMPI: begin
                alu_op    = ALU_SUB;
                alu_b_sel = 1'b1;
                z_we      = 1'b1;
                c_we      = 1'b1;
            end

            S_LOAD_ADDR: begin
                alu_op    = ALU_ADD;
                alu_b_sel = 1'b1;
                addr_we   = 1'b1;
            end

            S_LOAD_WAIT: begin
                // Адрес уже зафиксирован; ждём синхронный выход RAM.
            end

            S_LOAD_WB: begin
                reg_we = 1'b1;
                wb_sel = 1'b1;
            end

            S_STORE_ADDR: begin
                alu_op    = ALU_ADD;
                alu_b_sel = 1'b1;
                addr_we   = 1'b1;
            end

            S_STORE_WR: begin
                mem_we  = 1'b1;
                rs2_sel = 1'b1;
            end

            S_JUMP: begin
                pc_load = 1'b1;
            end

            S_BEQ, S_BNE: begin
                // Решение принимается в next_state по флагу Z.
            end

            S_TAKEN: begin
                pc_load = 1'b1;
            end

            S_NEXT, S_NOP: begin
                // PC уже указывает на следующую команду после FETCH.
            end

            S_HALT: begin
                // halt = 1 формируется assign выше.
            end

            default: begin
                // безопасные значения уже выставлены
            end
        endcase
    end

endmodule
