extends ColorRect
class_name RemapContainer

var label_text: String
var button_text: String
var action_name: String
var event_index:int

var button_text_2: String
var action_name_2: String
var event_index_2:int

@onready var l_input: Label = $L_input
@onready var b_remap: RemapButton = $B_remap
@onready var b_remap_2: RemapButton = $B_remap2


func _ready():
	l_input.text = label_text
	
	b_remap.text = button_text
	b_remap.action = action_name
	b_remap.event_index = event_index
	
	b_remap_2.text = button_text_2
	b_remap_2.action = action_name_2
	b_remap_2.event_index = event_index_2
	
