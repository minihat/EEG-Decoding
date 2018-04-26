#PONG pygame

import random
import pygame, sys
from pygame.locals import *
import sys

paddle_size_param = sys.argv[1]

pygame.init()
fps = pygame.time.Clock()


# Update_rate
update_rate = 4 #Hz
num_players = 1
#colors
WHITE = (255,255,255)
RED = (255,0,0)
GREEN = (0,255,0)
BLACK = (0,0,0)

#globals
kens_acceleration_constant = 1.0
WIDTH = 600
HEIGHT = 600
BALL_RADIUS = 20
PAD_WIDTH = 80
PAD_1_WIDTH = int(PAD_WIDTH * float(paddle_size_param))
HALF_PAD_1_WIDTH = PAD_1_WIDTH // 2
PAD_HEIGHT = 8
HALF_PAD_WIDTH = PAD_WIDTH // 2
HALF_PAD_HEIGHT = PAD_HEIGHT // 2
ball_pos = [0,0]
ball_vel = [0,0]
paddle1_vel = 0
paddle2_vel = 0
l_score = 0
r_score = 0

#canvas declaration
window = pygame.display.set_mode((WIDTH, HEIGHT), 0, 32)
pygame.display.set_caption('Hello World')

# helper function that spawns a ball, returns a position vector and a velocity vector
# if right is True, spawn to the right, else spawn to the left
def ball_init(right):
    global ball_pos, ball_vel # these are vectors stored as lists
    ball_pos = [WIDTH//2,HEIGHT//2]
    horz = random.randrange(1,2)
    vert = random.randrange(1,2)

    if right == False:
        vert = - vert

    ball_vel = [-horz,vert]

# define event handlers
def init():
    global paddle1_pos, paddle2_pos, paddle1_vel, paddle2_vel,l_score,r_score  # these are floats
    global score1, score2  # these are ints
    paddle1_pos = [WIDTH//2,HEIGHT - HALF_PAD_HEIGHT - 1]
    paddle2_pos = [WIDTH//2,HALF_PAD_HEIGHT]
    l_score = 0
    r_score = 0
    if random.randrange(0,2) == 0:
        ball_init(True)
    else:
        ball_init(False)


#draw function of canvas
def draw(canvas):
    global paddle1_pos, paddle2_pos, ball_pos, ball_vel, l_score, r_score

    canvas.fill(BLACK)
    pygame.draw.line(canvas, WHITE, [0, HEIGHT//2],[WIDTH, HEIGHT//2], 1)
    pygame.draw.line(canvas, WHITE, [0, PAD_HEIGHT],[WIDTH, PAD_HEIGHT], 1)
    pygame.draw.line(canvas, WHITE, [0, HEIGHT - PAD_HEIGHT],[WIDTH, HEIGHT - PAD_HEIGHT], 1)
    pygame.draw.circle(canvas, WHITE, [WIDTH//2, HEIGHT//2], 70, 1)

    #update ball
    ball_pos[0] += int(ball_vel[0])
    ball_pos[1] += int(ball_vel[1])

    # update paddle's horizontal position, keep paddle on the screen
    if paddle1_pos[0] > HALF_PAD_1_WIDTH and paddle1_pos[0] < WIDTH - HALF_PAD_1_WIDTH:
        paddle1_pos[0] += paddle1_vel
    elif paddle1_pos[0] == HALF_PAD_1_WIDTH and paddle1_vel > 0:
        paddle1_pos[0] += paddle1_vel
    elif paddle1_pos[0] == WIDTH - HALF_PAD_1_WIDTH and paddle1_vel < 0:
        paddle1_pos[0] += paddle1_vel
    elif paddle1_pos[0] < HALF_PAD_1_WIDTH:
        paddle1_pos[0] = HALF_PAD_1_WIDTH
    elif paddle1_pos[0] > WIDTH - HALF_PAD_1_WIDTH:
        paddle1_pos[0] = WIDTH - HALF_PAD_1_WIDTH

    if num_players == 1:
        paddle2_pos[0] = ball_pos[0]
    #paddle1_pos[0] = ball_pos[0]

    if paddle2_pos[0] > HALF_PAD_WIDTH and paddle2_pos[0] < WIDTH - HALF_PAD_WIDTH:
        paddle2_pos[0] += paddle2_vel
    elif paddle2_pos[0] == HALF_PAD_WIDTH and paddle2_vel > 0:
        paddle2_pos[0] += paddle2_vel
    elif paddle2_pos[0] == WIDTH - HALF_PAD_WIDTH and paddle2_vel < 0:
        paddle2_pos[0] += paddle2_vel

    # Make a perfect computer to play against
    paddle2_pos[0] = ball_pos[0]

    """
    #update ball
    ball_pos[0] += int(ball_vel[0])
    ball_pos[1] += int(ball_vel[1])
    """

    #draw paddles and ball
    pygame.draw.circle(canvas, RED, ball_pos, 20, 0)
    pygame.draw.polygon(canvas, GREEN, [[paddle1_pos[0] - HALF_PAD_1_WIDTH, paddle1_pos[1] - HALF_PAD_HEIGHT], [paddle1_pos[0] - HALF_PAD_1_WIDTH, paddle1_pos[1] + HALF_PAD_HEIGHT], [paddle1_pos[0] + HALF_PAD_1_WIDTH, paddle1_pos[1] + HALF_PAD_HEIGHT], [paddle1_pos[0] + HALF_PAD_1_WIDTH, paddle1_pos[1] - HALF_PAD_HEIGHT]], 0)
    pygame.draw.polygon(canvas, GREEN, [[paddle2_pos[0] - HALF_PAD_WIDTH, paddle2_pos[1] - HALF_PAD_HEIGHT], [paddle2_pos[0] - HALF_PAD_WIDTH, paddle2_pos[1] + HALF_PAD_HEIGHT], [paddle2_pos[0] + HALF_PAD_WIDTH, paddle2_pos[1] + HALF_PAD_HEIGHT], [paddle2_pos[0] + HALF_PAD_WIDTH, paddle2_pos[1] - HALF_PAD_HEIGHT]], 0)

    #ball collision check on top and bottom walls
    if int(ball_pos[0]) <= BALL_RADIUS:
        ball_vel[0] = - ball_vel[0]
    if int(ball_pos[0]) >= WIDTH + 1 - BALL_RADIUS:
        ball_vel[0] = -ball_vel[0]

    #ball collison check on gutters or paddles
    if int(ball_pos[1]) <= BALL_RADIUS + PAD_HEIGHT and int(ball_pos[0]) in range(paddle2_pos[0] - HALF_PAD_WIDTH,paddle2_pos[0] + HALF_PAD_WIDTH,1):
        ball_vel[1] = -ball_vel[1]
        ball_vel[1] *= kens_acceleration_constant
        ball_vel[0] *= kens_acceleration_constant
    elif int(ball_pos[1]) <= BALL_RADIUS + PAD_HEIGHT:
        r_score += 1
        ball_init(True)

    if int(ball_pos[1]) >= HEIGHT + 1 - BALL_RADIUS - PAD_HEIGHT and int(ball_pos[0]) in range(paddle1_pos[0] - HALF_PAD_1_WIDTH,paddle1_pos[0] + HALF_PAD_1_WIDTH,1):
        ball_vel[1] = -ball_vel[1]
        ball_vel[1] *= kens_acceleration_constant
        ball_vel[0] *= kens_acceleration_constant
    elif int(ball_pos[1]) >= HEIGHT + 1 - BALL_RADIUS - PAD_HEIGHT:
        l_score += 1
        ball_init(False)

    #update scores
    myfont1 = pygame.font.SysFont("Comic Sans MS", 20)
    label1 = myfont1.render("Score "+str(l_score), 1, (255,255,0))
    canvas.blit(label1, (WIDTH//5,20))

    myfont2 = pygame.font.SysFont("Comic Sans MS", 20)
    label2 = myfont2.render("Score "+str(r_score), 1, (255,255,0))
    canvas.blit(label2, (WIDTH//5, HEIGHT - 60))


#keydown handler
def keydown(event):
    global paddle1_vel, paddle2_vel

    if event.key == K_LEFT:
        paddle2_vel = -8
    elif event.key == K_RIGHT:
        paddle2_vel = 8
    elif event.key == K_a:
        paddle1_vel = -8
    elif event.key == K_d:
        paddle1_vel = 8

#keyup handler
def keyup(event):
    global paddle1_vel, paddle2_vel

    if event.key in (K_a, K_d):
        paddle1_vel = 0
    elif event.key in (K_LEFT, K_RIGHT):
        paddle2_vel = 0

init()


#game loop
frame_counter = 0
frame_reset_count = int(60/update_rate)
while True:

    draw(window)
# Comment here down to end of for
    """for event in pygame.event.get():

        if event.type == KEYDOWN:
            keydown(event)
        elif event.type == KEYUP:
            keyup(event)
        elif event.type == QUIT:
            pygame.quit()
            sys.exit()"""
    if frame_counter == frame_reset_count:
        frame_counter = 0
        f = open("hackytransferfile.txt", "r")
        try:
            move_class = int(f.read())
        except:
            move_class = 0
        if move_class == -1:
            paddle1_vel = -8
        if move_class == 0:
            paddle1_vel = 0
        if move_class == 1:
            paddle1_vel = 8
        f.close()
    frame_counter += 1
    pygame.display.update()
    fps.tick(60)
