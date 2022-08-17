d () 
{ 
    local dir=${D_DOCS:-~/.my_stuff/docs};
    local comment=36;
    if [[ -r $dir/d.conf ]]; then
        . $dir/d.conf;
    fi;
    if [[ -z $1 ]]; then
        echo "  Man pages: the cliffs notes.";
        echo "  Available: "$(ls $dir/*.txt | xargs basename -a | sed s/.txt//);
        echo "  Usage: d <entry>     # view entry";
        echo "         d -e <entry>  # create or edit entry";
        echo "  Supports ANSI color sequences.";
        return;
    fi;
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
    if [[ -f $dir/$1.txt ]]; then
        local doc=$(cat $dir/$1.txt);
        if [[ -t 1 ]]; then
            local esc=$(printf '\033');
            doc="$(echo "$doc" | sed "s/^\(#.*\)/${esc}[${comment}m\1${esc}[0m/")";
            echo -e "$doc" | less -rF;
        else
            echo "$doc";
        fi;
    else
        echo "  E: docs not found.";
        return 44;
    fi
}
