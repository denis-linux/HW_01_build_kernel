#!/bin/bash


function install_apt(){
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev bc rsync wget dpkg-dev dwarves kmod cpio debhelper-compat libdw-dev libelf-dev debhelper

wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.3.tar.xz
tar -xf linux-7.0.3.tar.xz
cd linux-7.0.3
}

function install_dnf(){
sudo dnf install -y gcc gcc-c++ make ncurses-devel bison flex openssl-devel bc rsync wget

wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.3.tar.xz
tar -xf linux-7.0.3.tar.xz
cd linux-7.0.3
}

function deleteCASH() {
    rm -f ../linux-u*
    rm -f ../linux-*
}

function makeCONFIG() {
    echo "Создание конфига для ядра 7.0.3..."
    rm -f .config
    # Используем базовую конфигурацию x86_64
    make x86_64_defconfig
    # ИЛИ make defconfig (для архитектуры по умолчанию)
}

function disable() {
    echo -e "\nОТКЛЮЧЕНИЕ модуля $1\n"
    ./scripts/config --disable "$1"
}

function enable() {
    echo -e "\nВКЛЮЧЕНИЕ модуля $1\n"
    ./scripts/config --enable "$1"
}

function set_val() {
    echo -e "\nУСТАНОВКА $1 = $2\n"
    ./scripts/config --set-val "$1" "$2"
}

function compile_kernel() {
    echo "Проверьте конфиг:"
    echo "nano .config"
    
    # Устанавливаем параметры отладки для ядра 7.x
    #set_val "CONFIG_DEBUG_INFO" "y"
    #set_val "CONFIG_DEBUG_INFO_NONE" "n"
    #set_val "CONFIG_DEBUG_INFO_DWARF5" "y"  # В ядре 7.x лучше DWARF5 вместо DWARF4
    ./scripts/config --set-val CONFIG_DEBUG_INFO y
    ./scripts/config --set-val CONFIG_DEBUG_INFO_NONE n
    #./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF4 y
    ./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF5 y
    
    make olddefconfig 
    echo -e "olddefconfig ok"
   # echo "========================================="
   # echo "Для компиляции выполните:"
   # echo "time make -j\$(nproc) bindeb-pkg"
   # echo "========================================="
}

################ START SCRIPT ####################
makeCONFIG

# Отключаем модули (для ядра 7.x некоторые опции могли измениться)
disable "SECURITY_SELINUX"
disable "SECURITY_SMACK"
disable "SECURITY_TOMOYO"
disable "SECURITY_APPARMOR"
disable "SECURITY_YAMA"
disable "RANDOMIZE_BASE"
disable "RANDOMIZE_KSTACK_OFFSET"
disable "RANDOMIZE_MEMORY"
disable "CPU_MITIGATIONS"
disable "MITIGATION_SPECTRE_BHI"
disable "MITIGATION_RFDS"
disable "PAGE_TABLE_ISOLATION"
disable "ZSWAP"
disable "ZRAM" # Новое в ядре 7.x

# Включаем модули отладки
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
enable "CONSOLE_POLL"
enable "KPROBES"
enable "KPROBE_EVENT"

# Для ядра 7.x - новые опции отладки
enable "DEBUG_KMEMLEAK"
enable "DEBUG_STACK_USAGE"
enable "PROVE_LOCKING"

compile_kernel


# Проверка конфига
echo -e "\nПроверка конфига:"
grep "CONFIG_DEBUG_INFO" .config
grep "CONFIG_DEBUG_INFO_NONE" .config
grep "CONFIG_DEBUG_INFO_DWARF5" .config

echo -e "\nПодготовка конфига завершена!"
echo "Запустите компиляцию командой:"
echo "time make -j$(nproc) bindeb-pkg"
