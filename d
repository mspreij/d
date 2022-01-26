# d is a function
d () 
{ 
    local dir=~nemo/.nemo/docs;
    if [[ -z $1 ]]; then
        echo "  Man pages: the cliffs notes.";
        echo "  Available: "$(ls $dir/*.txt | xargs basename -a | sed s/.txt//);
        return;
    fi;
    if [[ -f $dir/$1.txt ]]; then
        cat $dir/$1.txt;
    else
        echo "  E: docs not found.";
        return 44;
    fi
}
