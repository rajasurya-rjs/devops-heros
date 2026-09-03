# Linux Fundamentals - Homework

**Name:** Rajasurya J

## Environment note (please read first)

My laptop is a MacBook Air (macOS 26.6, Apple Silicon). macOS is Unix but it is
**not** Linux - it has no `useradd`, no `adduser`, no `journalctl` and no `ip`
command. So instead of faking the output, I built a real Ubuntu 22.04 container
with systemd running inside it and did the whole Linux homework there.

```bash
# Dockerfile I used for the practice box (homework/linux/Dockerfile)
docker build -t linux-hw:latest .

docker run -d --name linux-hw \
  --privileged --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --tmpfs /run --tmpfs /run/lock \
  linux-hw:latest

docker exec -it linux-hw bash
```

Checking that systemd actually booted (this is what makes `journalctl` work):

```
$ systemctl is-system-running
running

$ systemctl --version | head -1
systemd 249 (249.11-0ubuntu3.22)
```

All the outputs below are copy-pasted from that container. The hostname
`2ce981e561e9` in the prompts is the container ID.

---

## Task 1 - Soft link vs Hard link

### What they are

| | Hard link | Soft link (symbolic link) |
|---|---|---|
| What it points to | The **inode** (the actual data on disk) | The **path/filename** as a string |
| Command | `ln file link` | `ln -s file link` |
| Own inode? | No - shares the same inode | Yes - it is its own tiny file |
| Original deleted | Link still works, data survives | Link breaks (dangling link) |
| Works across filesystems? | No | Yes |
| Can link a directory? | No | Yes |
| `ls -l` type char | `-` (normal file) | `l` |

Every file on Linux is really an **inode** (metadata + pointer to data blocks).
A filename is just a directory entry pointing to an inode. A hard link is simply
a **second name for the same inode**, so the file has a link count of 2. The data
is only freed when the link count drops to 0.

### Creating the links

```
$ mkdir -p /root/links-practice && cd /root/links-practice
$ echo "Hello from the original file" > original.txt
$ cat original.txt
Hello from the original file

$ ln original.txt hardlink.txt        # hard link
$ ln -s original.txt softlink.txt     # soft link

$ ls -li
total 8
228081 -rw-r--r-- 2 root root 29 Sep  3 12:25 hardlink.txt
228081 -rw-r--r-- 2 root root 29 Sep  3 12:25 original.txt
228082 lrwxrwxrwx 1 root root 12 Sep  3 12:25 softlink.txt -> original.txt
```

This one output shows almost everything:

- `original.txt` and `hardlink.txt` both have inode **228081** - same file, two names.
- Their link count is **2** (the number right after the permissions).
- `softlink.txt` has a different inode **228082**, link count 1, type `l`, and
  `ls` even prints `-> original.txt`.
- The soft link is only 12 bytes = the length of the string `original.txt`.

### Both links see updates to the original

```
$ echo "second line added later" >> original.txt

$ cat hardlink.txt
Hello from the original file
second line added later

$ cat softlink.txt
Hello from the original file
second line added later
```

### Now delete the original (the important part)

```
$ rm original.txt

$ ls -li
total 4
228081 -rw-r--r-- 1 root root 53 Sep  3 12:25 hardlink.txt
228082 lrwxrwxrwx 1 root root 12 Sep  3 12:25 softlink.txt -> original.txt

$ cat hardlink.txt
Hello from the original file
second line added later

$ cat softlink.txt
cat: softlink.txt: No such file or directory
exit code was: 1
```

What happened:

- The hard link **still works** and still has all the data, because inode 228081
  still had one name pointing at it. Notice the link count went from `2` to `1`.
- The soft link is now **broken/dangling**. It still stores the text
  `original.txt`, but there is no such file any more, so `cat` fails.

### Limitations of hard links (tested, not just theory)

**1. You cannot hard link a directory:**

```
$ mkdir mydir
$ ln mydir dirlink
ln: mydir: hard link not allowed for directory
exit code: 1

$ ln -s mydir dirlink        # soft link to a directory is fine
$ ls -ld dirlink
lrwxrwxrwx 1 root root 5 Sep  3 12:26 dirlink -> mydir
```

