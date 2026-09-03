# Networking Fundamentals - Homework

**Name:** Rajasurya J

## Task 1 - Practice the commands / repos shared in the DevOps Hero repo

The networking resources shared in the class repo are listed in
[`session4-networking/resources.md`](../../session4-networking/resources.md):

- https://github.com/stars/Nency-Ravaliya/lists/networking
- https://github.com/Nency-Ravaliya/Network-Troubleshooting
- https://github.com/Nency-Ravaliya/OSI-Network-devices
- https://github.com/Nency-Ravaliya/Networking
- https://github.com/Nency-Ravaliya/Subnetting
- https://github.com/Nency-Ravaliya/IP-quest
- https://github.com/Nency-Ravaliya/IPFIX-NETFLOW-NTP
- https://github.com/Nency-Ravaliya/How-DHCP-Works

My subnetting / IP class notes from the session are in
[`session4-networking/ip.md`](../../session4-networking/ip.md). Task 2 below is
the practical part.

## Environment note

Same as the Linux homework - my host is macOS, which does not have `ip`, `ss` or
`netstat -tulnp` in the Linux form. So the Linux commands were run inside the
Ubuntu 22.04 practice container (`linux-hw`), and I ran `traceroute` on the macOS
host as well because the Docker VM's NAT swallows ICMP past the first hop. Each
block below says which machine it was run on.

---

## 1. `hostname` - what this machine is called

```
[container] $ hostname
2ce981e561e9

[container] $ hostname -I
172.17.0.2
```

`hostname` prints the machine name (here the container ID). `hostname -I` prints
all the IP addresses assigned to it, which is a fast way to answer "what is my
IP" without reading through `ip addr`.

---

## 2. `ip addr show` - interfaces and IP addresses

