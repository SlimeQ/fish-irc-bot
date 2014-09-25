#!/usr/bin/fish

# Default configuration
set server localhost
set port 6667
set chan test
set nick fish
set user 'fish localhost localhost :fish'

# User configuration
. bot.cfg

# Constants
set IN 'bot.input'
set OUT 'bot.output'
set ERR 'bot.error'
set LOG 'bot.log'

# Functions
function log -d 'Write to log file'
    echo (date '+[%y:%m:%d %T]')' '$argv[1] | tee -a $LOG
end

function out -d "Write to IRC server"
    set -l output $argv[1]
    log '>'$output
    echo $output >>$OUT
end

function msg -d "Send a PRIVMSG"
    set -l chan $argv[1]
    set -l rest $argv[2..-1]
    out "PRIVMSG $chan :$rest"
end

function me -d "Send a PRIVMSG ACTION"
    set -l chan $argv[1]
    set -l rest $argv[2..-1]
    msg $chan \001'ACTION '$rest
end

# Initialization
echo "" >$OUT

# Session
log ">>>>> New Session <<<<<"
out "NICK $nick"
out "USER $user"
out "JOIN #$chan"
tail -f $OUT | telnet $server $port ^$ERR | tee $IN | while read input;
    log $input
    switch $input
        case 'PING*'
            out $input | sed 's/I/O/'
        case '*PRIVMSG*'
            set components (echo $input | tr ' ' \n)
            if [ (count $components) -ge '4' ]
                set nick (echo $components[1] | sed 's/^:\(.*\)!.*/\1/')
                set chan $components[3]
                set cmd (echo $components[4] | sed 's/:!\(.*\)/\1/')
                if [ (count $components) -ge '5' ]
                    set rest (echo $components[5..-1] | tr \n ' ')
                else
                    set rest ''
                end
                . mods/$cmd.fish
            end
    end
end
