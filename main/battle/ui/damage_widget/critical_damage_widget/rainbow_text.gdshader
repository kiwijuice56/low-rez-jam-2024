shader_type canvas_item;

uniform sampler2D palette: filter_nearest;
uniform vec2 rect_global_position;
uniform vec2 rect_size;

void fragment() {
	if (COLOR.r < 0.1) {
		vec2 uv = (SCREEN_UV - rect_global_position) / rect_size;
		COLOR.rgb = texture(palette, vec2(uv.x, 0.0)).rgb;
	}
}
