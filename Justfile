# Common tasks for development environment

set shell := ['bash', '-uec']

setup:
  if command -v brew >/dev/null; then
    brew bundle --file ./Brewfile
  fi
  if command -v mise >/dev/null; then
    mise use -g node@20 pnpm@9 python@3.12 || true
  fi

update:
  if command -v brew >/dev/null; then
    brew update && brew upgrade && brew cleanup
  fi

lock:
  if command -v brew >/dev/null; then
    brew bundle lock --file ./Brewfile --lockfile=./Brewfile.lock.json
  fi

cleanup:
  if command -v brew >/dev/null; then
    brew bundle cleanup --file ./Brewfile
  fi

bench:
  if command -v zsh >/dev/null; then
    time zsh -i -c exit
  fi

docker-up:
  if command -v colima >/dev/null; then
    colima start --cpu 4 --memory 6
  fi

docker-down:
  if command -v colima >/dev/null; then
    colima stop
  fi

verify:
  if command -v git >/dev/null; then git --version; fi
  if command -v gh >/dev/null; then gh --version; fi
  if command -v rg >/dev/null; then rg --version; fi
  if command -v fd >/dev/null; then fd --version; fi
  if command -v node >/dev/null; then node --version; fi
  if command -v pnpm >/dev/null; then pnpm --version; fi
  if command -v python >/dev/null; then python --version; fi
  if command -v docker >/dev/null; then docker --version; fi
  if command -v colima >/dev/null; then colima --version; fi
  if command -v dotnet >/dev/null; then dotnet --version; fi
