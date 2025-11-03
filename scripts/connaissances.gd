extends Node

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_buttoncommencer_pressed():
	var questionselec = randi() %questions.size() + 1
	reponse = copie_reponses[questionselec - 1]
	print(reponse)
	$Questionslabel.text = questions[questionselec - 1]
	$Buttoncommencer.text = "Suivant"
	$Buttoncommencer.position = Vector2(448, 850)
	$Rep1.position.y = 350
	$Rep2.position.y = 350
	$Rep3.position.y = 350
	reponses.clear()
	reponses.append_array(copie_reponses)
	var repselec = randi() %reponses.size() + 1
	$Rep1 / Label1.text = reponses[repselec - 1]
	reponses.remove_at(repselec - 1)
	repselec = randi() %reponses.size() + 1
	$Rep2 / Label2.text = reponses[repselec - 1]
	reponses.remove_at(repselec - 1)
	repselec = randi() %reponses.size() + 1
	$Rep3 / Label3.text = reponses[repselec - 1]
	reponses.remove_at(repselec - 1)
	reponsesonbuttons = [$Rep1 / Label1.text, $Rep2 / Label2.text, $Rep3 / Label3.text]
	if reponse in reponsesonbuttons:
		return
	else:
		buttonrandom = randi() %3 + 1
		match buttonrandom:
			1:
				$Rep1 / Label1.text = reponse
			2:
				$Rep2 / Label2.text = reponse
			3:
				$Rep3 / Label3.text = reponse
	print(reponsesonbuttons)


var questions = ["Test1", "Test2", "Test3"]
var reponsesonbuttons = [""]
var reponses = ["rep1", "rep2", "rep3"]
var copie_reponses = ["rep1", "rep2", "rep3"]
var index = 0
var buttonrandom = 0
var data = null
var reponse = ""

func _on_rep_1_pressed():
	if $Rep1 / Label1.text == reponse:
		print("Bonne réponse!")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Bonnereponse.show()
	else:
		print("Mauvaise réponse")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Mauvaisereponse.show()
	_on_buttoncommencer_pressed()

func _on_rep_2_pressed():
	if $Rep2 / Label2.text == reponse:
		print("Bonne réponse!")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Bonnereponse.show()
	else:
		print("Mauvaise réponse")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Mauvaisereponse.show()
	_on_buttoncommencer_pressed()

func _on_rep_3_pressed():
	if $Rep3 / Label3.text == reponse:
		print("Bonne réponse!")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Bonnereponse.show()
	else:
		print("Mauvaise réponse")
		$Bonnereponse.hide()
		$Mauvaisereponse.hide()
		$Mauvaisereponse.show()
	_on_buttoncommencer_pressed()

func _ready():
	$Mauvaisereponse.hide()
	$Bonnereponse.hide()
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "_on_http_request_request_completed"))

	#var url = "https://raw.githubusercontent.com/Lord-Retrace/revision-physique-chimie-datajson/main/Questionsdatas.json"
	var url = "https://raw.githubusercontent.com/Lord-Retrace/RevisionPhysiquechimieGodotProject/main/AutresRessources/Connaissancesdatas.json"
	url += "?t=" + str(Time.get_unix_time_from_system())
	http.request(url)


func _on_http_request_request_completed(result, response_code, headers, body):

	print("Résultat Godot (0=OK) : ", result)
	print("Code HTTP : ", response_code)

	if result != OK:
		push_error("Erreur de connexion/téléchargement Godot: %s" % result)
		return

	if response_code != 200:
		push_error("Erreur HTTP : %s" % response_code)
		print("erreur 200")
		return

	var content = body.get_string_from_utf8()
	print("Contenu du fichier JSON : ", content)

	data = JSON.parse_string(content)
	if data == null:
		push_error("Erreur : JSON invalide")
		return

	questions.clear()
	reponses.clear()
	copie_reponses.clear()
	copie_reponses.append_array(data["reponses"])
	print("copie reponse:", (copie_reponses))
	questions.append_array(data["questions"])
	reponses.append_array(data["reponses"])

	print("Questions : ", questions)
	print("Réponses : ", reponses)
