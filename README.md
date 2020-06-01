
# NowRun
My (frostbyt#6969 on Discord) entry for the 2nd annual? [MOONCORD game jam](https://mooncordgamejam.github.io/MoonJam).

Plot/premise: You're trapped in a *spooky* dungeon filled with horrifying monsters of all sorts. Shoot (or run) your way out of the dungeon.

Basically, it's a shitty dungeon crawler shmup or whatever they're called. Originally I was going for something where running *might* be more advantageous than shooting your way out (in that I wanted there to be overwhelming, but slower than you mobs), but I made the player too tanky. I'm pretty proud of this steaming pile of shit though considering I've never worked with Godot before now :) I do plan on refining this though, I really enjoyed it.

# Controls
- **[W], [A], [S], [D]** -- movement, W = up, S = down, etc.
- **[Space]** -- generate a new dungeon
- **[Tab]** -- populate the newly generated dungeon
- **[Enter]**-- start playing
- **Left-click** -- shoot (hold to keep shooting)
- **Mouse wheel scroll** -- zoom in/out, useful for seeing where you need to go and what lies ahead
- **Mouse** -- aim (sorry, didn't have time to draw a crosshair, just use your fucking default pointer)
- **When generating a new dungeon**-- First, press **[Space]**, wait a few seconds, then press **[Tab]** to populate the dungeon, wait a few seconds, then press **[Enter]** to start playing

# Bugs
- When starting a new dungeon, wait 10 seconds before pressing the play button **[Enter]** or else the game will crash.
- sometimes ghosts will get stuck on walls and such, just shoot them and end their suffering :moon2SUFFER:
- One time a really hilarious bug happened where a fucking ghost started freaking out, spinning around 'n' shit and then flew off the screen. Probably had something to do with the collision shapes. (that is to say the collision shapes/boxes are shitty and may be prone to bugs)
- if you get cornered/surrounded by mobs, shoot until enough have died that you can move again
- Because I was too lazy to figure out a better solution, to end the game (meaning reaching the room marked END) you'll have to walk more than halfway into the room.
# Acknowledgements

Borrowed a lot fo code from the following sources:
- [Basic procedural generation](https://www.youtube.com/watch?v=o3fwlk1NI-w). ([GitHub source](https://github.com/kidscancode/godot3_procgen_demos/tree/master/part08/Godot3_DungeonGen03))
- [Random enemy spawns](https://www.youtube.com/watch?v=xTMM8HLFy-A)
- [The first 3 videos in this combat tutorial for 2D games](https://www.youtube.com/watch?v=h5slNt__Tt8&list=PLZ-54sd-DMALOePYMiM9aOj49eM8tWxly).
- [Basic enemy logic](https://www.youtube.com/watch?v=dHYeoQ4pN-s&list=PLZ-54sd-DMAIayOOwIPXoL61mh3XDdaPk)
- [Smooth player movement](https://www.youtube.com/watch?v=SUZpVd18IMM)
- [Titlescreen and pause menu](https://www.youtube.com/watch?v=sKuM5AzK-uA)
- probably lots of other stuff I forgot. If you see something that comes from somewhere else, please let me know so I can properly credit people. 
