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
	print("Questions chargées :", questions)
	print("Réponses chargées :", copie_reponses)


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

	# --- Sélection des 6 réponses associées ---
	var start_index = question_index * 6
	var end_index = min(start_index + 6, copie_reponses.size())
	var reponses_possibles = copie_reponses.slice(start_index, end_index)

	if reponses_possibles.size() == 0:
		push_error("Aucune réponse trouvée pour la question " + str(question_index))
		return

	# La bonne réponse est toujours la première du bloc dans le JSON
	reponse = reponses_possibles[0]

	# Mélange pour rendre l’ordre aléatoire
	reponses_possibles.shuffle()

	# S'assurer que la bonne réponse soit incluse
	if reponse not in reponses_possibles:
		reponses_possibles[0] = reponse

	# Sélectionner 3 réponses parmi les 6 (dont forcément la bonne)
	var reponses_affichees = []
	reponses_affichees.append_array(reponses_possibles.slice(0, 3))

	# Vérifier que la bonne réponse soit incluse, sinon remplacer une au hasard
	if reponse not in reponses_affichees:
		var rand_index = randi() % 3
		reponses_affichees[rand_index] = reponse

	# Afficher sur les boutons
	$Rep1/Label1.text = reponses_affichees[0]
	$Rep2/Label2.text = reponses_affichees[1]
	$Rep3/Label3.text = reponses_affichees[2]

	print("Question :", question)
	print("Réponses possibles (6) :", reponses_possibles)
	print("Réponses affichées (3) :", reponses_affichees)
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
