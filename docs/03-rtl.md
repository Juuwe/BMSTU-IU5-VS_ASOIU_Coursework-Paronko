# 03. RTL-реализация

## 1. Состав модулей

| Файл | Модуль | Ответственность |
|---|---|---|
| `rtl/ALU.v` | `ALU` | 16-битные арифметические и логические операции, `Z/C` |
| `rtl/Register_File.v` | `Register_File` | 8 × 16, два чтения, одна запись, `R0 = 0` |
| `rtl/Program_Counter.v` | `Program_Counter` | 10-битный `PC`, приоритет `reset → load → inc` |
| `rtl/Instruction_ROM.v` | `Instruction_ROM` | 1024 × 32, синхронное чтение, `$readmemh` |
| `rtl/Data_RAM.v` | `Data_RAM` | 1024 × 16, синхронные чтение/запись |
| `rtl/Video_Memory.v` | `Video_Memory` | 8 × 16, выход `rows[127:0]` |
| `rtl/Memory_Top.v` | `Memory_Top` | ROM/RAM/Video, декодер адреса, MUX чтения, MMIO-шина |
| `rtl/Control_Unit.v` | `Control_Unit` | FSM Мура и управляющие сигналы |
| `rtl/CPU_Core.v` | `CPU_Core` | `IR`, тракт данных, регистровый файл, АЛУ, флаги, `addr_reg` |
| `rtl/soc_top.v` | `soc_top` | соединение CPU, памяти и внешних портов |

## 2. Ключевые порты

### `CPU_Core`

| Порт | Направление | Ширина |
|---|---|---:|
| `clk`, `reset` | вход | 1 |
| `instr_addr` | выход | 10 |
| `instr_data` | вход | 32 |
| `data_addr` | выход | 16 |
| `data_we` | выход | 1 |
| `data_wdata` | выход | 16 |
| `data_rdata` | вход | 16 |
| `flags` | выход | 2 |
| `halt` | выход | 1 |

`flags = {Z, C}` — отладочный выход.

### `Memory_Top`

| Порт | Направление | Ширина |
|---|---|---:|
| `clk`, `reset` | вход | 1 |
| `instr_addr` | вход | 10 |
| `instr_data` | выход | 32 |
| `data_addr` | вход | 16 |
| `data_we` | вход | 1 |
| `data_wdata` | вход | 16 |
| `data_rdata` | выход | 16 |
| `mmio_rdata` | вход | 16 |
| `mmio_addr` | выход | 8 |
| `mmio_we` | выход | 1 |
| `mmio_wdata` | выход | 16 |
| `matrix_rows` | выход | 128 |

### `soc_top`

| Порт | Направление | Ширина |
|---|---|---:|
| `clk`, `reset` | вход | 1 |
| `mmio_rdata` | вход | 16 |
| `mmio_addr` | выход | 8 |
| `mmio_we` | выход | 1 |
| `mmio_wdata` | выход | 16 |
| `matrix_rows` | выход | 128 |
| `flags` | выход | 2 |
| `halt` | выход | 1 |

Параметры `ROM_FILE` и `RAM_FILE` передаются в `Memory_Top`.

## 3. FSM

`Control_Unit` — автомат Мура: выходы зависят только от `state_q`, а `opcode` и `z` влияют только на `next_state`.

### Группы состояний

| Группа | Состояния |
|---|---|
| Выборка | `S_FETCH`, `S_FETCH_WAIT`, `S_DECODE` |
| АЛУ | `S_ADD`, `S_SUB`, `S_AND`, `S_OR`, `S_XOR`, `S_NOT`, `S_CMP` |
| Immediate | `S_ADDI`, `S_SUBI`, `S_ANDI`, `S_ORI`, `S_XORI`, `S_CMPI` |
| Память | `S_LOAD_ADDR`, `S_LOAD_WAIT`, `S_LOAD_WB`, `S_STORE_ADDR`, `S_STORE_WR` |
| Переходы | `S_JUMP`, `S_BEQ`, `S_BNE`, `S_TAKEN`, `S_NEXT` |
| Прочее | `S_NOP`, `S_HALT` |

### Основные переходы

