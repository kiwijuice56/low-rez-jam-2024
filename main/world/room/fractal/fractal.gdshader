shader_type canvas_item;

uniform sampler2D palette: source_color, filter_nearest; // Insert a palette from lospec for instance
uniform int palette_size = 13;

// The bounds of the graph, set by fractal_navigation.gd
uniform highp float x_min = -2; uniform highp float x_max = 2;
uniform highp float y_min = -2; uniform highp float y_max = 2;

uniform float width = 1000;
uniform float height = 800;
uniform float angle = 0.0;

uniform highp vec2 mouse_pos;

// How fast the palette is cycled through, proportional to the change in `TIME`
uniform float shimmer_speed = 0.1;

// Coloration: This part is not relevant to the mandelbrot calculation, so you can
// modify it for different palettes. Most palettes use the iteration count `iter` to match
// a pixel to a color on a gradient. The parameter `mu` is a decimal number in the range
// [0, 1] that is functionally equivalent to `iter / max_iter`, but with some extra math 
// to reduce the color banding: http://linas.org/art-gallery/escape/escape.html
vec3 color_cell(float mu, vec2 uv) {
	if (abs(mu - 1.0) < 0.0001) {
		return vec3(0.0);
	}
	float shimmer_mu = mu + TIME * shimmer_speed;
	
	// Keep ratio in range [0, 1.0] since we are adding a large constant, TIME
	shimmer_mu -= floor(shimmer_mu);
	return vec3(shimmer_mu < 0.5 ? shimmer_mu * 2.0 : 2.0 - 2.0 * shimmer_mu);
}

vec3 mandelbrot(vec2 uv) {
	highp float x = x_min + uv.x * (x_max - x_min);
	highp float y = y_min + uv.y * (y_max - y_min);
	
	float xtemp = x;
	x = x * cos(angle) - y * sin(angle);
	y = y * cos(angle) + xtemp * sin(angle);
	
	int iter = 0;
	vec3 col = vec3(0.0);
	
	// https://en.wikipedia.org/wiki/Mandelbrot_set
	// WebGL has a limitation that won't allow the shader to compile
	// if a non-constant is used in for-loops; 256 is `MAX_ITER`
	for (int i = 0; i < 32; i++) {
		xtemp = x * x - y * y + mouse_pos.x;
		y = 2.0 * x * y + mouse_pos.y;
		x = xtemp;
		iter++;
		if (x * x + y * y > 4.0) 
			break;
	}
	
	if (iter == 256) {
		col = color_cell(1.0, uv);
	} else {
		// Here is where we calculate `mu` for coloration
		
		// We take some extra iterations for a smaller error in the coloration
		for (int extra_iter = 0; extra_iter < 4; extra_iter++) {
			xtemp = x * x - y * y + mouse_pos.x;
			y = 2.0 * x * y + mouse_pos.y;
			x = xtemp;
			iter++;
		}
		
		highp float modulus = sqrt(x * x + y * y);
		highp float mu = max(0, (float(iter) - log(log(modulus)) / log(2.0))) / 256.0;
		
		// `mu` is still in the range [0, 1], but the curve is shifted to spread the color
		// values farther from the high iteration values, which are rarely reached
		mu = sqrt(mu);  
		col = color_cell(mu, uv);
	}
	
	return col;
}

void fragment() {
	COLOR.rgb = vec3(0.0);
	vec2 uv_size = vec2(1.0 / width, 1.0 / height) / 4.0;
	for (float i = -1.0; i <= 1.0; i++) {
		for (float j = -1.0; j <= 1.0; j++) {
			COLOR.rgb += mandelbrot(UV - uv_size * vec2(i, j)) / 9.0;
		}
		
	}
	float index = max(1.0, round(COLOR.r * 255.0 / 19.0));
	float p_width = 1.0 / float(palette_size);
	
	COLOR = texture(palette, vec2(p_width * index + p_width / 2.0, 0.5));
}