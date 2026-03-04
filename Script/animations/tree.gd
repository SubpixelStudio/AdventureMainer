extends TileMapLayer

var health = 3
func _ready() -> void:
	add_to_group("Tree")

func _process(delta: float) -> void:
	if health <= 0: death()

func death() -> void:
	if health > 0: return
	get_cell_atlas_coords(Vector2i(5,6))

func _damage(dano:int) -> void:
	health -= dano
