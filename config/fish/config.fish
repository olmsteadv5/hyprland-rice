source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end


# Ollama AMD iGPU - Radeon 890M (gfx1150)
set -x HSA_OVERRIDE_GFX_VERSION 11.5.0
set -x OLLAMA_NUM_GPU 999

#Juypter Julia optimization
set -x JULIA_NUM_THREADS auto

#Fish Terminal
fish_add_path ~/.local/bin

# FreeSurfer Setup for Fish
set -gx FREESURFER_HOME /opt/freesurfer
if test -f $FREESURFER_HOME/SetUpFreeSurfer.sh
    # This allows Fish to skip the broken PS1 line and just get the paths
    set -gx OS (uname -s)
    set -gx FS_OVERRIDE 0
    set -gx FIX_VERTEX_AREA ""
    set -gx FSF_OUTPUT_FORMAT "nii.gz"

    # Manually add FreeSurfer binaries to your PATH
    fish_add_path $FREESURFER_HOME/bin
    fish_add_path $FREESURFER_HOME/fsfast/bin
    fish_add_path $FREESURFER_HOME/tktools
    fish_add_path $FREESURFER_HOME/mni/bin
end

# Starship prompt (gruvbox-rainbow preset in ~/.config/starship.toml)
if status is-interactive; and command -q starship
    starship init fish | source
end
