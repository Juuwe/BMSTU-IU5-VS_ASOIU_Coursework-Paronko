# Документация проекта

**Проект:** 16-битное процессорное ядро и SoC на Verilog.  
**Вариант:** ИУ5-51Б, №11, 2026.

## Что это

Учебный проект: собственное процессорное ядро с ISA, гарвардской памятью, MMIO-шиной и программой обработки массива в машинных кодах. RTL описан только на Verilog; Python используется для вспомогательных скриптов и будущего ассемблера.

## Статус

- RTL-ядро, SoC, память, тестбенчи и программа №23 — готовы.
- `make test` — 5 PASS, `make lint` — без предупреждений.
- Следующие этапы: собственный ассемблер/toolchain, MMIO-устройства, BCD/Pong и интерактивный мост.

## Быстрый старт

Нужны `iverilog`, `vvp` и `verilator`. Для просмотра временных диаграмм — GTKWave.

```bash
make test
make lint
```

Ожидаемый результат тестов:

```text
PASS tb_alu
PASS tb_register_file
PASS tb_memory
PASS tb_soc
PASS tb_task3
```

## Карта документации

| Документ | О чём |
|---|---|
| [01-architecture.md](01-architecture.md) | состав SoC, блоки, тракт данных, память, MMIO, тактирование |
| [02-isa.md](02-isa.md) | форматы команд, регистры, флаги, набор инструкций, адресация |
| [03-rtl.md](03-rtl.md) | модули RTL, FSM, управляющие сигналы, такты выполнения |
| [04-verification.md](04-verification.md) | тестбенчи, `make test`/`make lint`, VCD, результаты |
| [05-programs.md](05-programs.md) | машинный код, программа №23, `isa_smoke`, формат `.hex` |
| [06-build.md](06-build.md) | зависимости, команды сборки, структура репозитория, синтез |
| [waveforms/README.md](waveforms/README.md) | временные диаграммы: PNG-превью и VCD |

## Схема архитектуры

[PNG-превью](../report/rtl-schema.png) · [drawio](../report/rtl-schema.drawio)

## Структура репозитория

```text
rtl/          Verilog-модули процессора и памяти
tb/           автоматические тестбенчи
programs/     машинный код и данные для $readmemh
report/       схема архитектуры
docs/         документация проекта
Makefile      test / lint / clean
variant.py    вспомогательный скрипт варианта
asm/          место для будущего ассемблера
bridge/       место для интерактивного моста
synth/        результаты синтеза
```

## Как читать документацию

1. [01-architecture.md](01-architecture.md) — общая картина.
2. [02-isa.md](02-isa.md) — что умеет процессор.
3. [03-rtl.md](03-rtl.md) — как это реализовано.
4. [04-verification.md](04-verification.md) — как проверить.
5. [05-programs.md](05-programs.md) и [06-build.md](06-build.md) — программы и запуск.
