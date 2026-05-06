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

apt install -y build-essential libncurses-dev bison flex libssl-dev bc rsync

#dnf install -y gcc gcc-c++ make ncurses-devel bison flex openssl-devel bc rsync

### Основные зависимости для сборки ядра в Ubuntu
sudo apt install -y libncurses-dev bison flex libssl-dev bc rsync

### Дополнительные пакеты, которые могут понадобиться
sudo apt install -y dwarves rpm-binutils kmod cpio

### Для сборки deb-пакетов
sudo apt install -y dpkg-dev

### для работы с git и получением исходников
sudo apt install -y git

#by KONOVALOV
