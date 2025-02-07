function jump_to_slash
    if test (count $argv) -eq 0
        echo "Usage: jump_to_slash <number>"
        return 1
    end

    set -l pos (commandline --cursor)  # Get current cursor position
    set -l cmd (commandline)  # Get the entire command line
    set -l target_index $argv[1]  # Which slash to jump to

    set -l count 0
    for i in (seq (string length -- $cmd))
        if test (string sub --start=$i --length=1 $cmd) = "/"
            set count (math $count + 1)
            if test $count -eq $target_index
                commandline --cursor $i
                return
            end
        end
    end

    echo "Slash number $target_index not found"
end
