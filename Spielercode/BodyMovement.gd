extends CharacterBody3D
class_name Player

var camera = preload("res://Spieler/h.tscn")
var cameraInstance = camera.instantiate()

var jumpCooldown = 0

var inventoryOpen:bool = false
var inventory = preload("res://Spieler/Inventory.tscn")
var inventoryInstance = inventory.instantiate()

func _ready():
	add_child(inventoryInstance)
	inventoryInstance.visible = false
	add_child(cameraInstance)
	
	
	
func _physics_process(delta):
#Jumping/Falling
	if not inventoryOpen:
		if Input.is_action_just_pressed("EPressed"):
			inventoryInstance.visible = true
			inventoryOpen = true
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
			if Input.is_key_pressed(KEY_W):
				if Input.is_key_pressed(KEY_CTRL):
					velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 360
				else:
					velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 180
			if Input.is_key_pressed(KEY_S):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h - 90)) * delta * 60
			if Input.is_key_pressed(KEY_D):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h)) * delta * 60
			if Input.is_key_pressed(KEY_A):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 180)) * delta * 60
			if Input.is_key_pressed(KEY_SPACE) and jumpCooldown == 0:
				jumpCooldown = 5
				velocity.y += 300 * delta
		if not is_on_floor():
			velocity.y -= 10 * delta
			if Input.is_key_pressed(KEY_W):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 90)) * delta * 2
			if Input.is_key_pressed(KEY_S):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h - 90)) * delta * 1
			if Input.is_key_pressed(KEY_D):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h)) * delta * 1
			if Input.is_key_pressed(KEY_A):
				velocity += Vector3(1,0,0).rotated(Vector3(0, 1, 0), deg_to_rad(cameraInstance.camrot_h + 180)) * delta * 1
	else:
		if not is_on_floor():
			velocity.y -= 10 * delta
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
		if Input.is_action_just_pressed("EPressed"):
			inventoryInstance.visible = false
			inventoryOpen = false
	move_and_slide()
	if jumpCooldown > 0:
		jumpCooldown -= 1

func _input(event):
	if event.is_action_pressed("LeftClick"):
		if event.button_index == 1: # 1 == left
			var camera:Camera3D
			camera = cameraInstance.get_child(0).get_child(0)
			var parameters = PhysicsRayQueryParameters3D.create(camera.project_ray_origin(event.position), camera.project_ray_origin(event.position) + camera.project_ray_normal(event.position) * 100, 0x3, [self])
			parameters.set_hit_from_inside(true)
			var collision = get_world_3d().direct_space_state.intersect_ray(parameters)
			if (not collision.is_empty()):
				if (position.distance_squared_to(collision.position) < 5):
					collision.collider.get_parent().get_parent().startDestroy(collision.position, camera.project_ray_normal(event.position))
