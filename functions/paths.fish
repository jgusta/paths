function ___paths_plugin_wrap_color
    set_color normal
    set_color "$argv[1]"
    echo -n (set_color "$argv[1]")"$argv[2..]"
    set_color normal
end

# duplicated in conf.d
function ___paths_plugin_set_colors
    if not set -q ___paths_plugin_colors
        set -Ux ___paths_plugin_colors 27e6ff 29e0ff 5cd8ff 77d0ff 8ac8ff 9cbfff afb5ff c5a7ff d99bfe ea8feb f684d5 fe7abd ff73a3 ff708a fa7070 ff708a ff73a3 fe7abd f684d5 ea8feb d99bfe c5a7ff afb5ff 9cbfff 8ac8ff 77d0ff 5cd8ff 29e0ff
    end
    return 0
end

function ___paths_plugin_cycle_color
    if not set -q ___paths_plugin_current_color
        set -Ux ___paths_plugin_current_color 1
    else if test $___paths_plugin_current_color -gt (count $___paths_plugin_colors)
        set -Ux ___paths_plugin_current_color 1
    end
    echo $___paths_plugin_colors[$___paths_plugin_current_color]
    set -Ux ___paths_plugin_current_color (math $___paths_plugin_current_color + 1)
end

function ___paths_plugin_handle_found_item -a testName outFlags
    set -f flags (string split -n ' ' -- "$outFlags")
    set -f options (fish_opt -s c -l clean)
    set -a options (fish_opt -s s -l single)
    set -a options (fish_opt -s k -l no-color)
    set -a options (fish_opt -s n -l inline)
    argparse $options -- $flags

    set -f arrow "=>"
    # check if file exists
    if test -e "$testName"
        set -f nameOut (string trim -- "$testName")
        if not set -q _flag_c # is not clean
            if test -L "$testName" # is symlink
                set -f __linkname (readlink -f "$testName")
                set __linkname (string trim -- "$__linkname")
                set testName (string trim -- "$testName")
                if not set -q _flag_k # is color
                    set nameOut (___paths_plugin_wrap_color (___paths_plugin_cycle_color) $testName) (___paths_plugin_wrap_color "yellow" "$arrow") (___paths_plugin_wrap_color (___paths_plugin_cycle_color) $__linkname)
                else # is color
                    set nameOut (echo -n "$testName" "$arrow" "$__linkname")
                end
            else # is not symlink
                if not set -q _flag_k # is color
                    set testName (string trim -- "$testName")
                    set nameOut (___paths_plugin_wrap_color (___paths_plugin_cycle_color) "$testName")
                else
                    set testName (string trim -- "$testName")
                    set nameOut "$testName"
                end
            end

            set nameOut (string trim -- "$nameOut")
            # do the tick 
            if set -q _flag_k # is not color
                set nameOut "- $nameOut"
            else # is color
                set nameOut (___paths_plugin_wrap_color "yellow" "-") "$nameOut"
            end
        end
        set nameOut (string trim -- "$nameOut")
        echo -n $nameOut
    end
end

function paths --description "Reveal the executable matches in shell paths or fish autoload."
    set -f options (fish_opt -s c -l clean)
    set -a options (fish_opt -s s -l single)
    set -a options (fish_opt -s k -l no-color)
    set -a options (fish_opt -s q -l quiet)
    set -a options (fish_opt -s n -l inline)
    argparse $options -- $argv

    if test -z (count $argv) -lt 1
        set -f SCRIPTNAME (status function)
        echo "paths - executable matches in shell paths or fish autoload."
        and echo "usage: paths [-c|-s|-k] <name>"
        and echo -e "\t-k or --no-color: output without color"
        and echo -e "\t-c or --clean: output without tick marks or headers. Just a list of paths"
        and echo -e "\t-s or --single: output path in a single clean line. Implies -k and -c"
        and echo -e ""
        and echo -e ""
        # and echo -e "\t-n or --inline: output without endline"
        and return 1
    end

    set -f foundStatus 1
    set -f input (string trim -- $argv)
    # deprecated
    if set -q _flag_q
        set _flag_c True
    end

    if set -q NO_COLOR
        set _flag_k True
    end

    if set -q _flag_s
        set _flag_k True
        set _flag_c True
    end

    set -f outFlags ''
    set -q _flag_n; and set -a outFlags -n
    set -q _flag_c; and set -a outFlags -c
    set -q _flag_k; and set -a outFlags -k
    set -q _flag_s; and set -a outFlags -s
    set outFlags (string split -n " " -- "$outFlags")
    ___paths_plugin_set_colors
    # loop over list of path lists
    for pVar in VIRTUAL_ENV fisher_path fish_function_path fish_user_paths PATH
        set -e acc
        set -f acc ''
        set -e hit
        # see if variable is empty
        if test -z "$pVar"
            continue
        end
        set -f acc (begin
            for t in $$pVar
                for snit in "$t/$input.fish" "$t/$input"
                    set -f found (___paths_plugin_handle_found_item "$snit" "$outFlags")
                    set found (string trim -- "$found")
                    if test -n "$found"
                        set -f hit True
                        echo "$found"
                        if set -q _flag_s
                            break
                        end
                    end
                end
                if set -q _flag_s
                    if set -q hit
                        break
                    end
                end
            end
        end)

        # prepend source
        if not set -q _flag_c
            if set -q hit
                set pVar (string trim -- "$pVar")
                echo -e -n "$pVar\n"
            end
        end

        if test -n "$acc"
            set foundStatus 0
            for fk in $acc
                echo $fk
                if set -q _flag_s
                    # stop after one
                    return $foundStatus
                end
            end
        end
    end

    # check 
    set -l built (type --type $input 12&>/dev/null)
    if test -n "$built"
        and test "$built" = 'builtin'
        set $foundStatus 0
        if not set -q _flag_c
            echo -e -n "builtin\n"
            if set -q _flag_k
                echo - "$input"
            else # is color
                echo (___paths_plugin_wrap_color "yellow" "-") (___paths_plugin_wrap_color (___paths_plugin_cycle_color) "$input")
            end
        else
            echo "$input"
        end
    end
    return $foundStatus
end
