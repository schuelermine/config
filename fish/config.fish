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

fish_add_path $HOME/.local/bin

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

set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1

#* 2: User-facing settings

#* 2.1: Shell look & feel

function fish_greeting
    switch "$USER"
        case root
            echo "Hello."
        case '*'
#            if command -v fortune >/dev/null
#                and command -v cowsay >/dev/null
#                and command -v lolcat >/dev/null
#                and cowsay -l | grep "duck" >/dev/null
                fortune | cowsay -f duck | lolcat -t
#            end
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

function ...
    if test "$argv[1]" != ""
        set depth "$argv[1]"
    else
        set depth 2
    end
    for i in (seq $depth)
        cd ..
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
    ls -AR $argv
end

function lx --wraps ls
    ls -QRna $argv
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

#* 2.3: Custom behaviour

function mv --wraps mv
    command mv --no-clobber $argv
end

function nano --wraps nano
    command nano --atblanks --autoindent --cutfromcursor --historylog --indicator --linenumbers --mouse --positionlog --showcursor --smarthome --softwrap --suspendable --tabsize=4 --tabstospaces --zap $argv
end

function sl
    command sl -e $argv
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
