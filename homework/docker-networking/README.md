# Docker Networking & Volumes - Homework

**Name:** Rajasurya J
**Roll number:** 24BCS10086

---

# Task 1 - Docker Container Networking

## The topology I built

```
            frontend-net (172.21.0.0/16)        backend-net (172.22.0.0/16)      database-net (172.23.0.0/16)
          ┌──────────────────────────────┐  ┌──────────────────────────────┐  ┌─────────────────────────┐
          │                              │  │                              │  │                         │
  frontend-container ──────────── backend-container ──────────────── db-container ─────────────────────┘
   (nginx:alpine)                  (alpine:3.20)                       (mysql:8.0)
    172.21.0.2                  172.21.0.3 / 172.22.0.2          172.22.0.3 / 172.23.0.2
                                  ON TWO NETWORKS
```

- **frontend** is only on `frontend-net`
- **backend** is on **two** networks - `frontend-net` and `backend-net` (this is
  what the task asked for)
- **database** is on `backend-net` and `database-net`
- so frontend can reach backend, backend can reach the database, and
  **frontend cannot reach the database at all** - the backend is the only way
  through. That is the point of splitting the networks.

## Step 1 - create three networks

```
$ docker network create frontend-net
46a9d1687c43b946a4886d6af7b5562b3fdf1c62163b3de845adaaf4a5fbc10e
$ docker network create backend-net
e8d9fdb47ff205cbd88e9aed63348f633cb6070cca7ccfc71aa30c064b9cdcd2
$ docker network create database-net
4420fe4c162e1f6d98a73aba61084a4db7107c288228ae14e4cd35a983b70de7
```

```
$ docker network ls
NETWORK ID     NAME                   DRIVER    SCOPE
e8d9fdb47ff2   backend-net            bridge    local
b44f256cbe23   bridge                 bridge    local
4420fe4c162e   database-net           bridge    local
46a9d1687c43   frontend-net           bridge    local
9338f9730cbf   healixlabs_default     bridge    local
a8ec5aba019a   host                   host      local
1a3ad8001614   infra_default          bridge    local
ab90e3959af8   none                   null      local
2dea4ed02bb0   tiler-server_default   bridge    local
```

(`healixlabs_default`, `infra_default` and `tiler-server_default` are from other
projects already on my machine - not part of this homework.)

## Step 2 - create the three containers

```bash
docker run -d --name db-container --network database-net \
  -e MYSQL_ROOT_PASSWORD=DevopsHW@2026 \
  -e MYSQL_DATABASE=studentdb \
  mysql:8.0

docker run -d --name backend-container --network backend-net alpine:3.20 sleep infinity

docker run -d --name frontend-container --network frontend-net nginx:alpine
```

`MYSQL_ROOT_PASSWORD` is **required** by the mysql image - without it the
container exits immediately. `MYSQL_DATABASE=studentdb` makes it create an empty
database on first boot.

The alpine backend needs `sleep infinity` as its command, otherwise it would run
nothing, exit straight away and the container would stop.

## Step 3 - attach the backend to a second network

```
$ docker network connect frontend-net backend-container
$ docker network connect backend-net db-container
```

```
$ for c in frontend-container backend-container db-container; do
    echo -n "$c : "
    docker inspect -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}({{$v.IPAddress}})  {{end}}' $c
  done

frontend-container : frontend-net(172.21.0.2)
backend-container  : backend-net(172.22.0.2)  frontend-net(172.21.0.3)
db-container       : backend-net(172.22.0.3)  database-net(172.23.0.2)
```

The backend really does have two addresses on two different subnets. You can see
it as two network interfaces inside the container:

```
$ docker exec frontend-container ip -o addr show | grep "inet "
1: lo    inet 127.0.0.1/8 scope host lo
11: eth0    inet 172.21.0.2/16 brd 172.21.255.255 scope global eth0

$ docker exec backend-container ip -o addr show | grep "inet "      <- TWO
1: lo    inet 127.0.0.1/8 scope host lo
11: eth0    inet 172.22.0.2/16 brd 172.22.255.255 scope global eth0     (backend-net)
12: eth1    inet 172.21.0.3/16 brd 172.21.255.255 scope global eth1     (frontend-net)
```

## Step 4 - `docker network inspect`

