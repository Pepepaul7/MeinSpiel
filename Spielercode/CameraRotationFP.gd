extends Node3D

var camrot_h = 0
var camrot_v = 0
var cam_v_max = 90
var cam_v_min = -90
var h_sensitivity = 0.1
var v_sensitivity = 0.1
var h_acceleration = 10
var v_acceleration = 10
	
func _input(event):
	if event is InputEventMouseMotion:
		camrot_h -= event.relative.x * h_sensitivity
		camrot_v -= event.relative.y * v_sensitivity
		
func _physics_process(delta):
	
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	rotation_degrees.y = lerpf(rotation_degrees.y, camrot_h, delta * h_acceleration)
	$v.rotation_degrees.x = lerpf($v.rotation_degrees.x, camrot_v, delta * v_acceleration)
	
