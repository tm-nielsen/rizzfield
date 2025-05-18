shader_type spatial;
render_mode specular_toon, cull_disabled;

uniform vec3 albedo_colour: source_color = vec3(1);
uniform sampler2D albedo_texture: hint_default_white, filter_nearest;

uniform float edge_offset_x: hint_range(0, 0.5, 0.5);
uniform float edge_offset_y: hint_range(0, 0.5, 0.5);

uniform float roughness = 0.5;
uniform float metallic = 0;
uniform float specular = 0.5;

uniform vec3 emission: source_color = vec3(0);

uniform vec2 uv_scale = vec2(1);
uniform float normal_scale: hint_range(-1, 1, 2) = 1.0;

void vertex() {
	UV *= uv_scale;
	NORMAL *= normal_scale;
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * albedo_colour;

	vec3 v = (inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float edge_factor = step(mod(v.y + 0.55, 1.0), 0.1);
	edge_factor *=
		step(0.1, mod(v.x + 0.05 + edge_offset_x, 1.0))
		* step(0.1, mod(v.z + 0.05 + edge_offset_y, 1.0));
	ALBEDO *= edge_factor;

	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;

	EMISSION = emission;
}