```
$ docker network inspect frontend-net
frontend-net subnet=172.21.0.0/16
  - backend-container   172.21.0.3/16
  - frontend-container  172.21.0.2/16

$ docker network inspect backend-net
backend-net subnet=172.22.0.0/16
  - db-container        172.22.0.3/16
  - backend-container   172.22.0.2/16

$ docker network inspect database-net
database-net subnet=172.23.0.0/16
  - db-container        172.23.0.2/16
```

Each user-defined network got its own subnet, and each container appears exactly
in the networks it is attached to.

## Step 5 - connectivity tests

### Test 1: frontend -> backend (same network) - WORKS

```
$ docker exec frontend-container ping -c 3 backend-container
PING backend-container (172.21.0.3): 56 data bytes
64 bytes from 172.21.0.3: seq=0 ttl=64 time=0.240 ms
64 bytes from 172.21.0.3: seq=1 ttl=64 time=1.153 ms
64 bytes from 172.21.0.3: seq=2 ttl=64 time=0.721 ms

--- backend-container ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.240/0.704/1.153 ms
```

Note it resolved the **container name** to `172.21.0.3`. That is Docker's
built-in DNS, and it only works on **user-defined** networks - not on the default
`bridge` network.

### Test 2: backend -> frontend over HTTP - WORKS

```
$ docker exec backend-container curl -s -I http://frontend-container
HTTP/1.1 200 OK
Server: nginx/1.31.5
Date: Thu, 03 Sep 2026 12:50:11 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Wed, 02 Sep 2026 17:23:39 GMT
```

### Test 3: backend -> database (same network) - WORKS

```
$ docker exec backend-container ping -c 3 db-container
PING db-container (172.22.0.3): 56 data bytes
64 bytes from 172.22.0.3: seq=0 ttl=64 time=0.403 ms
64 bytes from 172.22.0.3: seq=1 ttl=64 time=0.491 ms
64 bytes from 172.22.0.3: seq=2 ttl=64 time=0.762 ms

--- db-container ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.403/0.552/0.762 ms
```

### Test 4: backend actually queries the database

I installed a mysql client in the alpine backend:

```
$ docker exec backend-container apk add --no-cache curl mysql-client
OK: 100 MiB in 33 packages
```

First attempt **failed**, and the error is worth keeping:

```
$ docker exec backend-container mysql -h db-container -u root -pDevopsHW@2026 -e "SHOW DATABASES;"
ERROR 1045 (28000): Plugin caching_sha2_password could not be loaded:
Error loading shared library /usr/lib/mariadb/plugin/caching_sha2_password.so: No such file or directory
```

**What went wrong:** Alpine's `mysql-client` package is actually the **MariaDB**
client, and MySQL 8 defaults to the `caching_sha2_password` authentication
plugin, which the MariaDB client cannot do. Nothing to do with networking - the
connection got all the way to the auth stage, which actually *proves* the network
path works.

**Fix** - create an application user that uses the older plugin:

```
$ docker exec db-container mysql -u root -pDevopsHW@2026 -e "
    CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED WITH mysql_native_password BY 'AppPass@2026';
    GRANT ALL PRIVILEGES ON studentdb.* TO 'appuser'@'%';
    FLUSH PRIVILEGES;
    SELECT user, host, plugin FROM mysql.user WHERE user IN ('root','appuser');"

user	host	plugin
appuser	%	mysql_native_password
root	%	caching_sha2_password
root	localhost	caching_sha2_password
```

Retry from the backend:

```
$ docker exec backend-container mysql -h db-container -u appuser -pAppPass@2026 -e "SHOW DATABASES;"
Database
information_schema
performance_schema
studentdb
```

And a real write + read across the network:

```
$ docker exec backend-container mysql -h db-container -u appuser -pAppPass@2026 studentdb -e "
    CREATE TABLE IF NOT EXISTS students (id INT PRIMARY KEY, name VARCHAR(50));
    INSERT IGNORE INTO students VALUES (1,'Rajasurya J'),(2,'test student');
    SELECT * FROM students;"

id	name
1	Rajasurya J
2	test student
```

The backend container created a table and read rows back out of MySQL over
`backend-net`, addressing it purely by the name `db-container`.

### Test 5: frontend -> database (different networks) - CORRECTLY FAILS

```
$ docker exec frontend-container ping -c 2 db-container
ping: bad address 'db-container'
exit code: 1
```

It cannot even **resolve the name** - Docker's DNS only tells a container about
other containers on networks it shares.

And it is not just DNS - it cannot reach the IP either:

