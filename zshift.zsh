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
  export _ZSHIFT_LIST_ALL_CMD=$'{ if ! command find -L "$b" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null | grep -q .; then if [[ "$b" != "/" ]]; then printf "%s\\n" "${b%/}/.."; fi; fi; { command find -L "$b" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null; } | awk "${_FZF_CYAN_DIR_AWK}"; command find -L "$b" -mindepth 1 -maxdepth 1 -type f -print 2>/dev/null | awk "${_FZF_GRAY_FILE_AWK}"; }'

  # ANSIを除去して {} からパスを取得
  local _d='$(printf '\''%s'\'' {} | perl -pe '\''s/\x1b\[[0-9;]*m//g; s/ \\(\\~\\)$//'\'' )'

  picks=$(b="$base"; eval "$_ZSHIFT_LIST_ALL_CMD" | \
    fzf --ansi --multi --height=100% --prompt="" \
        --header="Shift+←→:ディレクトリ移動  ~:ホーム　Enter:確定" \
        --bind "shift-left:transform:d=${_d}; d=\${d/#\\~/$HOME}; if [[ -z \"\$d\" ]]; then b=\"\${_FZF_BASE}\"; pos=1; came_from=\"\"; else came_from=\$(cd \"\$(dirname \"\$d\")\" && pwd); if [[ \"\$came_from\" == \"/\" ]]; then b=\"/\"; pos=1; else b=\$(cd \"\$came_from\" && cd .. && pwd); pos=\$(command find -L \"\$b\" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | awk -v target=\"\$came_from\" 'BEGIN{n=1; found=0} { if (\$0 == target) { print n; found=1; exit } n++ } END { if (!found) print 1 }'); fi; fi; [[ -z \"\$b\" ]] && b=\".\"; printf '%s | d=%s | came_from=%s | b=%s | pos=%s\n' \"\$(date '+%F %T')\" \"\$d\" \"\$came_from\" \"\$b\" \"\$pos\" >> /tmp/zshift-debug.log; printf \"reload-sync(b=%s; eval \\\"\\\$_ZSHIFT_LIST_ALL_CMD\\\")+pos(%s)+clear-query\" \"\$b\" \"\$pos\"" \
        --bind "shift-right:reload(d=${_d}; d=\${d/#\\~/$HOME}; d=\${d% \\(\\~\\)}; next_b=\"\"; if [[ \"\$d\" == */.. || \"\$d\" == \"..\" ]]; then printf '\\r\\033[2K\\033[95m** cannot enter: .. **\\033[0m' > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); next_b=\"\$b\"; else if [[ -d \"\$d\" ]]; then if [[ ! -r \"\$d\" || ! -x \"\$d\" ]]; then printf '\\r\\033[2K\\033[95m** permission denied: %s **\\033[0m' \"\$d\" > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); next_b=\"\$b\"; else printf '\\r\\033[2K' > /dev/tty; b=\"\$d\"; next_b=\"\$b\"; fi; else printf '\\r\\033[2K' > /dev/tty; b=\$(cd \"\$(dirname \"\$d\")\" && pwd); next_b=\"\$b\"; fi; fi; [[ -z \"\$b\" ]] && b=\".\"; printf '%s | dir=right | d=%s | next_b=%s | query=%s\n' \"\$(date '+%F %T')\" \"\$d\" \"\$next_b\" \"\$FZF_QUERY\" >> /tmp/zshift-debug.log; eval \"\$_ZSHIFT_LIST_ALL_CMD\")+clear-query" \
        --bind "~:reload(b=\"$HOME\"; eval \"\$_ZSHIFT_LIST_ALL_CMD\")+clear-query"
  )

  unset _FZF_GRAY_FILE_AWK _FZF_CYAN_DIR_AWK _FZF_HOME _FZF_BASE _ZSHIFT_LIST_ALL_CMD

  # 選択結果からANSIエスケープを除去
  picks=$(printf '%s' "$picks" | sed $'s/\x1b\\[[0-9;]*m//g')

  # ESCで抜けた場合、プロンプトをリセット
  if [[ -z "$picks" ]]; then
    zle redisplay
    return
  fi

  # ←← ここから"~ をエスケープしない"挿入ロジック
  [[ -n "$orig" ]] && LBUFFER="${LBUFFER%$orig}"
  local p ins rest
  for p in "${(f)picks}"; do
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
