## MazeWalker: An attempt at Raycasting

Mazewalker is a simple, not at all polished game or rather an experiment which uses raycating 
to create a pseudo 3d world/maze.

The maze is first generated in 2D form using Prim's randomised algorithm. Which means everytime
we run the game we start with a new maze. Also everytime we reach a door the player is put
into a newly generated maze. So in a way you can play this game or run this experiment infinitely.

Once the maze is generated, we apply raycasting to convert the 2D maze into a pseudo 3D world.

<video src='doc_assets/mazewalker_comp.mp4'>

## What is raycasting

Raycasting is one of the first 3D techniques that pushed the boundaries of 3D games. One of the very
first games that employed this technique is Wolfenstein 3D by the famous id Software. It does not create a pure 3D world but rather a pseuo 3D world. It draws 2D textures on the screen in a very clever manner to create the illusion of a 3D world.

I will not dig deep into the technique here because there are numerous articles/blogs and youtube
videos on the internet which explains this technique in great detail. I have tried to give an
overview of the technique <a href="https://github.com/djmgit/mazewalker/blob/master/mod.lua">here</a>

## How to run

Make sure you have installed lua (5.4.3 preferred) and <a href="https://love2d.org/#download">love2d</a> on your system.

After that, open this repository in your terminal and run
```
/path/to/love ./
```
If you have placed love2d in your system path then you dont need
to mention the full path.

## Controls

```
w                       -       move forward
s                       -       move backward
a                       -       move left
d                       -       move right
left mouse button       -       Fire
move mouse              -       Chnage player/camera direction
```
## What all I have used

I have used lua to create this game and the awesome lua based love2d library to render graphics on
screen. <a href="https://love2d.org/">love2d</a> is a truly amazing framework which is very easy
to use and learn.

As I have already mentioned, to generate the mazes I have used Prim's randomized algorithm. And to
make sure wall's get different textures, I have used flood fill algorithm to assign different textures
to different clusters of walls.

## NOTE

The idea was not really to create a game but to explore raycasting hands on. Also the code is by no
means perfect, on the contrary I would say its kind of messy and has some bugs. So if anyone is
interested to take a dig at the code and want to play around with lua and love, PRs are always
welcome.

## References:

### raycasting tutorials/articles

- https://lodev.org/cgtutor/raycasting.html
- https://github.com/vinibiavatti1/RayCastingTutorial
- https://www.youtube.com/watch?v=ECqUrT7IdqQ&t=1233s&pp=ygUUcmF5Y2FzdGluZyB0dXRvcmlhbCA%3D

### sprites and textures used:

- https://opengameart.org/
