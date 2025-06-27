extends CenterContainer

var selected_item_index := 0

@onready var evidence_rect: TextureRect = %EvidenceRect
@onready var evidence_name: Label = %EvidenceName
@onready var evidence_detial: Label = %EvidenceDetial
@onready var item_list: ItemList = %ItemList
@onready var config_panel: Control = %ConfigPanel

func _ready() -> void:
	config_panel.config_button.pressed.connect(_on_config_button_pressed)
	display_evidence()
	item_list.select(0)

func display_evidence():
	for evidence_index in Evidence.EVIDENCE_DETAIL:
		var is_add_item = Evidence.EVIDENCE_DETAIL[evidence_index]["is_add_item"]
		if is_add_item:
			item_list.add_icon_item(Evidence.EVIDENCE_DETAIL[evidence_index]["sprite"])

func add_evidence(evidence_index: int):
	item_list.add_icon_item(Evidence.EVIDENCE_DETAIL[evidence_index]["sprite"])

func display_evidence_detail(item_index: int):
	var evidence = Evidence.EVIDENCE_DETAIL[item_index]
	if evidence.has("name"):
		evidence_name.text = evidence["name"]
	
	if evidence.has("detail"):
		evidence_detial.text = evidence["detail"]
		
	if evidence.has("sprite"):
		evidence_rect.texture = evidence["sprite"]

func get_selected_evidence_name():
	var evidence = Evidence.EVIDENCE_DETAIL[selected_item_index]
	return evidence["en_name"]

func _on_item_list_item_selected(index: int) -> void:
	selected_item_index = index
	display_evidence_detail(index)

func _on_config_button_pressed():
	hide()
