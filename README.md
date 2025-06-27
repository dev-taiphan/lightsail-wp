# Bedrock Docker

## Recommends or Requires

### Recommends OS

- CentOS7 or later
- Ubuntu18.04 or later
- Windows10/Windows11(WSL2 + DockerCE)
- Windows10/Windows11(WSL2 + Docker Desktop for Windows)
- Mac(with Docker Desktop for mac)

### Require commands.

- docker(over 18.0x)

## Getting Started

### Add domain name

Add this line to your `hosts` file

```
127.0.0.1	local.awe-some.best
```

### Create environment file

```sh
cp .env.example .env
```

### Build environment

```sh
bash ./setup.sh
```

### Open wordpress site

[https://local.awe-some.best/](https://local.awe-some.best/)

### Open wordpress admin site

[https://local.awe-some.best/wp/wp-admin/](https://local.awe-some.best/wp/wp-admin/)

### Mailpit Instructions

For detailed guidance on using and configuring Mailpit, refer to the [Mailpit guideline](https://www.notion.so/staygold-sg/Mailpit-1909246d04e980bd8e05e01c2ee2bdba)

### Login PHP, Composer container

```sh
docker compose exec -it php sh
```

### Login Node container

```sh
docker compose exec -it node sh
```

### Compile SCSS to CSS and minify JS

```sh
docker compose exec -it node sh
npm run compile:assets:local
```

### Start docker container

```sh
docker compose start
```

### Stop docker container

```sh
docker compose stop
```
