extends Node

@export var player_character : Node
@export var enemy_character : Node
@onready var move_text : Label = get_node("/root/BattleScene/TextUI")
var current_character : Character
const turn_suffix : String = "%s's turn"

@export var next_turn_delay : float = 1.0
var game_over = false

signal character_begin_turn(character)
signal character_end_turn(character)

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.5).timeout
	begin_next_turn()


func begin_next_turn():
	if current_character == player_character:
		current_character = enemy_character
		move_text.text = turn_suffix % "Enemy"
	else:
		current_character = player_character
		move_text.text = turn_suffix % "Player"
	
		
	emit_signal("character_begin_turn", current_character)
	
	
func _update_move_text(user : String, action : CombatAction, damage : int):
	var text_builder = "%s uses %s! (%d damage)" % [user, action.display_name, damage]
	if damage > action.damage:
		text_builder += "\nCritical hit!"
	move_text.text = text_builder
	
	
func end_current_turn():
	emit_signal("character_end_turn", current_character)
	await get_tree().create_timer(next_turn_delay).timeout
	
	if not game_over:
		begin_next_turn()
	else:
		if not current_character.is_player:
			move_text.text = "Game over..."
		else:
			move_text.text = "You win!"


func _on_player_made_move(user, action, damage):
	_update_move_text(user, action, damage)


func _on_enemy_made_move(user, action, damage):
	_update_move_text(user, action, damage)


func _on_enemy_is_dead(_character):
	game_over = true


func _on_player_is_dead(_character):
	game_over = true
