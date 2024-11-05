function ___paths_plugin_set_colors
    if not set -q ___paths_plugin_colors
        set -Ux ___paths_plugin_colors 27e6ff 29e0ff 5cd8ff 77d0ff 8ac8ff 9cbfff afb5ff c5a7ff d99bfe ea8feb f684d5 fe7abd ff73a3 ff708a fa7070 ff708a ff73a3 fe7abd f684d5 ea8feb d99bfe c5a7ff afb5ff 9cbfff 8ac8ff 77d0ff 5cd8ff 29e0ff
    end
    return 0
end

function _paths_uninstall --on-event paths_uninstall
    for i in ___paths_plugin_wrap_color ___paths_plugin_output ___paths_plugin_handle_found_item ___paths_plugin_handle_source ___paths_plugin_cycle_color
        functions -e $i
    end
    set -e ___paths_plugin_colors
    set -e ___paths_plugin_current_color
end

function _paths_install --on-event _paths_install
    ___paths_plugin_set_colors
end

function _paths_update --on-event paths_update
    ___paths_plugin_set_colors
end
