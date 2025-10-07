extends Node


@onready var http_downloader = $HTTPDownloader
@onready var save_file_dialog = $SaveFileDialog
@onready var texture_rect = $TextureRect

var json_loader: HTTPRequest


var file_body: PackedByteArray
var data = null
var reponses = []
var questions = []
var copie_reponses = []
var num_photos: int = 0



const IMAGE_URL_BASE = "https://raw.githubusercontent.com/Lord-Retrace/revision-physique-chimie-datajson/main/mes_images_godot_1/images/image"

const JSON_URL = "https://raw.githubusercontent.com/Lord-Retrace/revision-physique-chimie-datajson/main/Questionsdatas.json"


var selec = 0
var http_image_loader: HTTPRequest


func _get_image_url(index: int) -> String:

	return IMAGE_URL_BASE + str(index) + ".jpg"


func _update_image():

	var image_index = selec + 1
	var full_url = _get_image_url(image_index)

	print("Chargement de l\'image : ", full_url)


	if is_instance_valid(http_image_loader):
		http_image_loader.cancel_request()



	http_image_loader.request(full_url)

func _on_gauche_pressed():

	var modulo = max(num_photos, 4)

	selec -= 1

	selec = (selec + modulo) %modulo

	print("Seléction actuelle: ", selec)
	_update_image()

func _on_droite_pressed():

	var modulo = max(num_photos, 4)

	selec += 1
	selec = selec % modulo

	print("Seléction actuelle: ", selec)
	_update_image()





func _ready():

	http_image_loader = HTTPRequest.new()
	add_child(http_image_loader)
	http_image_loader.request_completed.connect(_on_image_request_completed)


	_update_image()



	json_loader = HTTPRequest.new()
	add_child(json_loader)
	_load_json_data()


	save_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_file_dialog.title = "Enregistrer le fichier téléchargé"



	save_file_dialog.current_dir = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)

	http_downloader.request_completed.connect(_on_http_downloader_request_completed)
	save_file_dialog.file_selected.connect(_on_save_file_dialog_files_selected)


func _load_json_data():
	print("Début du téléchargement des données JSON...")

	json_loader.request_completed.connect(_on_json_data_request_completed)


	var url_with_cache_buster = JSON_URL + "?t=" + str(Time.get_unix_time_from_system())
	json_loader.request(url_with_cache_buster)


func _on_json_data_request_completed(result, response_code, headers, body):
	print("--- Rapport de chargement JSON ---")
	print("Résultat Godot (0=OK) : ", result)
	print("Code HTTP : ", response_code)

	if result != OK:
		push_error("Erreur Godot lors du chargement JSON: %s" % result)
		return

	if response_code != 200:
		push_error("Erreur HTTP lors du chargement JSON: %s" % response_code)
		return

	var content = body.get_string_from_utf8()


	var parse_result = JSON.parse_string(content)
	if parse_result == null:
		push_error("Erreur : JSON invalide après téléchargement")
		print("Contenu brut qui a échoué au parsing: ", content)
		return
	data = parse_result


	questions.clear()
	reponses.clear()
	copie_reponses.clear()

	questions.append_array(data.get("questions", []))
	reponses.append_array(data.get("reponses", []))
	copie_reponses.append_array(data.get("reponses", []))


	var nb_photos_string = data.get("nbphotos", "0")
	if typeof(nb_photos_string) == TYPE_STRING:
		num_photos = int(nb_photos_string)
	elif typeof(nb_photos_string) == TYPE_INT:
		num_photos = nb_photos_string
	else:
		num_photos = 0


	print("Contenu complet du JSON : ", content)
	print("Nombre de photos chargées (nbphotos) : ", num_photos)

	print("Données JSON chargées avec succès. Questions: %s, Réponses: %s" % [questions.size(), reponses.size()])
	print("---------------------------------")



	_update_image()







func _on_image_request_completed(result, response_code, headers, body):
	if result == OK and response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err == OK:
			var tex = ImageTexture.create_from_image(img)
			if is_instance_valid(texture_rect):
				texture_rect.texture = tex
				print("Image chargée avec succès dans TextureRect.")
			else:
				push_error("TextureRect n\'est pas un nœud valide.")
		else:
			push_error("Impossible de charger l\'image. Erreur Godot : " + str(err))

func _on_button_pressed():

	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_download_button_pressed():
	print("Démarrage du téléchargement...")

	var image_index = selec + 1
	var full_url = _get_image_url(image_index)
	print("URL de téléchargement : ", full_url)

	http_downloader.request(full_url)

func _on_http_downloader_request_completed(result, response_code, headers, body):

	if result != OK:
		push_error("Erreur de connexion/téléchargement Godot: " + str(result))
		return
	if response_code != 200:
		push_error("Erreur HTTP: " + str(response_code))
		return


	file_body = body
	var downloaded_url: String = _get_image_url(selec + 1)
	var default_filename: String = downloaded_url.get_file()


	if OS.has_feature("web"):



		var js_interface = Engine.get_singleton("JavaScript")
		if not is_instance_valid(js_interface):
			js_interface = Engine.get_singleton("JavaScriptBridge")

			if is_instance_valid(js_interface) and file_body.size() > 0:
				print("Tentative de téléchargement forcé via JavaScript.eval()...")


			var base64_data = Marshalls.raw_to_base64(file_body)


			var mime_type = "image/jpeg"
			var data_url = "data:" + mime_type + ";base64," + base64_data


			var js_code = "\n            var a = document.createElement(\'a\');\n            a.href = \'%s\';\n            a.download = \'%s\';\n            document.body.appendChild(a);\n            a.click();\n            document.body.removeChild(a);\n\t\t\t"\
\
\
\
\
\
\
%[data_url, default_filename]


			js_interface.eval(js_code)

		else:
			push_error("Échec de l\'initialisation du téléchargement Web. Singleton JS non trouvé ou données vides.")

	else:

		save_file_dialog.current_dir = OS.get_system_dir(OS.SystemDir.SYSTEM_DIR_DESKTOP)
		save_file_dialog.current_file = default_filename
		save_file_dialog.popup_centered()

func _on_save_file_dialog_files_selected(path: String):
	if file_body.is_empty():
		push_error("Données de fichier introuvables. Téléchargement échoué ou annulé.")
		return

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_buffer(file_body)
		file.close()
		print("Fichier sauvegardé avec succès à : " + path)
	else:
		push_error("Impossible d\'ouvrir le fichier pour l\'écriture : " + path)
