# Delete Aliases if it exists
unalias-if() {
  if whence -w "$1" | grep "alias" >/dev/null; then
    unalias "$1"
  fi
}
unalias-if diff
unalias-if grep
unalias-if which-command

alias ls='lsd'
