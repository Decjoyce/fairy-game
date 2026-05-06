extends HBoxContainer

@export var language_option: OptionButton

#en es ru  it fr cn ja de br ga 
var languages: = {
	"English": "en",
	"Spanish": "es",
	"Russian": "ru",
	"Italian": "it",
	"French": "fr",
	"Chinese": "cn",
	"Japanese": "ja",
	"German": "de",
	"Portuguese(Brazilian)": "br",
	"Irish": "ga"
	
	
	
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for lang_name in languages.keys():
		language_option.add_item(lang_name)
		
	var current_locale := TranslationServer.get_locale()
	for i in range(language_option.item_count):
			var lang_name := language_option.get_item_text(i)
			if current_locale.begins_with(languages[lang_name]):
				language_option.select(i)
				break
				
	language_option.item_selected.connect(_on_languagae_selected)

func _on_languagae_selected(index: int):
	var lang_name := language_option.get_item_text(index)
	var locale = languages[lang_name]
	TranslationServer.set_locale(lang_name)
	print("Locale set to:",locale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
