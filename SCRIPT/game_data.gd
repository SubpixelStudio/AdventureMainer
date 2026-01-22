extends Node2D

var inimigos_derrotados = 0
var iniciou_combat = false
var pegou_missao = false
var missao_atual = 0
var limite_de_inimigos = [10, 20, 50, 15, 1]

var has_dead = false
# cheats pra test
var jogador_imortal = false
var autoiniciar_missao = false

func _ready() -> void:
	# Garante que quando o jogo for exportado com debug desativado, 
	# os cheats serão desativados tb.
	if not OS.is_debug_build():
		jogador_imortal = false
		autoiniciar_missao = false
