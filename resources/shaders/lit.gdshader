shader_type spatial;
render_mode specular_toon;

uniform vec3 albedo_colour: source_color = vec3(1);
uniform sampler2D albedo_texture: hint_default_white;

uniform float roughness = 0.5;
uniform float metallic = 0;
uniform float specular = 0.5;

uniform vec3 emission: source_color = vec3(0);

uniform vec2 uv_scale = vec2(1);

void vertex() {
	UV *= uv_scale;
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * albedo_colour;

	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;

	EMISSION = emission;
}