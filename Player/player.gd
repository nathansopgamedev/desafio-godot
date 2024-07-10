class_name Player
extends CharacterBody2D



@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D 

@onready var sword_area : Area2D = $SwordArea
@onready var damage_area : Area2D = $DamageArea
@onready var health_bar : ProgressBar = $HealthBar

@export_category("Movement")
@export var speed: float = 3.4
@export_category("Sword")
@export var sword_damage : int = 2
@export_category("Ritual")
@export var ritual_damage : int = 1
@export var ritual_interval : float = 30.0
@export var ritual_scene : PackedScene
@export_category("Health")
@export var health : int = 50
@export var max_health : int = 50
@export var death_prefab : PackedScene

var input_vector : Vector2 = Vector2(0,0)
var is_running : bool = false
var was_running : bool = false
var is_attacking : bool = false
var attack_cooldown : float = 0.0
var hitbox_cooldown : float = 0.0
var ritual_cooldown : float = 0.0

signal meat_collected (value : int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value : int): GameManager.meat_counter +=1)

func _process(delta):
	# Adiciona a posição desse Player no GameManager
	GameManager.player_position = position
	
	# Ler Input
	read_input()
	
	# Atualizar temporizador do Ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Processar animação e Rotação do Sprite
	play_Run_idle_animation()
	if not is_attacking:
		flip_sprite()
		
	# Processar dano
	update_hitbox_detection(delta)

	# Ritual
	update_ritual(delta)

	# Atualizar heatlh bar
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta: float):
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05 )
	move_and_slide()

func update_attack_cooldown(delta : float):
	#  Atualizar temporizador do Ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("Idle")

func play_Run_idle_animation():
	# Tocar Animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("Run")
			else:
				animation_player.play("Idle")

func flip_sprite():
	# Girar sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func read_input():
	# Obter o InputVector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar deadzone do input vector
	var deadzone = 0.35
	if abs(input_vector.x) < 0.35:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.35:
		input_vector.y = 0
		
	# Atualizar o is_runnning
	was_running = is_running
	is_running = not input_vector.is_zero_approx()



func attack():
	if is_attacking:
		return
	# attack_side_1
	# attack_side_2
	
	# Tocar Animação
	animation_player.play("attack_side_1")
	
	# Configurar Temporizador
	attack_cooldown = 0.5
	
	# Marcar Attack
	is_attacking = true
	
	# Aplicar dano nos inimigos
	
func deal_damage_to_enemies():
	# Acessar todos os inimigos
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group("Enemies")):
			var enemy : Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction : Vector2 
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.3:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta : float):
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0 : return
	
	#frequencia (2x segundo
	hitbox_cooldown = 0.5
	

	
	#Detectar Inimigos
	var bodies = damage_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies"):
			var enemy : Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func update_ritual(delta : float) -> void:
	# Temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0 : return
	
	# Frequencia
	ritual_cooldown = ritual_interval
	
	# Criar Ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

func damage(amount: int):
	if health <= 0 : return
	
	health -= amount
	print("Dano causado: " ,  amount , " vida total: " , health , "/" , max_health)

	# Piscar o Node ao sofrer dano.
	modulate = Color.INDIAN_RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	# Processar morte
	if health <=0:
		die()
	
func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	print("Player Morreu")
	queue_free()

func heal(amount : int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Dano curado: " ,  amount , " vida total: " , health , "/" , max_health)
	return health
