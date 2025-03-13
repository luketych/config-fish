# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/luketych/miniconda3/bin/conda
    eval /Users/luketych/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "/Users/luketych/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
~/.local/bin/mise activate fish | source





function move_cursor_to_nth_char
    set -l char $argv[1]       # The target character
    set -l target_index $argv[2]  # The Nth occurrence to find
    set -l cmd (commandline)   # Get the full command input
    set -l count 0

    for i in (seq (string length -- $cmd))
        if test (string sub --start=$i --length=1 $cmd) = "$char"
            set count (math $count + 1)
            if test $count -eq $target_index
                commandline --cursor $i
                set -g fish_bind_mode insert; commandline -f repaint
                return
            end
        end
    end

    echo "Character '$char' number $target_index not found"
    set -g fish_bind_mode insert; commandline -f repaint
end


function move_cursor_forward_nth_char
    set -l char $argv[1]       # The target character
    set -l target_index $argv[2]  # The Nth occurrence to find
    set -l cmd (commandline)   # Get the full command input
    set -l cursor_pos (commandline --cursor)  # Get current cursor position

    # Ensure cursor_pos is at least 1 (Fish uses 1-based indexing)
    if test "$cursor_pos" -lt 1
        set cursor_pos 1
    end

    # Ensure $char is not empty
    if test -z "$char"
        echo "Error: No character selected."
        set -g fish_bind_mode insert; commandline -f repaint
        return
    end

    # Ensure target_index is a valid number
    if test -z "$target_index"; or not string match -rq '^-?[0-9]+$' -- "$target_index"
        echo "Error: Invalid target index '$target_index'."
        set -g fish_bind_mode insert; commandline -f repaint
        return
    end

    set -l count 0
    set -l last_match -1  # Track the last valid position

    # Loop through the command line AFTER the cursor position
    for i in (seq (math $cursor_pos + 1) (string length -- $cmd))
        if test (string sub --start=$i --length=1 $cmd) = "$char"
            set count (math $count + 1)
            set last_match $i  # Update last valid match
            if test $count -eq $target_index
                commandline --cursor $i  # Move cursor to this position
                set -g fish_bind_mode insert; commandline -f repaint
                return
            end
        end
    end

    # If requested index is too high, move to the last found occurrence
    if test $last_match -ne -1
        commandline --cursor $last_match
    else
        echo "Character '$char' not found after cursor"
    end

    set -g fish_bind_mode insert; commandline -f repaint
end


function fish_user_key_bindings
    # Step 1: Bind Ctrl+T to enter character selection mode for forward search (from cursor)
    bind \ct 'set -g fish_bind_mode char_select_forward; commandline -f repaint'

    # Step 2: Bind Shift+Ctrl+T to enter character selection mode for full-line search (from start)
    bind \cg 'set -g fish_bind_mode char_select_full; commandline -f repaint'

    # Step 3: Bind valid characters in char_select_forward mode (for Ctrl+T) and char_select_full mode (for Shift+Ctrl+T)
    for key in (string split '' 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-_.,;:!@#$%^&*()[]{}|\\<>?"')
        bind -M char_select_forward $key "set -g target_char $key; set -g fish_bind_mode num_select_forward; commandline -f repaint"
        bind -M char_select_full $key "set -g target_char $key; set -g fish_bind_mode num_select_full; commandline -f repaint"
    end

    # Step 4: Bind numbers 1-9 for both modes
    for num in 1 2 3 4 5 6 7 8 9
        bind -M num_select_forward $num "move_cursor_forward_nth_char \$target_char $num"
        bind -M num_select_full $num "move_cursor_to_nth_char \$target_char $num"
    end

    # Step 5: Pressing Esc resets to normal mode
    bind -M char_select_forward \e 'set -g fish_bind_mode insert; commandline -f repaint'
    bind -M num_select_forward \e 'set -g fish_bind_mode insert; commandline -f repaint'
    bind -M char_select_full \e 'set -g fish_bind_mode insert; commandline -f repaint'
    bind -M num_select_full \e 'set -g fish_bind_mode insert; commandline -f repaint'
end

# Set fish prompt to look like the following (w/ colors) [I] ❯ 257 ❯❯ ✔ ❯ luketych:config-fish/config-fish >
function fish_prompt
    # Capture exit status before anything else
    set -l last_status $status

    set -l status_symbol "$status_symbol"

    # Set the checkmark (✔) or cross (✘) with colors
    if test $last_status -eq 0
        set status_symbol (string join '' (set_color green) (echo "✔") (set_color normal))  # ✔ Green
    else
        set status_symbol (string join '' (set_color red) (echo "✘") (set_color normal))  # ✘ Red
    end

    

    # Vi mode indicator (Insert [I], Normal [N])
    set -l mode (string replace insert '[I]' (string replace normal '[N]' (string replace replace '[R]' $fish_bind_mode)))

    # Command history count (Orange / Magenta)
    set -l cmd_count (math (history | wc -l))
    set -l cmd_count_colored (set_color brmagenta; echo -n $cmd_count; set_color normal)

    # Get username and hostname
    set -l user (whoami)
    set -l host (hostname | cut -d . -f1)  # Short hostname

    # Show last two directories in path
    set -l path (string join "/" (string split "/" (pwd) | tail -n 2))

    echo $status_symbol
    echo $last_status

    echo -n "$mode ❯ $cmd_count_colored ❯❯ $status_symbol ❯ "  
    echo -n (set_color cyan)"$user"(set_color normal)
    echo -n ":"
    echo -n (set_color yellow)"$path"(set_color normal)
    echo -n " > "
end
