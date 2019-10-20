# dd-Cloner
Had to do a bunch of imaging at work one time and realized the manual way was horribly inefficeint plus I had never written something in bash so I jumped to it.

***FOR WARNING***
I have made alot of changes to this code so some tweaking might be desirable. Such as the blocksize I used while cloning drives on an old server may not be the best solution for you.

In a nutshell the script gets info about the system and builds a string with this info, executes the string as a bash command, then shuts the system down.
