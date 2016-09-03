#!/usr/bin/env bash

started=""
times=1
botfile=Doomiboter
puppetconf_pass=`cat .password`
echo $puppetconf_pass
rm $boterfile
mkfifo $boterfile
tail -f $boterfile | openssl s_client -CAfile ca.pem -connect puppetconf.irc.slack.com:6697 | while true ; do
    if [ -z $started ] ; then
        echo "PASS $puppetconf_pass" > $boterfile
        echo "USER doom 9 doom :" > $boterfile
        echo "NICK doom" > $boterfile
        echo "JOIN #test" > $boterfile
        echo "JOIN #random" > $boterfile
        echo "PART #general" > $boterfile
        started="yes"
    fi
    read irc
    case `echo $irc | cut -d " " -f 1` in
         "PING") echo "PONG `hostname`" > $boterfile
            ;;
    esac

    chan=`echo $irc | cut -d ' ' -f 3`
    barf=`echo $irc | cut -d ' ' -f 1-3`
    cmd=`echo ${irc##$barf :}|cut -d ' ' -f 1|tr -d "\r\n"`
    args=`echo ${irc##$barf :$cmd}|tr -d "\r\n"`
    nick="${irc%%!*}";nick="${nick#:}"
    if [ "`echo $cmd | cut -c1`" == "/" ] ; then
    echo "Got command $cmd from channel $chan with arguments $args"
    fi

case $cmd in
        "!help") echo "PRIVMSG $chan :!doom !source !help" >> $boterfile ;;
        "!source") echo "PRIVMSG $chan :https://github.com/nibalizer/doombot" >> $boterfile ;;
        "!doom")
          echo -n "PRIVMSG $chan :" >> $boterfile
          cat doom.txt | sort -R | head -n 1 >> $boterfile
        ;;
    esac
    echo $irc
done