#!/bin/bash
# =====================================================================
# system-info.sh
# DevOps homework - Shell Scripting task
# Author: Rajasurya J
#
# What it does:
#   prints date, hostname, username, disk usage and running processes,
#   asks the user for a few details with read -p, then creates a report
#   directory + files and saves the process list into a file using >
# =====================================================================

# ---------- variables ----------
current_date=$(date)
current_day=$(date '+%Y-%m-%d')
host_name=$(hostname)
user_name=$(whoami)
report_dir="system-report-$current_day"
process_file="$report_dir/process.log"
summary_file="$report_dir/summary.txt"

echo "======================================================"
echo "           SYSTEM INFORMATION REPORT"
echo "======================================================"

# ---------- 1. current date ----------
echo ""
echo "1) Current date and time"
echo "   $current_date"

# ---------- 2. hostname ----------
echo ""
echo "2) Hostname"
echo "   $host_name"

# ---------- 3. username ----------
echo ""
echo "3) Logged in user"
echo "   $user_name"

# ---------- 4. disk usage ----------
echo ""
echo "4) Disk usage (df -h)"
df -h

# ---------- 5. running processes ----------
echo ""
echo "5) Running processes (top 10 by CPU)"
# cut to terminal width so the report stays readable - the full untrimmed
# output still goes into process.log further down via > redirection
ps aux | head -11 | cut -c1-105

# ---------- 6. take input from the user ----------
echo ""
echo "======================================================"
echo "Please enter your details for the report"
echo "======================================================"
read -p "Enter your name: " name
read -p "Enter your roll number: " roll_no
read -p "Enter a short comment: " comment

echo ""
echo "My name is        : $name"
echo "My roll number is : $roll_no"
echo "My comment is     : $comment"

# ---------- 7. create directory and files ----------
echo ""
echo "======================================================"
echo "Creating report files"
echo "======================================================"

mkdir -p "$report_dir"
echo "created directory : $report_dir"

touch "$process_file"
echo "created file      : $process_file"

# ---------- 8. store the process info in the file using > ----------
ps aux > "$process_file"
echo "saved process list into $process_file"

# write a small summary file too (also using > and >>)
echo "System Report - $current_date"        > "$summary_file"
echo "----------------------------------"  >> "$summary_file"
echo "Hostname   : $host_name"             >> "$summary_file"
echo "User       : $user_name"             >> "$summary_file"
echo "Name       : $name"                  >> "$summary_file"
echo "Roll number: $roll_no"               >> "$summary_file"
echo "Comment    : $comment"               >> "$summary_file"
echo "Processes  : $(wc -l < "$process_file") lines saved in process.log" >> "$summary_file"
echo "created file      : $summary_file"

# ---------- 9. proof that it worked ----------
echo ""
echo "======================================================"
echo "Verification"
echo "======================================================"
ls -l "$report_dir"
echo ""
echo "--- first 5 lines of $process_file (cut to width) ---"
head -5 "$process_file" | cut -c1-105
echo ""
echo "--- $summary_file ---"
cat "$summary_file"

echo ""
echo "Report generated successfully in ./$report_dir"
