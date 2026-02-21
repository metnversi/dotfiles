---
- Emacs configuration is based from [rexim (tsoding) dotfiles](https://github.com/rexim/dotfiles).
- Many files just be here as personal backup , such as [nftables](./security/nftables.conf)

### Prerequisites
- Debian 13, emacs >= 29.0
- X11 as I use i3wm, not sway.
- Internet connection
- GNU Awk (`gawk`) if run admin script (manually, require root privilege)
```shell
$ awk --version
GNU Awk 5.2.1, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.2, GNU MP 6.3.0)
Copyright (C) 1989, 1991-2022 Free Software Foundation.
```

### Deployment
- In any circumstance, the `deploy.sh` script does not need root privlege.
- Clone the repo, run `deploy.sh`.

### Docker deployment 
- Intent for development only.
- Build the image.
```shell
$ docker build --network host -f Dockerfile -t test:trixie .
```
- Either run as rootless container or rootful container as below.
```shell
# rootful container for ease
# Note that I does not use $USER var, as with rootful container, 
# I can perform installation as any docker admin user.

$ MYUSER=rose
$ docker run -it --rm \
    --network=host \
    -e DISPLAY=$DISPLAY \
    -e DUID=$(id -u $MYUSER) \
    -e DUSER=$MYUSER \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/$MYUSER:/home/$MYUSER \
    test:trixie
```
