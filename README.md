# Code Server
Run a vscode like instance from server and use it from browser, all of the heavy work will be done on server. Code from browser insanely fast from any device without slowing down.

Cloned from https://github.com/linuxserver/docker-code-server
extras: 
Added custom build steps for downloading from its github release pages, extracting to /opt and adding its binaries to enviroment variable / $PATH of the list below:
 - Node
 - Java 17
 - Maven

## Advantages: 
- Great to work from anywhere, any device, fast or slow (even via tablets) because it works on browser
- No need to worry about compile, build, run and test. It is done on server side and you can see from terminal and access it even.
- Very fast dev enviroment and project first time start time. 
- For small coding stuff, this is great.

## Disadvantages: 
- Need to know about vscode project, extension and general usages for the first time.
- Project setups can be quite difficult (especially JAVA projects, I'm still having trouble.)

I would say that overall, it could an good option if you don't have an optimal setup for development. 

Some futuristic predictions: 
In the future, there will be companies that will hire developers, and tell them to enter a web address for devs to do their work on sandboxed enviroment, instructs them to open / create specific files, write code on them and test them or run given test. This could be the 'nirvana' of remote development.


Below is original content from cloned readme. Left them because it could be useful.

Access the webui at `http://<your-ip>:8443`.
For github integration, drop your ssh key in to `/config/.ssh`.
Then open a terminal from the top menu and set your github username and email via the following commands

```bash
git config --global user.name "username"
git config --global user.email "email address"
[OPTIONAL]
git config --global verifySSL false
```

### Hashed code-server password

How to create the [hashed password](https://github.com/cdr/code-server/blob/master/docs/FAQ.md#can-i-store-my-password-hashed).

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
version: "2.1"
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PASSWORD=password #optional
      - HASHED_PASSWORD= #optional
      - SUDO_PASSWORD=password #optional
      - SUDO_PASSWORD_HASH= #optional
      - PROXY_DOMAIN=code-server.my.domain #optional
      - DEFAULT_WORKSPACE=/config/workspace #optional
    volumes:
      - /path/to/appdata/config:/config
    ports:
      - 8443:8443
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=code-server \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PASSWORD=password `#optional` \
  -e HASHED_PASSWORD= `#optional` \
  -e SUDO_PASSWORD=password `#optional` \
  -e SUDO_PASSWORD_HASH= `#optional` \
  -e PROXY_DOMAIN=code-server.my.domain `#optional` \
  -e DEFAULT_WORKSPACE=/config/workspace `#optional` \
  -p 8443:8443 \
  -v /path/to/appdata/config:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/code-server:latest

```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 8443` | web gui |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e PASSWORD=password` | Optional web gui password, if `PASSWORD` or `HASHED_PASSWORD` is not provided, there will be no auth. |
| `-e HASHED_PASSWORD=` | Optional web gui password, overrides `PASSWORD`, instructions on how to create it is below. |
| `-e SUDO_PASSWORD=password` | If this optional variable is set, user will have sudo access in the code-server terminal with the specified password. |
| `-e SUDO_PASSWORD_HASH=` | Optionally set sudo password via hash (takes priority over `SUDO_PASSWORD` var). Format is `$type$salt$hashed`. |
| `-e PROXY_DOMAIN=code-server.my.domain` | If this optional variable is set, this domain will be proxied for subdomain proxying. See [Documentation](https://github.com/cdr/code-server/blob/master/docs/FAQ.md#sub-domains) |
| `-e DEFAULT_WORKSPACE=/config/workspace` | If this optional variable is set, code-server will open this directory by default |
| `-v /config` | Contains all relevant configuration files. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__PASSWORD=/run/secrets/mysecretpassword
```

Will set the environment variable `PASSWORD` based on the contents of the `/run/secrets/mysecretpassword` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```bash
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


## Support Info

* Shell access whilst the container is running: `docker exec -it code-server /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f code-server`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' code-server`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' lscr.io/linuxserver/code-server:latest`


### Via Docker Compose

* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull code-server`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d code-server`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Run

* Update the image: `docker pull lscr.io/linuxserver/code-server:latest`
* Stop the running container: `docker stop code-server`
* Delete the container: `docker rm code-server`
* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (only use if you don't remember the original parameters)

* Pull the latest image at its tag and replace it with the same env variables in one run:

  ```bash
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once code-server
  ```

* You can also remove the old dangling images: `docker image prune`



## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/linuxserver/docker-code-server.git
cd docker-code-server
docker build \
  --no-cache \
  --pull \
  -t lscr.io/linuxserver/code-server:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`

```bash
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

