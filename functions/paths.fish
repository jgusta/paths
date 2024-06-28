function ___paths_plugin_wrap_color
    set_color normal
    set_color "$argv[1]"
    echo -n "$argv[2..]"
    set_color normal
end

function ___paths_plugin_output
    set -l options (fish_opt -s c -l color --required-val)
    set -a options (fish_opt -s p -l no-prefix) # no prefix
    set -a options (fish_opt -s k -l clean) # no colors
    set -a options (fish_opt -s n -l no-endline) # echos without newline

    argparse $options -- $argv

    set -l acc ''
    set -l tick -
    set -l listy ""

    # -c/--color <color> means to color this line with <color>
    if set -q _flag_c
        # include tick?
        if not set -q _flag_p
            # color tick?
            if not set -q _flag_k
                set tick (___paths_plugin_wrap_color "yellow" $tick)
            end
        end
        # wrap line in color or not
        if set -q _flag_k
            set listy $argv
        else
            set listy (___paths_plugin_wrap_color $_flag_c $argv)
        end
    else
        # include tick?
        if not set -q _flag_p
            # we still color the tick unless -k is set
            if not set -q _flag_k
                set tick (___paths_plugin_wrap_color "yellow" $tick)
            end
        end
        # do not wrap line in color
        set listy $argv
    end

    # Bring line together with or without tick
    if set -q _flag_p
        set acc "$listy"
    else
        set acc "$tick $listy"
    end

    # echo line with or without new line
    if set -q _flag_n
        echo -n "$acc"
    else
        echo -n -e "$acc\n"
    end
end

function paths --description "Reveal the executable matches in shell paths or fish autoload."
    set options (fish_opt -s q -l clean)
    set -a options (fish_opt -s s -l single)
    set -a options (fish_opt -s n -l no-color)
    argparse $options -- $argv
    if test (count $argv) -lt 1
        echo "paths - executable matches in shell paths or fish autoload."
        and echo "usage: paths [-q|-s|-n] <name>"
        and echo -e "\t-q or --clean: output without color or headers"
        and echo -e "\t-s or --single: output without color or headers, the first result"
        and echo -e "\t-n or --no-color: output without color"
        and return 1
    end
    set -f foundStatus 1
    set -f input $argv
    set -f outFlags ''

    # determine no color flag
    if set -q NO_COLOR
        or set -q _flag_n
        or set -q _flag_q
        or set -q _flag_s
        set -f NO_COLOR
        set -p outFlags -k
    end

    # determine no prefix flag
    if set -q _flag_q
        or set -q _flag_s
        set -p outFlags -p
    end


    set colors 7343A9 9B0F8C B8007F CE2029 D84528 E26928 EB8E27 F5B227 FFD726 FFE675 FFF6CC FFEEE2 FFF5FF 10EDF5 28BCE0 556CBC 7343A9 9B0F8C B8007F CE2029 D84528 E26928 EB8E27 F5B227 FFD726 FFE675 FFF6CC FFEEE2 FFF5FF 10EDF5 28BCE0 556CBC
    set -f i (count $colors)
    # loop over list of path lists
    for pVar in VIRTUAL_ENV fisher_path fish_function_path fish_user_paths PATH
        set -e acc

        # see if variable is empty
        if test -z "$pVar"
            continue
        end
        # loop over path lists
        for t in $$pVar
            # loop over files with and without fish 
            for name in "$t/$input.fish" "$t/bin/$input" "$t/$input"
                # check if file exists
                if test -f "$name"
                    set -f nameOut $name
                    # check if file is a symlink
                    if test -L "$name"
                        if set -q _flag_q
                            or set -q _flag_s
                            set nameOut "$name"
                        else
                            set -f __linkname (readlink -f "$name")
                            set -f arrow "=>"
                            if not set -q NO_COLOR
                                set __linkName (___paths_plugin_wrap_color "$colors[$i]" $__linkname)
                                set arrow (___paths_plugin_wrap_color "yellow" "$arrow")
                            end
                            set name (___paths_plugin_output --color="$colors[$i]" $outFlags -n "$name")
                            set nameOut "$name $arrow $__linkname"
                        end
                    else
                        set nameOut (___paths_plugin_output --color="$colors[$i]" $outFlags -n "$name")
                    end
                    # if acc doesn't exist, create it
                    if set -q acc
                        set -f acc "$nameOut"
                    else
                        set -a acc "$nameOut"
                    end
                end # [end check file name]
            end # [end file name list loop]
        end # [end path list loop]

        # only print anything if there is anything.
        if set -q acc
            # determine if we print the source or not
            if not set -q _flag_q
                and not set -q _flag_s
                # prepend source
                set -p acc "$pVar\n"
                set -a acc "\n"
            end

            # echo the whole section
            echo -e "$acc"

            # next color
            set i (math $i - 1)

            # if single flag, then we are done here.
            if set -q _flag_s
                return 0
            end
            set foundStatus 0
        end

    end # [end list of path lists loop]
    return $foundStatus
end
