#!/bin/bash
#
# This tool is applicable to AspeedTech-BMC v09.07
#
# Author: Chris Deng <chris198421@gmail.com>
#

# ============================================================
# [ Base Settings ]
# ============================================================

# The QEMU tool will be using for ast2700 cpu architecture
QEMUTOOL="qemu-system-aarch64"

# The port settings does not require modification,
# but you can change it if it does not meet your system
SSH_PORT=3222; HTTPS_PORT=3443; IPMI_PORT=3623

# ============================================================
# [ Functions ]
# ============================================================

# Search upward to find 'bitbake' executable path
function search_bitbake() {
    local dir="$1"

    while [ "$dir" != "/" ]; do
        if [ -x "$dir/bitbake" ]; then
            echo "$dir"
            return 0 # Success
        fi
        dir="$(dirname "$dir")"
    done
    return 1 # Failure
}

# Find the directory that contains the file named 'image-bmc'
function find_image_bmc() {
    local dir="$1"
    # Declare a local variable to store the found string
    local image_bmc

    # Store the command's output in the variable
    image_bmc="$(find "$dir" -name image-bmc 2>/dev/null | grep "/tmp/deploy/images/" | sort | head -n 1)"

    if [ -n "$image_bmc" ]; then
        # Return the found path as the function's result (via standard output)
        # This allows the function caller to capture this value
        dirname "$image_bmc"
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Find the QEMU binary under qemu-helper-native path
function find_qemu_for_helper_native() {
    local dir="$1"
    # Declare a local variable to store the found string
    local qemu

    # Store the command's output in the variable
    qemu="$(find $dir -name $QEMUTOOL | grep "/qemu-helper-native/" | sort | head -n 1)"

    if [ -n "$qemu" ]; then
        # Return the found path as the function's result (via standard output)
        # This allows the function caller to capture this value
        echo "$qemu"
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# ----------------------------------------------------
# Function Definition: dump_variable_info
# Purpose: Prints variable names and their values, with an attempt at alignment
# Parameters:
#   $@ - One or more variable names (as strings) to be printed
# Example Usage:
#   my_var="Hello"
#   another_var=123
#   dump_variable_info "my_var" "another_var"
# ----------------------------------------------------
function dump_variable_info() {
    local name_width=12

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
                if [ "$line_number" -eq 1 ]; then
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

# ============================================================
# [ Check Environments ]
# ============================================================

# Get the script's absolute directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Search for the bitbake tool from current directory upward
BITBAKE_DIR="$(search_bitbake "$SCRIPT_DIR")"
if [ $? -ne 0 ] || [ -z "$BITBAKE_DIR" ]; then
    echo "Error! Could not find 'bitbake' in any parent directory."
    exit 1
fi

# Find where the 'image-bmc' is located
IMAGE_DIR="$(find_image_bmc "$BITBAKE_DIR")"
if [ $? -ne 0 ] || [ -z "$IMAGE_DIR" ]; then
    echo "Error! Cannot find build folder (image-bmc not found)."
    exit 1
fi

# Find the qemu binary path from helper-native
QEMU_PATH="$(find_qemu_for_helper_native "$BITBAKE_DIR")"
if [ $? -ne 0 ] || [ -z "$QEMU_PATH" ]; then
    echo "Error! QEMU not found or an issue occurred."
    exit 1
fi

# Check for available SSH port
while ss -tuln | grep -q ":$SSH_PORT "; do
    echo "SSH Port $SSH_PORT is in use, trying next..."
    SSH_PORT=$((SSH_PORT + 1))
done

# Check for available HTTPS port
while ss -tuln | grep -q ":$HTTPS_PORT "; do
    echo "HTTPS Port $HTTPS_PORT is in use, trying next..."
    HTTPS_PORT=$((HTTPS_PORT + 1))
done

# Check for available IPMI port
while ss -tuln | grep -q ":$IPMI_PORT "; do
    echo "IPMI Port $IPMI_PORT is in use, trying next..."
    IPMI_PORT=$((IPMI_PORT + 1))
done

# ============================================================
# [ Set Image Variables ]
# ============================================================

# Prepare the QEMU execution command with port forwarding and image path
read -r -d '' COMMAND_BASE << EOM
$QEMU_PATH
-net nic,netdev=net0
-netdev user,id=net0,hostfwd=tcp:127.0.0.1:$SSH_PORT-:22,hostfwd=tcp:127.0.0.1:$HTTPS_PORT-:443,hostfwd=udp:127.0.0.1:$IPMI_PORT-:623,tftp=$IMAGE_DIR
-drive file=$IMAGE_DIR/image-bmc,if=mtd,format=raw
-machine brunello-bmc
-m 2G
-serial mon:stdio
-serial null
-display none
EOM

# Prepare the QEMU execution command with virtual devices
read -r -d '' COMMAND_VIRTUAL_DEVICES << EOM

EOM

COMMAND="$COMMAND_BASE"$'\n'"$COMMAND_VIRTUAL_DEVICES"

# Prints variable names and their values
dump_variable_info  \
    "QEMUTOOL"      \
    "SSH_PORT"      \
    "HTTPS_PORT"    \
    "IPMI_PORT"     \
    "SCRIPT_DIR"    \
    "BITBAKE_DIR"   \
    "IMAGE_DIR"     \
    "QEMU_PATH"     \
    "COMMAND"

# ============================================================
# [ Play ]
# ============================================================

# Run the QEMU command
eval $COMMAND
exit 0
