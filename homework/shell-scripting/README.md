# Shell Scripting - Homework

**Name:** Rajasurya J
**Roll number:** 24BCS10086

## Objective

Write one shell script (`system-info.sh`) that collects basic system information
and also practises the shell features from the session:

| Requirement | Where it is in the script |
|---|---|
| Print the current date | `date` stored in `$current_date` |
| Print the hostname | `hostname` stored in `$host_name` |
| Print the username | `whoami` stored in `$user_name` |
| Print the disk usage | `df -h` |
| Print the running processes | `ps aux \| head -11` |
| Use variables | `current_date`, `host_name`, `user_name`, `report_dir`, ... |
| Take user input with `read -p` | name, roll number, comment |
| Create a directory with `mkdir` | `mkdir -p "$report_dir"` |
| Create a file with `touch` | `touch "$process_file"` |
| Store processes in a file with `>` | `ps aux > "$process_file"` |
| `echo` | used all through the script |

## The script

Full source: [`system-info.sh`](system-info.sh)

The parts that matter:

```bash
# ---------- variables ----------
current_date=$(date)
current_day=$(date '+%Y-%m-%d')
host_name=$(hostname)
user_name=$(whoami)
report_dir="system-report-$current_day"
process_file="$report_dir/process.log"
summary_file="$report_dir/summary.txt"
```

I used **command substitution** `$( )` to run a command and store its output in a
variable, instead of printing it directly. The report directory name is built
from a variable too, so every run makes a folder named after that day.

```bash
# ---------- take input from the user ----------
read -p "Enter your name: " name
read -p "Enter your roll number: " roll_no
read -p "Enter a short comment: " comment
```

`read -p` prints the prompt and waits on the same line - without `-p` you would
need a separate `echo -n` first.

```bash
# ---------- create directory and files ----------
mkdir -p "$report_dir"
touch "$process_file"

# ---------- store the process info using > ----------
ps aux > "$process_file"

echo "System Report - $current_date"       > "$summary_file"
echo "----------------------------------" >> "$summary_file"
echo "Hostname   : $host_name"            >> "$summary_file"
```

`mkdir -p` does not error if the directory already exists, so the script can be
re-run safely. `>` **overwrites** the file, `>>` **appends** to it - that is why
the first line of the summary uses `>` and the rest use `>>`.

All variables are in double quotes (`"$report_dir"`) so paths with spaces would
not break the script.

## How I ran it

```bash
cd homework/shell-scripting
chmod +x system-info.sh
./system-info.sh
```

`chmod +x` is needed once, otherwise you get `permission denied`. You could also
run it with `bash system-info.sh` without making it executable.

## Real output

This is the actual terminal session (macOS 26.6 on my MacBook Air):

```
$ ./system-info.sh
======================================================
           SYSTEM INFORMATION REPORT
======================================================

1) Current date and time
   Thu Sep  3 18:08:20 IST 2026

2) Hostname
   Rajasuryas-MacBook-Air.local

3) Logged in user
   rajasurya

4) Disk usage (df -h)
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1s1   228Gi    24Gi   3.3Gi    88%    459k   35M    1%   /
devfs            351Ki   351Ki     0Bi   100%    1.2k     0  100%   /dev
/dev/disk3s6     228Gi    10Gi   3.3Gi    76%      10   35M    0%   /System/Volumes/VM
/dev/disk3s2     228Gi    15Gi   3.3Gi    83%    1.7k   35M    0%   /System/Volumes/Preboot
/dev/disk3s4     228Gi   801Mi   3.3Gi    20%     501   35M    0%   /System/Volumes/Update
/dev/disk1s2     500Mi   6.0Mi   483Mi     2%       1  4.9M    0%   /System/Volumes/xarts
/dev/disk1s1     500Mi   5.8Mi   483Mi     2%      35  4.9M    0%   /System/Volumes/iSCPreboot
/dev/disk1s3     500Mi   960Ki   483Mi     1%      67  4.9M    0%   /System/Volumes/Hardware
/dev/disk3s5     228Gi   173Gi   3.3Gi    99%    2.3M   35M    6%   /System/Volumes/Data
map auto_home      0Bi     0Bi     0Bi   100%       0     0     -   /System/Volumes/Data/home
/dev/disk3s1     228Gi    24Gi   3.3Gi    88%    459k   35M    1%   /System/Volumes/Update/mnt1
/dev/disk4s1     1.4Gi   1.3Gi   3.1Mi   100%    8.2k  4.3G    0%   /Volumes/ChatGPT Installer

5) Running processes (top 10 by memory)
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
rajasurya        74112  23.1  2.6 440943856 217872   ??  S     3:20PM   3:13.51 /Users/rajasurya/.vscode/extensions
rajasurya        23372  18.3  1.4 1890497664 115904   ??  S     5:53PM   1:40.42 /Applications/Docker.app/Contents/
rajasurya        21883  18.0  0.9 437455600  79216   ??  S     5:53PM   1:01.51 /Applications/Docker.app/Contents/M
rajasurya        22683  14.5  3.9 437521456 328816   ??  Rs    5:53PM   9:27.24 /System/Library/Frameworks/Virtuali
rajasurya        69590   8.4  1.5 1949438800 125168   ??  S     3:20PM   3:00.56 /Applications/Visual Studio Code.a
_windowserver      393   5.7  0.3 436269520  25584   ??  Ss   11:35AM  45:19.24 /System/Library/PrivateFrameworks/S
rajasurya        32271   5.0  0.1 435401280   9216   ??  S     6:08PM   0:00.02 /usr/bin/expect -f /private/tmp/cla
rajasurya        32265   4.8  0.0 435307760   3072   ??  Ss    6:08PM   0:00.02 /bin/zsh -c source /Users/rajasurya
rajasurya        69143   4.7  0.5 486362224  42640   ??  S     3:19PM   1:25.92 /Applications/Visual Studio Code.ap
root               493   3.8  0.1 435355872  10480   ??  Ss   11:35AM   1:12.20 /usr/libexec/syspolicyd

======================================================
Please enter your details for the report
======================================================
Enter your name: Rajasurya J
Enter your roll number: 24BCS10086
Enter a short comment: First shell script for the DevOps homework

My name is        : Rajasurya J
My roll number is : 24BCS10086
My comment is     : First shell script for the DevOps homework

======================================================
Creating report files
======================================================
created directory : system-report-2026-09-03
created file      : system-report-2026-09-03/process.log
saved process list into system-report-2026-09-03/process.log
created file      : system-report-2026-09-03/summary.txt

======================================================
Verification
======================================================
total 272
-rw-r--r--  1 rajasurya  staff  133198 Sep  3 18:08 process.log
-rw-r--r--  1 rajasurya  staff     299 Sep  3 18:08 summary.txt

--- first 5 lines of system-report-2026-09-03/process.log ---
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
rajasurya        74112  23.1  2.6 440943856 217872   ??  S     3:20PM   3:13.51 /Users/rajasurya/.vscode/extensions
rajasurya        23372  18.3  1.4 1890497664 115904   ??  S     5:53PM   1:40.42 /Applications/Docker.app/Contents/
rajasurya        21883  18.0  0.9 437455600  79216   ??  S     5:53PM   1:01.51 /Applications/Docker.app/Contents/M
rajasurya        22683  14.5  3.9 437521456 328816   ??  Rs    5:53PM   9:27.24 /System/Library/Frameworks/Virtuali

--- system-report-2026-09-03/summary.txt ---
System Report - Thu Sep  3 18:08:20 IST 2026
----------------------------------
Hostname   : Rajasuryas-MacBook-Air.local
User       : rajasurya
Name       : Rajasurya J
Roll number: 24BCS10086
Comment    : First shell script for the DevOps homework
Processes  :      472 lines saved in process.log

Report generated successfully in ./system-report-2026-09-03
```

