shader_type canvas_item;
// https://godotshaders.com/shader/palette-shader-lospec-compatible/

uniform sampler2D screen_tex: hint_screen_texture;
uniform sampler2D palette_1: source_color, filter_nearest;
uniform sampler2D palette_2: source_color, filter_nearest;
uniform int palette_size = 23;
uniform float x = 0.0;

void fragment() {
	vec4 color = texture(screen_tex, SCREEN_UV);
	float width = 1.0 / float(palette_size);

	float closest = 1.0;
	for (int i = 0; i < palette_size; i++) {
		vec4 comparison = texture(palette_1, vec2(width * float(i) + width / 2.0, 0.5));
		if (length(comparison - color) < 0.01) {
			COLOR = texture(palette_2, vec2(width * float(i) + width / 2.0, 0.5));
			break;
		}
		if (length(comparison - color) < closest) {
			COLOR = texture(palette_2, vec2(width * float(i) + width / 2.0, 0.5));
			closest = length(comparison - color);
		}
	}
}