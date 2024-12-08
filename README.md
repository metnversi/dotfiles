- To load icon, u need to install a nerd fonts, refer [there](https://www.nerdfonts.com/font-downloads). My config auto download Iosevka nerd fonts.
- Take a look at [plugin reference](./pref/README.md)

## Deployment

```Bash
git clone https://github.com/metnversi/dotfiles.git
cd dotfiles
./deploy.sh
```

## GNS3 console command

```bash
/home/anna/.cargo/bin/alacritty --title %d -e bash -c 'telnet %h %p | /home/anna/myvenv/bin/ct'
```

```bash
/usr/local/bin/wezterm start --title %d -- bash -c 'telnet %h %p | /home/anna/myvenv/bin/ct'
```
