function fish_user_key_bindings
    # Step 1: Bind Ctrl+R to enter 'custom' mode
    bind \cr 'set fish_bind_mode custom'

    # Step 2: Inside 'custom' mode, bind 'T' to execute a command
    bind -M custom t 'echo "You pressed Ctrl+R then T"'

    # Step 3: Optional - Bind Escape to exit custom mode
    bind -M custom \e 'set fish_bind_mode default'
end
