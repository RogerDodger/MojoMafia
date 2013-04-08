Role and Team Logic
===================

Town, Scum, and Other are the three role "types":

- Town roles may only be in team "Town"
- Scum roles may only be in team "Mafia", "Yakuza", "Bratva", etc.
- Other roles may be in any team, and are "None" by default

Win conditions:

- Win conditions are checked at the end of every night and day. 
- Teams have specific win conditions which apply to all players on that team.
- A role has its own win condition if and only if it is on team "None".
- When a win condition is met, all players meeting their win condition win, and all other players lose.

## Town ##

- __Townie__       Vanilla Town role.
- __Vigilante__    (Player target) Kills target.
- __Cop__          (Player target) Learns target's type. Players of type Other appear as Town.
- __Doctor__       (Player target) Target cannot die that night. Cannot protect himself.
- __Bodyguard__    (Player target) If target is attacked, 50% chance that attacker is killed, 50% chance that self is killed.
- __Tracker__      (Player target) Learns who target visits that night.
- __Watcher__      (Player target) Learns who visits target that night.
- __Bulletproof__  If attacked at night, will survive once.
- __Miller__       Appears as Scum to Cop. Flips Goon if lynched.

## Scum ##

- __Goon__       Vanilla Scum role.
- __Hooker__     (Player target) Target's night action will do nothing that night.
- __Janitor__    (Player target) If target is killed, their role is revealed only to self. One use only.
- __Godfather__  Appears as Town to Cop.

## Other ##

- __Serial Killer__ (Player target) Kills target. Wins if one or zero other players are still alive.
