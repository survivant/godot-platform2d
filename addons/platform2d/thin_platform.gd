tool
extends "platform_base.gd"

const style_script = preload("res://addons/platform2d/thin_platform_material.gd")

func _ready():
	pass

func new_style():
	Style = Resource.new()
	Style.set_script(style_script)
	update()

func set_style(s):
	if s == null || s is Resource && s.script == style_script:
		.set_style(s)
	else:
		print("Set style failed")

func update_collision_polygon():
	if is_inside_tree() && Engine.editor_hint:
		var polygon = get_node("CollisionPolygon2D")
		if collision_layer == 0 && collision_mask == 0:
			if polygon != null:
				remove_child(polygon)
				free(polygon)
		else:
			var curve = get_curve()
			var point_array = baked_points(curve)
			var point_count = point_array.size()
			var polygon_height = Vector2(0, 10)
			if Style != null:
				polygon_height = Vector2(0, Style.Position * Style.Thickness)
			for i in range(point_count):
				point_array.append(point_array[point_count-i-1] + polygon_height)
			if polygon == null:
				polygon = CollisionPolygon2D.new()
				polygon.set_name("CollisionPolygon2D")
				polygon.hide()
				add_child(polygon)
				polygon.set_owner(get_owner())
			polygon.set_polygon(point_array)

func _draw():
	if Style != null:
		var LeftTexture = Style.LeftTexture
		var MidTexture = Style.MidTexture
		var RightTexture = Style.RightTexture
		var LeftOverflow = Style.LeftOverflow
		var RightOverflow = Style.RightOverflow
		var Thickness = Style.Thickness
		var Position = Style.Position
		var curve = get_curve()
		var baked_points_and_length = baked_points_and_length(curve)
		var point_array = baked_points_and_length.points
		var point_count = point_array.size()
		if point_count == 0 || MidTexture == null:
			return
		var sections = []
		var curve_length = baked_points_and_length.length
		var mid_length = MidTexture.get_width() * Thickness / MidTexture.get_height()
		if LeftTexture != null && RightTexture != null:
			var left_length = (1.0 - LeftOverflow) * LeftTexture.get_width() * Thickness / LeftTexture.get_height()
			var right_length = (1.0 - RightOverflow) * RightTexture.get_width() * Thickness / RightTexture.get_height()
			var mid_texture_count = floor(0.5 + (curve_length - left_length - right_length) / mid_length)
			var ratio_adjust = (left_length + mid_texture_count * mid_length + right_length) / curve_length
			sections.append({texture = LeftTexture, limit = 1.0, scale = ratio_adjust * LeftTexture.get_height() / (Thickness * LeftTexture.get_width())})
			if mid_texture_count > 0:
				sections.append({texture = MidTexture, limit = mid_texture_count, scale = ratio_adjust * MidTexture.get_height() / (Thickness * MidTexture.get_width())})
			sections.append({texture = RightTexture, limit = 1.0, scale = ratio_adjust * RightTexture.get_height() / (Thickness * RightTexture.get_width())})
		else:
			var mid_texture_count = curve_length / mid_length
			sections.append({texture = MidTexture, limit = mid_texture_count, scale = MidTexture.get_height() / (Thickness * MidTexture.get_width())})
		draw_border(point_array, Thickness, Position, sections, LeftOverflow)
