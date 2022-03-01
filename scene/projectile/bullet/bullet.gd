extends "res://scene/projectile/projectile.gd"

func stop_projectile():
	.stop_projectile()
	for i in _sprites:
		i.visible = false
