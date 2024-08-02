shader_type canvas_item;

uniform sampler2D screen_tex: hint_screen_texture;
uniform sampler2D palette: filter_nearest, repeat_enable;

void fragment() {
	COLOR.a = texture(screen_tex, SCREEN_UV).a;
	if (texture(screen_tex, SCREEN_UV).r < 0.1) {
		COLOR.rgb = texture(palette, vec2(UV.y, 0.0)).rgb;
	}
}
