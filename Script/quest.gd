class_name Quest
extends Resource

var quests := {
	0: {
		#"texto": "Derrote os inimigos da floresta.",
		"ativa": false,
		"etapa": 0,
		"progresso": 0,
		"limites": [10, 20, 50, 15, 1]
	},
	#1: {
		#"texto": "Derrote o guardião ancestral.",
		#"ativa": false,
		#"etapa": 0,
		#"progresso": 0,
		#"limites": [1]
	#}
}

func iniciar(id: int) -> void:
	if not quests.has(id):
		push_error("Quest inexistente: %d" % id)
		return
	
	var q = quests[id]
	q.ativa = true
	q.etapa = 0
	q.progresso = 0


func inimigo_morto() -> void:
	for q in quests.values():
		if not q.ativa:
			continue
		
		q.progresso += 1
		if q.progresso >= q.limites[q.etapa]:
			q.etapa += 1
			q.progresso = 0
			
			if q.etapa >= q.limites.size():
				q.ativa = false
				print("Quest concluída!")


func cancelar(id: int) -> void:
	if not quests.has(id):
		return
	
	var q = quests[id]
	q.ativa = false
	q.etapa = 0
	q.progresso = 0
