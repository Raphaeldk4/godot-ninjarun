extends CharacterBody2D

const gravity: int  = 4200
const jump_speed: int  = -1800
var isAttacking: bool 
var attackCoolDown: bool 
var godMode: bool
var walkTime: bool = true

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		if not get_parent().gameRunning:
			$AnimatedSprite2D.play("idle")
		else:
			$runCollision.disabled = false
			$duckCollision.disabled = true
			if Input.is_action_pressed("ui_accept"):
				velocity.y = jump_speed
				$jumpSound.play()
			elif Input.is_action_pressed("attack"):
				attack()
			else:
				if isAttacking == false:
					$AnimatedSprite2D.play("run")
					PlayWalkAudio()
	else:
		if isAttacking == false:
			$AnimatedSprite2D.play("jump")
		if Input.is_action_pressed("attack"):
					attack()
		
	move_and_slide()

func _on_is_attacking_timeout():
	isAttacking = false
	$attackCollision.disabled = true
	
func _on_attack_cooldown_timeout():
	attackCoolDown = false

func attack():
	if attackCoolDown == false: 
					attackCoolDown = true
					isAttacking = true
					godMode = true
					$Node/attackCooldown.start()
					$Node/isAttacking.start()
					$AnimatedSprite2D.play("attack")
					$runCollision.disabled = true
					$duckCollision.disabled = false
					$attackCollision.disabled = false
					$swordSlash.play()
					$swordSlash/AudioStreamPlayer2D.play()
					$Node/godMode.start()


func _on_god_mode_timeout():
	godMode = false
	
func PlayWalkAudio():
	if walkTime:
		walkTime = false
		$walkSound.pitch_scale = randi_range(0.5,1.5) 
		$Node/walkAudio.start()
		$walkSound.play()


func _on_walk_audio_timeout():
	walkTime = true
