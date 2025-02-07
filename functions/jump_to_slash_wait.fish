function jump_to_slash_wait
    set -l key (read -n 1)  # Wait for a single keystroke
    if string match -q --regex '^[0-9]$' "$key"  # Ensure it's a number
        jump_to_slash "$key"
    else
        echo "Invalid input: $key"
    end
end
