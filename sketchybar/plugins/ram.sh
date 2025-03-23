#!/bin/bash

# Get memory information using vm_stat
PAGE_SIZE=$(vm_stat | grep 'page size of' | awk '{print $8}')
MEM_USED=$(vm_stat | grep 'Pages active\|Pages wired' | awk '{sum+=$NF} END {print sum}')
MEM_USED=$((MEM_USED * PAGE_SIZE / 1024 / 1024))

# Get total physical memory in MB
MEM_TOTAL=$(sysctl -n hw.memsize | awk '{print $0 / 1024 / 1024}')

# Calculate usage percentage
RAM_PERCENT=$(echo "$MEM_USED $MEM_TOTAL" | awk '{printf "%.0f\n", ($1 / $2) * 100}')

sketchybar --set $NAME label="$RAM_PERCENT%"
