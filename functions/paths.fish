# paths plugin
# for fish shell
# by jgusta (https://github.com/jgusta)
set -gx VERSION 1.2.0

function ___paths_plugin_wrap_bold
    set_color normal
    echo -n (set_color --bold)"$argv[1..]"
    set_color normal
end

function ___paths_plugin_help
    echo (___paths_plugin_wrap_bold "NAME")
    echo "paths - executable matches in shell paths or fish autoload."
    echo ""
    echo (___paths_plugin_wrap_bold "USAGE")
    echo ""
    echo "\
        paths [-c|-s|-k|-f|-v] <name>"
    echo ""
    echo (___paths_plugin_wrap_bold "ARGUMENTS")
    echo ""
    echo "\
        <name> - name of a fish autoload function, function, shell script, executable or builtin"
    echo ""
    echo (___paths_plugin_wrap_bold "OPTIONS")
    echo ""
    echo "    -k, --no-color
        Output without color"
    echo ""
    echo "    -c, --clean
        Output without tick marks, headers or saymlink destination.
        Implies -k."
    echo ""
    echo "    -s, --single
        Output the first result. Implies -k -c"
    echo ""
    echo "    -l, --list
        Show all the locations fish looks for executables"
    echo ""
    echo "    -e, --fail-if-not-path
        If the first result that would be output is not an executable file
        then return nothing and exit with status 1. Use if you want to make sure
        that the output is executable before you run it. Implies -s."
    echo ""
    echo "    -v, --version
        Display version number"
    echo ""
    echo "    -h, --help
        Output this help text"
    echo ""
    echo (___paths_plugin_wrap_bold "EXPLAINATION")
    echo ""
    echo "\
        paths is a fish function that takes a command name and walks
        through each of the executable locations to see where the command will
        execute from. Once found, it continues to find each subsequent location
        that are next in line were the first command be removed (with exceptions*).
        Commands are listed in priority order with a heading for each group of
        executable listing."
    echo ""
    echo (___paths_plugin_wrap_bold "LIMITATIONS")
    echo ""
    echo "\
        For declared functions such as those loaded by config.fish only the
        latest sourced function will be listed. i.e. if the function is overwritten,
        paths will not be able to tell what it was before it was overwritten. 
        In the event of a function defined via stdin into the source command,
        the output will path will be '-' unless the `--fail-if-not-path` option
        is set."
    echo ""
    echo (___paths_plugin_wrap_bold "EXECUTABLE SCHEMES AND LOCATIONS")
    echo ""
    echo "\
        paths checks the following locations for executables in this order:

        1) functions defined interactively
        2) functions defined via standard input into `source`
        3) \$fish_function_path
        4) \$fish_user_paths
        5) \$PATH
        6) builtins"
    echo ""
    echo "Note that some builtins will appear twice because they are also in an executable path"
end

function ___paths_plugin_short_help
    echo "executable matches in shell paths or fish autoload."

    echo (___paths_plugin_wrap_bold "USAGE") "paths [-c|-s|-k|-f|-v] [NAME]"
    echo ""
    echo (___paths_plugin_wrap_bold "ARGUMENTS")
    echo "       [NAME] - name of a fish autoload function, function, shell script, executable or builtin"
    echo ""
    echo (___paths_plugin_wrap_bold "OPTIONS")
    echo "    -h, --help                   Show full help"
    echo "    -k, --no-color               Output without color"
    echo "    -c, --clean                  Clean output. Implies -k."
    echo "    -s, --single                 Output the first result. Implies -k -c"
    echo "    -l, --list                   Show all places fish looks for executables"
    echo "    -e, --fail-if-not-path       Return false if output not executable file. Implies -s"
    echo "    -v, --version.               Display version number"
    echo ""
end

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
    set -a options (fish_opt -s z -l special)
    argparse $options -- $flags

    if set -q _flag_z
        set -f nameOut (string trim -- "$testName")
        if not set -q _flag_c
            if not set -q _flag_k
                set nameOut (___paths_plugin_wrap_color (___paths_plugin_cycle_color) "$nameOut")
            end
            set nameOut (string trim -- "$nameOut")
            # do the tick 
            if set -q _flag_k # is not color
                set nameOut "- $nameOut"
            else # is color
                set nameOut (___paths_plugin_wrap_color "yellow" "-") "$nameOut"
            end
            set nameOut (string trim -- "$nameOut")
        end
        echo -n $nameOut
        return
    end

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
                    set nameOut (___paths_plugin_wrap_color (___paths_plugin_cycle_color) "$testName") (___paths_plugin_wrap_color "yellow" "$arrow") (___paths_plugin_wrap_color (___paths_plugin_cycle_color) "$__linkname")
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
        echo -n "$nameOut"
    end
end

function paths --description "Reveal the executable matches in shell paths or fish autoload."
    set -f options (fish_opt -s c -l clean)
    set -a options (fish_opt -s s -l single)
    set -a options (fish_opt -s k -l "no-color")
    set -a options (fish_opt -s q -l quiet)
    set -a options (fish_opt -s v -l version)
    set -a options (fish_opt -s n -l inline)
    set -a options (fish_opt -s l -l list)
    set -a options (fish_opt -s h -l help)
    set -a options (fish_opt -s e -l "fail-if-not-path")
    argparse $options -- $argv

    if set -q _flag_h
        ___paths_plugin_help
        and return 0
    end

    if set -q _flag_l
        set input " "
    else
        if test (count $argv) -lt 1
            ___paths_plugin_short_help
            and return 1
        end
    end

    if test (count $argv) -lt 1
        ___paths_plugin_help
        and return 1
    end

    set -f foundStatus 1
    set -f input (string trim -- $argv)

    if set -q _flag_v
        echo "paths plugin version $VERSION"
        and return 0
    end

    set -f foundStatus 1
    set -f input (string trim -- $argv)

    # deprecated
    if set -q _flag_q
        set _flag_c True
    end

    if set -q _flag_e
        set _flag_s True
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

    set -f specialFlags (string split -n " " -- "$outFlags -z")
    set -l special (functions "$input" | string match -r -i "# Defined (?:via `(source)`|(interactively))" | awk NR==2)

    if test "$special" = interactively
        if set -q _flag_e
            return 1
        end
        if not set -q _flag_c
            echo -e -n "Defined interactively\n"
        end
        set foundStatus 0

        set -f found (___paths_plugin_handle_found_item "$input" "$specialFlags")
        echo "$found"
        if set -q _flag_s
            # stop after one
            return $foundStatus
        end
    end

    if test "$special" = source
        if set -q _flag_e
            return 1
        end
        if not set -q _flag_c
            echo -e -n "Defined via source\n"
        end
        set foundStatus 0
        ___paths_plugin_handle_found_item
        if set -q _flag_s
            # stop after one
            return $foundStatus
        end
    end

    # loop over list of path lists
    for pVar in VIRTUAL_ENV fish_function_path fish_user_paths PATH
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
                echo "$fk"
                if set -q _flag_s
                    # stop after one
                    return $foundStatus
                end
            end
        end
    end

    set -l special (type -t $input)
    if test "$special" = builtin
        if set -q _flag_e
            return 1
        end
        if not set -q _flag_c
            echo -e -n "Built-in command\n"
        end
        set foundStatus 0
        if set -q _flag_s
            # stop after one
            return $foundStatus
        end
    end

    return $foundStatus
end
