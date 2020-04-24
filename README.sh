#!/bin/bash
output() {
    while IFS="" read -r lin; do
        echo "$lin"
    done
}

# Readme starts 2 lines down from here
txt=$(output << ----README----
# README.sh
The **new** way to write README files. README.sh has markdown-like syntax, only requires bash, and can be read from text editors and terminals alike.
 README.sh has support for **bold**, *italics* in _two different ways_ (although most terminals won't render it), __underline__, ~~strikethrough~~, and <red>c<yellow>o<green>l<blue>o<magenta>r<cyan>s</cyan>!

Even if you decide not to run it from the terminal, README.sh has been designed to use a human-readable and editable format, so both machines and humans alike can appreciate its beauty. Take a look inside this file!

README.sh also comes with convenience flags, including -a to enable ANSI color codes, -A to disable them, -l to pipe output through less, -L to not pipe output through less, and a help command with -h.
----README----
)

# Default options for ANSI colors and less
# Set to y for yes, or nothing for no
USE_ANSI=y
USE_LESS=

usage() {
    echo -e "$0 -[aAlLh]:\n-a: Enable ANSI colors.\n-A: Disable ANSI colors.\n-l: Enable output scrolling via less.\n-L: Disable output scrolling via less."
    exit 0
}

while getopts "haAlL" arg; do
    case $arg in
        a) USE_ANSI=y;;
        A) USE_ANSI=;;
        l) USE_LESS=y;;
        L) USE_LESS=;;
        h | *) usage;;
    esac
done

if [ -z "$USE_ANSI" ]; then
    declare -A codes=()
else
    declare -A codes=(
    ["bold"]=$'\e[1m'
    ["b"]=$'\e[1m'
    ["unbold"]=$'\e[22m'
    ["/b"]=$'\e[22m'
    ["crossed"]=$'\e[9m'
    ["del"]=$'\e[9m'
    ["nocrossed"]=$'\e[29m'
    ["/dek"]=$'\e[29m'
    ["underline"]=$'\e[4m'
    ["u"]=$'\e[4m'
    ["noline"]=$'\e[24m'
    ["/u"]=$'\e[24m'
    ["italics"]=$'\e[3m'
    ["i"]=$'\e[3m'
    ["noitalics"]=$'\e[20m'
    ["/i"]=$'\e[20m'
    ["black"]=$'\e[30m'
    ["red"]=$'\e[31m'
    ["green"]=$'\e[32m'
    ["yellow"]=$'\e[33m'
    ["blue"]=$'\e[34m'
    ["magenta"]=$'\e[35m'
    ["cyan"]=$'\e[36m'
    ["white"]=$'\e[37m'
    ["/black"]=$'\e[39m'
    ["/red"]=$'\e[39m'
    ["/green"]=$'\e[39m'
    ["/yellow"]=$'\e[39m'
    ["/blue"]=$'\e[39m'
    ["/magenta"]=$'\e[39m'
    ["/cyan"]=$'\e[39m'
    ["/white"]=$'\e[39m'
    ["bgblack"]=$'\e[40m'
    ["bgred"]=$'\e[41m'
    ["bggreen"]=$'\e[42m'
    ["bgyellow"]=$'\e[43m'
    ["bgblue"]=$'\e[44m'
    ["bgmagenta"]=$'\e[45m'
    ["bgcyan"]=$'\e[46m'
    ["bgwhite"]=$'\e[47m'
    ["/bgblack"]=$'\e[49m'
    ["/bgred"]=$'\e[49m'
    ["/bggreen"]=$'\e[49m'
    ["/bgyellow"]=$'\e[49m'
    ["/bgblue"]=$'\e[49m'
    ["/bgmagenta"]=$'\e[49m'
    ["/bgcyan"]=$'\e[49m'
    ["/bgwhite"]=$'\e[49m'
    )
fi

header_consume=
header_clean=
lined=y
bolded=
underlined=
italicized=
crossed=
tagged=
tag=

res=$(echo "$txt" |
while IFS="" read -r line
do
    len="${#line}"
    [ -z "$line" ] && [ -z "$lined" ] && lined=y && echo && echo
    for (( i=0; i<$len; i++ )); do
        cur="${line:$i:1}"
        dub="${line:$i:2}"
        if [ "$cur" = "\\" ]; then
            (( i = i + 1 ))
            echo -n "${line:$i:1}"
            continue
        fi
        if [ -n "$tagged" ]; then
            if [ "$cur" = ">" ]; then
                tagged=
                echo -n "${codes[$tag]}"
                continue
            fi
            tag="${tag}$cur"
            continue
        fi
        if [ "$i" -eq 0 ] && [ "$cur" = "#" ]; then
            header_consume=y
            header_clean=y
            echo -n "${codes[bold]}"
            continue
        fi
        if (( i == len - 2 )) && [ "$dub" = "  " ]; then
            lined=y
            echo
            break
        fi
        if (( i == len - 1 )) && [ "$cur" = "/" ]; then
            lined=y
            echo
            break
        fi
        if [ "$dub" = "**" ]; then
            (( i = i + 1 ))
            [ -n "$header_clean" ] && continue
            if [ -n "$bolded" ]; then
                echo -n "${codes[unbold]}"
                bolded=
            else
                echo -n "${codes[bold]}"
                bolded=y
            fi
            continue
        fi
        if [ "$dub" = "__" ]; then
            (( i = i + 1 ))
            if [ -n "$underlined" ]; then
                echo -n "${codes[noline]}"
                underlined=
            else
                echo -n "${codes[underline]}"
                underlined=y
            fi
            continue
        fi
        if [ "$dub" = "~~" ]; then
            (( i = i + 1 ))
            if [ -n "$crossed" ]; then
                echo -n "${codes[nocrossed]}"
                crossed=
            else
                echo -n "${codes[crossed]}"
                crossed=y
            fi
            continue
        fi
        if [ "$cur" = "_" ] || [ "$cur" = "*" ]; then
            if [ -n "$italicized" ]; then
                echo -n "${codes[noitalicized]}"
                italicized=
            else
                echo -n "${codes[italicized]}"
                italicized=y
            fi
            continue
        fi
        if [ "$cur" = "<" ]; then
            tagged=y
            tag=
            continue
        fi
        # Sorry, code blocks are not supported :(
        [ "$cur" = "\`" ] && continue;
        [ -n "$header_consume" ] && [[ "# " == *"$cur"* ]] && continue
        header_consume=
        lined=
        echo -n "$cur"
    done
    [ -n "$header_clean" ] && lined=y && echo "${codes[unbold]}"
    header_clean=
done)
if command -v less > /dev/null 2>&1 && [ -n "$USE_LESS" ]; then
    echo "$res" | less -R
else
    echo "$res"
fi
