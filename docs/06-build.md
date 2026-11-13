# 06. Сборка, запуск и структура проекта

## 1. Зависимости

| Инструмент | Назначение |
|---|---|
| `iverilog` | компиляция Verilog |
| `vvp` | запуск скомпилированных тестбенчей |
| `verilator` | lint RTL |
| GTKWave | просмотр VCD |
| `make` | запуск целей Makefile |

Опционально для следующих этапов: Yosys, Vivado/Quartus, Python 3.

## 2. Основные команды

```bash
make test    # собрать и запустить все тестбенчи
make lint    # verilator --lint-only -Wall
make clean   # удалить sim_build/
```

`make test` создаёт `sim_build/*.vvp`, `*.log` и `*.vcd`. Каталог `sim_build/` не хранится в git.

### Один тест

```bash
make sim_build/tb_task3.vvp
vvp sim_build/tb_task3.vvp
```

Аналогично можно запустить `tb_alu`, `tb_register_file`, `tb_memory`, `tb_soc`.

### Временные диаграммы

```bash
gtkwave sim_build/tb_task3.vcd
```

## 3. Структура репозитория

```text
rtl/          Verilog-модули
  ALU.v
  Register_File.v
  Program_Counter.v
  Instruction_ROM.v
  Data_RAM.v
  Video_Memory.v
  Memory_Top.v
  Control_Unit.v
  CPU_Core.v
  soc_top.v
tb/           тестбенчи
programs/     машинный код и данные
report/       схема архитектуры
docs/         документация
asm/          будущий ассемблер
bridge/       будущий интерактивный мост
synth/        результаты синтеза
Makefile
variant.py
```

## 4. Схема и диаграммы

- [PNG-превью архитектуры](../report/rtl-schema.png) · [drawio](../report/rtl-schema.drawio)
- [Временные диаграммы](waveforms/README.md)

## 5. Синтез

Синтез в текущую автоматизацию не входит. Планируется отдельный прогон (Yosys, Vivado или Quartus) и фиксация:

- LUT;
- Flip-Flops;
- Block RAM;
- `Fmax`.

Результаты синтеза следует складывать в `synth/`; эта папка пока является заготовкой.