```
$ docker exec frontend-container ping -c 2 -W 2 172.22.0.3     # the db's IP on backend-net
PING 172.22.0.3 (172.22.0.3): 56 data bytes

--- 172.22.0.3 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
exit code: 1
```

**100% packet loss** - real layer-3 isolation between the two bridge networks.
This is the security benefit: even if the frontend is compromised, the database
is not directly reachable.

### Summary of the connectivity matrix

| From | To | Same network? | Result |
|---|---|---|---|
| frontend | backend | yes (frontend-net) | ping OK, HTTP OK |
| backend | frontend | yes (frontend-net) | HTTP 200 OK |
| backend | database | yes (backend-net) | ping OK, SQL query OK |
| frontend | database | **no** | name does not resolve, 100% packet loss |

---

# Task 2 - Host Network

```bash
docker pull httpd:2.4
docker run -d --name apache-host --network host httpd:2.4
```

```
$ docker run -d --name apache-host --network host httpd:2.4
9d83413be5a52c72469d568f944d70f9ec081a1ed59ce51501f3501c2966b2bb

$ docker ps --filter name=apache-host
CONTAINER ID   IMAGE       COMMAND              CREATED         STATUS         PORTS     NAMES
9d83413be5a5   httpd:2.4   "httpd-foreground"   4 seconds ago   Up 4 seconds             apache-host
```

Notice the **PORTS column is empty**. There is no `-p` and no mapping, because
with `--network host` the container shares the host's network namespace directly.

Apache's own log confirms it took the host's identity:

```
$ docker logs apache-host
AH00558: httpd: Could not reliably determine the server's fully qualified domain name,
using 192.168.65.3. Set the 'ServerName' directive globally to suppress this message
[Thu Sep 03 12:51:06.815398 2026] [mpm_event:notice] [pid 1:tid 1] AH00489:
Apache/2.4.68 (Unix) configured -- resuming normal operations
[Thu Sep 03 12:51:06.819033 2026] [core:notice] [pid 1:tid 1] AH00094:
Command line: 'httpd -D FOREGROUND'
```

`192.168.65.3` is the Docker host's IP, not a `172.x` bridge IP.

## Accessing the Apache site on port 80

```
$ docker run --rm --network host alpine:3.20 wget -qO- http://localhost:80
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
```

```
$ docker run --rm --network host alpine:3.20 wget -qO- http://192.168.65.3:80
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
```

Apache is listening on **port 80** of the host, both on localhost and on the
host's real IP.

```
$ docker run --rm --network host alpine:3.20 netstat -tln | grep ":80 "
tcp        0      0 :::80                   :::*                    LISTEN
```

## Proof that it really is the host's network stack

A container on the host network sees **every interface on the host**, including
the docker bridges themselves:

```
$ docker run --rm --network host alpine:3.20 ip -o addr show | grep "inet "
1: lo               inet 127.0.0.1/8      scope host lo
4: eth0             inet 192.168.65.3/24  scope global eth0
15: services1       inet 192.168.65.6/32  scope global services1
16: docker0         inet 172.17.0.1/16    scope global docker0
17: br-1a3ad8001614 inet 172.18.0.1/16    scope global br-1a3ad8001614
18: br-2dea4ed02bb0 inet 172.20.0.1/16    scope global br-2dea4ed02bb0
19: br-9338f9730cbf inet 172.19.0.1/16    scope global br-9338f9730cbf
77: br-46a9d1687c43 inet 172.21.0.1/16    scope global br-46a9d1687c43
```

A bridge container only ever sees `lo` and its own `eth0`. This one sees
`docker0` and `br-46a9d1687c43` (which is the gateway side of my `frontend-net`
from Task 1). That is only possible if it is genuinely inside the host's network
namespace.

## Honest note about my machine

My host is a **MacBook Air**, and Docker Desktop runs all containers inside a
Linux VM. `--network host` gives the container the **Linux VM's** network stack,
not macOS's. So from macOS itself:

```
$ curl -s -m 5 -o /dev/null -w "http_code=%{http_code}\n" http://localhost:80
http_code=000

$ curl -s -m 5 -o /dev/null -w "http_code=%{http_code}\n" http://192.168.65.3:80
http_code=000
```

`000` means the connection never opened. This is **not** the container failing -
it is proven above to be serving on port 80. It is that macOS cannot route into
the VM's host network unless the "host networking" feature is switched on in
Docker Desktop's settings, and turning that on needs a Docker Desktop restart,
which would have killed the other projects running on my machine. On a real Linux
host, `curl http://localhost:80` from the terminal would have worked directly.

