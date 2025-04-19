extends Node

var selectedMangaFile : String
var selectedMangaFilePath : String
@onready var progress = $Panel2/Progress
@onready var eHentaiURL = $"E-Hentai URL"
@onready var hentaiName = $"Manga Name"

func _ready():
	$CookieHTTPRequest.request_completed.connect(_on_request_completed)


func _on_request_completed(result, response_code, headers, body):
	progress.text += "Parsed from URL:\n"
	var _parsed = ""
	
	progress.text += "\t- url: " + eHentaiURL.text + "\n"
	_parsed += "url: " + eHentaiURL.text + "\n"
	
	progress.text += "\t- name: " + hentaiName.text + "\n"
	_parsed += "name: " + hentaiName.text + "\n"
	
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
	_parsed += _languageTags + "\n"
	progress.text += "\t- " + _parodyTags + "\n"
	_parsed += _parodyTags + "\n"
	progress.text += "\t- " + _characterTags + "\n"
	_parsed += _characterTags + "\n"
	progress.text += "\t- " + _artistTags + "\n"
	_parsed += _artistTags + "\n"
	progress.text += "\t- " + _maleTags + "\n"
	_parsed += _maleTags + "\n"
	progress.text += "\t- " + _femaleTags + "\n"
	_parsed += _femaleTags + "\n"
	progress.text += "\t- " + _mixedTags + "\n"
	_parsed += _mixedTags + "\n"
	progress.text += "\t- " + _otherTags + "\n\n"
	_parsed += _otherTags
	
	WriteParsedIntoZipFile(_parsed)

func WriteParsedIntoZipFile(_parsed : String):
	progress.text += "Saving tags .txt file on selected manga file...\n"
	
	var _reader = ZIPReader.new()
	var _readerError = _reader.open(selectedMangaFilePath)
	if _readerError != OK:
		return PackedByteArray()
	var _filesInsideZip : Dictionary
	var _dataOverwrite : PackedByteArray
	for _file in _reader.get_files():
		# remove existed data.txt file
		if(_file != "data.txt"):
			_filesInsideZip[_file] = _reader.read_file(_file)
	_reader.close()


	var _writer = ZIPPacker.new()
	var _writerError := _writer.open(selectedMangaFilePath)
	if _writerError != OK:
		return _writerError
	
	_writer.start_file("data.txt")
	_writer.write_file(_parsed.to_utf8_buffer())
	_writer.close_file()
	
	for _f in _filesInsideZip:
		_writer.start_file(_f)
		_writer.write_file(_filesInsideZip[_f])
		_writer.close_file()
		
	_writer.close()
	
	var _dir = DirAccess.open(selectedMangaFilePath.replace(selectedMangaFile, ""))
	_dir.rename(selectedMangaFile, selectedMangaFile.replace(".zip", ".cbz"))
	
	progress.text += "Done."
	return OK

func _on_file_dialog_file_selected(path):
	selectedMangaFile = $FileDialog.current_file
	selectedMangaFilePath = path
	
	progress.text = "Manga Selected;\n" + $FileDialog.current_file + "\n\n"
	
	eHentaiURL.text = ""
	hentaiName.text = ""

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
	elif(eHentaiURL.text.contains("https://e-hentai.org/g/") == false && eHentaiURL.text.contains("https://exhentai.org/g/") == false):
		progress.text = "ERROR: Entered URL is not E-Hentai URL.\n"
	else:
		progress.text += "Scrapping from E-Hentai...\n" + eHentaiURL.text + "\n\n"
		
		var _exHentaiCookies = ["ipb_member_id: " + $ipb_member_id.text, "ipb_pass_hash: " + $ipb_pass_hash.text]
		$CookieHTTPRequest.request(eHentaiURL.text, _exHentaiCookies)
