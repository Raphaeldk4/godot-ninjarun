extends Node

#preload obstacles
var eyeEnemie = preload("res://scenes/eyeEnemie.tscn")
var goblinEnemie = preload("res://scenes/goblinEnemie.tscn")
var wormEnemie = preload("res://scenes/wormEnemie.tscn")
var obstacleType := [goblinEnemie, wormEnemie]
var obstacles: Array
var eyeHeight := [200, 390]

#variables
#start pos
const ninjaStartPos := Vector2i (150,458)
const camStartPos := Vector2i (576, 324)

#difficulty
var difficulty
const maxDifficulty: int = 2

#score
var score: int
const scoreModifier: int = 5

#speed
var speed: float 
const startSpeed: float = 2
const maxSpeed: int = 15
const speedInrease: int = (4000)
var screenSize: Vector2i


#objects
var groundHeight: int
var lastObject

#game state
var gameRunning: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_window().size
	groundHeight = $ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	#reset variable
	score = 0
	show_score()
	difficulty = 0
	
	#starting positions and state when game starts
	$ninja.position = ninjaStartPos
	$ninja.velocity = Vector2i(0,0)
	$Camera2D.position = camStartPos
	$ground.position = Vector2i(0,0)
	
	$hud.get_node("startLabel").show()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gameRunning:
		#speed and difficulty increase
		speed = startSpeed + score / speedInrease
		if speed > maxSpeed:
			speed = maxSpeed
		adjustDifficulty()

		#generate obstacles
		generateObstacles()
		
		#move ninja and camera
		$ninja.position.x += speed
		$Camera2D.position.x += speed
		
		#update score 
		score += speed
		show_score()
		
		#update ground pos
		if $Camera2D.position.x - $ground.position.x > screenSize.x * 1.5:
			$ground.position.x += screenSize.x
			
	else:
		if Input.is_action_pressed("ui_accept"):
			gameRunning = true
			$hud.get_node("startLabel").hide()

func generateObstacles(): 
	#generate ground obstacles
	if obstacles.is_empty() or lastObject.position.x < score + randi_range(300, 500):
		var obsType = obstacleType[randi() % obstacleType.size()]
		var obs
		obs = obsType.instantiate()
		var obs_x : int = screenSize.x + score + 100
		var obs_y : int = screenSize.y - groundHeight + 5
		lastObject = obs
		addObsticle(obs, obs_x, obs_y)

func addObsticle(obs, x, y): 
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func show_score():
	$hud.get_node("scoreLabel").text = "SCORE: " + str(score / scoreModifier)

func adjustDifficulty():
	difficulty = score / speedInrease
	if difficulty > maxDifficulty : 
		difficulty = maxDifficulty
