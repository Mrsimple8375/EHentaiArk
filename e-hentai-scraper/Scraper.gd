extends Node

var selectedMangaFile : String
var selectedMangaFilePath : String
@onready var progress = $Panel2/Progress
@onready var eHentaiURL = $"E-Hentai URL"
@onready var hentaiName = $"Manga Name"

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)

func _on_request_completed(result, response_code, headers, body):
	progress.text += "Parsed from URL:\n"
	
	# get gid and token from url
	var _gidANDtoken = eHentaiURL.text.replace("https://e-hentai.org/g/", "").split("/")
	var _gid = _gidANDtoken[0]
	var _token = _gidANDtoken[1]
	progress.text += "\t- gid: " + _gid + "\n"
	progress.text += "\t- token: " + _token + "\n"
	
	var _languageTags = "language: "
	var _parodyTags = "parody: "
	var _characterTags = "character: "
	var _artistTags = "artist: "
	var _maleTags = "male: "
	var _femaleTags = "female: "
	var _mixedTags = "mixed: "
	var _otherTags = "other: "
	
	var _parser = XMLParser.new()
	_parser.open_buffer(body)
	
	while(_parser.read() != ERR_FILE_EOF):
		var _nodeName = _parser.get_node_name()
		var _attributeDict = {}
		
		for idx in range(_parser.get_attribute_count()):
			_attributeDict[_parser.get_attribute_name(idx)] = _parser.get_attribute_value(idx)
		
		if(_attributeDict.size() != 0):
			if(_nodeName == "a"):
				var _value = _attributeDict.get("id")
				if(_value != null):
					if(_value.contains("ta_language:")):
						_languageTags += _value.split("ta_language:")[1] + "; "
					elif(_value.contains("ta_parody:")):
						_parodyTags += _value.split("ta_parody:")[1] + "; "
					elif(_value.contains("ta_character:")):
						_characterTags += _value.split("ta_character:")[1] + "; "
					elif(_value.contains("ta_artist:")):
						_artistTags += _value.split("ta_artist:")[1] + "; "
					elif(_value.contains("ta_male:")):
						_maleTags += _value.split("ta_male:")[1] + "; "
					elif(_value.contains("ta_female:")):
						_femaleTags += _value.split("ta_female:")[1] + "; "
					elif(_value.contains("ta_mixed:")):
						_mixedTags += _value.split("ta_mixed:")[1] + "; "
					elif(_value.contains("ta_other:")):
						_otherTags += _value.split("ta_other:")[1] + "; "
						
	progress.text += "\t- " + _languageTags + "\n"
	progress.text += "\t- " + _parodyTags + "\n"
	progress.text += "\t- " + _characterTags + "\n"
	progress.text += "\t- " + _artistTags + "\n"
	progress.text += "\t- " + _maleTags + "\n"
	progress.text += "\t- " + _femaleTags + "\n"
	progress.text += "\t- " + _mixedTags + "\n"
	progress.text += "\t- " + _otherTags

func _on_file_dialog_file_selected(path):
	selectedMangaFile = $FileDialog.current_file
	selectedMangaFilePath = path
	
	progress.text = "Manga Selected;\n" + $FileDialog.current_file + "\n\n"

func _on_select_manga_file_pressed():
	$FileDialog.visible = true

func _on_start_pressed():
	progress.text = "Manga Selected;\n" + $FileDialog.current_file + "\n\n"
	if(hentaiName.text == ""):
		progress.text = "ERROR: Manga name is required.\n"
	elif(eHentaiURL.text == ""):
		progress.text = "ERROR: E-Hentai URL is required.\n"
	elif(selectedMangaFile == ""):
		progress.text = "ERROR: Manga file must be selected.\n"
	elif(eHentaiURL.text.contains("https://e-hentai.org/g/") == false):
		progress.text = "ERROR: Entered URL is not E-Hentai URL.\n"
	else:
		progress.text += "Scrapping from E-Hentai...\n" + eHentaiURL.text + "\n\n"
		$HTTPRequest.request(eHentaiURL.text)