Reason: directory hard links could create loops in the filesystem tree and
`fsck`/`find` would never terminate, so the kernel simply forbids it.

**2. You cannot hard link across filesystems.** I mounted a tmpfs to get a
second filesystem to prove it:

```
$ mount -t tmpfs tmpfs /tmp_fs
$ df -hT /root /tmp_fs
Filesystem     Type     Size  Used Avail Use% Mounted on
overlay        overlay   95G   38G   52G  42% /
tmpfs          tmpfs    987M     0  987M   0% /tmp_fs

$ ln hardlink.txt /tmp_fs/cross.txt
ln: failed to create hard link '/tmp_fs/cross.txt' => 'hardlink.txt': Invalid cross-device link
exit code: 1

$ ln -s /root/links-practice/hardlink.txt /tmp_fs/cross-soft.txt
$ cat /tmp_fs/cross-soft.txt
Hello from the original file
second line added later
```

Reason: inode numbers are only unique **inside one filesystem**. Inode 228081 on
the overlay fs has nothing to do with inode 228081 on the tmpfs, so a hard link
across the two would be meaningless. A soft link just stores a path string, so
it does not care.

### Interview-style summary

> A hard link is another directory entry pointing to the same inode, so it is
> indistinguishable from the original file and the data survives until the last
> link is removed. A soft link is a separate small file whose content is a path;
> it can cross filesystems and point at directories, but it breaks if the target
> is moved or deleted.

---

## Task 2 - `adduser` vs `useradd`

### What they actually are

```
$ which adduser useradd
/usr/sbin/adduser
/usr/sbin/useradd

$ head -3 /usr/sbin/adduser
#!/usr/bin/perl

# adduser: a utility to add users to the system
```

So on Debian/Ubuntu:

- **`useradd`** is the low-level binary that comes with the `shadow` package. It
  is available on basically every Linux distro and does exactly what you tell it
  and nothing more.
- **`adduser`** is a **Perl script wrapper around `useradd`**, specific to
  Debian/Ubuntu. It is interactive and applies sensible defaults from a config
  file.

Defaults `adduser` reads from `/etc/adduser.conf`:

```
$ grep -vE "^#|^$" /etc/adduser.conf | head -20
DSHELL=/bin/bash
DHOME=/home
GROUPHOMES=no
LETTERHOMES=no
SKEL=/etc/skel
FIRST_SYSTEM_UID=100
LAST_SYSTEM_UID=999
FIRST_SYSTEM_GID=100
LAST_SYSTEM_GID=999
FIRST_UID=1000
LAST_UID=59999
FIRST_GID=1000
LAST_GID=59999
USERGROUPS=yes
USERS_GID=100
DIR_MODE=0750
SETGID_HOME=no
QUOTAUSER=""
SKEL_IGNORE_REGEX="dpkg-(old|new|dist|save)"
```

### Test A - plain `useradd`

```
$ useradd testuser1
exit code: 0

$ grep "^testuser1:" /etc/passwd
testuser1:x:1000:1000::/home/testuser1:/bin/sh

$ ls -ld /home/testuser1
ls: cannot access '/home/testuser1': No such file or directory

$ passwd -S testuser1
testuser1 L 09/03/2026 0 99999 7 -1
```

Look at what it did **not** do:

- No home directory was created (`/home/testuser1` does not exist) even though
  `/etc/passwd` claims it is there.
- The shell defaulted to `/bin/sh`, not bash.
- Password status is `L` = **locked**, so the account cannot log in.
- No GECOS/full name.

To get a usable account with `useradd` you would have to spell it all out:
`useradd -m -s /bin/bash -c "Full Name" username && passwd username`.

### Test B - `adduser` (the recommended way on Ubuntu)

```
$ adduser --gecos "DevOps Homework Test User" --disabled-password devopsuser
Adding user `devopsuser' ...
Adding new group `devopsuser' (1001) ...
Adding new user `devopsuser' (1001) with group `devopsuser' ...
Creating home directory `/home/devopsuser' ...
Copying files from `/etc/skel' ...
exit code: 0
```

Normally `adduser devopsuser` asks the questions interactively (password, full
name, room number, phone...). I passed `--gecos` and `--disabled-password` so it
would run non-interactively for this homework, then set the password separately.

Verifying:

```
$ grep "^devopsuser:" /etc/passwd
devopsuser:x:1001:1001:DevOps Homework Test User,,,:/home/devopsuser:/bin/bash

