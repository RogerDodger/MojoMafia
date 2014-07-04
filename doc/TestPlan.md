Test Plan
=========

The core of the game's logic is coupled with the Mafia::Result database
objects and the Mojomafia controllers. The most important thing to test is
that a game functions properly and has expected state after a number of
specific actions from players.

For example:

1. A game is created. Test that it exists.
2. Players join. Test that they're there.
3. Game starts. Test that the roles match the setup.
4. Players cast votes. Test that they went through.
5. Players make posts only visible to certain people. Test that the correct people see them, and others don't.
6. Someone achieved majority vote. Test that they're dead and that the game has cycled.
7. Have the dead person try to post. Test that it failed.
8. Repeat until the game is won.

Interactions between roles should be tested in every possible combination that
has forseeable conflicts. [0]

All of these tests can be done with fake users/players making programmed
requests against a :memory: database. [1]

Components that can be isolated from the game/website logic will reside in the
Mafia::* namespace. 

For example, Mafia::Markup is used to parse user posts with a specific markup
into safe HTML. Its tests only need to ensure that expected input produces
expected output. The two major things to consider are edge cases (e.g., random
combinations of metacharacters result in what?) and potential XSS
vulnerabilities. The latter is very important for obvious reasons. *Any*
codepath that messes with input that *doesn't* get `html_escape()`d first
needs very close scutiny. (For example, the current link-creating code is
dubious because most of the work is being offloaded to Mojo::URL, which
happily allows javascript: URLs.)

Maifa::Timestamp is used to create, store, and parse timestamps, and to
display them in a human-readable fashion (e.g., "12 minutes ago" instead of
"2014-08-04T11:24:43Z"). That this module does all of those things correctly
needs to be tested. In particular, the output of the human-readable deltas
should be given intense scrutiny. Again, just testing input with expected
output. Nice and simple.

---

[0]: Listing all these conflicts here would be fairly extensive and dependent
on the roles in question that are to be implemented. As it stands, that list
is not complete. So a tentative FIXME here.

[1]: It's slightly complicated as a result of the coupling, but abstracting
this logic away to separate classes don't help things. You'd have to test the
abstraction works, and then you'd need to check that the use of it by the
controllers work as well. It just adds more potential points of failure
without helping at all.
