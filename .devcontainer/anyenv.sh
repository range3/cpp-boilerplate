anyenv_system_root="/opt/anyenv"

# prefer a user anyenv over a system wide install
if [ -s "${HOME}/.anyenv/bin" ]; then
  anyenv_root="${HOME}/.anyenv"
elif [ -s "${anyenv_system_root}" ]; then
  anyenv_root="${anyenv_system_root}"
  export ANYENV_ROOT="$anyenv_root"
  export ANYENV_DEFINITION_ROOT="${anyenv_root}/share/anyenv-install"
fi

if [ -n "$anyenv_root" ]; then
  # export PATH="${anyenv_root}/bin:$PATH"
  if hash anyenv 2>/dev/null; then
    eval "$(anyenv init -)" > /dev/null 2>&1
  fi
fi