$ id devopsuser
uid=1001(devopsuser) gid=1001(devopsuser) groups=1001(devopsuser)

$ ls -la /home/devopsuser
total 20
drwxr-x--- 2 devopsuser devopsuser 4096 Sep  3 12:26 .
drwxr-xr-x 1 root       root       4096 Sep  3 12:26 ..
-rw-r--r-- 1 devopsuser devopsuser  220 Sep  3 12:26 .bash_logout
-rw-r--r-- 1 devopsuser devopsuser 3771 Sep  3 12:26 .bashrc
-rw-r--r-- 1 devopsuser devopsuser  807 Sep  3 12:26 .profile
```

In one command it created the group, the user, the home directory with mode
`0750`, copied the skeleton dotfiles from `/etc/skel`, and gave a proper bash shell.

Setting a password and actually logging in as the new user:

```
$ echo "devopsuser:Devops@2026" | chpasswd
$ passwd -S devopsuser
devopsuser P 09/03/2026 0 99999 7 -1      # P = usable password now

$ su - devopsuser -c 'whoami; pwd; echo "hello from $(whoami)" > mynote.txt; cat mynote.txt; ls -l'
devopsuser
/home/devopsuser
hello from devopsuser
total 4
-rw-rw-r-- 1 devopsuser devopsuser 22 Sep  3 12:26 mynote.txt
```

The account works - it logs in, lands in its own home directory and can write files.

### Cleanup

I removed the throwaway `useradd` account and kept only the one the task asked
for:

```
$ userdel -r testuser1
userdel: testuser1 mail spool (/var/mail/testuser1) not found
userdel: testuser1 home directory (/home/testuser1) not found
exit code: 0

