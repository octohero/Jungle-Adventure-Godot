extends Node2D

signal score_changed
var score
var Collectible = preload("res://Collectible.tscn")

onready var pickups = $Pickups

func _ready():
	score = 0
	emit_signal('score_changed', score)
	pickups.hide()
	$Player.start($PlayerSpawn.position)
	set_camera_limits()
	spawn_pickups()

func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.cell_size
	$Player/Camera2D.limit_left = (map_size.position.x + 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x - 5) * cell_size.x
	$Player/Camera2D.limit_top = (map_size.position.x + 7) * cell_size.y

func spawn_pickups():
	for cell in pickups.get_used_cells():
		var id = pickups.get_cellv(cell)
		var type = pickups.tile_set.tile_get_name(id)
		if type in ['gem', 'cherry']:
			var c = Collectible.instance()
			var pos = pickups.map_to_world(cell)
			c.init(type, pos + pickups.cell_size/2)
			add_child(c)
			c.connect('pickup', self, '_on_Collectible_pickup')

func _on_Collectible_pickup():
	score += 1
	emit_signal("score_changed")

func _on_Player_dead():
	pass
