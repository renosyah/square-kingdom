extends Control

onready var _templates = {
	"team" : $HBoxContainer/player_team/player_team,
	"player_name" : $HBoxContainer/player_name/player_name,
	"unit_deploy" : $HBoxContainer/unit_deploy/unit_deploy,
	"unit_kill" : $HBoxContainer/unit_kill/unit_kill,
	"unit_lost" : $HBoxContainer/unit_lost/unit_lost,
	"building_captured" : $HBoxContainer/building_capture/building_capture,
	"total" : $HBoxContainer/total/total
}

onready var _holders = {
	"team" : $HBoxContainer/player_team,
	"player_name" : $HBoxContainer/player_name,
	"unit_deploy" : $HBoxContainer/unit_deploy,
	"unit_kill" : $HBoxContainer/unit_kill,
	"unit_lost" : $HBoxContainer/unit_lost,
	"building_captured" : $HBoxContainer/building_capture,
	"total" : $HBoxContainer/total
}

class CustomSorter:
	static func sort(a, b):
		if a["total"] > b["total"]:
			return true
			
		return false
		
func display_scores(_scores : Dictionary):
	var scores = []
	for i in _scores.keys():
		scores.append(_scores[i])
		
	scores.sort_custom(CustomSorter, "sort")
	
	# itter array
	for items in scores:
		
		# itter dic
		for key in items.keys():
			var template = _templates[key].duplicate()
			template.visible = true
			
			if template is ColorRect:
				template.color = items[key]
				
			if template is Label:
				template.text = str(items[key])
				
			var holder = _holders[key]
			holder.add_child(template)
















