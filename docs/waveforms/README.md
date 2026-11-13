# Временные диаграммы

Все диаграммы получены из реальных VCD-файлов после `make test`. В папке лежат:

- **PNG** — быстрый просмотр прямо в репозитории;
- **VCD** — исходные данные для GTKWave.

## Что смотреть

| Тест | Превью | VCD | Что показывает |
|---|---|---|---|
| `tb_alu` | [tb_alu.png](tb_alu.png) | [tb_alu.vcd](tb_alu.vcd) | операции АЛУ, `Z/C` |
| `tb_register_file` | [tb_register_file.png](tb_register_file.png) | [tb_register_file.vcd](tb_register_file.vcd) | запись/чтение РОН, `R0`, сброс |
| `tb_memory` | [tb_memory.png](tb_memory.png) | [tb_memory.vcd](tb_memory.vcd) | RAM, Video, MMIO-декодер |
| `tb_soc` — обзор | [tb_soc-overview.png](tb_soc-overview.png) | [tb_soc.vcd](tb_soc.vcd) | полный прогон ISA-программы |
| `tb_soc` — первые 1 мкс | [tb_soc-zoom.png](tb_soc-zoom.png) | [tb_soc.vcd](tb_soc.vcd) | команды, адреса, данные, флаги |
| `tb_task3` — обзор | [tb_task3-overview.png](tb_task3-overview.png) | [tb_task3.vcd](tb_task3.vcd) | полный прогон программы №23 |
| `tb_task3` — первые 1 мкс | [tb_task3-zoom.png](tb_task3-zoom.png) | [tb_task3.vcd](tb_task3.vcd) | цикл обработки массива |

«Обзор» показывает весь прогон: видно старт, циклы и момент `halt`. «Первые 1 мкс» — детальный участок с командами, адресами и данными.

## Как открыть в GTKWave

```bash
gtkwave docs/waveforms/tb_task3.vcd
```

Для `tb_task3` полезно добавить сигналы:

- `clk`, `reset`, `halt`;
- `instr_addr`, `instr_data`;
- `data_addr`, `data_we`, `data_wdata`, `data_rdata`;
- `flags`.

Для `tb_soc` — те же сигналы; для `tb_memory` — `data_addr`, `data_we`, `data_wdata`, `data_rdata`, `sel_ram`, `sel_matrix`, `sel_mmio`.

## Как получить заново

```bash
make test
```

VCD-файлы появятся в `sim_build/`. PNG-превью в этой папке — снимки этих VCD; при изменении RTL их нужно обновить.
