extends Control


const ICON : Dictionary = {
	FULLSCREEN = &"\udb80\ude93",
	FULLSCREEN_OFF = &"\udb80\ude94",
}

@export_category("VN Elements")
@export var sprite: Sprite2D
@export var sprite_faces: Node2D
@export var sprite_2: CanvasItem
@export var background: Sprite2D

@export_category("Decors, Polish, & FX")
@export var time_label: Label
@export var timer_elapsed_second: Timer
@export var dot_indicator: TextureRect

@export_group("Flashlight")
@export var light: CanvasItem
@export var light_parallax_ref: CanvasItem
@export var light_parallax_distance_vec: Vector2
@export var light_parallax_offset: Vector2
@export var light_parallax_speed: float

@export_group("Parallax")
@export var sprite_parallax_ref: CanvasItem
@export var sprite_parallax_distance_vec: Vector2
@export var sprite_parallax_offset: Vector2
@export var sprite_parallax_speed: float
@export var background_parallax_ref: CanvasItem
@export var background_parallax_distance_vec: Vector2
@export var background_parallax_offset: Vector2
@export var background_parallax_speed: float

@export_group("Shaders")
@export_subgroup("CRT")
@export var shader_crt_overlay : ColorRect
@export var shader_crt_config : Dictionary = {
	&"resolution" : Vector2(1280.0, 720.0),
	&"scan_line_amount" : 0.3,
	&"warp_amount" : 0.15,
	&"noise_amount" : 0.03,
	&"interference_amount" : 1.0,
	&"grille_amount" : 0.1,
	&"grille_size" : 1.0,
	&"vignette_amount" : 0.5,
	&"vignette_intensity" : 0.3,
	&"aberation_amount" : 0.5,
	&"roll_line_amount" : 0.02,
	&"roll_speed" : 1.0,
	&"scan_line_strength" : -12,
	&"pixel_strength" : -2,
}:
	set(value):
		shader_crt_config = value
		shader_crt_update.call()

@export_subgroup("Glitch")
@export var shader_glitch_overlay: ColorRect

@export_subgroup("Blur")
@export_range(0.0, 0.5) var shader_blur_lod: float = 0.0:
	set(value):
		shader_blur_lod = value
		shader_blur_material.set_shader_parameter(&"lod", value)
@export var shader_blur_overlay : ColorRect

@export_category("User Configurations")
@export var user_name_input: TextEdit
@export var user_name_confirm: Button
@export var slider_brightness: HSlider
@export var slider_contrast: HSlider

@export_group("Fullscreen")
@export var button_display_mode: Button
@export var label_fullscreen: Label
@export var label_windowed: Label

@export_group("Closed Caption")
@export var button_cc: Button
@export var panel_config_cc: Control
@export var panel_config_cc_animation_player: AnimationPlayer
@export var panel_config_cc_2: Control
@export var spinbox_font_size: SpinBox
@export var spinbox_letter_spacing: SpinBox
@export var spinbox_bg_opacity: SpinBox

@export_category("Theatre Setup")
@export_file("*.dlg") var dialogue_file: String = ""
@export var actor_label: Label
@export var dialogue_label_container: Control
@export var caller_node_anim: AnimationPlayer
@export var caller_node_trans: AnimationPlayer

@export_group("History")
@export var history_button: Button
@export var history_button_close: Button
@export var history_window: Control
@export var history_container: VBoxContainer
@export var history_scroll: ScrollContainer
@export var history_dlg_template: VBoxContainer

var environment: Environment
var is_fullscreen := false
var font_size: int
var allow_progress := true

var face_tween: Tween
var face_current: Sprite2D
var faces: Dictionary

var history_scroll_bar: VScrollBar

var dialogue: Dialogue
var stage := Stage.new()
var dialogue_label := DialogueLabel.new()
var dialogue_font_variation: FontVariation
var dialogue_stylebox: StyleBoxFlat

var viewport: Viewport
var viewport_rect_size := Vector2.ZERO
var viewport_centre := Vector2.ZERO
var viewport_mouse_pos := Vector2.ZERO
var viewport_mouse_distance : float = 0.0
var viewport_mouse_direction := Vector2.ZERO

# 时间
var elapsed_time_second: int = 60 * 28 + randi_range(-20, 45)
var elapsed_hour: int
var elapsed_minute: int
var elapsed_second: int

var shader_crt_material := ShaderMaterial.new()
var shader_crt := Shader.new()
var shader_blur_material := ShaderMaterial.new()
var shader_blur := Shader.new()
var shader_glitch := Shader.new()
var shader_crt_update: Callable = func():
	for crt_param: StringName in shader_crt_config:
		shader_crt_material.set_shader_parameter(crt_param, shader_crt_config[crt_param])


@onready var tree := get_tree()
@onready var dlg_end_beep: AnimatedTexture
@onready var options: CenterContainer = $UI/Control/Options

func _enter_tree() -> void:
	viewport = get_viewport()
	label_fullscreen.visible = false
	label_windowed.visible = false
	is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	#region Initialize shaders
	shader_crt.code = SHADER_CRT_CODES
	shader_crt_material.shader = shader_crt
	shader_crt_overlay.material = shader_crt_material
	shader_crt_overlay.visible = true
	
	shader_crt_update.call()
	
	shader_glitch.code = SHADER_GLITCH_CODES
	shader_glitch_overlay.material.shader = shader_glitch
	
	shader_blur.code = SHADER_BLUR_CODES
	shader_blur_material.shader = shader_blur
	shader_blur_overlay.material = shader_blur_material
	shader_blur_overlay.visible = true
	#endregion

	#region Initialize Theatre
	dialogue = Dialogue.new(FileAccess.get_file_as_string(dialogue_file))
	dialogue_label.fit_content = true
	dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	dialogue_label_container.add_child(dialogue_label)
	
	add_child(stage)
	stage.dialogue_label = dialogue_label
	dialogue_label.set_stage(stage)
	
	stage.progressed.connect(_on_stage_progressed)
	
	stage.allow_cancel = false
	stage.allow_func = true
	stage.allow_skip = false
	#endregion

func _ready() -> void:
	environment = $Main/WorldEnvironment.environment
	dlg_end_beep = dot_indicator.texture
	
	stage.actor_label = actor_label
	stage.speed_scale = 1.0
	stage.add_caller("f", self)
	stage.finished.connect(_on_stage_finished)
	
	dialogue_font_variation = actor_label.get_theme_font(&"font")
	dialogue_stylebox = actor_label.get_theme_stylebox(&"normal")
	
	dialogue_label.add_theme_stylebox_override(&"normal", dialogue_stylebox)
	dialogue_label.add_theme_font_override(&"normal_font", dialogue_font_variation)
	
	initialize_config_ui()
	
	# set defaults
	panel_config_cc.visible = false
	
	font_size = 18
	spinbox_font_size.value = font_size
	spinbox_letter_spacing.value = 1
	spinbox_bg_opacity.value = 80
	
	timer_elapsed_second.timeout.connect(update_time)
	
	# Set up history
	history_window.visible = false
	history_dlg_template.visible = false
	history_scroll_bar = history_scroll.get_v_scroll_bar()
	history_button.pressed.connect(_on_history_button_pressed)
	history_button_close.pressed.connect(_on_history_button_pressed)
	
	# Initialize user name
	user_name_input.text_changed.connect(_on_user_name_input_text_changed)
	user_name_confirm.pressed.connect(_on_user_name_confirm_pressed)
	user_name_confirm.modulate.a = 0.0
	
	for face_ in sprite_faces.get_children():
		faces[face_.name] = face_
		face_.visible = true
		face_.modulate.a = 0.0
	
	face_current = faces["scawy"]
	face_current.modulate.a = 1.0
	
	# 显示输入光标
	user_name_input.grab_focus()
	
	# print("-".repeat(80))
	# print(dialogue.humanize())
	# print("-".repeat(80))

func _process(delta: float) -> void:
	viewport_rect_size = viewport.get_visible_rect().size
	viewport_centre = viewport_rect_size * 0.5
	
	viewport_mouse_pos = viewport.get_mouse_position()
	viewport_mouse_distance = clampf(
		viewport_mouse_pos.distance_to(viewport_centre) /\
		 (viewport_rect_size.length() * 0.5),
		0.0, 1.0)
	viewport_mouse_direction = viewport_centre.direction_to(viewport_mouse_pos)
	
	apply_parallax(
		sprite, sprite_parallax_ref,
		sprite_parallax_distance_vec,
		sprite_parallax_speed, delta,
		sprite_parallax_offset
	)
	apply_parallax(
		light, light_parallax_ref,
		light_parallax_distance_vec,
		light_parallax_speed, delta,
		light_parallax_offset
	)
	apply_parallax(
		background, background_parallax_ref,
		background_parallax_distance_vec,
		background_parallax_speed, delta,
		background_parallax_offset
	)

