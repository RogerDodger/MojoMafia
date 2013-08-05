MojoMafia (alpha)
=================

Forum-based Mafia with the boring stuff done for you.

Synopsis
--------

* Automatic processing of all game logic
* Consistent rules for power roles
* Votes and actions built in to the interface
* Posts hidden as appropriate -- no need to create a quicktopic for private chat
* Quick filtering of posts to get vote histories, kill/lynch sequences, etc.
* Archival of games for future reference/perusal
* Stat tracking: wins, losses, leave percent, etc.
* Host rules to require players to have a good record
* Waiting lists to replace dropped-out players
* Player aliases so that high-reputation players can avoid metagaming

Requirements
------------

* Perl v5.14.2 or higher

Installation
------------

    MojoMafia$ perl Makefile.PL
    MojoMafia$ ./script/mafia.pl deploy

Once deployed, you can start the application with morbo:

    MojoMafia$ morbo script/app.pl

