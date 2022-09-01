d () 
{ 
    local dir=${D_DOCS:-~/.my_stuff/docs};
    local comment=36;
    if [[ -r $dir/d.conf ]]; then
        . $dir/d.conf;
    fi;
    # Help text
    if [[ -z $1 ]]; then
        echo "  Man pages: the cliffs notes.";
        echo "  Available: "$(ls $dir/*.txt | xargs basename -a | sed s/.txt//);
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
        grep -n --color=always ${query} ${dir}/*.txt | less -rF
        return;
    fi
    # Display mode
    if [[ -f $dir/$1.txt ]]; then
        local doc=$(cat $dir/$1.txt);
        if [[ -t 1 ]]; then
            local esc=$(printf '\033');
            # sed 1: only within comments, a reset-color code is replaced by a color code using the $comment color (and resets
            #        style and background)
            # sed 2: comment lines get colored using the $comment color
            doc="$(echo "$doc" | sed "/^#/s/\\e\[0m/\\e[${comment};49;22m/g" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
            echo -e "$doc" | less -rF;
        else
            echo "$doc";
        fi;
    else
        echo "  E: docs not found.";
        return 44;
    fi
}