func _input(event: InputEvent) -> void:
	if allow_progress and stage.is_playing():
		if event.is_action_pressed(&"progress"):
			if event is InputEventMouse:
				if !is_mouse_on_config():
					stage.progress()
			else:
				stage.progress()

func apply_parallax(
	object : CanvasItem,
	object_reference : CanvasItem,
	distance_vec : Vector2,
	power : float,
	delta : float,
	offset : Vector2 = Vector2()
	) -> void:
	if object.visible:
		var distance_max := Vector2.ZERO.distance_to(distance_vec)
		var distance: float = 0.0
		
		object_reference.position = (
			distance_vec * viewport_mouse_direction * viewport_mouse_distance
		) + offset
		
		distance = remap(
			object.position.distance_to(object_reference.position),
			0.0, distance_max,
			0.0, 1.0
		)
		
		object.position = object.position.move_toward(
			object_reference.position,
			delta * power * ease(distance, 0.2)
		)
	

#region NOTE: User name prompt
# 玩家名输入
func _on_user_name_input_text_changed() -> void:
	user_name_confirm.disabled = user_name_input.text.is_empty()
	user_name_confirm.modulate.a = 0.0 if\
		user_name_confirm.disabled else\
		1.0

# 玩家名输入后隐藏输入菜单
func _on_user_name_confirm_pressed() -> void:
	if !user_name_input.text.is_empty():
		$UI/Control/Options/UserName.visible = false
		user_name_confirm.disabled = true
	
	await tree.create_timer(2.9).timeout
	
	options.visible = false
	$UI/Control/DialogueLabelContainer.visible = true
	dialogue_label_container.visible = true
	stage.start(dialogue)
	timer_elapsed_second.start(1.0)
	options.queue_free()

#endregion

#region NOTE: Dialogue flow
func anim(anim_name: String) -> void:
	caller_node_anim.play(anim_name)

func face(expression: String) -> void:
	if expression != face_current.name:
		face_tween = create_tween().bind_node(self).set_parallel(true)
		
		face_tween.tween_property(
			face_current, ^"modulate:a", 0.0, 0.5
			).set_ease(Tween.EASE_OUT)
			
		face_current = faces[expression]
		
		face_tween.tween_property(
			face_current, ^"modulate:a", 1.0, 0.5
		).set_ease(Tween.EASE_OUT)
	
func trans(trans_name: String) -> void:
	caller_node_trans.play(trans_name)
	
func glitch_1() -> void:
	shader_glitch_overlay.visible = true
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_power", 0.01
	)
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_color_rate", 0.01
	)

func glitch_2() -> void:
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_power", 0.025
	)
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_color_rate", 0.015
	)

func glitch_3() -> void:
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_power", 0.05
	)
	shader_glitch_overlay.material.set_shader_parameter(
		&"shake_color_rate", 0.04
	)
#endregion

#region NOTE: User configurations
var mouse_on_config_state : Dictionary = {
	button_cc = false,
	panel_config_cc = false,
	panel_config_cc_2 = false,

	button_display_mode = false,

	slider_contrast = false,
	slider_brightness = false,

	spinbox_font_size = false,
	spinbox_letter_spacing = false,
	spinbox_bg_opacity = false,

	history_button = false,
}

func set_mouse_on_config_state(config_ui: String, state: bool) -> void:
	mouse_on_config_state[config_ui] = state	

func is_mouse_on_config() -> bool:
	for config_ui: String in mouse_on_config_state:
		if mouse_on_config_state[config_ui]:
			return true
	return false

func initialize_config_ui() -> void:
	for config_ui: String in mouse_on_config_state:
		var config_node: Control = get(config_ui)
		config_node.mouse_entered.connect(
			set_mouse_on_config_state.bind(config_ui, true))
		config_node.mouse_exited.connect(
			set_mouse_on_config_state.bind(config_ui, false))
	
	# cc动画播放
	button_cc.pressed.connect(_on_button_cc_pressed)
	
	# 全屏功能
	button_display_mode.pressed.connect(_on_button_display_mode_pressed)
	button_display_mode.mouse_entered.connect(_on_button_display_mode_mouse_entered)
	button_display_mode.mouse_exited.connect(_on_button_display_mode_mouse_exited)
	
	# 对比度与亮度拉条
	slider_contrast.value_changed.connect(_on_slider_contrast_value_changed)
	slider_brightness.value_changed.connect(_on_slider_brightness_value_changed)
	
	# 聊天框字体、间距、背景透明度
	spinbox_font_size.value_changed.connect(_on_spinbox_font_size_value_changed)
	spinbox_letter_spacing.value_changed.connect(_on_spinbox_letter_spacing_value_changed)
	spinbox_bg_opacity.value_changed.connect(_on_spinbox_bg_opacity_value_changed)
	
	# cc
	panel_config_cc_animation_player.animation_started.connect(
		_on_panel_config_cc_animation_player_animation_started
	)
	panel_config_cc_animation_player.animation_finished.connect(
		_on_panel_config_cc_animation_player_animation_finished
	)
	
# 播放cc动画
func _on_button_cc_pressed() -> void:
	if !panel_config_cc_animation_player.is_playing():
		if not panel_config_cc.visible:
			panel_config_cc_animation_player.play(&"enter")
		else:
			panel_config_cc_animation_player.play(&"exit")

# 全屏功能
func _on_button_display_mode_pressed() -> void:
	is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if !is_fullscreen else
		DisplayServer.WINDOW_MODE_WINDOWED
	)
	
	is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	button_display_mode.text =\
		ICON.FULLSCREEN if !is_fullscreen else ICON.FULLSCREEN_OFF

# 鼠标移动到全屏图标时全屏提示字体显示功能
func _on_button_display_mode_mouse_entered() -> void:
	label_fullscreen.visible = !is_fullscreen
	label_windowed.visible = is_fullscreen

# 鼠标离开全屏图标时全屏提示字体显示功能
func _on_button_display_mode_mouse_exited() -> void:
	label_fullscreen.visible = false
	label_windowed.visible = false

# 对比度条映射
func _on_slider_contrast_value_changed(value : float) -> void:
	environment.adjustment_contrast = remap(value, 0.0, 1.0, 0.25, 1.75)

# 亮度条映射
func _on_slider_brightness_value_changed(value: float) -> void:
	environment.adjustment_brightness = remap(value, 0.0, 1.0, 0.25, 1.75)

# 字体大小调整
func _on_spinbox_font_size_value_changed(value : float) -> void:
	font_size = int(value)
	dialogue_label.add_theme_font_size_override(&"normal_font_size", font_size)
	actor_label.add_theme_font_size_override(&"font_size", font_size)
	dialogue_label.update_image(
		"end_beep",
		RichTextLabel.UPDATE_SIZE,
		dlg_end_beep,font_size, font_size
	)

func _on_spinbox_letter_spacing_value_changed(value : float) -> void:
	dialogue_font_variation.spacing_glyph = int(value)

func _on_spinbox_bg_opacity_value_changed(value: float) -> void:
	value /= 100
	dialogue_stylebox.bg_color.a = value
	dialogue_stylebox.border_color.a = value

func _on_panel_config_cc_animation_player_animation_started(anim_name: String) -> void:
	if anim_name == &"enter":
		panel_config_cc.visible = true
		
func _on_panel_config_cc_animation_player_animation_finished(anim_name : StringName) -> void:
	if anim_name == &"exit":
		panel_config_cc.visible = false
#endregion

#region NOTE: Time handler
func update_time() -> void:
	elapsed_time_second += 1
	elapsed_minute = int((elapsed_time_second % 3600) / 60.0)
	elapsed_second = int(elapsed_time_second % 60)
	
	time_label.text = "00:%02d:%02d" % [elapsed_minute, elapsed_second]
#endregion

#region NOTE: Theatre control

func history_add(actor: String, body: String) -> void:
	var template: Control = history_dlg_template.duplicate()
	template.get_node(^"Actor").text = actor.format(stage.variables)
	template.get_node(^"BodyContainer/Body").text = body.format(stage.variables)
	template.visible = true
	
	history_container.add_child(template)