```
[container] $ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
...  (gre0, gretap0, erspan0, ip_vti0, ip6_vti0, sit0, ip6tnl0, ip6gre0 - all DOWN)
11: eth0@if51: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65535 qdisc noqueue state UP group default
    link/ether 06:a7:f7:9d:9c:70 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

Shorter version, much easier to read:

```
[container] $ ip -brief addr show
lo               UNKNOWN        127.0.0.1/8 ::1/128
tunl0@NONE       DOWN
gre0@NONE        DOWN
gretap0@NONE     DOWN
erspan0@NONE     DOWN
ip_vti0@NONE     DOWN
ip6_vti0@NONE    DOWN
sit0@NONE        DOWN
ip6tnl0@NONE     DOWN
ip6gre0@NONE     DOWN
eth0@if51        UP             172.17.0.2/16
```

**What I understood:**

- `lo` is the loopback interface, always `127.0.0.1/8`. Traffic to it never
  leaves the machine.
- `eth0` is the real interface. It has IP **172.17.0.2** with a **/16** mask,
  meaning the network is `172.17.0.0` and the host part is the last 16 bits -
  that is the default Docker bridge network `docker0`.
- `link/ether 06:a7:f7:9d:9c:70` is the MAC address (layer 2), while `inet` is
  the IP address (layer 3).
- `eth0@if51` - the `@if51` says this is a **veth pair**; the other end is
  interface index 51 on the Docker host. That is literally how container
  networking is wired.
- `brd 172.17.255.255` is the broadcast address for a /16 on 172.17.x.x.
- All the `tunl0/gre0/sit0` interfaces are tunnel stubs the kernel creates; they
  are DOWN and unused.

`ip addr` is the modern replacement for the old `ifconfig` from net-tools.

---

## 3. `ip route` - how packets leave this machine

```
[container] $ ip route
default via 172.17.0.1 dev eth0
172.17.0.0/16 dev eth0 proto kernel scope link src 172.17.0.2
```

Same thing in the old net-tools format:

```
[container] $ netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         172.17.0.1      0.0.0.0         UG        0 0          0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 eth0
```

**What I understood:** the routing table is read most-specific-first.

- Anything destined for `172.17.0.0/16` is on the same link, so it goes straight
  out `eth0` with no gateway (the `U` flag, no `G`).
- Everything else matches the **default route** and is handed to the gateway
  `172.17.0.1` (the `docker0` bridge on the host), which is the `UG` flag.

So "no internet in the container" is usually either a missing default route here
or a DNS problem - and this is the first command to check.

---

## 4. `ip neigh` - the ARP table

```
[container] $ ip neigh
(empty)
```

**What I understood:** `ip neigh` (the modern `arp -a`) shows the IP-to-MAC
mappings the kernel has learned. It was empty because the container had just
booted and had not yet talked to any neighbour on its subnet - the cache is
populated on demand and expires. After pinging another container on the same
network it fills up (I saw this later in the Docker networking homework).

---

## 5. `ping` - is the host reachable, and how far away is it

```
[container] $ ping -c 4 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=63 time=32.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=63 time=26.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=63 time=23.6 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=63 time=23.6 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3018ms
rtt min/avg/max/mdev = 23.588/26.422/32.268/3.543 ms
```

```
[container] $ ping -c 3 google.com
PING google.com (142.251.221.238) 56(84) bytes of data.
64 bytes from pnbomb-bk-in-f14.1e100.net (142.251.221.238): icmp_seq=1 ttl=63 time=19.0 ms
64 bytes from pnbomb-bk-in-f14.1e100.net (142.251.221.238): icmp_seq=2 ttl=63 time=28.4 ms
64 bytes from pnbomb-bk-in-f14.1e100.net (142.251.221.238): icmp_seq=3 ttl=63 time=22.2 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2006ms
rtt min/avg/max/mdev = 19.006/23.194/28.364/3.882 ms
```

**What I understood:**

- `ping` sends ICMP echo requests. `0% packet loss` = the path works both ways.
- `time=` is the **round-trip time**. ~20-30 ms to Google from my connection.
- `ttl=63` - the packet started at TTL 64 and one router decremented it, so the
  reply came back one hop away in TTL terms (Docker's NAT).
- Pinging `google.com` also proves **DNS works**, because it resolved to
  142.251.221.238 first. The reverse name `pnbomb-bk-in-f14.1e100.net` says the
  server is in a Google POP near Mumbai (`bomb` = Bombay), which is why the
  latency is low.
- Useful troubleshooting order: ping the gateway -> ping 8.8.8.8 -> ping a
  domain name. Wherever it first fails tells you if the problem is local
  network, internet routing, or DNS.

---

## 6. `nslookup` and `dig` - DNS resolution

```
[container] $ nslookup github.com
Server:		192.168.65.7
Address:	192.168.65.7#53

Non-authoritative answer:
Name:	github.com
Address: 20.207.73.82
```

```
[container] $ dig github.com +short
20.207.73.82

[container] $ dig github.com A

; <<>> DiG 9.18.39-0ubuntu0.22.04.6-Ubuntu <<>> github.com A
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4105
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;github.com.			IN	A

;; ANSWER SECTION:
github.com.		15	IN	A	20.207.73.82

;; Query time: 2 msec
;; SERVER: 192.168.65.7#53(192.168.65.7) (UDP)
;; WHEN: Thu Sep 03 12:27:21 UTC 2026
;; MSG SIZE  rcvd: 54
```

And where that DNS server came from:

```
[container] $ cat /etc/resolv.conf
# Generated by Docker Engine.
# This file can be edited; Docker Engine will not make further changes once it
# has been modified.

nameserver 192.168.65.7

# Based on host file: '/etc/resolv.conf' (legacy)
# Overrides: []
```

**What I understood:**

- Both tools do the same job; `dig` gives much more detail.
- `Server: 192.168.65.7#53` - queries go to that resolver on **port 53**. In my
  case that is Docker Desktop's internal DNS forwarder, written into
  `/etc/resolv.conf` by the Docker engine.
- `status: NOERROR` = the lookup succeeded (`NXDOMAIN` would mean no such name).
- `github.com. 15 IN A 20.207.73.82` reads as: name, **TTL 15 seconds**, class
  IN, record type **A**, and the IPv4 address. The low TTL means clients
  re-resolve often, which is how GitHub can move traffic between edges quickly.
- `20.207.73.82` is an Azure India address - GitHub answers with an edge near me,
  which is why the earlier `curl -I` header showed
  `x-github-edge-region: centralindia`.
