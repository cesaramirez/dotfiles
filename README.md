## A Fresh macOS Setup

These instructions are for setting up a new Mac using **your own** dotfiles in this repository. If you want to customize further, see “Your Own Dotfiles” below.

### Backup your data

If you're migrating from an existing Mac, you should first make sure to backup all of your existing data. Go through the checklist below to make sure you didn't forget anything before you migrate.

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?
- If you use Mackup and want to keep app preferences in the cloud, make sure it’s up to date and run `mackup backup` (optional).

### Setting up your Mac

After backing up your old Mac you may now follow these install instructions to setup a new one.

1. Update macOS to the latest version through system preferences
2. Set up your SSH key:
   - If you use **1Password**, enable the **1Password SSH agent** and sync your keys locally.
   - Otherwise, generate a keypair following the official GitHub guide (avoid piping remote scripts).

3. Clone this repo to `~/.dotfiles` with:

    ```zsh
    git clone --recursive git@github.com:cesaramirez/dotfiles.git ~/.dotfiles
    ```

4. Run the installation:

    ```zsh
      cd ~/.dotfiles && ./install.sh
      # If you prefer the legacy flow, you can still use:
      # cd ~/.dotfiles && ./fresh.sh
    ```

5. Start `Herd.app` and run its install process
6. (Optional) If you use **Mackup** and it’s already synced with your cloud storage, restore preferences:

        mackup restore
7. Restart your computer to finalize the process

Your Mac is now ready to use!

> You can use a different location than `~/.dotfiles` if you want. Make sure you also update the references in your shell config and scripts accordingly.
### Security note
Avoid piping remote scripts directly into your shell (`curl … | sh`). Prefer local scripts from this repository or official documentation (e.g., GitHub’s SSH key guide).


### Cleaning your old Mac (optionally)

After you've set up your new Mac you may want to wipe and clean install your old Mac. Follow [this article](https://support.apple.com/guide/mac-help/erase-and-reinstall-macos-mh27903/mac) to do that. Remember to [backup your data](#backup-your-data) first!

## Your Own Dotfiles


Please note that this repository is ready to be used as-is. If you want to customize your own dotfiles:
  * Review `.macos` and adjust settings (you can define `COMPUTER_NAME` and `TIMEZONE` at the top).
  * Update the `Brewfile` to your needs (use `brew search` to find formulas/casks).
  * Add or tweak shell aliases in `aliases.zsh` and PATH entries in `path.zsh`.

> Tip: This setup does **not** require Oh My Zsh. If you prefer a minimal and fast shell, keep Zsh lean. If you like Oh My Zsh, you can still enable it in your `.zshrc`.

Go through:
- `.macos`: system defaults you want to apply.
- `Brewfile`: CLI tools and apps to install (run `brew bundle` against it).
- `aliases.zsh` / `path.zsh`: shell aliases and PATH entries you need.
- `.zshrc`: your shell configuration (keep it minimal for faster startup).

This repo includes extra tooling for Laravel and .NET development. Runtime versions are managed with [mise](https://github.com/jdx/mise). The `Brewfile` still installs utilities such as `azure-cli` and GUI apps like `azure-data-studio` and `powershell`.

Check out the [`aliases.zsh`](./aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [`path.zsh`](./path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles` directory. You can adjust the [`.zshrc`](./.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization).

Some useful aliases are already provided, including shortcuts for `npm run dev`, `dotnet build`, and common Git commands.

### Runtimes with mise

The `.mise.toml` file defines the versions of Node, PNPM and Python used:

```toml
[tools]
node = "20"
pnpm = "9"
python = "3.12"
```

After running `brew bundle`, install them globally with:

```bash
mise use -g node@20 pnpm@9 python@3.12
```

Use `mise install` whenever you update the versions in `.mise.toml`.
### Tasks (Just)
Install [just](https://github.com/casey/just) and run common tasks:

```bash
just setup      # install dependencies
just update     # update Homebrew packages
just lock       # update Brewfile.lock.json
just bench      # measure shell startup
just docker-up  # start colima Docker VM
just docker-down # stop colima
just verify     # print tool versions
```


### Optional: Mackup
If you want to sync app preferences across machines:

```bash
brew install mackup
mackup backup
```
See Mackup docs if you prefer a different storage (e.g., non‑iCloud).
You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Thanks To...

I first got the idea for starting this project by visiting the [GitHub does dotfiles](https://dotfiles.github.io/) project. Both [Zach Holman](https://github.com/holman/dotfiles) and [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) were great sources of inspiration. [Sourabh Bajaj](https://twitter.com/sb2nov/)'s [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/) proved to be invaluable. Thanks to [@subnixr](https://github.com/subnixr) for [his awesome Zsh theme](https://github.com/subnixr/minimal)! Thanks to [Caneco](https://twitter.com/caneco) for the header in this readme. And lastly, I'd like to thank [Emma Fabre](https://twitter.com/anahkiasen) for [her excellent presentation on Homebrew](https://speakerdeck.com/anahkiasen/a-storm-homebrewin) which made me migrate a lot to a [`Brewfile`](./Brewfile) and [Mackup](https://github.com/lra/mackup).

In general, I'd like to thank every single one who open-sources their dotfiles for their effort to contribute something to the open-source community.