func _on_history_button_pressed() -> void:
	history_window.visible = !history_window.visible
	allow_progress = !history_window.visible
	history_scroll_bar.ratio = 1.0

func _on_stage_progressed() -> void:
	if panel_config_cc.visible and !panel_config_cc_animation_player.is_playing():
		panel_config_cc_animation_player.play(&"exit")
	
	actor_label.visible = actor_label.text != ""
	actor_label.text += ":"
	
	history_add(
		stage.get_current_line()["actor"].format({}),
		stage.get_current_line()["line"].format({})
	)
	
	dialogue_label.add_image(
		dlg_end_beep,
		font_size, font_size,
		Color.WHITE, INLINE_ALIGNMENT_CENTER,
		Rect2(), "end_beep"
	)
	
func _on_stage_finished() -> void:
	$UI/Control/Black.visible = true
	await tree.create_timer(2.4).timeout
	tree.quit()
#endregion

#region NOTE: Shaders

# 摄影机效果处理
const SHADER_CRT_CODES : String =\
	"""
	/*
	Shader from Godot Shaders - the free shader library.

	This shader is under CC0 license. Feel free to use, improve and 
	change this shader according to your needs and consider sharing 
	the modified result to godotshaders.com.

	Optimised and packed by @c64cosmin
	If you do use this please share it with me
	Would love to see what you're making with it <3

	It's a combination of these two shaders
	~godotshaders.com/shader/VHS-and-CRT-monitor-effect
	godotshaders.com/shader/crt-shader-with-realistic-blurring/

	CRT grille and rolling lines made by @c64cosmin
	Vignette and warping effect was made by pend00
	Scanlines are from "TimothyLottes" FROM SHADERTOY
	Then ported by AHOPNESS (@ahopness)
	https://www.shadertoy.com/view/MsjXzh
	*/

	shader_type canvas_item;

	uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

	uniform vec2 resolution = vec2(320.0, 180.0);

	uniform float scan_line_amount :hint_range(0.0, 1.0) = 1.0;
	uniform float warp_amount :hint_range(0.0, 5.0) = 0.1;
	uniform float noise_amount :hint_range(0.0, 0.3) = 0.03;
	uniform float interference_amount :hint_range(0.0, 1.0) = 0.2;
	uniform float grille_amount :hint_range(0.0, 1.0) = 0.1;
	uniform float grille_size :hint_range(1.0, 5.0) = 1.0;
	uniform float vignette_amount :hint_range(0.0, 2.0) = 0.6;
	uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
	uniform float aberation_amount :hint_range(0.0, 1.0) = 0.5;
	uniform float roll_line_amount :hint_range(0.0, 1.0) = 0.3;
	uniform float roll_speed :hint_range(-8.0, 8.0) = 1.0;
	uniform float scan_line_strength :hint_range(-12.0, -1.0) = -8.0;
	uniform float pixel_strength :hint_range(-4.0, 0.0) = -2.0;

	float random(vec2 uv){
		return fract(cos(uv.x * 83.4827 + uv.y * 92.2842) * 43758.5453123);
	}

	vec3 fetch_pixel(vec2 uv, vec2 off){
	vec2 pos = floor(uv * resolution + off) / resolution + vec2(0.5) / resolution;

	float noise = 0.0;
	if(noise_amount > 0.0){
		noise = random(pos + fract(TIME)) * noise_amount;
	}

	if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5){
		return vec3(0.0, 0.0, 0.0);
	}

	vec3 clr = texture(SCREEN_TEXTURE , pos, -16.0).rgb + noise;
	return clr;
	}

	// Distance in emulated pixels to nearest texel.
	vec2 Dist(vec2 pos){ 
	pos = pos * resolution;
	return - ((pos - floor(pos)) - vec2(0.5));
	}
		
	// 1D Gaussian.
	float Gaus(float pos, float scale){ return exp2(scale * pos * pos); }

	// 3-tap Gaussian filter along horz line.
	vec3 Horz3(vec2 pos, float off){
	vec3 b = fetch_pixel(pos, vec2(-1.0, off));
	vec3 c = fetch_pixel(pos, vec2( 0.0, off));
	vec3 d = fetch_pixel(pos, vec2( 1.0, off));
	float dst = Dist(pos).x;
	
	// Convert distance to weight.
	float scale = pixel_strength;
	float wb = Gaus(dst - 1.0, scale);
	float wc = Gaus(dst + 0.0, scale);
	float wd = Gaus(dst + 1.0, scale);
	
	// Return filtered sample.
	return (b * wb + c * wc + d * wd) / (wb + wc + wd);
	}

	// Return scanline weight.
	float Scan(vec2 pos, float off){
	float dst = Dist(pos).y;
	
	return Gaus(dst + off, scan_line_strength);
	}

	// Allow nearest three lines to effect pixel.
	vec3 Tri(vec2 pos){
	vec3 clr = fetch_pixel(pos, vec2(0.0));
	if(scan_line_amount > 0.0){
		vec3 a = Horz3(pos,-1.0);
		vec3 b = Horz3(pos, 0.0);
		vec3 c = Horz3(pos, 1.0);

		float wa = Scan(pos,-1.0);
		float wb = Scan(pos, 0.0);
		float wc = Scan(pos, 1.0);

		vec3 scanlines = a * wa + b * wb + c * wc;
		clr = mix(clr, scanlines, scan_line_amount);
	}
	return clr;
	}

	// Takes in the UV and warps the edges, creating the spherized effect
	vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	vec2 warped = uv + delta * delta_offset;
	return (warped - 0.5) / mix(1.0,1.2,warp_amount/5.0) + 0.5;
	}

	float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_amount);
	}

	vec3 grille(vec2 uv){
	float unit = PI / 3.0;
	float scale = 2.0*unit/grille_size;
	float r = smoothstep(0.5, 0.8, cos(uv.x*scale - unit));
	float g = smoothstep(0.5, 0.8, cos(uv.x*scale + unit));
	float b = smoothstep(0.5, 0.8, cos(uv.x*scale + 3.0*unit));
	return mix(vec3(1.0), vec3(r,g,b), grille_amount);
	}

	float roll_line(vec2 uv){
	float x = uv.y * 3.0 - TIME * roll_speed;
	float f = cos(x) * cos(x * 2.35 + 1.1) * cos(x * 4.45 + 2.3);
	float roll_line = smoothstep(0.5, 0.9, f);
	return roll_line * roll_line_amount;
	}

	void fragment(){
	vec2 pix = FRAGCOORD.xy;
	vec2 pos = warp(SCREEN_UV);
	
	float line = 0.0;
	if(roll_line_amount > 0.0){
		line = roll_line(pos);
	}

	vec2 sq_pix = floor(pos * resolution) / resolution + vec2(0.5) / resolution;
	if(interference_amount + roll_line_amount > 0.0){
		float interference = random(sq_pix.yy + fract(TIME));
		pos.x += (interference * (interference_amount + line * 6.0)) / resolution.x;
	}

	vec3 clr = Tri(pos);
	if(aberation_amount > 0.0){
		float chromatic = aberation_amount + line * 2.0;
		vec2 chromatic_x = vec2(chromatic,0.0) / resolution.x;
		vec2 chromatic_y = vec2(0.0, chromatic/2.0) / resolution.y;
		float r = Tri(pos - chromatic_x).r;
		float g = Tri(pos + chromatic_y).g;
		float b = Tri(pos + chromatic_x).b;
		clr = vec3(r,g,b);
	}
	
	if(grille_amount > 0.0)clr *= grille(pix);
	clr *= 1.0 + scan_line_amount * 0.6 + line * 3.0 + grille_amount * 2.0;
	if(vignette_amount > 0.0)clr *= vignette(pos);
	
	COLOR.rgb = clr;
	COLOR.a = 1.0;
	}
	"""

