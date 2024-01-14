d ()
{
    local dir=${D_DOCS:-~/.local/share/d_docs};
    local comment=36;
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
        return;
    fi;
    # Edit mode
    if [[ $1 = "-e" ]]; then
        local entry;
        entry=$2;
        if [[ -z $entry ]]; then
            echo -n "  Name of entry: ";
            read entry;
            if [[ -z $entry ]]; then
                return;
            fi;
        fi;
        ${EDITOR:-nano} $dir/$entry.txt;
        return;
    fi;
    # Search mode
    if [[ $1 = '-s' ]]; then
        local query
        query=$2
        if [[ -z $query ]]; then
            echo -n "  Search for..: "
            read query;
            if [[ -z $query ]]; then
                return;
            fi;
        fi;
        command grep -in --color=always "${query}" ${dir}/*.txt | less -rF
        return;
    fi
    # check for color flag
    if [[ $1 = '-c' || $1 = '--color' ]]; then
        local color=true
        shift
    fi
    # Display mode
    local file;
    local partial;
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
        local doc=$(cat "$file");
        if [[ $partial == 1 ]]; then doc="===> $(basename ${file%.*})\n$doc"; fi
        local esc=$(printf '\033');
        # sed 1: only within comments, a reset-color code is replaced by a color code using the $comment color (and resets
        #        style and background)
        # sed 2: comment lines get colored using the $comment color
        # also a backup here because the new version works better with undoing underlined text but I don't know why
        # doc="$(echo "$doc" | sed "/^#/s/\\e\[0m/\\e[${comment};49;22m/g" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
        doc="$(echo "$doc" | sed "/^#/s/\\\e\[0m/${esc}[0m${esc}[36;49;22m/g" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
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
        return 44;
    fi
}
