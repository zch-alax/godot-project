extends Resource
class_name Dialogue

# 角色名
@export var character_name: String
# 角色头像
@export var avatar: Texture
# 显示角色头像是否在左边
@export var show_on_left: bool
# 对话内容
@export_multiline var content: String
