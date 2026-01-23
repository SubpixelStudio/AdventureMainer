extends Label

var textos_missao: Dictionary = {
	0: "Mate 10 Almas Vermelhas",
	1: "Mate 20 Almas Vermelhas",
	2: "Proteja a casa de Edgar",
	3: "Mate 15 Almas Vermelhas",
	4: "Mate o King SoulRed"
}

@onready var world: WorldManager = get_tree().current_scene

func _ready() -> void:
	text = "..."

func _physics_process(_delta) -> void:
	# Só mostra durante combate
	if GameData.iniciou_combat and GameData.pegou_missao:
		var total = GameData.limite_de_inimigos[GameData.missao_atual]
		text = textos_missao.get(GameData.missao_atual, "Missão") \
			+ "\n\n" \
			+ str(world.inimigos_derrotados) + " / " + str(total)
