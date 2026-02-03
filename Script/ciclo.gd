extends CanvasModulate

var duracao_dia:float = 60.0
var tempo:float = 0.0

@export var luz: PointLight2D

func _process(delta: float) -> void:
	tempo += delta
	var t := fmod(tempo / duracao_dia, 1.0)
	color = calcular_cor(t)
	luz.visible = t > 0.6


func calcular_cor(t: float) -> Color:
	if t < 0.25:
		# Dia → Tarde
		return Color(1,1,1).lerp(Color(1,0.85,0.7), t / 0.25)
	elif t < 0.5:
		# Tarde → Noite
		return Color(1,0.85,0.7).lerp(Color(0.2,0.2,0.35), (t - 0.25) / 0.25)
	elif t < 0.75:
		# Noite → Madrugada
		return Color(0.2,0.2,0.35).lerp(Color(0.1,0.1,0.2), (t - 0.5) / 0.25)
	else:
		# Madrugada → Dia
		return Color(0.1,0.1,0.2).lerp(Color(1,1,1), (t - 0.75) / 0.25)
