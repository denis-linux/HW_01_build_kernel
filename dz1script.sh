#!/bin/bash

# нужные команды спрятаны в функции

function how_install_kernel(){
    # Установить все необходимые пакеты одной командой
sudo dpkg -i linux-image-7.0.3_7.0.3-11_amd64.deb \
            linux-headers-7.0.3_7.0.3-11_amd64.deb \
            linux-libc-dev_7.0.3-11_amd64.deb
}


#где конфиг для дз?? 
function where_config(){
# Распакуйте image пакет
dpkg-deb -R linux-image-7.0.3_7.0.3-1_amd64.deb ./image_extracted
# config лежит здесь:
cat image_extracted/boot/config-7.0.3

#его надо скопировать и отправить на проверку дз
}

function install_apt(){
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev bc rsync wget dpkg-dev dwarves kmod cpio debhelper-compat libdw-dev libelf-dev debhelper

wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.3.tar.xz
tar -xf linux-7.0.3.tar.xz
cd linux-7.0.3
}


# 
function install_dnf(){
# эти команды не проверялись (!), но возможно помогут вам на редхат подобных ОС Линукс

sudo dnf groupinstall -y "Development Tools"

sudo dnf install -y \
    bison \          # Замена bison
    flex \           # Замена flex
    openssl-devel \  # Замена libssl-dev
    bc \             # bc (есть в репозиториях)
    rsync \          # rsync
    wget \           # wget
    dwarves \        # Пакет для DWARF (из EPEL)
    elfutils-libelf-devel \ # Обработка ELF-файлов
    ncurses-devel \  # Замена libncurses-dev
    kmod \           # Инструменты для работы с модулями ядра
    gcc \            # Компилятор C
    gcc-c++          # Компилятор C++ зачем-то, но видимо надо

wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.3.tar.xz
tar -xf linux-7.0.3.tar.xz
cd linux-7.0.3
}

function start_comp(){
make -j$(nproc) bindeb-pkg 2>error.log
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
    echo -e "ОТКЛЮЧЕНИЕ модуля $1"
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
    echo "vim .config"
    
    # Устанавливаем параметры отладки для ядра 7.x
    ./scripts/config --set-val CONFIG_DEBUG_INFO y
    ./scripts/config --set-val CONFIG_DEBUG_INFO_NONE n
    #./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF4 y
    ./scripts/config --set-val CONFIG_DEBUG_INFO_DWARF5 y # В ядре 7.x лучше DWARF5 вместо DWARF4
    
    make olddefconfig 
    make localmodconfig
    echo -e "olddefconfig ok"
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
echo "make -j$(nproc) bindeb-pkg"