# 摄像机震动效果处理
const SHADER_GLITCH_CODES : String =\
	"""
	/*
		Glitch Effect Shader by Yui Kinomoto @arlez80

		MIT License
		Copyright (c) 2020-2022 Yui Kinomoto

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in
		all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
		THE SOFTWARE.
	*/

	shader_type canvas_item;
	uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

	// 振動の強さ
	const float shake_power = 0.03;
	// 振動率
	const float shake_rate = 1.0;
	// 振動速度
	const float shake_speed = 5.0;
	// 振動ブロックサイズ
	const float shake_block_size = 40.5;
	// 色の分離率
	uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.06;

	float random( float seed )
	{
		return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
	}

	void fragment( )
	{
		float enable_shift = float(
			random( trunc( TIME * shake_speed ) )
		<    shake_rate
		);

		vec2 fixed_uv = SCREEN_UV;
		fixed_uv.x += (
			random(
				( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
			+    TIME
			) - 0.5
		) * shake_power * enable_shift;

		vec4 pixel_color = textureLod( SCREEN_TEXTURE, fixed_uv, 0.0 );
		pixel_color.r = mix(
			pixel_color.r
		,    textureLod( SCREEN_TEXTURE, fixed_uv + vec2( shake_color_rate, 0.0 ), 0.0 ).r
		,    enable_shift
		);
		pixel_color.b = mix(
			pixel_color.b
		,    textureLod( SCREEN_TEXTURE, fixed_uv + vec2( -shake_color_rate, 0.0 ), 0.0 ).b
		,    enable_shift
		);
		COLOR = pixel_color;
	}
	"""

# 模糊化处理
const SHADER_BLUR_CODES : String =\
	"""
	shader_type canvas_item;

	uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
	uniform float lod: hint_range(0.0, 5) = 0.0;

	void fragment(){
	   vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	   COLOR = color;
	}
	"""
#endregion

#region Embedded Theatre plugin, with modifications - ff5b5b01d5bf9b9484348a90aa746f28024e3653 
class Dialogue extends Resource:
	## Compiled [Dialogue] resource.
	##
	## This is the resource that have been parsed and processed from the written [Dialogue].
	## Load it from the text file with [method Dialogue.load], or write it directly in script using [method Dialogue.new]
	## [codeblock]
	## var dlg = Dialogue.load("res://your_dialogue.dlg")
	##
	## var dlg = Dialogue.new("""
	##
	## Godette:
	##      "Hello world!"
	##
	## """)
	## [/codeblock]

	#region NOTE: Stored variables ---------------------------------------------------------------------

	@export_storage var _sets : Array[Dictionary] = []
	@export_storage var _source_path : String

	@export_storage var _used_variables : PackedStringArray = []
	@export_storage var _used_function_calls : Dictionary = {}
	#endregion

	#region NOTE: Loader/constructor -------------------------------------------------------------------
	## Returns [code]true[/code] if [param filename] use a valid written [Dialogue] file name ([code]*.dlg.txt[/code] or [code]*.dlg[/code]).
	static func is_valid_filename(filename : String) -> bool:
		return (
			(filename.ends_with(".dlg.txt") or filename.ends_with(".dlg"))
			and filename.get_file().is_valid_filename()
		)

	func _init(dlg_src : String = ""):
		_sets = []
		_used_variables = []
		var parser : DialogueParser

		if is_valid_filename(dlg_src):
			print("Parsing Dialogue from file: %s..." % dlg_src)

			if !FileAccess.file_exists(dlg_src):
				push_error("Unable to create Dialogue resource: '%s' does not exists" % dlg_src)

			else:
				_source_path = dlg_src
				parser = DialogueParser.new(FileAccess.get_file_as_string(dlg_src))
				_sets = parser.output
				_update_used_variables()
				_update_used_function_calls()

		elif DialogueParser.is_valid_source(dlg_src) and dlg_src.split("\n", false).size() >= 2:
			#var stack : Dictionary = get_stack()[-1]
			#print("Parsing Dialogue from raw string: %s:%d" % [
				#stack["source"], stack["line"]
			#])
			parser = DialogueParser.new(
				# BUG
				DialogueParser.normalize_indentation(dlg_src)
			)
			_sets = parser.output
			_update_used_variables()
			_update_used_function_calls()

			#_source_path = "%s:%d" % [stack["source"], stack["line"]]
			_source_path = "UwU"

	## Load written [Dialogue] file from [param path]. Use [method Dialogue.new] instead to create a written [Dialogue] directly in the script.
	static func load(path : String) -> Dialogue:
		if !is_valid_filename(path):
			printerr("Error loading Dialogue: '%s' is not a valid path/filename\n" % path,
				#Theatre.Debug.format_stack(get_stack())
				get_stack()
			)
			return null
		else:
			# Find filename alias
			var dlg_compiled := path

			if path.ends_with(".txt"):
				dlg_compiled = path.trim_suffix(".txt")

			if FileAccess.file_exists(dlg_compiled + ".res"):
				dlg_compiled += ".res"
			elif FileAccess.file_exists(dlg_compiled + ".tres"):
				dlg_compiled += ".tres"

			print("Getting Dialogue from file: %s..." % dlg_compiled)

			if FileAccess.file_exists(dlg_compiled):
				var dlg := load(dlg_compiled)
				return dlg as Dialogue
			else:
				push_warning("Compiled Dialogue '%s' doesn't exists. Creating new dialogue\n" % path)
				return Dialogue.new(path)
	#endregion

	#region NOTE: Utilities ----------------------------------------------------------------------------
	## Return all actors present in the compiled [Dialogue]. Optionally pass [param variables] to
	## insert variables used in the actor's name, otherwise it will return it as is (e.g. [code]{player_name}[/code])
	func get_actors(variables : Dictionary = {}) -> PackedStringArray:
		var output : PackedStringArray = []
		for n in _sets:
			var actor : String = n.actor.format(variables)
			if !output.has(actor):
				output.append(actor)
		return output

	## Return line count in the compiled [Dialogue].
	func get_length() -> int:
		return _sets.size()

	## Returns the path of written [Dialogue] source. If the [Dialogue] is created in a script using
	## [method Dialogue.new], it will returns the script's path and the line number from where the [Dialogue] is created
	## (e.g. [code]res://your_script.gd:26[/code]).
	func get_source_path() -> String:
		return _source_path

	## Returns word count in the compiled [Dialogue]. Optionally pass [param variables] to insert
	## variables used by the [Dialogue], otherwise it will count any variable placeholder as 1 word.
	func get_word_count(variables : Dictionary = {}) -> int:
		var output : int = 0
		var text : String
		for n in _sets:
			for chr in ":;.,{}-":
				text = n["line_raw"]\
					.format(variables)\
					.format(Stage._VARIABLES_BUILT_IN)\
					.replace(chr, " ")
			output += text.split(" ", false).size()
		return output

	func get_character_count(variables : Dictionary = {}) -> int:
		return humanize(variables).length()
		

	func get_function_calls() -> Dictionary:
		return _used_function_calls

	func _update_used_function_calls() -> void:
		for n : Dictionary in _sets:
			for m : Dictionary in n["func"]:
				if !_used_function_calls.has(m["caller"]):
					_used_function_calls[m["caller"]] = {}

				_used_function_calls[m["caller"]][m["ln_num"]] = {
					"name": m["name"],
					"args": m["args"],
				}

	## Gets all variables used in the written [Dialogue].
	func get_variables() -> PackedStringArray:
		return _used_variables

	func _update_used_variables() -> void:
		for n : Dictionary in _sets:
			for m : String in n["vars"]:
				if not m in _used_variables:
					_used_variables.append(m)

	## Returns the human-readable string of the compiled [Dialogue]. This will return the [Dialogue]
	## without the Dialogue tags and/or BBCode tags. Optionally, insert the variables used by passing it to [param variables].
	func humanize(variables : Dictionary = {}) -> String:
		return _strip(variables, true)

	func _strip(
		variables : Dictionary = {},
		exclude_actors : bool = false,
		exclude_newline : bool = false
		) -> String:
		var output := ""
		var newline : String = "" if exclude_newline else "\n"

		for n in _sets:
			if !exclude_actors:
				output += n.actor + ":" + newline

			output += "    " + n.line + newline + newline

		# Strip BBCode tags
		var regex_bbcode := RegEx.new()
		regex_bbcode.compile(DialogueParser.REGEX_BBCODE_TAGS)
		var regex_bbcode_match := regex_bbcode.search_all(output)
		for bb in regex_bbcode_match:
			output = output.replace(bb.strings[0], "")

		return output.format(variables)

	## Save the compiled [Dialogue] data as a JSON file to the specified [param path]. Returns [member OK] if successful.
	func to_json(path : String) -> Error:
		var file := FileAccess.open(path, FileAccess.WRITE)
		if FileAccess.get_open_error() == OK:
			file.store_string(
				JSON.stringify(_sets, "  ", true, true)
			)
		else:
			return FileAccess.get_open_error()
		file.close()
		return file.get_error()
	#endregion

