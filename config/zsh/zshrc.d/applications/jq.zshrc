is-executable jq || return

# Catppuccin Mocha colors for jq output (truecolor).
# Fields: null:false:true:numbers:strings:arrays:objects:object-keys
#   null=overlay0  false=red  true=green  numbers=peach
#   strings=green  arrays=blue  objects=mauve  object-keys=lavender
export JQ_COLORS="38;2;108;112;134:38;2;243;139;168:38;2;166;227;161:38;2;250;179;135:38;2;166;227;161:38;2;137;180;250:38;2;203;166;247:38;2;180;190;254"
