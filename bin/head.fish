. lib/file.fish
set file(chan_file $chan $rest)
if test -n "$file" -a -f $file
    msg $chan (head -1 $file)
else
    msg $chan $nick': no such file'
end
