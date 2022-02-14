extends Control

const COLORS = [
	"#800000",
	"#8B0000",
	"#B22222",
	"#FF0000",
	"#FA8072",
	"#FF6347",
	"#FF7F50",
	"#FF4500",
	"#D2691E",
	"#F4A460",
	"#FF8C00",
	"#FFA500",
	"#B8860B",
	"#DAA520",
	"#FFD700",
	"#808000",
	"#FFFF00",
	"#9ACD32",
	"#ADFF2F",
	"#7FFF00",
	"#7CFC00",
	"#008000",
	"#00FF00",
	"#32CD32",
	"#00FF7F",
	"#00FA9A",
	"#40E0D0",
	"#20B2AA",
	"#48D1CC",
	"#008B8B",
	"#00FFFF",
	"#00CED1",
	"#00BFFF",
	"#1E90FF",
	"#4169E1",
	"#00BFFF",
	"#1E90FF",
	"#4169E1",
	"#000080",
	"#00008B",
	"#0000CD",
	"#0000FF",
	"#8A2BE2",
	"#9932CC",
	"#9400D3",
	"#800080",
	"#8B008B",
]

signal on_pick(_color)

onready var _holder = $VBoxContainer/ScrollContainer/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in COLORS:
		var item = preload("res://assets/ui/input-color/item/item.tscn").instance()
		item.connect("pick", self, "_on_pick")
		item.color = Color(i)
		_holder.add_child(item)
		
func _on_pick(_color):
	emit_signal("on_pick", _color)
	visible = false
	
func _on_back_pressed():
	visible = false
