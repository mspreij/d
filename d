d () 
{ 
    local dir=~/.my_stuff/docs;
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
        ${EDITOR:-/usr/bin/nano} $dir/$entry.txt;
        return;
    fi;
    if [[ -f $dir/$1.txt ]]; then
        local doc=$(cat $dir/$1.txt);
        doc="$(echo "$doc" | sed "s/^\(#.*\)/${esc}[36m\1${esc}[0m/")";
        echo -e "$doc";
    else
        echo "  E: docs not found.";
        return 44;
    fi
}