## Host network vs bridge network

| | bridge (default) | host |
|---|---|---|
| Network namespace | its own | shares the host's |
| Needs `-p` to publish | yes | no - already on the host's ports |
| Container IP | e.g. 172.21.0.2 | the host's IP |
| Port conflicts | no (each container isolated) | yes - two containers cannot both take :80 |
| Isolation | good | none |
| Performance | slight NAT overhead | no NAT, slightly faster |
| Container-name DNS | yes, on user-defined networks | no |
| Linux only? | works everywhere | full support on Linux only |

Use host networking when you need raw performance or the container has to see the
real network (monitoring agents, load balancers). Otherwise bridge, because
isolation is worth more than the small NAT cost.

---

# Task 3 - Bind Mount

## Create a folder and an index.html on my machine

```
$ mkdir -p bind-mount-site
$ cat bind-mount-site/index.html
<!DOCTYPE html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 100px;">
    <h1>Hello students</h1>
  </body>
</html>
```

The folder is committed in this repo: [`bind-mount-site/`](bind-mount-site/).

## Bind mount it into an nginx container

```bash
docker run -d --name nginx-bind -p 3007:80 \
  -v "$(pwd)/bind-mount-site":/usr/share/nginx/html:ro \
  nginx:alpine
```

```
$ pwd
/Users/rajasurya/devops-heros/homework/docker-networking

$ docker run -d --name nginx-bind -p 3007:80 -v "$(pwd)/bind-mount-site":/usr/share/nginx/html:ro nginx:alpine
20973b0b13d86d4e276b8e6f37e6716210ee0987ba5db8b244bdea3fba65d72d
```

The source path **must be absolute** - that is why I used `$(pwd)/...`. With a
relative path Docker treats it as a named volume instead.

## Access the site - before

```
$ curl http://localhost:3007
<!DOCTYPE html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 100px;">
    <h1>Hello students</h1>
  </body>
</html>
```

![Bind mount before](../docs/screenshots/docker-bind-mount-before.png)

Container state before I touched anything:

```
$ docker inspect -f 'started at: {{.State.StartedAt}}   restarts: {{.RestartCount}}   pid: {{.State.Pid}}' nginx-bind
started at: 2026-09-03T12:52:06.523034382Z   restarts: 0   pid: 14644
```

## Modify index.html on the host

I edited the file in my normal editor on macOS and changed the heading. **No
docker command was run** - no `restart`, no `stop`, no `cp`.

## Access it again - after

```
$ curl http://localhost:3007
<!DOCTYPE html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 100px;">
    <h1>Hello students - this file was edited on my Mac</h1>
    <p>The container was never restarted. Bind mounts are live.</p>
    <p>edited at: 2026-09-03 18:22 IST</p>
  </body>
</html>
```

![Bind mount after](../docs/screenshots/docker-bind-mount-after.png)

## Proof the container was never restarted

```
$ docker inspect -f 'started at: {{.State.StartedAt}}   restarts: {{.RestartCount}}   pid: {{.State.Pid}}' nginx-bind
started at: 2026-09-03T12:52:06.523034382Z   restarts: 0   pid: 14644
```

**Identical** to before the edit - same start time, same PID `14644`, restart
count still `0`. The new content was served by the exact same running process.

The container is reading my Mac's filesystem directly:

```
$ docker exec nginx-bind cat /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
  <head><title>Bind Mount Demo</title></head>
  <body style="font-family: sans-serif; text-align: center; margin-top: 100px;">
    <h1>Hello students - this file was edited on my Mac</h1>
    <p>The container was never restarted. Bind mounts are live.</p>
```

```
$ docker inspect -f '{{range .Mounts}}Type={{.Type}}  Source={{.Source}}  Destination={{.Destination}}  RW={{.RW}}{{end}}' nginx-bind
Type=bind  Source=/Users/rajasurya/devops-heros/homework/docker-networking/bind-mount-site  Destination=/usr/share/nginx/html  RW=false
```

## The `:ro` flag

I added `:ro`, so the mount is read-only from the container's side:

```
$ docker exec nginx-bind sh -c "echo hacked > /usr/share/nginx/html/index.html"
sh: can't create /usr/share/nginx/html/index.html: Read-only file system
exit code: 1
```

`RW=false` in the inspect output above matches. For a web server that only needs
to *read* static files this is the right thing to do - a compromised container
cannot rewrite my source files.

