extends CharacterBody2D

const gravity: int  = 4200
const jump_speed: int  = -1800

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
				#$jumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$runCollision.disabled = true
				$duckCollision.disabled = false
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
	move_and_slide()
		
