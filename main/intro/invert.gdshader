shader_type canvas_item;

uniform sampler2D tex: hint_screen_texture;

void fragment() {
	vec3 rgb = texture(tex, SCREEN_UV).rgb;
	COLOR.rgb = vec3(1.0) - rgb;
}