$ awk -F: '$3>=1000 && $3<65534 {print $1"  uid="$3"  home="$6"  shell="$7}' /etc/passwd
devopsuser  uid=1001  home=/home/devopsuser  shell=/bin/bash
```

(The two `userdel` warnings are expected - `useradd` never created the home dir
or mail spool in the first place, which is exactly the point of this task.)

### Which one should I use?

On **Ubuntu/Debian: `adduser`**, because it is the friendly front-end that does
the right thing by default (home dir, group, skel files, bash, password prompt).
`useradd` is what you use in **scripts and Dockerfiles**, or on RHEL/CentOS/Alpine
where `adduser` either does not exist or behaves differently. `adduser` is not
portable; `useradd` is.

---

## Task 3 - `journalctl`

`journalctl` is the tool for reading the **systemd journal**. On systemd distros,
`systemd-journald` collects the kernel ring buffer, early boot messages, stdout
and stderr of every service, and syslog messages into one indexed binary journal.
`journalctl` queries it. It replaces having to `tail` a dozen different files in
`/var/log`.

### 1. `journalctl` - the whole journal, oldest first

```
$ journalctl --no-pager | head -15
Sep 03 12:25:30 2ce981e561e9 kernel: Booting Linux on physical CPU 0x0000000000 [0x610f0000]
Sep 03 12:25:30 2ce981e561e9 kernel: Linux version 6.12.68-linuxkit (root@buildkitsandbox) (gcc (Alpine 13.2.1_git20240309) 13.2.1 20240309, GNU ld (GNU Binutils) 2.42) #1 SMP Mon Feb  2 10:12:50 UTC 2026
Sep 03 12:25:30 2ce981e561e9 kernel: OF: reserved mem: Reserved memory: No reserved-memory node in the DT
Sep 03 12:25:30 2ce981e561e9 kernel: Zone ranges:
Sep 03 12:25:30 2ce981e561e9 kernel:   DMA      [mem 0x0000000070000000-0x00000000efffffff]
Sep 03 12:25:30 2ce981e561e9 kernel:   DMA32    empty
Sep 03 12:25:30 2ce981e561e9 kernel:   Normal   empty
Sep 03 12:25:30 2ce981e561e9 kernel: Movable zone start for each node
Sep 03 12:25:30 2ce981e561e9 kernel: Early memory node ranges
Sep 03 12:25:30 2ce981e561e9 kernel:   node   0: [mem 0x0000000070000000-0x00000000efffffff]
Sep 03 12:25:30 2ce981e561e9 kernel: Initmem setup node 0 [mem 0x0000000070000000-0x00000000efffffff]
Sep 03 12:25:30 2ce981e561e9 kernel: psci: probing for conduit method from DT.
Sep 03 12:25:30 2ce981e561e9 kernel: psci: PSCIv1.1 detected in firmware.
Sep 03 12:25:30 2ce981e561e9 kernel: psci: Using standard PSCI v0.2 function IDs
Sep 03 12:25:30 2ce981e561e9 kernel: psci: Trusted OS migration not required
```

`--no-pager` just stops it opening `less`.

### 2. `journalctl -n 10` - the last N entries

```
$ journalctl -n 10 --no-pager
Sep 03 12:26:26 2ce981e561e9 systemd[172]: Reached target Basic System.
Sep 03 12:26:26 2ce981e561e9 systemd[172]: Reached target Main User Target.
Sep 03 12:26:26 2ce981e561e9 systemd[172]: Startup finished in 40ms.
Sep 03 12:26:26 2ce981e561e9 systemd[1]: Started User Manager for UID 1001.
Sep 03 12:26:26 2ce981e561e9 systemd[1]: Started Session c1 of User devopsuser.
Sep 03 12:26:26 2ce981e561e9 su[167]: pam_unix(su-l:session): session closed for user devopsuser
Sep 03 12:26:26 2ce981e561e9 systemd[1]: session-c1.scope: Deactivated successfully.
Sep 03 12:26:26 2ce981e561e9 userdel[183]: delete user 'testuser1'
Sep 03 12:26:26 2ce981e561e9 userdel[183]: removed group 'testuser1' owned by 'testuser1'
Sep 03 12:26:26 2ce981e561e9 userdel[183]: removed shadow group 'testuser1' owned by 'testuser1'
```

This is a nice accident - the last few lines are literally the `su - devopsuser`
and `userdel testuser1` I ran in **Task 2**. The journal picked up my own work,
which is a good demonstration that it logs everything system-wide.

### 3. `journalctl -b` - only the current boot

```
$ journalctl -b --no-pager | head -10
Sep 03 12:25:30 2ce981e561e9 kernel: Booting Linux on physical CPU 0x0000000000 [0x610f0000]
...

$ journalctl -b --no-pager | wc -l
843

$ journalctl --list-boots --no-pager
 0 e266164d1ed54bef80857fe01fd320f1 Thu 2026-09-03 12:25:30 UTC-Thu 2026-09-03 12:26:38 UTC
```

`-b` = current boot, `-b -1` = previous boot. This is how you check "did it log
anything before it crashed and rebooted".

### 4. `journalctl -u <service>` - logs for one service

I started nginx as a real systemd service so there was something to look at:

```
$ systemctl start nginx
$ systemctl is-active nginx
active

$ journalctl -u nginx --no-pager
Sep 03 12:26:37 2ce981e561e9 systemd[1]: Starting A high performance web server and a reverse proxy server...
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Started A high performance web server and a reverse proxy server.
```

Then restarted it and looked again - the stop/start cycle is recorded:

```
$ systemctl restart nginx
$ journalctl -u nginx -n 8 --no-pager
Sep 03 12:26:37 2ce981e561e9 systemd[1]: Starting A high performance web server and a reverse proxy server...
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Started A high performance web server and a reverse proxy server.
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Stopping A high performance web server and a reverse proxy server...
Sep 03 12:26:38 2ce981e561e9 systemd[1]: nginx.service: Deactivated successfully.
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Stopped A high performance web server and a reverse proxy server.
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Starting A high performance web server and a reverse proxy server...
Sep 03 12:26:38 2ce981e561e9 systemd[1]: Started A high performance web server and a reverse proxy server.
```

This is the one I will use most in real life: *"the service won't start, what does
`journalctl -u <service> -n 50` say"*.

### 5. Filtering by priority and time

```
$ journalctl -p err -b --no-pager
Sep 03 12:26:25 2ce981e561e9 su[167]: pam_env(su-l:session): Unable to open env file: /etc/default/locale: No such file or directory