| Состояние | Условие | Следующее |
|---|---|---|
| `S_FETCH` | — | `S_FETCH_WAIT` |
| `S_FETCH_WAIT` | — | `S_DECODE` |
| `S_DECODE` | `opcode` | состояние команды |
| АЛУ-состояния | — | `S_FETCH` |
| `S_LOAD_ADDR` | — | `S_LOAD_WAIT` |
| `S_LOAD_WAIT` | — | `S_LOAD_WB` |
| `S_LOAD_WB` | — | `S_FETCH` |
| `S_STORE_ADDR` | — | `S_STORE_WR` |
| `S_STORE_WR` | — | `S_FETCH` |
| `S_BEQ` | `Z = 1` | `S_TAKEN` |
| `S_BEQ` | `Z = 0` | `S_NEXT` |
| `S_BNE` | `Z = 0` | `S_TAKEN` |
| `S_BNE` | `Z = 1` | `S_NEXT` |
| `S_TAKEN`, `S_NEXT` | — | `S_FETCH` |
| `S_HALT` | — | `S_HALT` |
| неизвестный код / `0x1F` | — | `S_HALT` |

## 4. Управляющие сигналы

| Сигнал | Назначение |
|---|---|
| `ir_we` | запись `instr_data` в `IR` |
| `pc_inc` | `PC ← PC + 1` |
| `pc_load` | `PC ← IR[9:0]` |
| `reg_we` | запись в регистровый файл |
| `wb_sel` | 0 — `alu_y`, 1 — `data_rdata` |
| `alu_op[2:0]` | операция АЛУ |
| `alu_b_sel` | 0 — `rs2_data`, 1 — `imm16` |
| `rs2_sel` | 0 — `rs2`, 1 — `rd` (для `STORE`) |
| `addr_we` | запись `alu_y` в `addr_reg` |
| `mem_we` | запись в память данных |
| `z_we`, `c_we` | обновление флагов |
| `halt` | остановка |

Точные значения по состояниям заданы в `rtl/Control_Unit.v`.

## 5. Тракт данных

- `rd = IR[26:24]`, `rs1 = IR[23:21]`, `rs2 = IR[20:18]`.
- `imm16 = IR[15:0]`.
- `ra2 = rs2_sel ? rd : rs2`.
- `alu_b = alu_b_sel ? imm16 : rs2_data`.
- `wb_data = wb_sel ? data_rdata : alu_y`.
- `data_wdata = rs2_data`.
- `addr_reg` записывается из `alu_y` в `S_LOAD_ADDR` и `S_STORE_ADDR`.
- `PC` загружается `IR[9:0]` в `S_JUMP` и `S_TAKEN`.
- `R0` всегда 0.

## 6. Такты выполнения

| Команда | Такты | Состояния |
|---|---:|---|
| АЛУ, `CMP`, `CMPI`, immediate | 4 | `FETCH`, `FETCH_WAIT`, `DECODE`, исполнение |
| `LOAD` | 6 | `FETCH`, `FETCH_WAIT`, `DECODE`, `LOAD_ADDR`, `LOAD_WAIT`, `LOAD_WB` |
| `STORE` | 5 | `FETCH`, `FETCH_WAIT`, `DECODE`, `STORE_ADDR`, `STORE_WR` |
| `JUMP` | 4 | `FETCH`, `FETCH_WAIT`, `DECODE`, `JUMP` |
| `BEQ`/`BNE` | 5 | `FETCH`, `FETCH_WAIT`, `DECODE`, проверка, `TAKEN`/`NEXT` |
| `NOP` | 4 | `FETCH`, `FETCH_WAIT`, `DECODE`, `NOP` |
| `HALT` | 4 + удержание | `FETCH`, `FETCH_WAIT`, `DECODE`, `HALT` |

## 7. Сброс и память

- Сброс синхронный, активный высокий.
- Сбрасываются `PC`, `IR`, `addr_reg`, регистровый файл, флаги и видеопамять.
- `Instruction_ROM` инициализируется нулями и `$readmemh`.
- `Data_RAM` инициализируется нулями и `$readmemh`, но сбросом не очищается.
- `Instruction_ROM`, `Data_RAM` и `Video_Memory` читаются синхронно; отсюда `FETCH_WAIT` и `LOAD_WAIT`.

## 8. Ограничения

- `COLLISION_CHK` (`0x1F`) не реализована: переводит CPU в `HALT`.
- MMIO-устройства не подключены; есть только шина и декодер.
- `C` сохраняется, но в управлении переходами используется только `Z`.
- `HALT` не сбрасывает процессор; для повторного запуска нужен `reset`.
- Конвейер, кэш, стек, прерывания и DMA отсутствуют.
