# DevOps Homework

**Name:** Rajasurya J
**Roll number:** 24BCS10086
**Repository:** https://github.com/rajasurya-rjs/devops-heros
**Assignment:** [DevOps Homework doc](https://docs.google.com/document/d/1cjXFYf2Thm8cBEN-0C48B-v02cj3jGLd47lcO18prHE/edit)

All seven sections of the homework, with the actual commands I ran and the real
output they produced.

## Contents

| # | Section | Folder |
|---|---|---|
| 1 | Linux Fundamentals | [`linux/`](linux/README.md) |
| 2 | Shell Scripting | [`shell-scripting/`](shell-scripting/README.md) |
| 3 | Networking | [`networking/`](networking/README.md) |
| 4 | Git and GitHub | [`git/`](git/README.md) |
| 5 | Docker Images (Hello World apps) | [`docker-images/`](docker-images/README.md) |
| 6 | Docker Multi-Stage Build | [`docker-multistage/`](docker-multistage/README.md) |
| 7 | Docker Networking and Volumes | [`docker-networking/`](docker-networking/README.md) |

Screenshots are in [`docs/screenshots/`](docs/screenshots/).

## My setup

- **Laptop:** MacBook Air (Apple Silicon), macOS 26.6
- **Docker:** 29.2.1 (Docker Desktop)
- **Node:** v22.18.0 · **Python:** 3.13.5 · **Java:** OpenJDK 21 (Temurin) · **Git:** 2.48.1

**One important note:** macOS is Unix but it is not Linux. It has no `useradd`,
`adduser`, `journalctl`, `ip` or `ss`. Rather than fake that output, I built an
Ubuntu 22.04 container **with systemd actually running** and did the Linux and
networking sections inside it. The Dockerfile for that box is
[`linux/Dockerfile`](linux/Dockerfile). Every block in this repo says which
machine it was run on.

---

## 1. Linux Fundamentals -> [`linux/README.md`](linux/README.md)

**Objective:** soft vs hard links, `adduser` vs `useradd`, `journalctl`, and a
command cheat sheet.

**What I did:**

- Created a file, a hard link and a soft link, and used `ls -li` to show the hard
  link **shares the original's inode (228081) with a link count of 2** while the
  soft link has its own inode and points at a path.
- Deleted the original: the hard link kept working (link count dropped 2 -> 1),
  the soft link broke with `cat: softlink.txt: No such file or directory`.
- Proved both hard-link limitations for real: `ln: mydir: hard link not allowed
  for directory`, and `Invalid cross-device link` after mounting a tmpfs to get a
  second filesystem.
- Ran `useradd testuser1` and `adduser devopsuser` side by side. `useradd` made
  **no home directory** (`ls: cannot access '/home/testuser1'`) and left the
  account locked; `adduser` created the group, home dir, copied `/etc/skel` and
  gave a bash shell. Then logged in as `devopsuser` and wrote a file to prove the
  account works, and cleaned up the throwaway one.
- Used `journalctl`, `-n`, `-b`, `-p err`, `--since`, `--list-boots` and
  `-u nginx` against a real running nginx service.
- Ran ~30 cheat-sheet commands and recorded the output.

**Learned:** the inode is the real file and a filename is just a label - that one
idea explains link counts, why `rm` doesn't always free space, and why hard links
can't cross filesystems. `journalctl -u <service> -n 50` is the fastest way to
debug a service that won't start.

## 2. Shell Scripting -> [`shell-scripting/README.md`](shell-scripting/README.md)

**Objective:** one script that prints date, hostname, username, disk usage and
processes, uses variables and `read -p`, and creates a directory + file with the
process list saved via `>`.

**Script:** [`shell-scripting/system-info.sh`](shell-scripting/system-info.sh)

```bash
chmod +x system-info.sh
./system-info.sh
```

It ran and produced [`system-report-2026-09-03/`](shell-scripting/system-report-2026-09-03/)
containing `process.log` (**472 lines, 133 KB**, written by `ps aux > "$process_file"`)
and `summary.txt` (built with `>` then `>>`). Both are committed as proof.

**Learned:** `>` overwrites and `>>` appends - the one thing to be careful about.
`read -p` makes a script interactive, which also means it will hang forever in
cron or CI. `mkdir -p` and `touch` make the script safely re-runnable.

## 3. Networking -> [`networking/README.md`](networking/README.md)

**Objective:** run the networking commands and write down what each one does.

**Commands run with real output:** `hostname -I`, `ip addr show`,
`ip -brief addr`, `ip route`, `ip neigh`, `ping`, `nslookup`, `dig`, `curl -I`,
`curl -w`, `ss -tulnp`, `netstat -tulnp`, `netstat -rn`, `traceroute`,
`/etc/resolv.conf`, `/etc/hosts`.

Two things I liked: `eth0@if51` in `ip addr` is literal proof of the veth pair
into the Docker host, and `traceroute` inside the container only got one hop
(`* * *` after that) because Docker Desktop's VM NAT eats the ICMP - so I ran it
on macOS too and got the full path through my ISP into Google's backbone.

**Learned:** there is a debugging ladder - `ip addr`/`ip route` (am I on the
network) -> `ping` (is it reachable) -> `dig` (is it DNS) -> `traceroute` (where
does it break) -> `ss`/`curl` (is the service actually listening).

## 4. Git and GitHub -> [`git/README.md`](git/README.md)

**Objective:** the difference between `git commit -a -m` and `git commit -m`, and
a cherry-pick.

**What I did:**

- Modified a tracked file **and** created a new untracked file. `git commit -m`
  refused (**exit code 1**, "no changes added to commit"). `git commit -a -m`
  committed - but `git show --stat` proved it contained **only** the tracked
  file, and the new file was still untracked afterwards.
- Also showed `-a` stages **deletions** of tracked files.
- Made 3 commits on `git-hw-main`, branched to `feature-pages`, made 3 more, then
  cherry-picked exactly one commit (`1e45e53 add contact page`) back.
- Verified: `contact.html` appeared on main, `about.html` and the footer did
  **not**, and the hash changed `1e45e53` -> `74c7ba6`.

Both branches are pushed so the history is checkable:
[`git-hw-main`](https://github.com/rajasurya-rjs/devops-heros/commits/git-hw-main) ·
[`feature-pages`](https://github.com/rajasurya-rjs/devops-heros/commits/feature-pages)

**Learned:** `-a` is `git add -u`, not `git add .` - it never picks up new files.
Cherry-pick **replays a diff as a new commit**, so the hash always changes; the
same change then exists twice in the repo.

## 5. Docker Images -> [`docker-images/README.md`](docker-images/README.md)

**Objective:** six Hello World web apps, each in its own folder with a Dockerfile,
built, run, and verified in a browser.

| Folder | Stack | Host port | Verified |
|---|---|---|---|
| `nodejs-app` | Express on node:22-alpine | 3001 | 200 + screenshot |
| `python-app` | Flask on python:3.12-slim | 3002 | 200 + screenshot |
| `java-app` | JDK HTTP server, JDK -> JRE multi-stage | 3003 | 200 + screenshot |
| `Apache-app` | httpd:2.4 + static HTML | 3004 | 200 + screenshot |
| `React-app` | Vite build -> nginx (multi-stage) | 3005 | 200 + screenshot |
| `nginx-app` | nginx:alpine + static HTML | 3006 | 200 + screenshot |

All six ran at the same time and all six returned HTTP 200.

**Learned:** the Dockerfile shape is identical across languages - base, workdir,
copy manifest, install, copy code, EXPOSE, CMD. A server must bind `0.0.0.0` not
`127.0.0.1` inside a container. And `curl` is not always enough to verify: the
React app returns an empty `<div id="root">` over the wire because it renders on
the client, so that one genuinely needed a browser screenshot.

## 6. Docker Multi-Stage Build -> [`docker-multistage/README.md`](docker-multistage/README.md)

**Objective:** build and run the class multi-stage Dockerfile, confirm the
message and port 8080.

```
$ curl http://100.128.172.156:8080
<h1>Hello World from Docker Multi-Stage Build!</h1>

$ docker ps --filter name=multistage-app
CONTAINER ID   IMAGE                  STATUS         PORTS                            NAMES
622e32b93a09   multi-stage-hello:v1   Up 4 seconds   100.128.172.156:8080->3000/tcp   multistage-app
```

Host `127.0.0.1:8080` was already taken by a container from another project of
mine, so I published port 8080 on my machine's LAN address instead of stopping
somebody else's stack. Full explanation and the `lsof` evidence are in the
section README.

I also measured whether multi-stage actually helps: for this small Express app,
**249MB -> 243MB** (only 6MB, because it has no devDependencies). For my React
app, **449MB -> 102MB, a 77% cut**.

Task 3 of this section (deploy 3 different app types) is covered by the Node.js,
Python and Java apps above.

**Learned:** `COPY --from=<stage>` is the whole trick, only the last stage becomes
the image, and multi-stage saves exactly as much as the toolchain you manage to
leave behind - which is nothing for a plain Node app and enormous for anything
with a compile step.

## 7. Docker Networking and Volumes -> [`docker-networking/README.md`](docker-networking/README.md)

**Objective:** three containers on three networks with the backend on two of them,
host networking, a bind mount, and overlay networks.

**Task 1** - `frontend-container` (nginx), `backend-container` (alpine),
`db-container` (mysql:8.0) across `frontend-net` / `backend-net` / `database-net`.
The backend sits on two networks (`eth0` 172.22.0.2 + `eth1` 172.21.0.3). Tested:

- frontend -> backend: ping OK by container name
- backend -> frontend: HTTP 200
- backend -> database: ping OK, and a **real SQL `CREATE TABLE` + `INSERT` +
  `SELECT`** over the network
- frontend -> database: `ping: bad address 'db-container'`, and **100% packet
  loss** to its IP - genuine isolation

**Task 2** - Apache on `--network host`, serving "It works!" on **port 80** of the
host network, with no `-p` and an empty PORTS column. Verified from inside the
host namespace; noted honestly that macOS itself can't route into Docker
Desktop's VM without enabling host networking in settings.

**Task 3** - bind-mounted a folder into nginx, edited `index.html` on my Mac, and
the change was served immediately. Proof it never restarted: **same PID 14644,
same StartedAt, RestartCount 0** before and after.
[Before](docs/screenshots/docker-bind-mount-before.png) ·
[After](docs/screenshots/docker-bind-mount-after.png)

**Task 4** - explained overlay networks and demonstrated a real one: `docker
network create --driver overlay` failed with "This node is not a swarm manager",
so I initialised a single-node swarm, created `app-overlay` (driver `overlay`,
**scope `swarm`** vs `local` for bridge), ran a 2-replica service on it, and showed
service DNS resolving `web` -> VIP 10.0.1.2 and `tasks.web` -> 10.0.1.3/10.0.1.4.
I was honest that one laptop cannot demonstrate true multi-host networking, then
left the swarm to put my machine back as it was.

**Learned:** user-defined networks give DNS by container name (the default bridge
does not), splitting networks is a real security boundary for one command, bind
mounts are live and `:ro` is a free security win, and overlay = bridge across
machines using VXLAN, which is why it needs swarm.

---

## Reproducing all of it

```bash
git clone https://github.com/rajasurya-rjs/devops-heros.git
cd devops-heros/homework

# Linux + networking practice box
docker build -t linux-hw:latest linux/
docker run -d --name linux-hw --privileged --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw --tmpfs /run --tmpfs /run/lock linux-hw:latest
docker exec -it linux-hw bash

# shell script
cd shell-scripting && chmod +x system-info.sh && ./system-info.sh

# the six hello world apps
cd ../docker-images
for a in nodejs-app python-app java-app Apache-app React-app nginx-app; do
  docker build -t "hw-$(echo $a | tr 'A-Z' 'a-z')" "$a"
done

# git exercises
git log --oneline --graph --all
```
