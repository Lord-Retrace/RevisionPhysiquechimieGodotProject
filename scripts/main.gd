extends Node

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/QCM.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://scenes/sujets.tscn")

func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://scenes/connaissances.tscn")
