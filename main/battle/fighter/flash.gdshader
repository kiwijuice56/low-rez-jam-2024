shader_type canvas_item;

uniform vec4 flash: source_color;

// Animate from 0 to 1
uniform float progress: hint_range(0.0, 1.0) = 0.0;

// How jagged each band of melting pixels are
uniform float meltiness: hint_range(0.0, 16.0) = 1.0;

uniform bool broken;
uniform int h_frames;
uniform float broken_dist = 0.1;

uniform float random_seed;

float psuedo_rand(float x) {
	return mod((x + random_seed) * 2048103.0 + cos(x * 1912.0), 1.0);
}

void fragment() {
	vec2 uv = UV;
	
	// Move pixels near the top faster
	uv.y -= progress / UV.y;
	
	// Created jagged edges for each pixel on the x-axis 
	uv.y -= progress * meltiness * psuedo_rand(UV.x - mod(UV.x, TEXTURE_PIXEL_SIZE.x));
	
	COLOR.rgb += flash.rgb;
	COLOR = texture(TEXTURE, uv);
	
	// "delete" pixels out of range
	if (uv.y <= 0.0) {
		COLOR.a = 0.0;
	}
	
	if (broken && distance(0.05*sin(UV.y * 16.0) + mod(UV.x, 1.0 / float(h_frames)) * float(h_frames), 0.5) < cos(2.0*TIME)*0.05 + broken_dist) {
		COLOR.a = 0.0;
	}
}
