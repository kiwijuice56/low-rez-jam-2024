shader_type canvas_item;

uniform sampler2D screen_tex: hint_screen_texture;
uniform sampler2D palette: filter_nearest, repeat_enable;

void fragment() {
	COLOR = texture(screen_tex, SCREEN_UV);
	COLOR.a = texture(screen_tex, SCREEN_UV).a;
	if (length(texture(screen_tex, SCREEN_UV).rgb) < 0.05) {
		COLOR.rgb = texture(palette, vec2(UV.y, 0.0)).rgb;
	}
	
}