$ journalctl --since "10 minutes ago" -n 5 --no-pager
Sep 03 12:25:30 2ce981e561e9 kernel: Booting Linux on physical CPU 0x0000000000 [0x610f0000]
...

$ journalctl --disk-usage
Archived and active journals take up 16.0M in the file system.
```

`-p err` shows only priority `err` and worse. The single error found is a minor
locale warning from my `su` in Task 2 - a slim container image has no
`/etc/default/locale`. Harmless, but it proves the filter works.

### Cheat sheet of the options I practised

| Command | What it does |
|---|---|
| `journalctl` | whole journal, oldest first |
| `journalctl -n 20` | last 20 lines |
| `journalctl -f` | follow live, like `tail -f` |
| `journalctl -b` | current boot only |
| `journalctl -b -1` | previous boot |
| `journalctl -u nginx` | one service |
| `journalctl -u nginx -f` | follow one service live |
| `journalctl -p err` | errors and worse |
| `journalctl --since "1 hour ago"` | time window |
| `journalctl --since today --until "12:00"` | time range |
| `journalctl -k` | kernel messages only (= `dmesg`) |
| `journalctl --disk-usage` | how big the journal is |
| `journalctl --vacuum-time=7d` | delete journal older than 7 days |
| `journalctl -o json-pretty` | structured output |

I did not run `journalctl -f` or `--vacuum-time` in the transcript above -
`-f` never exits so there is nothing to paste, and I did not want to delete logs
on the box I was still using.

---

## Task 4 - Linux command cheat sheet

I set up a small practice folder and actually ran everything below.

```
$ mkdir -p cheatsheet-practice/{docs,logs} && cd cheatsheet-practice
$ printf "alpha\nbravo\ncharlie\ndelta\necho\nfoxtrot\n" > docs/words.txt
$ printf "...4 log lines..." > logs/app.log
```

### Navigation and listing

```
$ pwd
/root/cheatsheet-practice

$ ls -l
total 8
drwxr-xr-x 2 root root 4096 Sep  3 12:26 docs
drwxr-xr-x 2 root root 4096 Sep  3 12:26 logs

$ tree .
.
|-- docs
|   `-- words.txt
`-- logs
    `-- app.log

2 directories, 2 files
```

### Reading files

```
$ cat docs/words.txt
alpha
bravo
charlie
delta
echo
foxtrot

$ head -3 docs/words.txt
alpha
bravo
charlie

$ tail -2 docs/words.txt
echo
foxtrot

$ wc -l docs/words.txt
6 docs/words.txt
```

`less file` is the interactive pager (`q` to quit, `/word` to search) - can't
paste output for that one since it takes over the screen.

### Searching

```
$ grep ERROR logs/app.log
2026-09-03 ERROR db connection refused

$ grep -c INFO logs/app.log
2

$ find . -type f -name "*.log"
./logs/app.log
```

### Copy / move / delete / permissions

```
$ cp docs/words.txt docs/words-backup.txt && ls docs
words-backup.txt
words.txt

$ mv docs/words-backup.txt docs/words.bak && ls docs
words.bak
words.txt

$ touch script.sh && ls -l script.sh
-rw-r--r-- 1 root root 0 Sep  3 12:27 script.sh

$ chmod +x script.sh && ls -l script.sh
-rwxr-xr-x 1 root root 0 Sep  3 12:27 script.sh

$ chown devopsuser:devopsuser docs/words.bak && ls -l docs/words.bak
-rw-r--r-- 1 devopsuser devopsuser 39 Sep  3 12:27 docs/words.bak

$ rm docs/words.bak && ls docs
words.txt
```

`chmod +x` is visible in the output - the mode went from `-rw-r--r--` to
`-rwxr-xr-x`. `chown` changed the owner from `root` to `devopsuser` (the user I
created in Task 2).

### System information

