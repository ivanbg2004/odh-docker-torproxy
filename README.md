
# 🛡️ OD&H Docker TorProxy

### _High-Privacy, Zero-Hassle Tor Proxy for the Modern Age._

---

## 🚀 Overview

**OD&H TorProxy** is a hardened, production-grade Tor proxy in a Docker image. Built for developers, sysadmins, and privacy advocates who demand speed, security, and full-stack anonymity—right out of the box.

Whether you're bypassing censorship, cloaking DNS, or building resilient privacy-first architectures, this image brings Tor’s full capabilities to your fingertips.

> 🔐 _"Privacy isn't optional—it's a right. OD&H delivers uncompromising solutions for a surveillance-heavy world."_  
> — *Oblivion, Founder of OD&H*

<p align="center">
  <a href="https://hub.docker.com/r/ivanbg2004/torproxy">
    <img src="https://img.shields.io/docker/pulls/ivanbg2004/torproxy?style=for-the-badge&color=blue" />
  </a>
  <a href="https://github.com/ivanbg2004/odh-docker-torproxy/stargazers">
    <img src="https://img.shields.io/github/stars/ivanbg2004/odh-docker-torproxy?style=for-the-badge&color=yellow" />
  </a>
  <a href="https://github.com/ivanbg2004/odh-docker-torproxy/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/ivanbg2004/odh-docker-torproxy?style=for-the-badge&color=lightgray" />
  </a>
</p>

---

## ⚙️ Key Features

- 🔌 **Multi-Protocol Proxy Stack**  
  Supports **SOCKS5**, **HTTP**, and **Shadowsocks** natively.

- 🧥 **Pluggable Transports**  
  Baked-in **obfuscation** via **Meek**, **Snowflake**, and **Lyrebird**. DPI? Defeated.

- 🔒 **DNS over Tor**  
  Prevents leaks with **Tor-routed DNS resolution**.

- 💻 **Multi-Arch Ready**  
  Runs on **x86_64**, **ARM**, **Raspberry Pi**, and cloud VMs.

- ⚡ **Minimal Setup, Max Power**  
  Env var configuration. Volume mount support. CI/CD friendly.

- 🔄 **Constantly Maintained**  
  Updated with latest **Tor**, **security patches**, and **community feedback**.

---

## 📦 Prerequisites

- [Docker 20+](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) *(optional but recommended)*

---

## 🛠️ Building from Source

```bash
git clone https://github.com/ivanbg2004/odh-docker-torproxy
cd odh-docker-torproxy
docker build -t ivanbg2004/torproxy .
```

Multi-platform build:

```bash
docker buildx bake image-all
```

---

## ⚡ Quick Start

### 🧱 Docker Compose (Preferred)

```yaml
version: "3.9"
services:
  torproxy:
    image: ivanbg2004/torproxy:latest
    container_name: torproxy
    ports:
      - "1080:1080"
      - "8080:8080"
    environment:
      TOR_SOCKS_PORT: 1080
      TOR_HTTP_PORT: 8080
    restart: always
```

Launch with:

```bash
docker compose up -d
```

### 🧪 CLI

```bash
docker run -d \
  --name torproxy \
  -p 1080:1080 \
  -p 8080:8080 \
  -e TOR_SOCKS_PORT=1080 \
  -e TOR_HTTP_PORT=8080 \
  ivanbg2004/torproxy:latest
```

---

## ☁️ Kubernetes

K8s deployment template:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: torproxy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: torproxy
  template:
    metadata:
      labels:
        app: torproxy
    spec:
      containers:
      - name: torproxy
        image: ivanbg2004/torproxy:latest
        ports:
        - containerPort: 9050
        - containerPort: 8118
        env:
        - name: TOR_PROXY_TYPE
          value: "socks5"
        - name: ENABLE_DNS
          value: "true"
```

---

## 🧩 Configuration

| Variable              | Description                                                        | Default   |
|----------------------|--------------------------------------------------------------------|-----------|
| `TOR_SOCKS_PORT`      | Port for SOCKS5 proxy                                              | `1080`    |
| `TOR_HTTP_PORT`       | Port for HTTP proxy                                                | `8080`    |
| `TOR_CONTROL_PORT`    | Enables Tor control port                                           | _(none)_  |
| `TOR_CONTROL_PASSWD`  | Password for control port                                          | _(none)_  |
| `TOR_BRIDGE`          | Use obfs4/Meek/Snowflake bridges                                   | _(none)_  |
| `TOR_USE_BRIDGES`     | Enables bridge use                                                 | `0`       |
| `TOR_CUSTOM_CONFIG`   | Add custom lines to torrc (newline-separated)                     | _(none)_  |

> 💡 You can override everything by mounting a custom `/etc/tor/torrc`.

---

## 🛡️ Security Best Practices

- **Use strong passwords** on the control port
- **Route only HTTPS traffic** through Tor when possible
- **Stay anonymous**: don’t log into real accounts via Tor
- **Tor ≠ invincibility**: Be aware of correlation attacks and malware risks

---

## 📊 Monitoring

- `docker logs torproxy`
- Tor Control Port (if enabled): `telnet localhost 9051`

---

## 🧯 Troubleshooting

| Problem              | Solution                                                                 |
|----------------------|--------------------------------------------------------------------------|
| Proxy unreachable    | Check container logs and port bindings                                   |
| DNS leak detected    | Ensure your resolver uses Tor-routed DNS or set `DisableNetwork 0`       |
| Tor won’t start      | Validate config file and check for time sync issues                      |

---

## 🤝 Contributing

We welcome PRs, issues, and forks. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidelines.

---

## 📜 License

MIT License. See [`LICENSE`](LICENSE) for full details.

## 📞 Contact

For questions, bug reports, or general inquiries, reach out to Oblivion Development & Hosting via our website: [https://odh.ivan-vcard.xyz](https://odh.ivan-vcard.xyz)

---

Developed with ❤️ by [@ivanbg_2004](https://github.com/ivanbg2004), inspired by [@shahradelahi](https://github.com/shahradelahi) and remastered by [Oblivion Development & Hosting](https://odh.ivan-vcard.xyz). <br>
Oblivion Development & Hosting is a Linux-first company, but we reluctantly support other platforms.
