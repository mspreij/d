#!/usr/bin/env bash

dir=${D_DOCS:-~/.local/share/d_docs};
comment=36;
if [[ -r $dir/d.conf ]]; then
    . $dir/d.conf;
fi;
# Help text
if [[ -z $1 ]]; then
    echo "  Man pages: the cliffs notes.";
    echo "  Available: "$(command ls $dir/*.txt | xargs basename -a | sed s/.txt//);
    echo "  Usage: d <entry>     # view entry";
    echo "         d -e <entry>  # create or edit entry";
    echo "         d -s <query>  # search entries for string";
    echo "  Supports ANSI color sequences.";
    exit
fi;

# Edit mode
if [[ $1 = "-e" ]]; then
    entry=$2;
    if [[ -z $entry ]]; then
        echo -n "  Name of entry: ";
        read entry;
        if [[ -z $entry ]]; then
            exit;
        fi;
    fi;
    ${EDITOR:-nano} "$dir/$entry.txt";
    modified_files=$(git -C "$dir" status -s -uno --porcelain | cut -c4- | sed 's/^"//;s/"$//')
    if [[ -n "$commit_edits" && $(printf '%s\n' "$modified_files" | grep -Fx "${entry}.txt") ]]; then
        echo -n "  Git commit message, will (try to) push (leave empty to skip): "
        read msg
        if [[ -n $msg ]]; then
            git -C "$dir" commit "$entry".txt -m "$msg"
            git -C "$dir" push
        fi
    fi
    exit;
fi;

# Search mode
if [[ $1 = '-s' ]]; then
    query=$2
    if [[ -z $query ]]; then
        echo -n "  Search for..: "
        read query;
        if [[ -z $query ]]; then
            exit;
        fi;
    fi;
    command grep -in --color=always "${query}" ${dir}/*.txt | less -rF
    exit;
fi

# check for color flag
if [[ $1 = '-c' || $1 = '--color' ]]; then
    color=true
    shift
fi

# Display mode
if [[ -f "$dir"/"$1".txt ]]; then                                    # exact match
    file="$dir"/"$1".txt
elif [[ $(command ls "$dir"/"$1"*.txt 2>/dev/null | wc -l) -eq 1 ]]; then    # starts with
    file=$(command ls "$dir"/"$1"*.txt)
    partial=1
elif [[ $(command ls "$dir"/*"$1"*.txt 2>/dev/null | wc -l) -eq 1 ]]; then   # contains
    file=$(command ls "$dir"/*"$1"*.txt)
    partial=1
fi
if [[ -f "$file" ]]; then
    doc=$(cat "$file");
    if [[ $partial == 1 ]]; then doc="===> $(basename ${file%.*})\n$doc"; fi
    esc=$(printf '\033');
    # sed 1: only within comments, a reset-color code is replaced by a color code using the $comment color (and resets
    #        style and background)
    # sed 2: comment lines get colored using the $comment color
    # also a backup here because the new version works better with undoing underlined text but I don't know why
    # doc="$(echo "$doc" | sed "/^#/s/\\e\[0m/\\e[${comment};49;22m/g" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
    doc="$(echo "$doc" | sed "/^#/s/\\\e\[0m/${esc}[0m${esc}[${comment};49;22m/g" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
    if [[ -t 1 ]]; then
        echo -e "$doc" | less -rF;
    else
        if [[ $color ]]; then
            echo -e "$doc"
        else
            echo -e "$doc" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g"
        fi;
    fi;
else
    echo "  E: docs not found.";
    exit 44;
fi
