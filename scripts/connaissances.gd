extends Node

var questions = []
var reponsesonbuttons = []
var reponses = []
var copie_reponses = []
var index = 0
var buttonrandom = 0
var data = null
var reponse = ""

func _ready():
	$Mauvaisereponse.hide()
	$Bonnereponse.hide()
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", Callable(self, "_on_http_request_request_completed"))

	var url = "https://raw.githubusercontent.com/Lord-Retrace/RevisionPhysiquechimieGodotProject/refs/heads/main/AutresRessources/Connaissancesdata.json"
	url += "?t=" + str(Time.get_unix_time_from_system())
	http.request(url)

func _on_http_request_request_completed(result, response_code, headers, body):
	if result != OK or response_code != 200:
		push_error("Erreur de téléchargement (result=%s, code=%s)" % [result, response_code])
		return

	var content = body.get_string_from_utf8()
	data = JSON.parse_string(content)
	if data == null:
		push_error("Erreur : JSON invalide")
		return

	questions = data["questions"]
	copie_reponses = data["reponses"]
	print("Questions chargées :", questions)
	print("Réponses chargées :", copie_reponses)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_buttoncommencer_pressed():
	# Sélection aléatoire d’une question
	var question_index = randi() % questions.size()
	var question = questions[question_index]
	$Questionslabel.text = question
	$Buttoncommencer.text = "Suivant"
	$Buttoncommencer.position = Vector2(448, 850)
	$Rep1.position.y = 350
	$Rep2.position.y = 350
	$Rep3.position.y = 350

	# Calcul des indices des réponses associées à cette question
	# Ex : Q1 → indices 0,1,2 ; Q2 → 3,4,5 ...
	var start_index = question_index * 3
	var end_index = start_index + 3
	var reponses_possibles = copie_reponses.slice(start_index, end_index)

	# Choisir aléatoirement les positions des réponses
	reponses_possibles.shuffle()
	reponse = reponses_possibles[0]  # la "bonne" réponse (on peut ajuster selon besoin)

	# Placement des réponses sur les boutons
	$Rep1/Label1.text = reponses_possibles[0]
	$Rep2/Label2.text = reponses_possibles[1]
	$Rep3/Label3.text = reponses_possibles[2]

	print("Question :", question)
	print("Réponses proposées :", reponses_possibles)
	print("Bonne réponse :", reponse)


func _on_rep_1_pressed():
	_verifier_reponse($Rep1/Label1.text)

func _on_rep_2_pressed():
	_verifier_reponse($Rep2/Label2.text)

func _on_rep_3_pressed():
	_verifier_reponse($Rep3/Label3.text)

func _verifier_reponse(rep_text):
	$Bonnereponse.hide()
	$Mauvaisereponse.hide()
	if rep_text == reponse:
		print("Bonne réponse!")
		$Bonnereponse.show()
	else:
		print("Mauvaise réponse")
		$Mauvaisereponse.show()
	_on_buttoncommencer_pressed()
