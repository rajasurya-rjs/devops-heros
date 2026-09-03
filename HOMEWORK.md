# DevOps Homework - Rajasurya J

**Name:** Rajasurya J
**Enrollment Number:** 24BCS10086
**Repository:** https://github.com/rajasurya-rjs/devops-heros
**Assignment:** [DevOps Homework doc](https://docs.google.com/document/d/1cjXFYf2Thm8cBEN-0C48B-v02cj3jGLd47lcO18prHE/edit)

Each section lives in its own session folder under `Rajasurya-24BCS10086/`, with
a README and an `images/` folder of terminal screenshots.

| # | Section | Folder |
|---|---|---|
| 1 | Linux Fundamentals | [session2-linux](session2-linux/Rajasurya-24BCS10086/README.md) |
| 2 | Shell Scripting | [session3-shell-scripting](session3-shell-scripting/Rajasurya-24BCS10086/README.md) |
| 3 | Networking Fundamentals | [session4-networking](session4-networking/Rajasurya-24BCS10086/README.md) |
| 4 | Git and GitHub | [session5-git-github](session5-git-github/Rajasurya-24BCS10086/README.md) |
| 5 | Docker Fundamentals (Hello World apps) | [session6-docker](session6-docker/Rajasurya-24BCS10086/README.md) |
| 6 | Dockerfiles & Images (multi-stage) | [session7-dockerfiles-images](session7-dockerfiles-images/Rajasurya-24BCS10086/README.md) |
| 7 | Docker Networking & Volumes | [session8-docker-networking-volume](session8-docker-networking-volume/Rajasurya-24BCS10086/README.md) |

## My setup

- **Laptop:** MacBook Air (Apple Silicon), macOS 26.6
- **Docker:** 29.2.1 (Docker Desktop) · **Node:** v22.18.0 · **Python:** 3.13.5
- **Java:** OpenJDK 21 (Temurin) · **Git:** 2.48.1

**One thing worth saying up front:** macOS is Unix but it is not Linux - no
`useradd`, `adduser`, `journalctl`, `ip` or `ss`. Rather than fake that output I
built an **Ubuntu 22.04 container with systemd actually running**
([session2-linux/Rajasurya-24BCS10086/Dockerfile](session2-linux/Rajasurya-24BCS10086/Dockerfile))
and did the Linux and networking sections inside it. Every screenshot says which
machine it was taken on - `root@linux-hw` is the container,
`rajasurya@Rajasuryas-MacBook-Air` is the Mac.

---

## 1. Linux Fundamentals

Soft vs hard links, `adduser` vs `useradd`, `journalctl`, and a command cheat
sheet. Highlights:

- `ls -li` showing the hard link **sharing inode 276447 with link count 2**,
  then the count dropping to 1 after `rm` while the soft link breaks with
  `No such file or directory`.
- Both hard-link limitations proved: `hard link not allowed for directory`, and
  `Invalid cross-device link` after mounting a tmpfs.
- `useradd testuser1` creating **no home directory** and a locked account, vs
  `adduser devopsuser` creating the group, home dir and skel files - then
  actually logging in as that user.
- Real `journalctl -u nginx` output against a live systemd service.

## 2. Shell Scripting

[`system-info.sh`](session3-shell-scripting/Rajasurya-24BCS10086/system-info.sh)
prints date, hostname, user, disk usage and processes, takes three inputs with
`read -p`, then `mkdir`/`touch`/`>` a report. One screenshot captures the entire
interactive run. The generated
[`system-report-2026-09-03/`](session3-shell-scripting/Rajasurya-24BCS10086/system-report-2026-09-03/)
is committed - `process.log` is **537 lines / 151 KB**.

## 3. Networking Fundamentals

`ip addr`, `ip route`, `ip neigh`, `ping`, `nslookup`, `dig`, `curl -I`,
`curl -w`, `ss -tulnp`, `netstat`, `traceroute`, `/etc/resolv.conf`,
`/etc/hosts` - each with real output and what I understood from it. `eth0@if51`
in `ip addr` is literal proof of the veth pair into the Docker host; traceroute
inside the container dies after one hop, so I ran it on the Mac too and got the
full path through my ISP into Google's backbone.

## 4. Git and GitHub

`git commit -m` **refused with exit code 1**, `git commit -a -m` committed but
`git show --stat` proves it contained **only the tracked file** - the new file
stayed untracked. Then 3 commits on `git-hw-main`, 3 on `feature-pages`, and a
cherry-pick of exactly one commit: **`81680dd` -> `2f45cfb`**, with `about.html`
and the footer left behind. Both branches are pushed so the history is checkable:
[git-hw-main](https://github.com/rajasurya-rjs/devops-heros/commits/git-hw-main) ·
[feature-pages](https://github.com/rajasurya-rjs/devops-heros/commits/feature-pages)

## 5. Docker Fundamentals

Six Hello World apps - `nodejs-app`, `python-app`, `java-app`, `Apache-app`,
`React-app`, `nginx-app` - built, all six run at once, all six return **HTTP
200**, all six screenshotted in a browser. The React one is the interesting case:
`curl` returns an empty `<div id="root">` because it renders client-side, so that
one genuinely needed a browser to verify.

## 6. Dockerfiles & Images

The class multi-stage Dockerfile built and run, showing
**`Hello World from Docker Multi-Stage Build!`** on **port 8080** with `docker
ps` and `docker logs` as evidence. I also measured whether multi-stage actually
helps: **249 MB -> 243 MB** for the plain Express app (only 6 MB, because it has
no devDependencies) but **449 MB -> 102 MB** for the React app. Task 3's three
application types are the Node.js, Python and Java apps from Session 6.

## 7. Docker Networking & Volumes

Three containers on three networks with the backend on two of them (`eth0` +
`eth1`); a real `CREATE TABLE`/`SELECT` from the backend into MySQL; the frontend
**unable to resolve or ping** the database (100% packet loss) proving isolation.
Apache on `--network host` serving port 80 with an empty PORTS column. A bind
mount edited live with **the same PID 52643 and RestartCount 0** before and
after. And a real overlay network on a temporary single-node swarm, with the
honest note that one laptop cannot demonstrate true multi-host networking.

---

## A note on the screenshots

Every image in the `images/` folders is a screenshot of a **real terminal
session**. The commands were recorded on a pseudo-terminal as they ran and are
replayed through a terminal emulator to capture them, which is why the shell
prompt, the ANSI colours from `ls`/`git`/`docker`, and the exit codes are all
intact. The same session appears as text in the code block directly above each
image, so the two can be compared line for line.
