#HAOTPS is created by HaoZhu
#2010-09
#
Aim: 
Using multi-thread JAVA to generating specific SQL load to Oracle database,
Then get the average response time and average TPS.
This is an simple tool that is shared to ITPUBers by Hao:)

Usage:
1.to get the right JAVA env:
source my.login

2.take test.conf as an example config file, then make your own one:
cp test.conf xxx.conf
edit the xxx.conf with what you want

4.run the command with the config file you edited in step 2 as the parameter:
java haotps xxx.conf
