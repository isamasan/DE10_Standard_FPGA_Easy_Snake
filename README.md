# DE10_Standard_FPGA_Simple_Snake

1. GENERAL DESCRIPTION
In this project a simplified version of the popular game Snake has been developed. In this version of the game you cannot control the direction in which the snake moves forward, but you simply have to prevent it from crashing into a a block that appears in its path.

When you start the game, the snake starts to move forward automatically and at a constant speed, and the block that appears in its path also appears.In order to win the round and continue playing, you have to stop the snake just before it collides with the block. If you succeed, you score a point, the snake returns to the start and the block moves to another position. If you fail to stop the snake, the game is over.

The game is played using the LT24 display, which is managed by the DE10
Standard. To control the snake, the keyboard of the PC to which the board is connected is used.In order to win the round and
In order to win the round and
continue playing, you have to stop the snake just before it collides with the snake. with the snake. If you succeed, you score a point, the snake returns to the start and the block moves to another position. the block moves to another position. If you fail to stop the snake, the game is over. the game is over.

The game is played using the LT24 display, which is managed by the DE10
Standard. To control the snake, the keyboard of the PC to which the board is connected is used. connected to the board

2. USER INTERFACE
The user only interacts with the game through the keyboard of the PC to which the board is connected, and of all the keys on the keyboard only 3 are to be used: R, J and P, both upper and lower case. Each key has the following function:
- R: This is the reset key. If pressed, the entire game is reset and the accumulated points are lost.
- J: This is the play key ('jugar' in spanish). The round does not start (the snake does not start moving nor the block is generated) until this key is pressed. It must also be pressed between rounds, and if you restart the game by pressing R.
- P: This is the stop key ('parar' in spanish). If you press it, you stop the snake's progress and two options arise: you win the round or lose the game. The first situation occurs if the snake is stopped just before it hits the block. The second is if the key is pressed too early, away from the block. Logically, if the key is not pressed, the snake will not stop and will advance until it crashes into the block, which also means losing the game.

The snake and the block appear on the LT24 display, the snake is green and the blocks are blue. The accumulated points appear on the 7-segment displays HEX0 and HEX1 of the DE10 Standard. If the game is lost, the points are deleted and an F appears on each 7-segment display. On the other hand if the round is won, all 10 LEDRs of the DE10 Standard light up.
 
 For a full description of the project, read 'informe.pdf' (only in spanish).