## Bind mount vs volume

| | Bind mount | Named volume |
|---|---|---|
| Where the data lives | a path I choose on the host | Docker-managed area (`/var/lib/docker/volumes`) |
| Syntax | `-v /abs/host/path:/container/path` | `-v myvolume:/container/path` |
| Edit from the host | yes, with any editor | awkward |
| Portable across machines | no - depends on my paths | yes |
| Best for | **development** - live-editing code/config | **production data** - databases, uploads |

---

# Task 4 - Overlay Network

## What an overlay network is

A **bridge** network is a virtual switch that exists on **one** Docker host.
Containers on the same bridge can talk to each other, but a container on machine
A can never reach a bridge network on machine B.

An **overlay** network spans **multiple Docker hosts**. It creates one flat
virtual layer-2 network that containers on different physical machines all share,
so `containerA` on host 1 can reach `containerB` on host 2 by name, as if they
were plugged into the same switch.

## How it works

- Docker builds a **VXLAN tunnel** between the hosts. Container traffic (an
  ethernet frame) is wrapped inside a UDP packet, sent over the real physical
  network to the other host, unwrapped there and delivered to the target
  container. The containers never know they crossed a machine boundary.
- The swarm managers keep a **distributed key-value store** (built into swarm)
  holding which container has which overlay IP and which host it lives on. That
  is how routing decisions get made.
- Ports used: **2377/tcp** (cluster management), **7946/tcp+udp** (node
  discovery / gossip), **4789/udp** (the VXLAN data plane).
- Encryption is optional: `docker network create --opt encrypted` turns on IPsec
  for the data plane.

## Why overlay networks exist

Because containers have to be able to move. In a cluster, the scheduler decides
which machine a container runs on, and it can move at any time. Hard-coding IPs
or ports would fall apart immediately. The overlay gives every service a stable
name and a stable virtual IP no matter which host it lands on.

## Relationship with Docker Swarm

Overlay networks are a **swarm feature**. They need a swarm cluster (or an
external KV store like Consul/etcd in the old pre-1.12 setup) because something
has to keep the cluster-wide map of container-to-host. Proof on my machine:

```
$ docker info | grep -i "Swarm:"
 Swarm: inactive

$ docker network create --driver overlay test-overlay
Error response from daemon: This node is not a swarm manager.
Use "docker swarm init" or "docker swarm join" to connect this node to swarm and try again.
exit code: 1
```

## A real (single-node) overlay demo

I only have one laptop, so I **cannot** honestly demonstrate real multi-host
networking - that needs two or more machines. What I *can* do is initialise a
one-node swarm and create a genuine overlay network on it, which shows the
overlay driver, the swarm scope and the service DNS. Everything below is real
output from my machine.

```
$ docker swarm init
Swarm initialized: current node (ysrhwbjz0huvokpjkm9f1gr5k) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2pqfxb9gnhg2zcn6ixqkmlckqbksxv8shx5obvnyng2x15w8s6-66ebnj80pputdqgz2mqcb4q59 192.168.65.3:2377
```

That `docker swarm join ...` line is exactly what I would run on a second
machine to make the overlay actually span two hosts.

```
$ docker info | grep -E "Swarm:|NodeID:|Is Manager:|Nodes:|Managers:"
 Swarm: active
  NodeID: ysrhwbjz0huvokpjkm9f1gr5k
  Is Manager: true
  Managers: 1
  Nodes: 1

$ docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
ysrhwbjz0huvokpjkm9f1gr5k *   docker-desktop   Ready     Active         Leader           29.2.1
```

Create the overlay:

```
$ docker network create --driver overlay --attachable app-overlay
2slswtu2vpi3amshae1ppe7hr

$ docker network ls --filter driver=overlay
NETWORK ID     NAME          DRIVER    SCOPE
2slswtu2vpi3   app-overlay   overlay   swarm
oxau52nlyax2   ingress       overlay   swarm

$ docker network inspect app-overlay
Name=app-overlay
Driver=overlay
Scope=swarm
Attachable=true
Subnet=10.0.1.0/24
```

**The SCOPE column is the key difference** - my Task 1 bridge networks are
`local` (this host only), overlay networks are `swarm` (cluster-wide). The
`ingress` overlay is created automatically by swarm for the routing mesh.

`--attachable` is what lets a plain `docker run` container join an overlay;
without it only swarm services can.

Deploy a service on it:

