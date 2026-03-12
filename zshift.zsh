# === ディレクトリ移動・パス補完 ===

# zoxide
eval "$(zoxide init zsh)"
alias z='zi'   # 常に選択UIで移動

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# === Path-aware Ctrl-T (shallow) — tildeをエスケープせずに挿入 ===
fzf_path_aware_ctrl_t_shallow() {
  setopt localoptions noglob
  local orig token base base_exp pretty picks

  orig=${LBUFFER##* }
  token=$orig
  [[ -z "$token" ]] && token="."

  case "$token" in
    \"*\") token=${token:1:-1} ;;
    \'*\') token=${token:1:-1} ;;
  esac

  if [[ "$token" == "~" || "$token" == "~/"* ]]; then
    base_exp="$HOME/${token#\~/}"
  else
    base_exp="$token"
  fi

  if [[ -d "$base_exp" ]]; then
    base="$base_exp"
  elif [[ "$base_exp" == */* ]]; then
    base="${base_exp%/*}"; [[ -z "$base" ]] && base="."
  else
    base="."
  fi

  pretty="$base"; [[ "$pretty" == "$HOME"* ]] && pretty="~${pretty#$HOME}"

  # 色設定: ディレクトリ=水色(36)、./プレフィックス=グレー(90)
  local _gray_file_awk=$'BEGIN{g="\\033[90m./\\033[0m"; r="\\033[0m"; h=ENVIRON["_FZF_HOME"]} { p=$0; if (h != "" && p==h) { p=p " (~)" } else if (h != "" && index(p,h)==1) { p="~" substr(p,length(h)+1) } if (p ~ /^\\.\\//) { sub(/^\\.\\//,"",p); p=g p r } print p }'
  local _cyan_dir_awk=$'BEGIN{g="\\033[90m./\\033[0m"; c="\\033[36m"; r="\\033[0m"; h=ENVIRON["_FZF_HOME"]} { p=$0; if (h != "" && p==h) { p=p " (~)" } else if (h != "" && index(p,h)==1) { p="~" substr(p,length(h)+1) } if (p ~ /^\\.\\//) { sub(/^\\.\\//,"",p); p=g c p r } else { p=c p r } print p }'
  export _FZF_GRAY_FILE_AWK="$_gray_file_awk"
  export _FZF_CYAN_DIR_AWK="$_cyan_dir_awk"
  export _FZF_HOME="$HOME"
  export _FZF_BASE="$base"

  # ANSIを除去して {} からパスを取得
  local _d='$(printf '\''%s'\'' {} | perl -pe '\''s/\x1b\[[0-9;]*m//g; s/ \\(\\~\\)$//'\'' )'
  local _list_all=$'{ if ! command find -L "$b" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | grep -q .; then if [[ "$b" != "/" ]]; then printf "%s\\n" "${b%/}/.."; fi; fi; { command find -L "$b" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null; } | awk "${_FZF_CYAN_DIR_AWK}"; command find -L "$b" -mindepth 1 -maxdepth 1 -type f -print 2>/dev/null | awk "${_FZF_GRAY_FILE_AWK}"; }'
  local _list_dirs=$'{ if ! command find -L "$b" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null | grep -q .; then if [[ "$b" != "/" ]]; then printf "%s\\n" "${b%/}/.."; fi; fi; command find -L "$b" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null; } | awk "${_FZF_CYAN_DIR_AWK}"'

  picks=$({ { if ! command find -L "$base" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | grep -q .; then if [[ "$base" != "/" ]]; then printf '%s\n' "${base%/}/.."; fi; fi; command find -L "$base" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null; } | awk "$_cyan_dir_awk"; \
            command find -L "$base" -mindepth 1 -maxdepth 1 -type f -print 2>/dev/null | awk "$_gray_file_awk"; } | \
    fzf --ansi --multi --height=100% --prompt="" \
        --header="Shift+←→:ディレクトリ移動  ~:ホーム　Enter:確定" \
        --bind "shift-left:reload(d=${_d}; d=\${d/#\\~/$HOME}; if [[ -z \"\$d\" || \"\$d\" == \"/\" ]]; then b=\"\${_FZF_BASE}\"; else b=\$(cd \"\$(dirname \"\$d\")\" && cd .. && pwd); fi; [[ -z \"\$b\" ]] && b=\".\"; name=\$(printf '%s' \"\$d\" | perl -pe 's/\\x1b\\[[0-9;]*m//g; s|.*/||; s|^\\./||; s|/$||'); pref=\"\$b/\$name\"; if [[ \"\$b\" == \"/\" ]]; then name=\"\"; pref=\"\"; fi; { if [[ -n \"\$name\" && -e \"\$pref\" ]]; then printf '%s\\n' \"\$pref\"; fi; if ! command find -L \"\$b\" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | grep -q .; then if [[ \"\$b\" != \"/\" ]]; then printf '%s\\n' \"\${b%/}/..\"; fi; fi; command find -L \"\$b\" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | { if [[ -n \"\$pref\" ]]; then grep -v -F \"\$pref\"; else cat; fi; } | awk \"\${_FZF_CYAN_DIR_AWK}\"; command find -L \"\$b\" -mindepth 1 -maxdepth 1 -type f -print 2>/dev/null | awk \"\${_FZF_GRAY_FILE_AWK}\"; })+first+transform-query(printf '%s' \"\\$FZF_QUERY\")" \
        --bind "shift-right:reload(d=${_d}; d=\${d/#\\~/$HOME}; d=\${d% \\(\\~\\)}; if [[ \"\$d\" == */.. || \"\$d\" == \"..\" ]]; then printf '\\r\\033[2K\\033[95m** cannot enter: .. **\\033[0m' > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); else if [[ -d \"\$d\" ]]; then if [[ ! -r \"\$d\" || ! -x \"\$d\" ]]; then printf '\\r\\033[2K\\033[95m** permission denied: %s **\\033[0m' \"\$d\" > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); else printf '\\r\\033[2K' > /dev/tty; b=\"\$d\"; fi; else printf '\\r\\033[2K' > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); fi; fi; [[ -z \"\$b\" ]] && b=\".\"; ${_list_all})+transform-query(printf '%s' \"\\$FZF_QUERY\")" \
        --bind "~:reload(b=\"$HOME\"; ${_list_all})+transform-query(printf '%s' \"\\$FZF_QUERY\")"
  )

  unset _FZF_GRAY_FILE_AWK _FZF_CYAN_DIR_AWK _FZF_HOME _FZF_BASE

  # 選択結果からANSIエスケープを除去
  picks=$(printf '%s' "$picks" | sed $'s/\x1b\\[[0-9;]*m//g')

  # ESCで抜けた場合、プロンプトをリセット
  if [[ -z "$picks" ]]; then
    zle redisplay
    return
  fi

  # ←← ここから"~ をエスケープしない"挿入ロジック
  [[ -n "$orig" ]] && LBUFFER="${LBUFFER%$orig}"
  local IFS=$'\n' p ins rest
  for p in $picks; do
    p="${p% (~)}"
    if [[ "$p" == "." || "$p" == "./" || "$p" == "$PWD" ]]; then
      LBUFFER+="./ "
      continue
    fi
    local p_abs
    if [[ "$p" == "~" || "$p" == "~/"* ]]; then
      p_abs="$HOME${p#\~}"
    elif [[ "$p" == "./"* || "$p" == "." ]]; then
      p_abs="$PWD/${p#./}"
    else
      p_abs="$p"
    fi
    if [[ -d "$p_abs" && "$p_abs" == "$PWD/"* ]]; then
      local rel="${p_abs#$PWD/}"
      LBUFFER+="./${(q)rel}/ "
      continue
    fi
    if [[ -d "$p" && "$p" != */ ]]; then
      p="$p/"
    fi
    if [[ "$p" == "~" || "$p" == "~/"* ]]; then
      # 先頭 ~ を保持、残りだけをクォート
      rest="${p#\~}"
      LBUFFER+="~${(q)rest} "
    elif [[ "$p" == "$HOME"* ]]; then
      # 先頭 ~ を保持、残りだけをクォート
      rest="${p#$HOME}"
      LBUFFER+="~${(q)rest} "
    else
      ins="$p"
      LBUFFER+="${(q)ins} "
    fi
  done
  zle redisplay
}
zle -N fzf_path_aware_ctrl_t_shallow
bindkey '^T' fzf_path_aware_ctrl_t_shallow

# （任意）元のCtrl-Tを退避
if zle -l | grep -q '^fzf-file-widget$'; then bindkey '^G' fzf-file-widget; fi
