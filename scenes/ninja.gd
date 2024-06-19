extends CharacterBody2D

const gravity: int  = 4200
const jump_speed: int  = -1800
var isAttacking: bool 
var attackCoolDown: bool 
var godMode: bool
var walkTime: bool = true

var ninja

func _ready():
	ninja = $ninja
	$ninja2.visible = false
	$ninja3.visible = false

func _physics_process(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		if not get_parent().gameRunning:
			ninja.play("idle")
		else:
			if Input.is_action_pressed("ui_accept"):
				velocity.y = jump_speed
				$jumpSound.play()
			elif Input.is_action_pressed("attack"):
				if ninja == $ninja or ninja == $ninja2:
					attackSword()
				else:
					attackShuriken()
			else:
				if isAttacking == false:
					ninja.play("run")
					PlayWalkAudio()
	else:
		if isAttacking == false:
			ninja.play("jump")
		if Input.is_action_pressed("attack"):
			if ninja == $ninja or ninja == $ninja2:
					attackSword()
			else:
				attackShuriken()
		
	move_and_slide()

func _on_is_attacking_timeout():
	isAttacking = false
	$ninja1Attack.disabled = true
	$ninja2Attack.disabled = true
	
func _on_attack_cooldown_timeout():
	attackCoolDown = false

func attackSword():
	if attackCoolDown == false: 
		attackCoolDown = true
		isAttacking = true
		$Node/attackCooldown.start()
		$Node/isAttacking.start()
		ninja.play("attack")
		
		if ninja == $ninja2:
			$ninja2Attack.disabled = false
		else:
			$ninja1Attack.disabled = false
			
		$swordSlash.play()
		$swordSlash/AudioStreamPlayer2D.play()

func attackShuriken():
	if attackCoolDown == false:
		attackCoolDown = true
		isAttacking = true
		$Node/attackCooldown.start()
		$Node/isAttacking.start()
		ninja.play("attack")

func PlayWalkAudio():
	if walkTime:
		walkTime = false
		$Node/walkAudio.start()
		$walkSound.play()


func _on_walk_audio_timeout():
	walkTime = true