- `dig name +short` is the version I will actually use day to day.

---

## 7. `curl` - talking HTTP from the terminal

```
[container] $ curl -I https://github.com
HTTP/2 200
date: Thu, 03 Sep 2026 12:27:15 GMT
content-type: text/html; charset=utf-8
content-language: en-US
etag: W/"045c19aa505f13769490260b423b7ec0"
cache-control: max-age=0, private, must-revalidate
strict-transport-security: max-age=31536000; includeSubdomains; preload
x-frame-options: deny
x-content-type-options: nosniff
referrer-policy: origin-when-cross-origin, strict-origin-when-cross-origin
content-security-policy: default-src 'none'; base-uri 'self'; ...   <- (this header is ~4000 chars, trimmed here)
server: github.com
accept-ranges: bytes
set-cookie: _octo=GH1.1.1100196032.1788438442; expires=Fri, 03 Sep 2027 ...; secure; SameSite=Lax
set-cookie: logged_in=no; ...
x-github-request-id: D1E9:13E9EB:12891B2:13DDBE2:6A9967AA
x-github-edge-region: centralindia
```

*(I trimmed the `content-security-policy` header - it is genuinely thousands of
characters long and would fill this page. Everything else is exactly as printed.)*

```
[container] $ curl -s https://api.github.com/zen
Avoid administrative distraction.
```

```
[container] $ curl -s -o /dev/null -w "http_code=%{http_code}  time_total=%{time_total}s  remote_ip=%{remote_ip}\n" https://www.google.com
http_code=200  time_total=0.349519s  remote_ip=142.251.157.119
```

**What I understood:**

- `curl -I` sends a **HEAD** request - headers only, no body. Perfect for "is the
  site up and what does it say about itself".
- `HTTP/2 200` - the protocol is HTTP/2 and the status is OK.
- `strict-transport-security`, `x-frame-options: deny`, `x-content-type-options:
  nosniff` and the CSP are all **security headers**. Good thing to recognise.
- `-s` silences the progress meter, `-o /dev/null` throws the body away, and
  `-w` prints exactly the fields I want. That `-w` form is the one I would use
  in a health-check script, because it gives me the status code and the response
  time in one line.
- The response time of 0.35 s for Google includes DNS + TCP + TLS + first byte.

---

## 8. `ss` and `netstat` - which ports are open

```
[container] $ ss -tulnp
Netid State  Recv-Q Send-Q Local Address:Port Peer Address:Port Process
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=224,fd=6),("nginx",pid=223,fd=6),("nginx",pid=222,fd=6),("nginx",pid=221,fd=6),("nginx",pid=220,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=224,fd=7),("nginx",pid=223,fd=7),("nginx",pid=222,fd=7),("nginx",pid=221,fd=7),("nginx",pid=220,fd=7))
```

```
[container] $ netstat -tulnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      220/nginx: master p
tcp6       0      0 :::80                   :::*                    LISTEN      220/nginx: master p
```

```
[container] $ ss -tan state established
Recv-Q Send-Q Local Address:Port Peer Address:Port Process
(no rows - nothing was connected at that moment)
```

**What I understood:**

- Flags: `-t` TCP, `-u` UDP, `-l` listening only, `-n` numeric (don't resolve
  names, much faster), `-p` show the process.
- Only nginx is listening, on **port 80**, on `0.0.0.0` (all IPv4 addresses) and
  `::` (all IPv6). `0.0.0.0` means reachable from outside; if it said
  `127.0.0.1:80` it would only be reachable from inside the machine - that is a
  very common "why can't I reach my app" bug.
- Five nginx PIDs share the same listening socket: 220 is the master and
  221-224 are workers that inherited the fd.
- `Send-Q 511` on a LISTEN row is the **accept backlog**, not queued bytes.
- `ss` is the modern, faster replacement for `netstat`; `netstat` needs the
  `net-tools` package, which is not installed by default on Ubuntu any more.
- This is the command I use to answer "is my app actually listening, and on
  which interface".

---

## 9. `traceroute` - the path to a destination

First inside the container, where it does **not** work properly:

