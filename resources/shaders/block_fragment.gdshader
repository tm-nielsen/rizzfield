shader_type spatial;
render_mode specular_toon, cull_disabled;

uniform vec3 albedo_colour: source_color = vec3(1);
uniform sampler2D albedo_texture: hint_default_white, filter_nearest;

uniform float edge_width: hint_range(0, 0.5) = 0.2;
uniform vec3 edge_colour: source_color = vec3(0);
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

float get_edge(float axis, float offset)
{
	return step(mod(axis + edge_width / 2.0 + offset, 1.0), edge_width);
}

void fragment() {
	vec3 tex_col = texture(albedo_texture, UV).rgb;

	vec3 v = (inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 e = vec3(
		get_edge(v.x, edge_offset_x),
		get_edge(v.y, 0.5),
		get_edge(v.z, edge_offset_y)
	);
	float edge_factor = step(1.0, e.x * e.y + e.x * e.z + e.y * e.z);
	ALBEDO = tex_col * mix(albedo_colour, edge_colour, edge_factor);

	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;

	EMISSION = emission;
}