class DialogueParser extends RefCounted: 
	var output : Array[Dictionary]

	const REGEX_DLG_TAGS :=\
		r"\{\s*(?<tag>\w+)\s*(\=\s*(?<arg>.+?)\s*)*\}"
	const REGEX_DLG_TAGS_NEWLINE :=\
		r"^\s*(?<tag>\w+)\=((?<arg>.+))*$"
	const REGEX_BBCODE_TAGS :=\
		r"(?<tag>[\[\/]+?\w+)[^\[\]]*?\]"
	const REGEX_FUNC_CALL :=\
		r"(?<caller>\w+)\.(?<name>\w+)\((?<args>.*)\)$"
	const REGEX_PLACEHOLDER :=\
		r"\{(\w+?)\}"
	const REGEX_INDENT :=\
		r"(?<=\n{1})\s+"
	const REGEX_VALID_DLG :=\
		r"\n+\w+\:\n+\s+\w+"

	const SETS_TEMPLATE := {
		"actor": "",
		"line": "",
		"line_raw": "",
		"line_num": -1,
		"tags": {
			"delays": {
				#   pos,    delay(s)
				#   15,     5
			},
			"speeds": {
				#   pos,    scale(f)
				#   15:     1.2
			},
		},
		"func": [],
		"func_pos": {},
		"func_idx": [],
		"offsets": {
			#   start, end
			#   15: 20
		},
		"vars": [],
	}
	const FUNC_TEMPLATE := {
		"caller": "",
		"name": "",
		"args": [],
		"ln_num": 0,
	}

	const TAG_DELAY_ALIASES : PackedStringArray = [
		"DELAY", "WAIT", "D", "W"
	]
	const TAG_SPEED_ALIASES : PackedStringArray = [
		"SPEED", "SPD", "S"
	]

	const VARS_BUILT_IN_KEYS : PackedStringArray = ["n"]

	const BUILT_IN_TAGS : PackedStringArray = (
		TAG_DELAY_ALIASES +
		TAG_SPEED_ALIASES +
		VARS_BUILT_IN_KEYS
	)

	func _init(src : String = ""):
		output = []
		var dlg_raw : PackedStringArray = src.split("\n")

		var body_pos : int = 0
		var dlg_raw_size : int = dlg_raw.size()
		var newline_stack : int = 0

		var regex_func := RegEx.new();\
			regex_func.compile(REGEX_FUNC_CALL);\
			var regex_func_match : RegExMatch

		var regex_tags_newline := RegEx.new();\
			regex_tags_newline.compile(REGEX_DLG_TAGS_NEWLINE);\
			var regex_tags_newline_match : RegExMatch

		var regex_bbcode := RegEx.new();\
			regex_bbcode.compile(REGEX_BBCODE_TAGS);\
			var regex_bbcode_match : RegExMatch

		# Per raw string line
		for i in dlg_raw_size:
			var ln_num : int = i + 1
			var n := dlg_raw[i]
			var is_valid_line := !n.begins_with("#") and !n.is_empty()

			var current_processed_string : String = ""

			if is_valid_line and !is_indented(n) and n.strip_edges().ends_with(":"):
				#region NOTE: Create new Dialogue line -------------------------------------------------
				var setsl := SETS_TEMPLATE.duplicate(true)
				newline_stack = 0

				if dlg_raw_size < i + 1:
					printerr("Error: actor's name exists without a dialogue body")

				setsl["actor"] = n.strip_edges().trim_suffix(":")
				setsl["line_num"] = ln_num

				if setsl["actor"] == "_":
					setsl["actor"] = ""
				elif setsl["actor"].is_empty():
					if output.size() - 1 < 0:
						printerr("Warning: missing initial actor's name on line %d" % ln_num)
					else:
						setsl["actor"] = output[output.size() - 1]["actor"]

				output.append(setsl)
				body_pos = output.size() - 1
				#endregion

			elif n.strip_edges().is_empty():
				newline_stack += 1

			elif is_valid_line:
				current_processed_string = dlg_raw[i].strip_edges()

				regex_func_match = regex_func.search(current_processed_string)
				regex_tags_newline_match = regex_tags_newline.search(current_processed_string)
				regex_bbcode_match = regex_bbcode.search(current_processed_string)

				#region NOTE: Function calls -----------------------------------------------------------
				if regex_func_match != null:
					var func_dict := FUNC_TEMPLATE.duplicate(true)
					for func_n : String in [
						"caller", "name",
					]:
						func_dict[func_n] = regex_func_match.get_string(
							regex_func_match.names[func_n]
						)

					# Function arguments
					var args_raw := regex_func_match.get_string(
						regex_func_match.names["args"]
					).strip_edges()

					func_dict["ln_num"] = ln_num

					# Parse parameter arguments
					var args := Expression.new()
					var args_err := args.parse("[%s]" % args_raw)
					if args_err != OK:
						printerr("Error: '%s' when parsing arguments on function %s.%s(%s) on line %d" % [
							error_string(args_err),
							func_dict["caller"], func_dict["name"], args_raw, ln_num
						])

					func_dict["args"] = args.execute() as Array
					output[body_pos]["func"].append(func_dict)
				#endregion

				#region NOTE: Newline Dialogue tags ----------------------------------------------------
				elif is_regex_full_string(regex_tags_newline_match):
					output[body_pos]["line_raw"] += "{%s}" % current_processed_string
					output[body_pos]["line"] += "{%s}" % current_processed_string
				#endregion

				#region NOTE: Newline BBCode tags ------------------------------------------------------
				elif is_regex_full_string(regex_bbcode_match):
					output[body_pos]["line_raw"] += current_processed_string
					output[body_pos]["line"] += current_processed_string
				#endregion

				# Dialogue text body
				else:
					if newline_stack > 0:
						newline_stack += 1
					var dlg_body := "\n".repeat(newline_stack) + current_processed_string + " "
					newline_stack = 0

					# Append Dialogue body
					output[body_pos]["line_raw"] += dlg_body
					output[body_pos]["line"] += dlg_body

		# Per dialogue line
		for n in output.size():
			var body : String = ""

			if output[n]["line_raw"].is_empty():
				printerr("Warning: empty dialogue body for '%s' on line %d" % [
					output[n]["actor"], output[n]["line_num"]
				])

			else:
				var parsed_tags := parse_tags(output[n]["line_raw"])

				for tag : String in SETS_TEMPLATE["tags"].keys():
					output[n]["tags"][tag].merge(parsed_tags["tags"][tag])

				var regex_tags := RegEx.new()
				regex_tags.compile(REGEX_DLG_TAGS)
				var regex_tags_match := regex_tags.search_all(output[n]["line_raw"])

				body = output[n]["line_raw"]
				for tag in regex_tags_match:
					body = body.replace(tag.strings[0], "")

				output[n]["vars"] = parsed_tags["variables"]
				output[n]["func_pos"] = parsed_tags["func_pos"]
				output[n]["func_idx"] = parsed_tags["func_idx"]

			output[n]["line"] = body

		regex_func.clear()
		regex_tags_newline.clear()
		regex_bbcode.clear()

		regex_func = null
		regex_tags_newline = null
		regex_bbcode = null

		regex_func_match = null
		regex_tags_newline_match = null
		regex_bbcode_match = null

		dlg_raw.clear()

	## Check if [param string] is indented with tabs or spaces.
	func is_indented(string : String) -> bool:
		return string != string.lstrip(" \t")

	## Check if [param string] is written in a valid Dialogue string format/syntax or not.
	static func is_valid_source(string : String) -> bool:
		var regex := RegEx.new()
		regex.compile(REGEX_VALID_DLG)
		var res := regex.search(string)

		regex.clear()
		regex = null
		return res == null

	# BUG
	## Normalize indentation of the Dialogue raw string.
	static func normalize_indentation(string : String) -> String:
		var regex := RegEx.new()
		var indents : Array[int] = []

		regex.compile(REGEX_INDENT)

		for n in regex.search_all(string):
			var length := n.get_string(1).length()
			if !indents.has(length):
				indents.append(n.get_string(1).length())

		if indents.max() > 0:
			var spc := ""
			for n in indents.min():
				spc += " "
			string = string.replacen("\n" + spc, "\n")

		regex.clear()
		regex = null
		indents.clear()

		return string

	# 😭😭😭
	static func parse_tags(string : String) -> Dictionary:
		var output_loc : Dictionary = {}
		var vars : PackedStringArray = []
		var tags : Dictionary = SETS_TEMPLATE["tags"].duplicate(true)
		var func_pos : Dictionary = {}
		var func_idx : PackedInt64Array = []

		var regex_tags := RegEx.new()
		regex_tags.compile(REGEX_DLG_TAGS)

		# BBCode ===============================================================
		var bb_data : Dictionary = {}
		# Strip all Dialogue tags to process BBCode tags
		var stripped_tags := regex_tags.sub(string, "", true)

		var regex_bbcode := RegEx.new()
		regex_bbcode.compile(REGEX_BBCODE_TAGS)
		var regex_bbcode_match := regex_bbcode.search_all(stripped_tags)

		var bbcode_pos_offset : int = 0

		# Strip and log BBCode tags
		for bb in regex_bbcode_match:
			var bb_start : int = bb.get_start() - bbcode_pos_offset
			#var bb_end : int = bb.get_end() - bbcode_pos_offset

			bb_data[bb_start] = {
				"content" : bb.strings[0],
				"img" : false,
			}

			string = string.replace(bb.strings[0], "")

		# Dialogue tags ========================================================
		var regex_tags_match := regex_tags.search_all(string)
		var tag_pos_offset : int = 0

		var regex_int_func := RegEx.new()
		regex_int_func.compile(r"\d+")

		for b in regex_tags_match:
			var string_match := b.strings[0]

			var tag_pos : int = b.get_start() - tag_pos_offset
			var tag_key := b.get_string("tag").to_upper()
			var tag_key_l := b.get_string("tag")
			var tag_value := b.get_string("arg")

			if TAG_DELAY_ALIASES.has(tag_key):
				tags["delays"][tag_pos] = float(tag_value)
			elif TAG_SPEED_ALIASES.has(tag_key):
				tags["speeds"][tag_pos] = float(
					1.0 if tag_value.is_empty() else float(tag_value)
				)

			if !(tag_key_l in VARS_BUILT_IN_KEYS):
				string = string.replace(string_match, "")

			var regex_int_func_match := regex_int_func.search(tag_key_l)
			if regex_int_func_match != null:
				var idx = regex_int_func_match.strings[0].to_int()
				func_pos[tag_pos] = idx

				if !func_idx.has(idx):
					func_idx.append(idx)

			if !BUILT_IN_TAGS.has(tag_key) and\
				!(tag_key_l in vars) and\
				(regex_int_func_match == null):
				vars.append(tag_key_l)

			tag_pos_offset += string_match.length()

		# Insert back BBCodes ==================================================
		for bb in bb_data:
			string = string.insert(bb, bb_data[bb]["content"])

			if bb_data[bb]["img"]:
				string = string.erase(bb_data[bb]["img-pos"], 1)
				string = string.insert(
					bb_data[bb]["img-pos"],
					bb_data[bb]["img-res"],
				)

		output_loc["tags"] = tags
		output_loc["string"] = string
		output_loc["func_pos"] = func_pos
		output_loc["func_idx"] = func_idx
		output_loc["variables"] = vars

		#region CLEANUP
		regex_tags.clear()
		regex_tags = null
		regex_tags_match.clear()

		regex_bbcode.clear()
		regex_bbcode = null
		regex_bbcode_match.clear()

		regex_int_func.clear()
		regex_int_func = null
		#endregion

		return output_loc

	## Format Dialogue body at [param pos] position with [member Stage.variables], and update the positions of the built-in tags.
	## Return the formatted string.
	static func update_tags_position(dlg : Dialogue, pos : int, vars : Dictionary) -> void:
		var dlg_str : String = dlg._sets[pos]["line_raw"].format(vars)
		for n in ["delays", "speeds"]:
			dlg._sets[pos]["tags"][n].clear()

		var parsed_tags := parse_tags(dlg_str)

		dlg._sets[pos]["tags"] = parsed_tags["tags"]
		dlg._sets[pos]["line"] = parsed_tags["string"]
		dlg._sets[pos]["vars"] = parsed_tags["variables"]
		dlg._sets[pos]["func_pos"] = parsed_tags["func_pos"]
		dlg._sets[pos]["func_idx"] = parsed_tags["func_idx"]

	static func is_regex_full_string(regex_match : RegExMatch) -> bool:
		if regex_match == null:
			return false
		return regex_match.get_start() == 0 and\
			regex_match.get_end() == regex_match.subject.length()

