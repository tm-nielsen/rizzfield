shader_type spatial;
render_mode unshaded, fog_disabled;

uniform float angle: hint_range(-3.14, 3.14) = 1;
uniform float influence: hint_range(0, 1) = 1;
uniform float offset = 0.5;
uniform float scale = 1.0;

uniform vec4 colour: source_color = vec4(1);
uniform sampler2D noise: filter_nearest;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float s = scale / influence;
	vec2 pos = 2.0 * (UV - vec2(0.5));
	pos.x += offset * cos(angle);
	pos.y += offset * sin(angle);
	float d = pos.x * pos.x + pos.y * pos.y;
	float a = step(s, d);

	a *= step(s / d, texture(noise, UV).r);
	ALPHA = a;

	ALBEDO = mix(vec3(0), colour.rgb, a) * influence;
	ALPHA *= colour.a;
	ALPHA += influence / 2.0;
}
