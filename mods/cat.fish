. lib/file.fish
set file (file_file $rest)
if test -n $file -a -f $file
    msg $chan (cat $file)
else
    msg $chan $nick': no such file'
end
