class_name player
extends CharacterBody2D

var player := player
var speed := 256
var render_radius:= 26
var attack_boost: = 512*10
var guard_speed := speed * 0.1
var look_at := float(1)
var controls = {"W": "forward",
				"S": "backward",
				"A": "left",
				"D": "right",
				"m1": "attack",
				"m2": "guard"}