```
$ docker service create --name web --network app-overlay --replicas 2 nginx:alpine
verify: Service g86kc41idma7lnnfnw5ekblvh converged

$ docker service ls
ID             NAME      MODE         REPLICAS   IMAGE          PORTS
g86kc41idma7   web       replicated   2/2        nginx:alpine

$ docker service ps web
NAME      NODE             CURRENT STATE
web.1     docker-desktop   Running 13 seconds ago
web.2     docker-desktop   Running 13 seconds ago
```

Both replicas are on `docker-desktop` because I only have one node. With a second
machine joined, the scheduler would place one on each and they would still be on
the same overlay.

Service discovery on the overlay:

```
$ docker run -d --name overlay-client --network app-overlay alpine:3.20 sleep 300

$ docker exec overlay-client nslookup web
Non-authoritative answer:
Name:	web
Address: 10.0.1.2

$ docker exec overlay-client nslookup tasks.web
Non-authoritative answer:
Name:	tasks.web
Address: 10.0.1.3
Name:	tasks.web
Address: 10.0.1.4

$ docker exec overlay-client wget -qO- http://web | head -5
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

This shows swarm's two DNS names:

- **`web` -> 10.0.1.2** is the service's **Virtual IP (VIP)**. Traffic to it is
  load-balanced across the replicas by IPVS in the kernel.
- **`tasks.web` -> 10.0.1.3, 10.0.1.4** are the **individual task containers**.
  Used when you want to talk to each replica yourself.

In a real two-host swarm, `10.0.1.3` might be on host 1 and `10.0.1.4` on host 2,
and `wget http://web` would work identically - that is the whole value of the
overlay.

## Cleanup - I put my machine back the way I found it

```
$ docker rm -f overlay-client
$ docker service rm web
$ docker network rm app-overlay
$ docker swarm leave --force
Node left the swarm.

$ docker info | grep "Swarm:"
 Swarm: inactive
```

## Use cases

- **Multi-host container clusters** - Docker Swarm / (conceptually) Kubernetes
  CNI plugins like Flannel VXLAN work the same way.
- **Microservices spread across machines** that need to talk by service name.
- **Scaling out** - add a host, the overlay stretches to it, no reconfiguration.
- **Cross-host service discovery + load balancing** via the VIP.
- **Encrypted east-west traffic** with `--opt encrypted` when the underlying
  network is not trusted.

## Limitations

- **Needs swarm mode** (or an external KV store) - not usable on a standalone
  Docker host, as my error above shows.
- **VXLAN adds overhead**: 50 bytes of encapsulation per packet, so the effective
  MTU drops (typically 1500 -> 1450). Apps that assume 1500 can see weird
  fragmentation or hangs.
- **Slower than bridge or host** - encapsulate/decapsulate on every packet, and
  `--opt encrypted` costs more again.
- **Firewall requirements** - 2377/tcp, 7946/tcp+udp and 4789/udp must be open
  between every pair of nodes; this is the usual reason an overlay silently fails.
- **Not encrypted by default** - the control plane is, the data plane is not
  until you ask for it.
- **Debugging is harder** - `tcpdump` on the host shows UDP 4789 packets, not
  your application traffic.
- **Docker Swarm itself is much less used now** than Kubernetes, so overlay in
  the Docker-native sense is less common in new projects - though the underlying
  VXLAN idea is exactly what Kubernetes network plugins use.

---

# What I learned overall

- **User-defined networks give you DNS by container name**; the default `bridge`
  network does not. That alone is a reason to always create a network.
- **Isolation is real and cheap.** Splitting into three networks meant the
  frontend genuinely could not reach the database - 100% packet loss, name did
  not even resolve. That is a security boundary for one `docker network create`.
- **A container can have several networks**, and each one adds an interface
  (`eth0`, `eth1`) with its own IP. That is how you build a tiered app.
- **`--network host` removes the network namespace entirely** - no `-p`, no
  mapping, no isolation, and you can see it because the container sees the host's
  `docker0` and bridge interfaces.
- **Bind mounts are live** - the same PID served both versions of the file. And
  `:ro` is a one-word security improvement.
- **Overlay is bridge-across-machines**, built on VXLAN, and it needs swarm
  because something has to store the cluster-wide map.
- Reading errors carefully pays off - the MySQL `caching_sha2_password` failure
  looked like a networking problem and was actually an auth-plugin mismatch. The
  fact that it got as far as an auth error was proof the network was fine.
