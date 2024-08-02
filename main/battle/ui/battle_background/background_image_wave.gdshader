shader_type canvas_item;

uniform sampler2D palette: source_color, filter_nearest;
uniform int palette_size = 11;

uniform sampler2D tex_a: filter_nearest, source_color, repeat_enable;
uniform sampler2D tex_b: filter_nearest, source_color, repeat_enable;
uniform sampler2D tex_c: filter_nearest, source_color, repeat_enable;

uniform int idx_1 = 1;
uniform int idx_2 = 2;
uniform int idx_3 = 3;
uniform int idx_4 = 4;

uniform float speed_a = 24.0;
uniform float speed_b = 12.0;
uniform float speed_c = 64.0;

uniform float wave_a = 3.0;
uniform float wave_b = 2.0;

void fragment() {
	float r_1 = texture(tex_a, sin(UV.y * wave_a) + UV - TIME * speed_a).a;
	float r_2 = texture(tex_b, sin(UV.y * wave_b) + UV - TIME * speed_b).a;
	float r_3 = texture(tex_c, UV - TIME * speed_c).a;
	
	float threshold = 0.0;
	
	int index = 0;
	
	if (r_1 <= threshold && r_2 <= threshold) {
		index = idx_1;
	} else if (r_1 <= threshold || r_2 <= threshold) {
		index = idx_2;
	} else if (r_3 <= threshold){
		index = idx_3;
	} else {
		index = idx_4;
	}
	
	float width = 1.0 / float(palette_size);
	
	COLOR = texture(palette, vec2(width * float(index) + width / 2.0, 0.5));
}