class DialogueLabel extends RichTextLabel:
	## Control node built for displaying [Dialogue].
	##
	## A [RichTextLabel] inherited node that are built for displaying and rendering [Dialogue] lines.
	## [DialogueLabel] has a partial support for BBCode tags, as for now, the [code][img][/code] tag are not supported.
	## [member RichTextLabel.bbcode_enabled] will always be [code]true[/code].

	## Each string character will be drawn every [param characters_draw_tick] seconds
	@export var characters_draw_tick : float = .015
	var _characters_draw_tick_scaled : float

	#region NOTE: Setup --------------------------------------------------------------------------------
	var _current_stage : Stage:
		set = set_stage,
		get = get_stage

	## Returns the [Stage] that is currently controling the [DialogueLabel].
	func get_stage() -> Stage:
		return _current_stage

	## Set the [Stage] that will be used to control the [DialogueLabel]. If there's already a [Stage]
	## set, this will remove the previous [member Stage.dialogue_label].
	## [br][br]
	## [b]Note:[/b] [member Stage.dialogue_label] will be set automatically when you assign
	## a [DialogueLabel] to the [Stage] on the inspector.
	func set_stage(stage : Stage) -> void:
		if _current_stage != null:
			_current_stage.dialogue_label = null
		if stage != null:
			_current_stage = stage
			if !_current_stage.skipped.is_connected(_on_stage_skipped):
				_current_stage.skipped.connect(_on_stage_skipped)
		else:
			if _current_stage.skipped.is_connected(_on_stage_skipped):
				_current_stage.skipped.disconnect(_on_stage_skipped)
			_current_stage = null

	func _validate_property(property: Dictionary) -> void:
		if property["name"] == "bbcode_enabled":
			bbcode_enabled = true
			property["usage"] = PROPERTY_USAGE_NO_EDITOR

	func _enter_tree() -> void:
		if !Engine.is_editor_hint():
			_delay_timer = Timer.new()
			_characters_ticker = Timer.new()

			text = ""
			bbcode_enabled = true

			_delay_timer.autostart = false
			_delay_timer.one_shot = true
			_delay_timer.timeout.connect(_delay_timer_timeout)
			add_child(_delay_timer)

			_characters_ticker.autostart = false
			_characters_ticker.one_shot = false
			_characters_ticker.timeout.connect(_characters_ticker_timeout)
			add_child(_characters_ticker)
	#endregion

	#region NOTE: Signals ------------------------------------------------------------------------------
	## Emitted when the text or the [Dialogue] line has finished rendering.
	signal text_rendered(rendered_text : String)

	## Emitted everytime a character drawn.
	signal character_drawn
	#endregion

	#region NOTE: Core & rendering ---------------------------------------------------------------------
	var _is_rendering := false

	var _delay_queue : PackedInt64Array = []
	var _speed_queue : PackedInt64Array = []
	var _func_queue : PackedInt64Array = []

	var _delay_timer : Timer
	var _characters_ticker : Timer

	## Start the rendering of the current [Dialogue] line text.
	func start_render() -> void:
		_delay_timer.one_shot = true

		_characters_draw_tick_scaled = characters_draw_tick /\
			_current_stage.speed_scale_global / _current_stage.speed_scale
		_characters_ticker.start(_characters_draw_tick_scaled)

		_delay_queue = _current_stage._current_dialogue_set["tags"]["delays"].keys()
		_speed_queue = _current_stage._current_dialogue_set["tags"]["speeds"].keys()
		_func_queue = _current_stage._current_dialogue_set["func_pos"].keys()
		_is_rendering = true

	## Stop the process of rendering text, and clear the [DialogueLabel] text.
	func clear_render() -> void:
		_delay_timer.stop()
		_characters_ticker.stop()

		visible_ratio = 0

		_delay_queue.clear()
		_speed_queue.clear()
		_func_queue.clear()

		_is_rendering = false

	## Returns [code]true[/code] if the [DialogueLabel] is in the process of rendering text.
	func is_rendering() -> bool:
		return _is_rendering

	## Restart text rendering. Written [Dialogue] functions will also be re-called.
	func rerender() -> void:
		clear_render()
		start_render()

	func _characters_ticker_timeout() -> void:
		if !_func_queue.is_empty():
			if _func_queue[0] == visible_characters:
				if _current_stage.allow_func:
					_current_stage._call_functions(
						_current_stage._current_dialogue_set["func"][
							_current_stage._current_dialogue_set["func_pos"][_func_queue[0]]
						]
					)
				_func_queue.remove_at(0)

		if !_delay_queue.is_empty():
			if _delay_queue[0] == visible_characters:
				_characters_ticker.stop()
				_delay_timer.start(
					_current_stage._current_dialogue_set["tags"]["delays"][_delay_queue[0]]
				)
				return

		if !_speed_queue.is_empty():
			if _speed_queue[0] == visible_characters:
				_characters_ticker.wait_time = _characters_draw_tick_scaled /\
					_current_stage.speed_scale_global /\
					_current_stage._current_dialogue_set["tags"]["speeds"][_speed_queue[0]]
				_characters_ticker.start()
				_speed_queue.remove_at(0)

		visible_characters += 1

		if visible_ratio >= 1.0:
			_characters_ticker.stop()
			_is_rendering = false
			text_rendered.emit(text)
			_characters_ticker.wait_time = _characters_draw_tick_scaled

		if _current_stage._step == -1:
			clear_render()

		character_drawn.emit()

	func _delay_timer_timeout() -> void:
		_delay_queue.remove_at(0)
		_characters_ticker.start()

	func _on_stage_skipped() -> void:
		for f in _func_queue:
			_current_stage._call_functions(
				_current_stage._current_dialogue_set["func"][
					_current_stage._current_dialogue_set["func_pos"][f]
				]
			)
		text_rendered.emit(text)
	#endregion

	func _exit_tree() -> void:
		if !Engine.is_editor_hint():
			_delay_queue.clear()
			_speed_queue.clear()
			_func_queue.clear()

