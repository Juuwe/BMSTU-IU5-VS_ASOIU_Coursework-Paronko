#!/usr/bin/env python3
"""Генератор индивидуального варианта курсовой работы по ВС АСОИУ.

Алгоритм выбора задач ПОЛНОСТЬЮ повторяет скрипт из методички
(seed = "{год}-{группа}-{вариант}-kursovik", MD5, разные срезы хэша для
задач на «3», «4», «5»). Отличия только в удобстве:
  * параметры берутся из аргументов командной строки или запрашиваются
    интерактивно, а не зашиты в код;
  * дополнительно печатаются НАЗВАНИЯ задач из пулов (в методичке только номера).

Примеры запуска:
    python3 variant.py --year 2026 --group ИУ5-41Б --variant 11
    python3 variant.py            # спросит параметры в диалоге
"""

import argparse
import hashlib

# Размеры пулов заданий (как в методичке)
TOTAL_GRADE_3 = 25
TOTAL_GRADE_4 = 25
TOTAL_GRADE_5 = 30

# Названия задач из документа «Варианты для курсового проекта»
TASKS_3 = [
    "Числа Фибоначчи", "Факториал (с флагом переполнения)", "Пузырьковая сортировка (10 чисел)",
    "Реверс массива (16, in-place)", "Шифр Цезаря", "Поиск подстроки (3 в 20)",
    "НОД (алгоритм Евклида)", "НОК", "Сложение матриц 3x3", "Скалярное произведение (длина 5)",
    "Проверка на палиндром (10 элементов)", "Подсчёт гласных", "Минимум и максимум (16 чисел)",
    "Среднее арифметическое", "Сортировка выбором", "Бинарный поиск (16 элементов)",
    "Перевод в двоичную систему (побитово)", "Проверка на простое число", "Решето Эратосфена (1..30)",
    "Циклический сдвиг массива на K", "Поиск моды", "XOR-сумма массива (20 байт)",
    "Удаление подряд идущих дубликатов", "Слияние двух отсортированных массивов (5+5)",
    "Умножение матрицы 2x2 на вектор 2x1",
]

TASKS_4 = [
    "Traffic Light (светофор)", "Hardware Calculator (keypad 4x4, 7-seg)", "PWM Generator",
    "Vending Machine", "Morse Code Generator", "Stopwatch (секундомер)", "Safe Lock (кодовый замок)",
    "Elevator Controller (лифт на 4 этажа)", "ASCII to Hex Converter", "Memory Tester (паттерн 0xAA)",
    "Digital Thermometer", "Stepper Motor Controller", "Chat Terminal (UART echo)",
    "Water Level Controller", "Logic Gate Emulator", "RPN Calculator", "Garage Door Opener",
    "BCD Counter (00-99)", "Reaction Timer", "Barcode Decoder (упрощ.)", "Melody Synthesizer",
    "RGB Color Mixer", "Washing Machine", "Battery Monitor", "Simple ALU Coprocessor",
]

# (название, кастомная инструкция)
TASKS_5 = [
    ("Pong (1D)", "COLLISION_CHK"), ("Snake (змейка)", "RAND_GEN"),
    ("Space Invaders (упрощ.)", "MEM_SHIFT_DOWN"), ("Flappy Bird (упрощ.)", "APPLY_GRAVITY"),
    ("Arkanoid (прорыв)", "BLOCK_BREAK"), ("Doodle Jump", "CAM_SCROLL"),
    ("Racing (гонка с препятствиями)", "LANE_SHIFT"), ("Catch the Drop", "RAND_LANE"),
    ("Whack-a-Mole", "TIMER_TICK"), ("Runner (динозаврик)", "SPEED_ACCEL"),
    ("Tetris 4x8", "CHK_LINE"), ("Tic-Tac-Toe", "WIN_DETECT"), ("2048 (4x4)", "MERGE_ROW"),
    ("Simon Says", "SEQ_CMP"), ("Minesweeper 8x8", "COUNT_NEIGHBORS"), ("Lights Out 5x5", "CROSS_XOR"),
    ("Memory Match", "STATE_FLIP"), ("Sokoban", "PUSH_LOGIC"), ("Maze Escape", "RAY_CAST"),
    ("Mastermind (быки и коровы)", "BULL_COW_CALC"), ("Hardware Calculator (приложение)", "BIN2BCD"),
    ("Digital Synthesizer", "FREQ_GEN"), ("Stopwatch & Timer", "TIME_FMT"),
    ("Marquee (бегущая строка)", "FONT_RENDER"), ("Paint (рисовалка)", "PIXEL_SET"),
    ("Tamagotchi", "STAT_DECAY"), ("Safe Lock (расширенный)", "PASS_HASH"),
    ("Reaction Tester", "HIGH_RES_TICK"), ("Morse Code Trainer", "MORSE_DEC"),
    ("Smart Metronome", "BPM2TICKS"),
]


def pick_tasks(year, group, variant):
    """Возвращает номера задач (3, 4, 5) — формулы идентичны методичке."""
    seed_string = f"{year}-{group}-{variant}-kursovik"
    hash_int = int(hashlib.md5(seed_string.encode()).hexdigest(), 16)
    task_3 = (hash_int % TOTAL_GRADE_3) + 1
    task_4 = ((hash_int // 100) % TOTAL_GRADE_4) + 1
    task_5 = ((hash_int // 10000) % TOTAL_GRADE_5) + 1
    return task_3, task_4, task_5


def main():
    parser = argparse.ArgumentParser(description="Генератор варианта курсовой по ВС АСОИУ")
    parser.add_argument("--year", help="год, например 2026")
    parser.add_argument("--group", help="группа, например ИУ5-41Б")
    parser.add_argument("--variant", help="номер в журнале")
    args = parser.parse_args()

    year = args.year or input("Год: ").strip()
    group = args.group or input("Группа: ").strip()
    variant = args.variant or input("Номер в журнале: ").strip()

    # В методичке year/variant передаются числами, group — строкой; в f-строке
    # результат одинаков, поэтому приводить типы не нужно.
    t3, t4, t5 = pick_tasks(year, group, variant)
    name5, custom5 = TASKS_5[t5 - 1]

    line = "=" * 80
    print(line)
    print(f"КУРСОВОЙ ПРОЕКТ: Группа {group}, Вариант {variant}, Год {year}")
    print(line)
    print("Вам необходимо спроектировать процессор (SoC) и выполнить задание")
    print("в зависимости от оценки, на которую вы претендуете:")
    print("-" * 80)
    print(f"НА ОЦЕНКУ «3»: алгоритм №{t3} — {TASKS_3[t3 - 1]}")
    print(f"НА ОЦЕНКУ «4»: утилита №{t4} — {TASKS_4[t4 - 1]}")
    print(f"НА ОЦЕНКУ «5»: игра/приложение №{t5} — {name5}; кастомная инструкция: {custom5}")
    print(line)


if __name__ == "__main__":
    main()
