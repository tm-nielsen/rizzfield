shader_type spatial;
render_mode unshaded;

uniform vec3 colour: source_color = vec3(1);
uniform sampler2D albedo_texture: hint_default_white, filter_nearest;
uniform vec2 uv_scale = vec2(1);

void vertex() {
	UV *= uv_scale;
}

void fragment() {
	ALBEDO = colour * texture(albedo_texture, UV).rgb;
}
