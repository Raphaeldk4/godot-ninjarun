extends Node

#preload obstacles
var eyeEnemie = preload("res://scenes/eyeEnemie.tscn")
var goblinEnemie = preload("res://scenes/goblinEnemie.tscn")
var wormEnemie = preload("res://scenes/wormEnemie.tscn")
var object = preload("res://scenes/shuriken.tscn")
var shurikenList: Array
var obstacleType := [goblinEnemie, wormEnemie]
var obstacles: Array
var airEnemie: Array
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
var highScore: int

#speed
var speed: float 
const startSpeed: float = 7
const maxSpeed: int = 14
const speedInrease: int = (5000)
var screenSize: Vector2i


#objects
var groundHeight: int
var lastObject

#game state
var gameRunning: bool

#shuriken
var attackCooldown: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_window().size
	groundHeight = $ground.get_node("Sprite2D").texture.get_height()
	$gameOver.get_node("RESTART").pressed.connect(new_game)
	$gameOver.get_node("SKINS").pressed.connect(openSkins)
	$skins.get_node("ninja1/select").pressed.connect(startGameNinja1)
	$skins.get_node("ninja2/select").pressed.connect(startGameNinja2)
	$skins.get_node("ninja3/select").pressed.connect(startGameNinja3)
	$skins.get_node("BACK").pressed.connect(back)
	$hud.get_node("highScoreLabel").text = "HIGHSCORE: 0"
	new_game()

func new_game():
	#reset variable
	score = 0
	show_score()
	gameRunning = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obsticles and flying enemies
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	for enemies in airEnemie:
		enemies.queue_free()
	airEnemie.clear()
	
	#starting positions and state when game starts
	$ninja.position = ninjaStartPos
	$ninja.velocity = Vector2i(0,0)
	$Camera2D.position = camStartPos
	$ground.position = Vector2i(0,0)
	
	#reset HUD + game over screen + skins selection
	$hud.get_node("startLabel").show()
	$gameOver.hide()
	$skins.hide()
	if $ninja.ninja == $ninja.get_node("ninja3"):
		$hud.get_node("Sprite2D/sword").visible = false
		$hud.get_node("Sprite2D/shuriken").visible = true
	else: 
		$hud.get_node("Sprite2D/sword").visible = true
		$hud.get_node("Sprite2D/shuriken").visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
			if obs.position.x < ($Camera2D.position.x - screenSize.x + 400):
				removeObsticle(obs)
				
		for enemie in airEnemie:
			if enemie.position.x < ($Camera2D.position.x - screenSize.x + 400):
				removeEnemie(enemie)
		shurikenSpawner()
		
			
		#remove passed shuriken
		for shuriken in shurikenList:
			if shuriken.position.x > ($Camera2D.position.x + 600):
				shuriken.queue_free()
				shurikenList.erase(shuriken)
		
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
	if body.name == "ninja" && $ninja.isAttacking == false:
		setHighScore()
		gameOver()
	if $ninja.isAttacking == true && $ninja.ninja != $ninja.get_node("ninja3"):
		var obs = obstacles[0]
		obs.set_collision_layer_value ( 1, 0 )
		obs.set_collision_mask_value( 1, 0 )
		obs.get_node("AnimatedSprite2D").play("death")
		obs.get_node("deathAudio").play()
		obs.get_node("PointLight2D").enabled = false
	if body.name == "shuriken":
		var obs = obstacles[0]
		var hitShuriken = shurikenList[0]
		hitShuriken.queue_free()
		obs.set_collision_layer_value ( 1, 0 )
		obs.set_collision_mask_value( 1, 0 )
		hitShuriken.set_collision_layer_value ( 1, 0 )
		hitShuriken.set_collision_mask_value ( 1, 0 )
		obs.get_node("AnimatedSprite2D").play("death")
		obs.get_node("deathAudio").play()
		shurikenList.erase(hitShuriken)


func hitEnemie(body):
	if body.name == "ninja" && $ninja.isAttacking == false:
		setHighScore()
		gameOver()
	if $ninja.isAttacking == true:
		var enemie = airEnemie[0]
		enemie.get_node("AnimatedSprite2D").play("death")
		enemie.get_node("AnimationPlayer").play("death")
		enemie.get_node("deathAudio").play()
		enemie.set_collision_layer_value ( 1, 0 )
		enemie.set_collision_mask_value( 1, 0 )
	if body.name == "shuriken":
		var enemie = airEnemie[0]
		var hitShuriken = shurikenList[0]
		hitShuriken.queue_free()
		enemie.get_node("AnimatedSprite2D").play("death")
		enemie.get_node("AnimationPlayer").play("death")
		enemie.get_node("deathAudio").play()
		enemie.set_collision_layer_value ( 1, 0 )
		enemie.set_collision_mask_value( 1, 0 )
		shurikenList.erase(hitShuriken)


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

func openSkins():
	$gameOver.hide()
	$skins.show()

func startGameNinja1():
	$ninja.ninja = $ninja.get_node("ninja")
	$ninja.get_node("ninja").visible = true
	$ninja.get_node("ninja2").visible = false
	$ninja.get_node("ninja3").visible = false 
	$ninja.get_node("ninja2Attack").disabled = true
	$ninja.get_node("ninja2Collision").disabled = true
	$ninja.get_node("ninja1Attack").disabled = false
	$ninja.get_node("ninja1Collision").disabled = false
	$ninja.get_node("ninja3Collision").disabled = true
	
func startGameNinja2():
	$ninja.ninja = $ninja.get_node("ninja2")
	$ninja.get_node("ninja2").visible = true
	$ninja.get_node("ninja").visible = false 
	$ninja.get_node("ninja3").visible = false 
	$ninja.get_node("ninja2Attack").disabled = false
	$ninja.get_node("ninja2Collision").disabled = false
	$ninja.get_node("ninja1Attack").disabled = true
	$ninja.get_node("ninja1Collision").disabled = true
	$ninja.get_node("ninja3Collision").disabled = true
	
func startGameNinja3():
	$ninja.ninja = $ninja.get_node("ninja3")
	$ninja.get_node("ninja2").visible = false
	$ninja.get_node("ninja").visible = false 
	$ninja.get_node("ninja3").visible = true 
	$ninja.get_node("ninja2Attack").disabled = true
	$ninja.get_node("ninja2Collision").disabled = true
	$ninja.get_node("ninja1Attack").disabled = true
	$ninja.get_node("ninja1Collision").disabled = true
	$ninja.get_node("ninja3Collision").disabled = false

func shurikenSpawner():
	if $ninja.ninja == $ninja.get_node("ninja3"):
		if attackCooldown == false:
			if Input.is_action_just_pressed("attack"):
				attackCooldown = true
				$timers/attackCooldown.start()
				var shuriken
				shuriken = object.instantiate()
				shurikenList.append(shuriken)
				shuriken.get_node("CollisionShape2D").disabled = false
				shuriken.get_node("AnimatedSprite2D").visible = true 
				shuriken.set_collision_layer_value ( 1, 1 )
				shuriken.set_collision_mask_value ( 1, 1 )
				shuriken.position = $ninja.position
				shuriken.position.x += 70
				add_child(shuriken)
func back():
	$gameOver.show()
	$skins.hide()
	

func gameOver():
	$ninja/death.play()
	get_tree().paused = true
	gameRunning = false
	$gameOver.show()

func _on_attack_cooldown_timeout():
	attackCooldown = false
