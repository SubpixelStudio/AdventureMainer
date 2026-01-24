extends Node2D

var inimigos_derrotados: int = 0
var iniciou_combat: bool = false
var pegou_missao: bool = false
var missao_atual = 0
var limite_de_inimigos: PackedInt32Array = [10, 20, 50, 15, 1]
var has_died: bool = false

# cheats pra test
var jogador_imortal: bool = false
var autoiniciar_missao: bool = false

func _ready() -> void:
	# Garante que quando o jogo for exportado com debug desativado, 
	# os cheats serão desativados tb.
	if not OS.is_debug_build():
		jogador_imortal = false
		autoiniciar_missao = false
