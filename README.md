- Install a nerd fonts, refer [there](https://www.nerdfonts.com/font-downloads). Mine requires `Iosevka Nerd Fonts` and `JetBrain Mono Nerd Fonts`
- Take a look at [plugin reference](./pref/README.md)
- Why not [Chezmoi](https://github.com/twpayne/chezmoi) and [comtrya](https://github.com/comtrya/comtrya)? Nah

## Deployment

```Bash
git clone https://github.com/metnversi/dotfiles.git
cd dotfiles
./deploy.sh
```

### rename prefix command

```bash
rename 's/^(\d)\./0$1-/; y/A-Z/a-z/' *.md
```
