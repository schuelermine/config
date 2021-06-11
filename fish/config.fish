#!/usr/bin/fish

# CONTENTS:
# 1 Environment setups
# 1.1 Local binaries
# 1.2 GHCup
# 1.3 Deno
# 1.4 Glamour
# 1.5 .NET SDK
# 2 User-facing settings
# 2.1 Shell look & feel
# 2.2 Utility functions
# 2.3 Custom behaviour
# 2.4 Default programs

#* 2: Environment setups

#* 1.1: Local binaries

fish_add_path $HOME/.local/bin/

fish_add_path $HOME/Apps/

#* 1.2: GHCup

set -q GHCUP_INSTALL_BASE_PREFIX[1]
or set GHCUP_INSTALL_BASE_PREFIX $HOME

test -f /home/anselmschueler/.ghcup/env
and fish_add_path $HOME/.cabal/bin /home/anselmschueler/.ghcup/bin

#* 1.3 Deno

set -gx DENO_INSTALL /home/anselmschueler/.deno
fish_add_path $DENO_INSTALL/bin

#* 1.4 Glamour

set -gx GLAMOUR_STYLE /home/anselmschueler/.config/glamour/dark.json

#* 1.5 .NET SDK

fish_add_path $HOME/.dotnet
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1

#* 2: User-facing settings

#* 2.1: Shell look & feel

function fish_greeting
    switch "$USER"
        case root
            echo "Hello."
        case '*'
            fortune | cowsay -f duck | lolcat -t
            echo ""
            echo "Welcome to fish."
    end
end

function fish_prompt --description 'Write out the prompt'
    set oldstatus $status

    set red (set_color brred)
    set gray (set_color brblack)
    set user_color (set_color $fish_color_cwd)
    set root_color (set_color $fish_color_cwd_root)
    set path_color (set_color $fish_color_user)
    set normal_color (set_color normal)

    set warning_color $path_color
    if test $oldstatus -gt 0
        set warning_color $red
    end

    switch "$USER"
        case root
            echo ┌[(date +%H:%M:%S)] "$gray"[fish] "$root_color""$USER" "$path_color""$PWD" "$warning_color"["$oldstatus"]"$normal_color"
            echo ╘\#" "

        case '*'
            echo ┌[(date +%H:%M:%S)] "$gray"[fish] "$user_color""$USER" "$path_color""$PWD" "$warning_color"["$oldstatus"]"$normal_color"
            echo └\$" "
    end
end

#* 2.2: Utility functions

function gzxh
    if test (count $argv) = 0
        return 1
    end
    set session (tmux new-session -d -P -F '#{session_name}' $argv[2])
    for cmd in $argv[3..-1]
        tmux split-window -t "$session:{start}.{bottom}" $cmd
        if test $status != 0
            tmux select-layout -t $session $argv[1]
            tmux split-window -t "$session:{start}.{bottom}" $cmd
        end
    end
    tmux select-layout -t $session $argv[1]
    tmux attach -t $session
end

function capture-window
    magick convert (xwd $argv[2..-1] | psub -s .xwd) png:- > $argv[1]
end

function ...
    if test "$argv[1]" != ""
        set depth "$argv[1]"
    else
        set depth 2
    end
    set dest .
    for i in (seq $depth)
        set dest $dest/..
    end
    if isatty stdout
        cd $dest
    else
        echo $dest
    end
end

function throw
    return $argv[1]
end

function random-cow-fortune
    fortune | cowsay -f (random choice (cowsay -l | tail +2 | string split " ")) | lolcat -t
end

function date-overview --wraps date
    date "+Year%t%t%Y%nISO year%t%G%nQuarter of year%t%q%nMonth%t%t%m%nMonth name%t%B%nDay of year%t%j%nDay of month%t%d%nWeek%t%t%W%nISO Week%t%V%nWeekday%t%t%u%nWeekday name%t%A%nHalf of day%t%p%nHour%t%t%H%nMinute%t%t%M%nSeconds%t%t%S%nNanoseconds%t%N%nTimestamp%t%s%nTimezone%t%z%nTimezone name%t%Z" $argv
end

function isodate --wraps date
    date +'%Y-%m-%d %H:%M:%S %:z' $argv
end

function hd --wraps hd
    command hd -v $argv
end

function l+ --wraps ls
    ls --almost-all --recursive $argv
end

function lq --wraps ls
    ls --quote-name --recursive --numeric-uid-gid --all $argv
end

function lf --wraps ls
    ls -l --almost-all --classify --color=always --human-readable $argv
end

function lx --wraps ls
    ls -l --almost-all --classify --author --group-directories-first --recursive $argv
end

function mkdir+ --wraps mkdir
    mkdir $argv
    cd $argv[1]
end

function mv-
    mv $argv[1..-2] $argv[-1]
    mkdir $argv[1..-2]
end

function repeat
    for i in (seq $argv[1])
        eval $argv[2..-1]
    end
end

function rmcl
    xsel -bc
end

function sesc --wraps=sed
    sed s/\x1b/␛/g $argv
end

function git-commit
    set files $argv
    if test (count $files) = 0
        set files "."
    end
    git add $files
    read --prompt-str (set_color green)"Commit message: "(set_color normal) message
    git commit --message $message
end

#* 2.3: Custom behaviour

function mv --wraps mv
    command mv --no-clobber $argv
end

function nano --wraps nano
    command nano --atblanks --autoindent --cutfromcursor --historylog --indicator --linenumbers --mouse --positionlog --showcursor --smarthome --softwrap --suspendable --tabsize=4 --tabstospaces --zap $argv
end

function sl --wraps sl
    command sl -e $argv
end

function la --wraps ls
    ls -AF $argv
end

#* 2.4: Default programs

set -gx EDITOR nano --atblanks --autoindent --cutfromcursor --historylog --indicator --linenumbers --mouse --positionlog --showcursor --smarthome --softwrap --suspendable --tabsize=4 --tabstospaces --zap
set -gx VISUAL code-insiders -w

#* 2.5 Editing this file

set -l config_directory (
    set -q XDG_CONFIG_HOME
    and echo $XDG_CONFIG_HOME
    or echo $HOME/.config
)
set -g fishrc $config_directory/fish/config.fish

function fishrcedit
    $EDITOR $fishrc
end

#* 2.6 Aliases

function cls --wraps clear
    clear $argv
end

# 2.7 Keybinds

bind \b backward-kill-path-component

bind \e\[3\;5~ kill-bigword
