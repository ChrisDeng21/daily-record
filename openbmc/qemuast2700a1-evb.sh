#!/bin/bash

# [ Base Settings ]

# The QEMU tool path depends on your system,
# feel free to adjust it to match your system configuration.
QEMUTOOL=qemu-system-aarch64

# The build path does not require modification,
# but you can change it if it does not meet your system.
BUILD_PATH=build/*/tmp/deploy/images/*

# The port settings does not require modification,
# but you can change it if it does not meet your system.
SSH_PORT=2222
HTTPS_PORT=2443
IPMI_PORT=2623


# [ Functions ]

# ----------------------------------------------------
# Function Definition: dump_variable_info
# Purpose: Prints variable names and their values, with an attempt at alignment.
# Parameters:
#   $@ - One or more variable names (as strings) to be printed.
# Example Usage:
#   my_var="Hello"
#   another_var=123
#   dump_variable_info "my_var" "another_var"
# ----------------------------------------------------
function dump_variable_info()
{
    local name_width=10

    # Ensure at least one argument is passed
    if [ "$#" -eq 0 ]; then
        echo "Usage: dump_variable_info <var_name1> [var_name2] ..."
        return 1 # Return an error code
    fi

    echo "==============================================================================="
    printf "%-${name_width}s | %s\n" "Name" "Value"
    echo "-------------------------------------------------------------------------------"

    # Iterate over all passed variable names
    for var_name in "$@"; do
        # Use indirect expansion (or variable indirection) to get the variable's value
        # This allows us to retrieve the value based on its string name using ${!var_name}
        # If the variable doesn't exist, its value will be an empty string
        local var_value="${!var_name}"

        if [ "$var_name" == "COMMAND" ]; then
            local line_number=0
            while IFS= read -r line; do
                ((line_number++))  # Increase count
                if [ $line_number -eq 1 ]; then
                    printf "%-${name_width}s | %s\n" "$var_name" "$line"
                else
                    printf "%-${name_width}s | %s\n" " " "$line"
                fi
            done <<< "$var_value"
        else
            # Use printf for formatted output, left-aligned
            printf "%-${name_width}s | %s\n" "$var_name" "$var_value"
        fi

    done

    echo "==============================================================================="
}


# [ Check Environments ]

if [[ ! $(which $QEMUTOOL) ]]; then
    echo "Error! QEMU tool not installed."
    exit 1
fi

if [ -d $BUILD_PATH ]; then
    BUILD_DIR=`dirname $BUILD_PATH`
    MACHINE=`basename $BUILD_PATH`
else
    echo "Error! cann't find build folder."
    exit 1
fi

while netstat -tuln | grep ":$SSH_PORT " > /dev/null 2>&1; do
    echo "SSH Port $SSH_PORT is in use, trying next..."
    SSH_PORT=$((SSH_PORT + 1))
done

while netstat -tuln | grep ":$HTTPS_PORT " > /dev/null 2>&1; do
    echo "HTTPS Port $HTTPS_PORT is in use, trying next..."
    HTTPS_PORT=$((HTTPS_PORT + 1))
done

while netstat -tuln | grep ":$IPMI_PORT " > /dev/null 2>&1; do
    echo "IPMI Port $IPMI_PORT is in use, trying next..."
    IPMI_PORT=$((IPMI_PORT + 1))
done

# [ Set Image Variables ]

# Refer https://www.qemu.org/docs/master/system/arm/aspeed.html#booting-the-ast2700-evb-machine
IMGDIR=$BUILD_DIR/$MACHINE
UBOOT_SIZE=$(stat --format=%s -L $IMGDIR/u-boot-nodtb.bin)
read -r -d '' COMMAND << EOM
$QEMUTOOL
 -M ast2700a1-evb
 -device loader,force-raw=on,addr=0x400000000,file=$IMGDIR/u-boot-nodtb.bin
 -device loader,force-raw=on,addr=$((0x400000000 + $UBOOT_SIZE)),file=$IMGDIR/u-boot.dtb
 -device loader,force-raw=on,addr=0x430000000,file=$IMGDIR/bl31.bin
 -device loader,force-raw=on,addr=0x430080000,file=$IMGDIR/optee/tee-raw.bin
 -device loader,cpu-num=0,addr=0x430000000
 -device loader,cpu-num=1,addr=0x430000000
 -device loader,cpu-num=2,addr=0x430000000
 -device loader,cpu-num=3,addr=0x430000000
 -smp 4
 -drive file=$IMGDIR/image-bmc,format=raw,if=mtd
 -nographic
 -net nic
 -net user,hostfwd=:127.0.0.1:$SSH_PORT-:22,hostfwd=:127.0.0.1:$HTTPS_PORT-:443,hostfwd=udp:127.0.0.1:$IPMI_PORT-:623,hostname=qemu
EOM

dump_variable_info "BUILD_DIR" "MACHINE" "IMGDIR" "UBOOT_SIZE" "SSH_PORT" "HTTPS_PORT" "IPMI_PORT" "COMMAND"


# [ Play ]

exec $COMMAND
