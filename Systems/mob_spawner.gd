class_name MobSpawner

extends Node2D

@export var creatures : Array[PackedScene]
var mobs_per_minute : float = 60.0

@onready var path_follow_2d : PathFollow2D = %PathFollow2D
var cooldown : float = 0.0

func _process(delta):
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Temporizador
	cooldown -= delta
	if cooldown > 0 : return
	
	# Frequencia quantos mobs por min.
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	# Checar se ponto é válido
	var point = get_point()
	
	# Verificar se esse ponto tem colisão
	var worldstate = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	var results: Array = worldstate.intersect_point(parameters, 1)
	
	if not results.is_empty():
		return
	
	# Instanciar criatura aleatoria
	var index = randi_range(0, creatures.size() - 1 ) 
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

