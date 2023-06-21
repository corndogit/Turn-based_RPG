extends Node2D
class_name Character  # this is how you declare scene as a class

@export var is_player : bool
@export var current_hp : int = 25
@export var max_hp : int = 25
@export var combat_actions : Array
@export var opponent : Node

@export var visual : Texture2D
@export var flip_visual : bool

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_text : Label = get_node("HealthBar/Label")
@onready var character_name = "Player" if is_player else "Enemy"

signal made_move(user : String, move : String, damage : int)
signal is_dead(character : Character)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = visual
	$Sprite2D.flip_h = flip_visual
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)
	health_bar.value = current_hp
	health_bar.max_value = max_hp
	_update_health_bar()

func take_damage(damage : int):
	current_hp -= damage
	_update_health_bar()
	
	if current_hp <= 0:  # kill this character
		emit_signal("is_dead", self)
		queue_free()

func heal_self(amount : int):
	if amount + current_hp >= max_hp:
		current_hp = max_hp
	else:
		current_hp += amount
	_update_health_bar()

func _update_health_bar():
	health_bar.value = current_hp
	health_text.text = str(current_hp, " / ", max_hp)
	
func cast_combat_action(action):
	var critical_hit = action.crit_chance > 0.0 and action.crit_chance >= randf()
	var damage = action.damage * 2 if critical_hit else action.damage
	if action.damage != 0:
		opponent.take_damage(damage)
	if action.heal != 0:
		heal_self(action.heal)
	emit_signal("made_move", character_name, action, damage)
	get_node("/root/BattleScene").end_current_turn()
	
func _on_character_begin_turn(character):
	if character == self and not character.is_player:
		_decide_character_action()
	
func _decide_character_action():
	var health_percent = float(current_hp) / float(max_hp)
	
	for i in combat_actions:
		var action = i as CombatAction
		
		if action.heal > 0:
			if randf() > health_percent + 0.2:
				cast_combat_action(action)
				return
			else:
				continue
		else:
			cast_combat_action(action)
			return
		