```
$ whoami
root

$ hostname
2ce981e561e9

$ uname -a
Linux 2ce981e561e9 6.12.68-linuxkit #1 SMP Mon Feb  2 10:12:50 UTC 2026 aarch64 aarch64 aarch64 GNU/Linux

$ id
uid=0(root) gid=0(root) groups=0(root)

$ date
Thu Sep  3 12:27:01 UTC 2026

$ uptime
 12:27:01 up 3 min,  0 users,  load average: 3.63, 2.65, 1.12
```

`aarch64` because my Mac is Apple Silicon, so the container runs ARM64 Linux.

### Disk and memory

```
$ df -h /
Filesystem      Size  Used Avail Use% Mounted on
overlay          95G   39G   52G  43% /

$ du -sh /root/cheatsheet-practice
20K	/root/cheatsheet-practice

$ free -h
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       1.0Gi        31Mi        12Mi       893Mi       823Mi
Swap:          1.0Gi       195Mi       828Mi
```

`df` = **disk free** per filesystem. `du` = **disk usage** of a directory tree.
Easy to mix up: `df` answers "is the disk full", `du` answers "what is eating it".

### Processes

```
$ ps aux | head -6
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.3  0.4  17712  9272 ?        Ss   12:25   0:00 /lib/systemd/systemd
root          23  0.1  0.7  39820 14268 ?        S<s  12:25   0:00 /lib/systemd/systemd-journald
message+     168  0.0  0.2   8724  4084 ?        Ss   12:26   0:00 @dbus-daemon --system ...
root         170  0.2  0.3  15664  6872 ?        Ss   12:26   0:00 /lib/systemd/systemd-logind
root         220  0.0  0.1  55072  2280 ?        Ss   12:26   0:00 nginx: master process /usr/sbin/nginx
```

PID 1 is `systemd` - that is what makes this a proper Linux box and not just a
process in a container. `systemd-journald` (PID 23) is the daemon behind Task 3,
and nginx (PID 220) is the service I started for `journalctl -u nginx`.

`top` / `htop` are the live versions - again nothing to paste because they are
full-screen interactive.

### Quick reference table

| Command | Purpose |
|---|---|
| `pwd` | print working directory |
| `ls -l` / `ls -la` / `ls -li` | list; long / include hidden / show inodes |
| `cd path` | change directory (`cd ..` up, `cd ~` home, `cd -` previous) |
| `mkdir -p a/b/c` | create directories, `-p` makes parents |
| `touch file` | create empty file / update timestamp |
| `cp src dst` | copy (`-r` for directories) |
| `mv src dst` | move or rename |
| `rm file` | delete (`-r` recursive, `-f` force - be careful) |
| `cat file` | print whole file |
| `less file` | page through a file interactively |
| `head -n N` / `tail -n N` | first / last N lines (`tail -f` follows) |
| `grep pattern file` | search text (`-i` ignore case, `-r` recursive, `-c` count, `-n` line numbers) |
| `find . -name "*.log"` | find files by name/type/size/time |
| `wc -l` | count lines |
| `chmod` | change permissions (`+x`, or numeric like `755`) |
| `chown user:group` | change owner and group |
| `ps aux` | snapshot of all processes |
| `top` | live process/CPU view |
| `kill PID` / `kill -9 PID` | stop a process |
| `df -h` | free space per filesystem |
| `du -sh dir` | size of a directory |
| `free -h` | RAM and swap usage |
| `whoami` / `id` | current user / uid, gid, groups |
| `hostname` | machine name |
| `uname -a` | kernel and architecture |
| `uptime` | how long up + load average |
| `date` | current date and time |
| `ip addr` / `ip route` | IP addresses / routing table |
| `ping host` | test reachability |
| `curl url` | HTTP request from the terminal |
| `history` | previously run commands |
| `man cmd` | manual page for a command |

---

## What I learned

- An inode is the real file; filenames are just labels pointing at it. That one
  idea explains hard links, link counts and why `rm` doesn't always free space.
- `adduser` vs `useradd` is really "Debian convenience wrapper vs portable
  low-level tool" - and the `ls: cannot access /home/testuser1` output made the
  difference obvious immediately.
- `journalctl -u <service>` is the fastest way to debug a service that won't
  start, and everything on a systemd box goes into one queryable journal.
- macOS is not a substitute for Linux for this kind of work. Spinning up a
  container with systemd took five minutes and gave me a genuine environment.
