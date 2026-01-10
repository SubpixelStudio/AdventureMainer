class_name Objective extends Label

@export var missoes: Dictionary = {
	0: """Objetivo: Mate 10 Almas Vermelhas
A cidade adormece sob um manto de silêncio,
mas algo se move nas sombras.
Almas perdidas,
corrompidas pelo medo e pela noite, 
vagam pelas ruas.
Sua primeira missão,
eliminá-las
antes que encontrem vítimas inocentes.""",

	1: """Objetivo: Mate 20 Almas Vermelhas
Edgar, o guardião da floresta, 
envia um pedido urgente.
A escuridão se intensifica entre as árvores, 
e criaturas inquietas se aproximam da aldeia.
Não há tempo a perder: 
proteja os que ainda sobrevivem.""",

	2: """Objetivo: Proteja a casa de Edgar
As trevas não param e agora cercam a residência de Edgar.
O velho guardião está vulnerável; 
sua presença é a última barreira entre ele e a destruição.
Defenda a casa a todo custo e prepare-se para o que vem depois.""",

	3: """Objetivo: Mate 15 Almas Vermelhas
As almas perdidas evoluíram, 
tornando-se guerreiros impiedosos.
Elas patrulham a região em busca de qualquer sinal de vida.
Sua habilidade será testada enquanto você limpa os caminhos sombrios.""",

	4: """Objetivo: Mate o King SoulRed
A origem da corrupção é finalmente revelada: 
o temido King SoulRed.
Enquanto o medo e a escuridão se espalham, 
apenas você pode deter a fonte do mal.
Encare o inimigo supremo e... 
liberte a cidade do terror eterno."""
}

var frases: PackedStringArray
var frase_atual := -1

@export var world: WorldManager # WorldManager para iniciar o combate depois

func _ready():
	text = ""
	visible = false
	world = $"../../../../.."

func iniciar_missao(indice: int):
	frases = missoes[indice].split("\n")
	# Pega as linhas da missão
	if frase_atual < frases.size():
		text = frases[frase_atual]
		visible = true


func _input(event):
	if event.is_action_pressed("attack"):
		frase_atual += 1
		if frase_atual < frases.size():
			text = frases[frase_atual]  # mostra próxima linha
		else:
			text = ""
			visible = false