**Note on the `ps` lines above:** macOS prints extremely long COMMAND lines
(some Electron apps are 2000+ characters), so in this README I cut them at 115
characters just so the block stays readable. The values are untouched and the
full untrimmed output is committed in
[`system-report-2026-09-03/process.log`](system-report-2026-09-03/) - 472 lines.

## Verification that it actually worked

The generated folder is committed to the repo as proof:

```
homework/shell-scripting/
├── system-info.sh
├── README.md
└── system-report-2026-09-03/
    ├── process.log     <- 472 lines, written by `ps aux > "$process_file"`
    └── summary.txt     <- written with > and >>
```

```
$ ls -l system-report-2026-09-03
-rw-r--r--  1 rajasurya  staff  133198 Sep  3 18:08 process.log
-rw-r--r--  1 rajasurya  staff     299 Sep  3 18:08 summary.txt

$ wc -l system-report-2026-09-03/process.log
     472 system-report-2026-09-03/process.log
```

The directory exists, the file exists, and the process list really is inside it -
`process.log` is 133 KB, which it could only be if `>` actually redirected the
output of `ps aux` into it.

## Explanation of each required command

| Command | What it does | How I used it |
|---|---|---|
| `date` | prints the current date/time | `current_date=$(date)` and `date '+%Y-%m-%d'` for the folder name |
| `hostname` | prints the machine's name | `host_name=$(hostname)` |
| `whoami` | prints the current user | `user_name=$(whoami)` |
| `df -h` | disk free per filesystem, `-h` = human readable (Gi/Mi) | printed in section 4 |
| `ps aux` | snapshot of all running processes; `a` all users, `u` user-friendly columns, `x` including ones with no terminal | printed and redirected to `process.log` |
| `mkdir -p` | create directory, `-p` creates parents and does not fail if it exists | `mkdir -p "$report_dir"` |
| `touch` | create an empty file (or update its timestamp) | `touch "$process_file"` |
| `echo` | print a line of text | used everywhere, including writing the summary file |
| `read -p` | prompt and read one line into a variable | name, roll number, comment |
| Variables | `name=value` to set (no spaces around `=`), `$name` to use | all the `$( )` captures above |
| `>` | redirect stdout to a file, **overwriting** it | `ps aux > "$process_file"` |
| `>>` | redirect stdout to a file, **appending** | building `summary.txt` line by line |
| `$( )` | command substitution - run a command, use its output as a value | `$(date)`, `$(whoami)`, `$(wc -l < "$process_file")` |

## Problems I hit

- The first time I ran it I forgot `chmod +x` and got
  `permission denied`. Adding the execute bit fixed it.
- I originally wrote `ps aux > $process_file` without quotes. It worked, but I
  changed it to `"$process_file"` because if the path ever contained a space the
  shell would split it into two arguments and the redirect would go to the wrong
  place.
- I used `wc -l < "$process_file"` instead of `wc -l "$process_file"` in the
  summary, because passing the filename makes `wc` print the filename too and I
  only wanted the number.

## What I learned

- Variables + command substitution are what turn a list of commands into an
  actual script - I can compute the folder name once and reuse it everywhere.
- The difference between `>` and `>>` is the thing to be careful about; `>`
  silently destroys whatever was in the file.
- `read -p` makes a script interactive, but that also means it will hang forever
  in a cron job or a CI pipeline, so interactive input is only for scripts a
  human runs.
- `mkdir -p` and `touch` are both safe to re-run, which makes the whole script
  idempotent - I can run it as many times as I like without it breaking.