```
[container] $ traceroute -m 8 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 8 hops max, 60 byte packets
 1  172.17.0.1 (172.17.0.1)  0.225 ms  0.021 ms  0.013 ms
 2  * * *
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
```

Only hop 1 (the Docker bridge gateway) answered; after that everything is `*`.
That is because Docker Desktop on macOS runs containers inside a Linux VM whose
NAT does not pass back the ICMP "time exceeded" messages traceroute depends on.
So I ran the same command on the macOS host instead:

```
[macOS host] $ traceroute -m 10 -w 1 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 10 hops max, 40 byte packets
 1  wifi.height8tech.com (100.128.160.1)  9.646 ms  8.314 ms  19.188 ms
 2  114.79.130.29.dvois.com (114.79.130.29)  20.890 ms  19.512 ms  19.497 ms
 3  72.14.208.165 (72.14.208.165)  25.281 ms  21.475 ms  20.000 ms
 4  192.178.110.221 (192.178.110.221)  22.897 ms
    192.178.84.175 (192.178.84.175)  22.243 ms
    192.178.110.221 (192.178.110.221)  21.072 ms
 5  142.251.77.95 (142.251.77.95)  19.601 ms
    142.250.212.171 (142.250.212.171)  19.295 ms
    142.250.238.197 (142.250.238.197)  20.448 ms
 6  dns.google (8.8.8.8)  19.820 ms  20.270 ms  19.995 ms
```

**What I understood:**

- traceroute sends packets with TTL 1, 2, 3... Each router that decrements the
  TTL to zero replies "time exceeded", which is how each hop is discovered.
- Reading my real path: hop 1 is my **local router**, hop 2 is my **ISP**
  (dvois.com), hop 3 is where the ISP **hands off to Google** (72.14.x is
  Google's AS15169), hops 4-5 are inside Google's own backbone, and hop 6 is the
  destination `dns.google`.
- Three timings per hop because it sends three probes.
- Hops 4 and 5 show **different IPs on the same line** - the probes took
  different equal-cost paths through Google's network. Normal for load balancing.
- `* * *` does not necessarily mean broken - lots of routers just don't reply to
  ICMP, exactly as the container case showed.

---

## 10. `/etc/hosts` - static name resolution

```
[container] $ cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::	ip6-localnet
ff00::	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.2	2ce981e561e9
```

**What I understood:** `/etc/hosts` is checked **before** DNS, so it is a manual
override. The last line was added by Docker so the container can resolve its own
hostname. This is also how Docker's user-defined networks let containers reach
each other by name - which is exactly what Task 1 of the Docker networking
homework relies on.

---

## Summary table

| Command | Answers the question |
|---|---|
| `hostname` / `hostname -I` | what am I called / what is my IP |
| `ip addr show` | which interfaces exist and what IPs do they have |
| `ip -brief addr` | the same, in one readable line each |
| `ip route` | where do my packets go, what is my gateway |
| `ip neigh` | which MACs have I learned on this subnet |
| `ping host` | is it reachable, how far, any packet loss |
| `nslookup` / `dig` | what IP does this name resolve to |
| `curl -I url` | is the web service up, what headers does it send |
| `curl -w` | status code and response time for a health check |
| `ss -tulnp` | what is listening on which port, and which process |
| `netstat -rn` | routing table, net-tools style |
| `traceroute host` | what path do packets take, where does it break |
| `cat /etc/resolv.conf` | which DNS server am I using |
| `cat /etc/hosts` | any manual name overrides |

## What I learned overall

The commands split neatly into a debugging ladder, and I now know the order to
try them in:

1. **Layer 2/3 - is my machine on the network?** `ip addr`, `ip route`, `ip neigh`
2. **Reachability** - `ping gateway`, then `ping 8.8.8.8`
3. **DNS** - `dig`/`nslookup`, `cat /etc/resolv.conf`
4. **Path** - `traceroute`
5. **The service itself** - `ss -tulnp` locally, `curl -I` remotely

The nicest thing was seeing theory show up in real output: the `/16` mask in
`ip addr` matching the `172.17.0.0` network in `ip route`, `eth0@if51` proving
the veth pair, and `ttl=63` telling me a router had already touched the packet.
