#New function to change sudo alias to merge xauthority for graphical users
function xsudo {
    display=`echo $DISPLAY|sed 's/localhost/'\`hostname\`'\/unix/'`
    if [[ $display == "" ]];
    then
       echo "DISPLAY environment variable was empty. Make sure X11 forwarding is enabled in your SSH session!"
       return 1
    fi
	xauth extract - ${display} | /usr/bin/sudo $@ xauth merge - 
	/usr/bin/sudo $@ 
}