---
- I based my Emacs configuration on the code 
  found in [rexim dotfiles](https://github.com/rexim/dotfiles).
- Many files just be here as backup for my configuration, such as [nftables](./security/nftables.conf)

### Prerequisites
- Debian 13 (trixie). Debian 12 (bookworm) may still work, but might need to tune some code.
- GNU Awk (`gawk`) is required to run the [admin script](./security/admin.sh) 
  if you have not yet set up your environment
  package names or dependency functions
- X11. I don't use Wayland though I did used Hyprland, but in the end, I prefer simplicity.
- Internet connection
- Review [packages.yaml](./packages.yaml)
- Review [admin script](./security/admin.sh)
- Review [function file](./function)
- Review all dotfiles gonna be linked in [MANIFEST.linux](./MANIFEST.linux)

```shell
$ awk --version
GNU Awk 5.2.1, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.2, GNU MP 6.3.0)
Copyright (C) 1989, 1991-2022 Free Software Foundation.
```
### Deployment
- Root privileage is required to run the optional admin script `security/admin.sh`. 
  Yet it is just my setup to enable some laptop/GUI function, since real Linux user 
  should not use root as possible as is, because we are not Microsoft Windows monkey.
- Clone the repo, run `deploy.sh`.
