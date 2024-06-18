extends Node

#preload obstacles
var eyeEnemie = preload("res://scenes/eyeEnemie.tscn")
var goblinEnemie = preload("res://scenes/goblinEnemie.tscn")
var wormEnemie = preload("res://scenes/wormEnemie.tscn")
var obstacleType := [goblinEnemie, wormEnemie]
var obstacles: Array
var airEnemie: Array
var eyeHeight := [200, 390]
var dyingObstacle

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
var highScore: int

#speed
var speed: float 
const startSpeed: float = 2
const maxSpeed: int = 10
const speedInrease: int = (5000)
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
	$gameOver.get_node("RESTART").pressed.connect(new_game)
	$hud.get_node("highScoreLabel").text = "HIGHSCORE: 0"
	new_game()

func new_game():
	#reset variable
	score = 0
	show_score()
	gameRunning = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obsticles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#starting positions and state when game starts
	$ninja.position = ninjaStartPos
	$ninja.velocity = Vector2i(0,0)
	$Camera2D.position = camStartPos
	$ground.position = Vector2i(0,0)
	
	#reset HUD + game over screen
	$hud.get_node("startLabel").show()
	$gameOver.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gameRunning:
		#passing game state to hud
		$hud.gameState = gameRunning
		
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
			
		#remove passed obstacles and enemies
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screenSize.x + 200):
				removeObsticle(obs)
				
		for enemie in airEnemie:
			if enemie.position.x < ($Camera2D.position.x - screenSize.x + 200):
				removeEnemie(enemie)
		
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
		
		#generate air enemies
		if (randi() % 2) == 0:
			var airEnemie
			airEnemie = eyeEnemie.instantiate()
			var airEnemie_x = screenSize.x + score + 100
			var airEnemie_y = eyeHeight[randi() % eyeHeight.size()]
			addEnemie(airEnemie, airEnemie_x, airEnemie_y)

func addObsticle(obs, x, y): 
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hitObsticle)
	add_child(obs)
	obstacles.append(obs)
	
func addEnemie(obs, x, y): 
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hitEnemie)
	add_child(obs)
	airEnemie.append(obs)
	
func removeObsticle(obs): 
	obs.queue_free()
	obstacles.erase(obs)
	
func removeEnemie(enemie): 
	enemie.queue_free()
	airEnemie.erase(enemie)
	
func hitObsticle(body):
	if body.name == "ninja" && $ninja.godMode == false:
		setHighScore()
		gameOver()
	if $ninja.isAttacking == true:
		var obs = obstacles[0]
		dyingObstacle = obs
		obs.get_node("AnimatedSprite2D").play("death")
		$timers/Timer.start()

func hitEnemie(body):
	if body.name == "ninja" && $ninja.godMode == false:
		setHighScore()
		gameOver()
	if $ninja.isAttacking == true:
		var enemie = airEnemie[0]
		enemie.queue_free()
		airEnemie.erase(enemie)

func show_score():
	$hud.get_node("scoreLabel").text = "SCORE: " + str(score / scoreModifier)
	
func setHighScore():
	if score > highScore: 
		highScore = score
		$hud.get_node("highScoreLabel").text = "HIGHSCORE: " + str(highScore / scoreModifier)

func adjustDifficulty():
	difficulty = score / speedInrease
	if difficulty > maxDifficulty : 
		difficulty = maxDifficulty
		
func gameOver():
	$ninja/death.play()
	get_tree().paused = true
	gameRunning = false
	$gameOver.show()
	


func _on_timer_timeout():
	dyingObstacle.visible = false
	obstacles.erase(dyingObstacle)
