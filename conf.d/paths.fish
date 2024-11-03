function ___paths_plugin_set_colors
    set -q ___paths_plugin_colors or
    set -U ___paths_plugin_colors 7343A9 9B0F8C B8007F CE2029 D84528 E26928 EB8E27 F5B227 FFD726 FFE675 FFF6CC FFEEE2 FFF5FF 10EDF5 28BCE0 556CBC 7343A9 9B0F8C B8007F CE2029 D84528 E26928 EB8E27 F5B227 FFD726 FFE675 FFF6CC FFEEE2 FFF5FF 10EDF5 28BCE0 556CBC
end

function _paths_uninstall --on-event paths_uninstall
    for i in ___paths_plugin_wrap_color ___paths_plugin_output ___paths_plugin_handle_found_item ___paths_plugin_handle_source
        functions -e $i
    end
    set -e ___paths_plugin_colors
end

function _paths_install --on-event _paths_install
    ___paths_plugin_set_colors
end

function _paths_update --on-event paths_update
    ___paths_plugin_set_colors
end
