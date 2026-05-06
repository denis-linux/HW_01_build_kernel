#!/bin/bash

function deleteCASH() {
    rm -f ../linux-u*
    rm -f ../linux-*
}

function makeCONFIG() {
    echo "Создание конфига..."
    rm -f .config
    make defconfig
}

function disable() {
    echo -e "\nОТКЛЮЧЕНИЕ модуля $1\n"
    ./scripts/config --disable "$1"
}

function enable() {
    echo -e "\nВКЛЮЧЕНИЕ модуля $1\n"
    ./scripts/config --enable "$1"
}

function compile_kernel() {
    echo "Проверьте конфиг:"
    echo "vim .config"
    
    # Гарантированно устанавливаем нужные значения
    ./scripts/config --set-val CONFIG_DEBUG_INFO y
    ./scripts/config --set-val CONFIG_DEBUG_INFO_NONE n
    ./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF4 y
    make olddefconfig    
    echo "введи для компиляции "
    echo "time make -j$(nproc) deb-pkg 2>error.log"
}

################ START SCRIPT ####################
#deleteCASH
makeCONFIG

# Отключаем ненужные модули
disable "SECURITY_SELINUX"
disable "SECURITY_SMACK"
disable "SECURITY_TOMOYO"
disable "SECURITY_APPARMOR"
disable "SECURITY_YAMA"
disable "RANDOMIZE_BASE"
disable "CPU_MITIGATIONS"
disable "MITIGATION_SPECTRE_BHI"
disable "MITIGATION_RFDS"
disable "PAGE_TABLE_ISOLATION"
disable "ZSWAP"
#disable "BPF"
#disable "BPF_SYSCALL"
#disable "BPF_JIT"
#disable "BPF_EVENTS"
#disable "BPFILTER"
disable "CONFIG_DEBUG_INFO_NONE"


# Включаем нужные модули
enable "DEBUG_FS"
enable "FTRACE"
enable "FUNCTION_TRACER"
enable "DYNAMIC_FTRACE"
enable "FUNCTION_GRAPH_TRACER"
enable "STACK_TRACER"
enable "KUNIT"
enable "KUNIT_TEST"
enable "KASAN"
enable "STACKTRACE"
enable "KASAN_GENERIC"
enable "KASAN_INLINE"
enable "KASAN_EXTRA_INFO"
enable "KGDB"
enable "KGDB_SERIAL_CONSOLE"
enable "SERIAL_CONSOLE"
enable "CONSOLE_POLL"
enable "KPROBES"
enable "KPROBE_EVENT"

# Явно устанавливаем параметры отладки
./scripts/config --set-val CONFIG_DEBUG_INFO y
./scripts/config --set-val CONFIG_DEBUG_INFO_NONE n
./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF4 y

# Проверяем перед компиляцией
echo "Проверка конфига ДО :"
grep "CONFIG_DEBUG_INFO" .config
grep "CONFIG_DEBUG_INFO_NONE" .config
grep "CONFIG_DEBUG_INFO_DWARF4" .config

compile_kernel

echo "Проверка конфига ПОСЛЕ :"
grep "CONFIG_DEBUG_INFO" .config
grep "CONFIG_DEBUG_INFO_NONE" .config
grep "CONFIG_DEBUG_INFO_DWARF4" .config
