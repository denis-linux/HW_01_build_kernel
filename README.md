# Скрипт для компиляции ядра Linux

Этот скрипт автоматизирует процесс настройки и компиляции ядра Linux с оптимизированной конфигурацией.

## Особенности конфигурации

### Отключенные модули:
- Все системы безопасности (SELinux, SMACK, TOMOYO, AppArmor, YAMA)
- Механизмы митигации (CPU_MITIGATIONS, SPECTRE_BHI, RFDS)
- Page Table Isolation (PTI)
- Zswap


### Включенные модули:
- DEBUG_FS
- FTRACE с подсистемами (FUNCTION_TRACER, DYNAMIC_FTRACE и др.)
- KUNIT (тестирование)
- KASAN (детектор ошибок памяти)
- KGDB (отладка ядра)
- KPROBES (динамическое трассирование)

# ПЕРЕД ЗАПУСКОМ УСТАНОВИТЬ 


apt install -y build-essential libncurses-dev bison flex libssl-dev bc rsync wget dpkg-dev dwarves kmod cpio

#dnf install -y gcc gcc-c++ make ncurses-devel bison flex openssl-devel bc rsync wget


#by KONOVALOV