class Stage extends Node:
	## Run, control, and configure [Dialogue], and reference UIs and Nodes that will be used to display the [Dialogue].
	##
	## [Stage] connects your [Dialogue] and the [DialogueLabel]. This is where you configure and control
	## your [Dialogue], manage variables, and set up function calls from your written [Dialogue].

	#region NOTE: Configurations & stored variables ----------------------------------------------------

	## Optional [Label] node that displays actors of the current line of [member current_dialogue].
	@export var actor_label : Label = null

	## [DialogueLabel] node that displays the [Dialogue] line body. This is [b]required[/b] to be set before playing or running [Dialogue].
	@export var dialogue_label : RichTextLabel = null

	@export_group("Configurations")

	## Allow skipping [Dialogue] or the [member dialogue_label] text rendering. See [method progress].
	@export var allow_skip := true

	## Allow cancelling/stopping [Dialogue] with [method cancel] or [method reset].
	@export var allow_cancel := true

	## Allow calling functions in the written [Dialogue].
	@export var allow_func := true

	static var speed_scale_global : float = 1.0

	## The speed scale of the [member dialogue_label] text rendering.
	@export_range(0.01, 3.0, 0.01) var speed_scale : float = 1.0:
		set(s):
			speed_scale = s
			if dialogue_label != null:
				dialogue_label._characters_draw_tick_scaled =\
					dialogue_label.characters_draw_tick / s
				dialogue_label._characters_ticker.wait_time =\
					dialogue_label._characters_draw_tick_scaled

	@export_group("Dialogues")

	## [Dialogue] resource to be used by [Stage]. Set it by assigning your [Dialogue],
	## or by passing the [Dialogue] to [method start].
	## [br][br]
	## [b]Note:[/b] [member current_dialogue] will be set to [code]null[/code],
	## when [method cancel] or [method reset] is called with [param keep_dialogue]
	## set to [code]false[/code] (default), [i]and[/i] when [Stage] is finished.
	@export_storage var current_dialogue : Dialogue:
		set(new_dlg):
			if !is_playing():
				current_dialogue = new_dlg
				if !variables.is_empty() and new_dlg != null:
					for n in current_dialogue._sets.size():
						DialogueParser.update_tags_position(
							current_dialogue, n, variables
						)
			else:
				push_error("Cannot set Dialogue: there's a Dialogue running")

	@export_storage var _caller : Dictionary = {}

	#endregion

	#region NOTE: Variable related ---------------------------------------------------------------------
	## [Dictionary] of user-defined variables that will be used by [Stage].
	##
	## [b]Note:[/b] Avoid modifying [member variables] directly, use methods such as [method add_variable],
	## [method merge_variables], [method remove_variable], and [method clear_variables] instead.
	@export var variables : Dictionary = {}:
		set(new_var):
			variables = new_var

			if is_playing():
				_update_display()

			_update_variables_dialogue()
		get:
			return variables

	func _update_variables_dialogue() -> void:
		_variables_all.clear()
		_variables_all.merge(variables, true)
		_variables_all.merge(_VARIABLES_BUILT_IN, true)
		if current_dialogue != null:
			var stepn := clampi(_step, 0, current_dialogue._sets.size())
			DialogueParser.update_tags_position(
				current_dialogue, stepn, variables
			)

			if is_playing():
				_dialogue_full_string = _current_dialogue_set["line"]
				_update_display()

				if dialogue_label != null:
					dialogue_label.rerender()

	const _VARIABLES_BUILT_IN : Dictionary = {
		"n" : "\n",
	}
	var _variables_all : Dictionary = {}

	## Set a variable used in the written [Dialogue].
	## [br][br]
	## See also [method merge_variables], and [method remove_variable], and [method clear_variables].
	func set_variable(var_name : String, value) -> void:
		variables[var_name] = value
		_update_variables_dialogue()

	## Set multiple variables in a [Dictionary] used in the written [Dialogue]. Will overwrite
	## same variable name with the new one.
	##
	## [br][br]
	## See also [method set_variable], [method remove_variable], and [method clear_variables].
	func merge_variables(vars : Dictionary) -> void:
		variables.merge(vars, true)
		_update_variables_dialogue()

	## Remove a variable used in the written [Dialogue].
	## [br][br]
	## See also [method set_variable], [method merge_variables], and [method clear_variables].
	func remove_variable(var_name : String) -> void:
		variables.erase(var_name)
		_update_variables_dialogue()

	## Remove all variable in [member variables].
	## [br][br]
	## See also [method set_variable], [method merge_variables], and [method remove_variable].
	func clear_variables() -> void:
		variables.clear()
		_update_variables_dialogue()

	#endregion

	#region NOTE: Function calls related ---------------------------------------------------------------
	@export var caller_nodes : Array[Node] = []

	static var _caller_built_in : Dictionary = {}
	var _caller_all : Dictionary = {}

	func _update_caller() -> void:
		_caller_all = _caller.merged(_caller_built_in, true)

	## Return user-defined callers that will be used in the written [Dialogue].
	func get_callers() -> Dictionary:
		return _caller

	## Add function caller used in the written [Dialogue].
	## If [param object] is a [Node], it will be removed automatically when its freed.
	## [br][br]
	## See also [method remove_caller], and [method clear_caller].
	func add_caller(id : String, object : Object) -> void:
		_caller[id] = object
		if object is Node:
			object.tree_exited.connect(remove_caller.bind(id))
		_update_caller()

	## Remove function caller used in the written [Dialogue].
	## [br][br]
	## See also [method add_caller], and [method clear_caller].
	func remove_caller(id : String) -> void:
		if !_caller.has(id):
			push_error("Cannot remove caller: caller '%s' doesn't exists" % id)
		else:
			if _caller[id] is Node:
				if (_caller[id] as Node).tree_exited\
					.is_connected(remove_caller.bind(id)):
					(_caller[id] as Node).tree_exited.disconnect(
						remove_caller.bind(id)
					)
			_caller.erase(id)
		_update_caller()

	## Remove all function callers.
	## [br][br]
	## See also [method add_caller], and [method remove_caller].
	func clear_callers() -> void:
		for id : String in _caller:
			if _caller[id] is Node:
				if (_caller[id] as Node).tree_exited\
					.is_connected(remove_caller.bind(id)):
					(_caller[id] as Node).tree_exited.disconnect(
						remove_caller.bind(id)
					)
		_caller.clear()
		_update_caller()

	func _call_functions(func_data : Dictionary) -> void:
		if allow_func:
			var f := func_data
			print("Calling function: %s.%s()" % [
				f["caller"], f["name"],
			])
			if !_caller_all.has(f["caller"]):
				printerr("Error @%s:%d - caller '%s' doesn't exists" % [
					"UwU", f["ln_num"],
					f["caller"],
				])
			else:
				if !_caller_all[f["caller"]].has_method(f["name"]):
					printerr("Error @%s:%d - function '%s.%s()' doesn't exists" % [
						"UwU", f["ln_num"],
						f["name"], f["caller"]
					])
				else:
					_caller_all[f["caller"]].callv(f["name"], f["args"])

	func _execute_functions() -> void:
		if allow_func:
			for n in _current_dialogue_set["func"].size():
				# do not call positional functions
				if not n in _current_dialogue_set["func_idx"]:
					_call_functions(_current_dialogue_set["func"][n])

	#endregion

	#region NOTE: Signals ------------------------------------------------------------------------------
	## Emitted when the [Dialogue] started.
	signal started
	## Emitted when the [Dialogue] reached the end.
	signal finished

	## Emitted when the [Dialogue] progressed using [method progress]. This signal is
	## also emitted when the [Dialogue] is started using [member start].
	signal progressed
	## Same as [signal progressed], but with the line number and line data of the [Dialogue] passed.
	signal progressed_at(line : int, line_data : Dictionary)

	## Emitted when the [Dialogue] progress is skipped. See [method progress].
	signal skipped
	## Same as [signal skipped], but with the line number and line data of the [Dialogue] passed.
	signal skipped_at(line : int, line_data : Dictionary)

	## Emitted when the [Dialogue] progress is cancelled using [method cancel] or [method reset].
	signal cancelled
	## Same as [signal cancelled], but with the line number and line data of the [Dialogue] passed.
	signal cancelled_at(line : int, line_data : Dictionary)

	#endregion

	#region NOTE: Utilities ----------------------------------------------------------------------------
	func get_line() -> int:
		return _step

	## Return the current [Dialogue] line data. Will return empty [Dictionary], if [member current_dialogue] is
	## [code]null[/code], or if [Stage] is not currently running/playing any [Dialogue].
	func get_current_line() -> Dictionary:
		if current_dialogue != null and _step >= 0:
			return current_dialogue._sets[_step]
		return {}

	## Returns [code]true[/code] if [Stage] is currently playing/running a [Dialogue].
	func is_playing() -> bool:
		return _step >= 0

	## Returns [PackedStringArray] of unused variables in [member current_dialogue]. It
	## compares [method Dialogue.get_variables] and [member variables] to find unused variables.
	func get_unused_variables() -> PackedStringArray:
		if current_dialogue == null:
			return []

		var output : PackedStringArray = []
		var used_vars := variables.keys()

		for n in current_dialogue.get_variables():
			if not n in used_vars:
				output.append(n)

		return output

	func get_invalid_functions() -> Dictionary:
		if current_dialogue == null:
			return {}

		var output : Dictionary = {}
		var used_funcs := current_dialogue.get_function_calls()
		var curr_caller := _caller.keys()

		for n in used_funcs:
			if not n in curr_caller:
				if !output.has("no_caller"):
					output["no_caller"] = []

				output["no_caller"].append(n)

			else:
				for m in used_funcs[n]:
					if !(_caller[n] as Object).has_method(&"%s" % used_funcs[n][m]["name"]):
						if !output.has("no_method"):
							output["no_method"] = []

						output["no_method"].append(
							"%s.%s" % [n, used_funcs[n][m]["name"]]
						)

		return output

	#endregion

	#region NOTE: Core & Dialogue controls -------------------------------------------------------------
	var _current_dialogue_length : int
	var _current_dialogue_set : Dictionary
	var _dialogue_full_string : String = ""

	# Current progress of the Dialogue.
	var _step : int = -1

	## Start the [Dialogue] specified in [param dialogue], if [param dialogue] is [code]null[/code], 
	## [member current_dialogue] will be used instead.
	## Optionally set [param to_line] parameter to jump to a specific line when the [Dialogue] start.
	func start(dialogue : Dialogue = null, to_line : int = 0) -> void:
		if is_playing():
			push_warning("Theres already a running Dialogue!")
		else:
			if dialogue != null:
				current_dialogue = dialogue

			if current_dialogue == null:
				push_error("Cannot start the Stage: `dialogue` is null")
			else:
				print("Starting Dialogue: %s..." % current_dialogue.get_source_path())
				_current_dialogue_length = current_dialogue._sets.size()

				_step = to_line - 1
				_progress_forward()
				started.emit()

	## Reset, and start over the [Dialogue] progres. Functions will be re-called. And [signal started] will also be emitted.
	func restart() -> void:
		if current_dialogue == null:
			push_error("Cannot restart Stage: no current Dialogue")
		else:
			_reset_progress(true)
			start()

	var _at_end := false

	## Progress the [Dialogue].
	## Calling [method progress] with [param skip_render] set to [code]false[/code] while the
	## [member dialogue_label] is still rendering the text, will force it to finish the rendering instead of progressing. [signal skipped] will also be emitted.
	## [br][br]
	## If the parameter [param skip_render] is set to [code]true[/code], text rendering by the [DialogueLabel] will be
	## skipped, and immediately progress to the next Dialogue line. [signal skipped] will also be emitted.
	## [br][br]
	## If [member allow_skip] is set to [code]false[/code]. Regardless of whether [param skip_render]
	## is [code]true[/code] or [code]false[/code], the [Dialogue] won't progress until [member dialogue_label] has finished rendering.
	func progress(skip_render : bool = false) -> void:
		if current_dialogue == null:
			push_error("Failed to progress Stage: no Dialogue present")
		elif dialogue_label == null:
			push_error("Failed to progress Stage: no DialogueLabel")
		else:
			_at_end = _step + 1 >= _current_dialogue_length

			if dialogue_label._is_rendering:
				if !skip_render:
					if allow_skip:
						_progress_skip()
				else:
					if allow_skip:
						if _at_end:
							_reset_progress()
						else:
							_progress_forward()
			else:
				if _at_end:
					_reset_progress()
				else:
					_progress_forward()

	func _progress_skip() -> void:
		dialogue_label.clear_render()
		dialogue_label.visible_ratio = 1.0
		skipped.emit()
		skipped_at.emit(_step, _current_dialogue_set)

	func _progress_forward() -> void:
		dialogue_label.clear_render()

		_step += 1
		_current_dialogue_set = current_dialogue._sets[_step]
		_dialogue_full_string = _current_dialogue_set["line"]

		_execute_functions()
		_update_display()

		dialogue_label.start_render()
		progressed.emit()
		progressed_at.emit(_step, _current_dialogue_set)

	## Stop the [Dialogue], clear [member dialogue_label] text render, and reset everything.
	## Require [member allow_cancel] to be [code]true[/code]. Optionally, pass [code]true[/code] to keep the [member current_dialogue].
	func cancel(keep_dialogue : bool = false) -> void:
		if !allow_cancel:
			print("Resetting Dialogue is not allowed")
		else:
			if current_dialogue != null:
				_reset_progress(keep_dialogue)
			else:
				push_error("Cannot cancel Stage: no Dialogue present")

	## Alias for method [method cancel].
	func reset(keep_dialogue : bool = false) -> void:
		cancel(keep_dialogue)

	func _reset_progress(keep_dialogue : bool = false) -> void:
		print("Resetting Dialogue: %s..." % current_dialogue.get_source_path())

		if _step >= _current_dialogue_length - 1:
			finished.emit()
		else:
			cancelled.emit()
			cancelled_at.emit(_step,
				current_dialogue._sets[_step] if _step != -1 else\
				DialogueParser.SETS_TEMPLATE
			)

		_step = -1

		if actor_label != null:
			actor_label.text = ""

		dialogue_label.clear_render()
		dialogue_label.text = ""

		if !keep_dialogue:
			current_dialogue = null

	func _update_display() -> void:
		if actor_label != null:
			actor_label.text = _current_dialogue_set["actor"].format(_variables_all)
		if dialogue_label != null:
			dialogue_label.text = _dialogue_full_string.format(_variables_all)

	#endregion

	func _enter_tree() -> void:
		_update_caller()

		if dialogue_label != null:
			dialogue_label._current_stage = self

		if !variables.is_empty():
			_update_variables_dialogue()

		await get_tree().current_scene.ready
		for node in caller_nodes:
			if node != null:
				add_caller("%s" % node.name, node)

	func _exit_tree() -> void:
		if dialogue_label._current_stage == self:
			dialogue_label._current_stage = null

		actor_label = null
		dialogue_label = null
		current_dialogue = null

		caller_nodes.clear()
		clear_variables()
		clear_callers()

#endregion
