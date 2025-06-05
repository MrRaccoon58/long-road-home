extends Node2D

const PADDLE_SIZE = Vector2(80, 20)
const BALL_RADIUS = 8
const BRICK_SIZE = Vector2(60, 20)
const BRICK_COLS = 8
const BRICK_ROWS = 4
const BALL_SPEED = 200

var paddle_pos : Vector2
var ball_pos : Vector2
var ball_velocity = Vector2(1, -1) * BALL_SPEED
var bricks: Array = []

func _ready():
    var screen_size = get_viewport_rect().size
    paddle_pos = Vector2(screen_size.x / 2 - PADDLE_SIZE.x / 2, screen_size.y - 40)
    ball_pos = paddle_pos - Vector2(0, PADDLE_SIZE.y + BALL_RADIUS)
    _create_bricks()

func _create_bricks():
    bricks.clear()
    var margin = Vector2(40, 40)
    for row in range(BRICK_ROWS):
        for col in range(BRICK_COLS):
            var pos = margin + Vector2(col * (BRICK_SIZE.x + 10), row * (BRICK_SIZE.y + 10))
            bricks.append(Rect2(pos, BRICK_SIZE))

func _process(delta):
    _handle_input(delta)
    _move_ball(delta)
    queue_redraw()



func _handle_input(delta):
    var speed = 300
    if Input.is_action_pressed("ui_left"):
        paddle_pos.x -= speed * delta
    if Input.is_action_pressed("ui_right"):
        paddle_pos.x += speed * delta
    var screen_size = get_viewport_rect().size
    paddle_pos.x = clamp(paddle_pos.x, 0, screen_size.x - PADDLE_SIZE.x)

func _move_ball(delta):
    ball_pos += ball_velocity * delta
    var screen_size = get_viewport_rect().size
    if ball_pos.x < BALL_RADIUS or ball_pos.x > screen_size.x - BALL_RADIUS:
        ball_velocity.x = -ball_velocity.x
        ball_pos.x = clamp(ball_pos.x, BALL_RADIUS, screen_size.x - BALL_RADIUS)
    if ball_pos.y < BALL_RADIUS:
        ball_velocity.y = -ball_velocity.y
        ball_pos.y = BALL_RADIUS
    if ball_pos.y > screen_size.y:
        ball_pos = screen_size / 2
        ball_velocity = Vector2(1, -1).normalized() * BALL_SPEED

    var paddle_rect = Rect2(paddle_pos, PADDLE_SIZE)
    if _rect_circle_intersect(paddle_rect, ball_pos, BALL_RADIUS) and ball_velocity.y > 0:
        ball_velocity.y = -abs(ball_velocity.y)
        ball_pos.y = paddle_rect.position.y - BALL_RADIUS

    for i in range(bricks.size() - 1, -1, -1):
        var r = bricks[i]
        if _rect_circle_intersect(r, ball_pos, BALL_RADIUS):
            bricks.remove_at(i)
            ball_velocity.y = -ball_velocity.y
            break

func _rect_circle_intersect(rect: Rect2, circle_pos: Vector2, radius: float) -> bool:
    var closest_x = clamp(circle_pos.x, rect.position.x, rect.position.x + rect.size.x)
    var closest_y = clamp(circle_pos.y, rect.position.y, rect.position.y + rect.size.y)
    var dx = circle_pos.x - closest_x
    var dy = circle_pos.y - closest_y
    return dx * dx + dy * dy < radius * radius

func _draw():
    draw_rect(Rect2(paddle_pos, PADDLE_SIZE), Color(1, 1, 1))
    draw_circle(ball_pos, BALL_RADIUS, Color(1, 1, 0))
    for r in bricks:
        draw_rect(r, Color(1, 0, 0))

