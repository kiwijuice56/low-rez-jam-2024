shader_type canvas_item;

// Decrease iteration and bounce counts for better performance
// Increase collision threshold for lower detail and better performance
group_uniforms detail;
uniform int max_iter = 512; // Max iterations a regular collision ray can march
uniform int max_bounce = 2; // Max times a ray can be reflected
uniform int light_iter = 64; // Max times a shadow collision ray can march
uniform float collision_threshold = 1.0e-3; // Min distance a ray can be from a surface for it to collide
uniform float normal_sample_length = 1.0e-2; // How far along a collided surface to move when sampling for a normal vector

group_uniforms fractal;
uniform int bulb_iter = 8; // Max iterations of the fractal algorithm
uniform float bulb_power = 8.0; // Dimension of the fractal
uniform float bulb_runaway_threshold = 2.0;
uniform vec3 fractal_color1: source_color;
uniform vec3 fractal_color2: source_color;
uniform vec3 color_center_point = vec3(0.0, 0.5, -0.5);
uniform float color_intensity = 0.5;
uniform float rotation_speed = 1.0;
uniform bool mirror = false;

group_uniforms camera;
uniform float fov = 95.0; // In degrees
uniform float runaway_threshold = 8.0; // Distance where a ray is considered far enough to stop iteration

group_uniforms light;
uniform vec3 light_ray = vec3(0.0, -1.0, 0.0);

// Updated by script only
group_uniforms internal;
uniform vec3 _cam_pos = vec3(0.0); // Camera position
uniform mat3 _cam_mat = mat3(0.0); // Camera basis matrix
uniform vec2 _screen_size;

struct Material {
	float reflectivity;
	float roughness;
	float shadow_sharpness;
	float specular_alpha;
	vec3 albedo_color;
};


void rotate(inout vec3 p) {
	vec3 pt = p;
	float t = rotation_speed * TIME / 8.0;
	p.y = cos(t) * p.y + sin(t) * p.z;
	p.z = -sin(t) * pt.y + cos(t) * pt.z;
	
	t *= 1.5;
	
	pt = p;
	p.x = cos(t) * pt.x - sin(t) * pt.z;
	p.z = sin(t) * pt.x + cos(t) * pt.z;
}

// Returns distance estimate to fractal
// `collision_info` parameter is overwritten with color information
// http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
// https://iquilezles.org/articles/ftrapsgeometric/
float mandelbulb_DE(vec3 p, inout vec3 collision_info) {
	if (mirror) {
		p = mod(p, 4.0) - vec3(2.0);
	}
	
	rotate(p);
	
	vec3 z = p;
	float dr = 1.0;
	float r = 0.0;
	
	collision_info = vec3(2.0);
	for (int i = 0; i < bulb_iter; i++) {
		r = length(z);
		if (r > bulb_runaway_threshold)
			break;
		
		// Convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y, z.x);
		dr = pow(r, bulb_power - 1.0) * bulb_power * dr + 1.0;
		
		// Scale and rotate the point
		float zr = pow(r, bulb_power);
		theta = theta * bulb_power;
		phi = phi * bulb_power;
		
		// Convert back to cartesian coordinates
		z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		z += p;
		
		// Store minimum distance along orbit to a random (predetermined) point...
		// Creates nice colors along fractal "bulbs"
		collision_info.r = min(collision_info.r, length(z - color_center_point));
	}
	// Divide by arbitrary value 
	collision_info *= color_intensity; 
	return 0.5 * log(r) * r/dr;
}

// Returns a vec4 of the color and distance to the closest object as rgba respectively
// `collision_info` holds extra information about the collision; Only stores
// distance values for coloring at this point
float world_DE(vec3 p, inout int collider_id, inout vec3 collision_info) {
	collider_id = 0; 
	return  mandelbulb_DE(p, collision_info);
}

int march(inout vec3 ray_pos, vec3 ray_dir, inout int id, inout vec3 collision_info) {
	float dist = 10000.0;
	int iter = 0;
	for (int i = 0; i < max_iter; i++) {
		dist = abs(world_DE(ray_pos, id, collision_info));
		ray_pos += ray_dir * dist;
		
		// We can quit marching early if we are extremely far from the fractal
		if (dist > runaway_threshold) {
			iter = max_iter;
			break;
		}
		
		// Once we are close enough to the fractal, we say we collided with it
		if (dist < collision_threshold)
			break;
		iter++;
	}
	return iter;
}

// https://iquilezles.org/articles/rmshadows/
float soft_shadow(vec3 ray_pos, vec3 ray_dir, float light_sharpness) {
	float min_shadow = 1.0;
	float dist_from_surface = 0.0;
	vec3 _orbit_dist;
	for(int i = 0; i < light_iter; i++) {
		int _id;
		float dist = abs(world_DE(ray_pos, _id, _orbit_dist));
		if(dist < collision_threshold)
			return 0.0;
		if (dist > runaway_threshold * 4.0) {
			break;
		}
		ray_pos += ray_dir * dist;
		min_shadow = min(min_shadow, light_sharpness * dist/dist_from_surface);
		dist_from_surface += dist;
	}
	return min_shadow;
}

vec3 get_normal(vec3 ray_pos) {
	int _id;
	vec3 _col_info;
	return normalize(
		vec3(world_DE(ray_pos + vec3(normal_sample_length, 0.0, 0.0), _id, _col_info) - world_DE(ray_pos - vec3(normal_sample_length, 0.0, 0.0), _id, _col_info),
			 world_DE(ray_pos + vec3(0.0, normal_sample_length, 0.0), _id, _col_info) - world_DE(ray_pos - vec3(0.0, normal_sample_length, 0.0), _id, _col_info),
			 world_DE(ray_pos + vec3(0.0, 0.0, normal_sample_length), _id, _col_info) - world_DE(ray_pos - vec3(0.0, 0.0, normal_sample_length), _id, _col_info)));
}

// https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-generating-camera-rays/generating-camera-rays.html
void fragment() {
	// Initialize materials
	Material fractal = Material(0.07, 0.2, 9.0, 0.2, vec3(0.0));
	
	// Take the pixel position (UV) and convert it into a ray based on the camera's orientation
	vec3 ray_pos = _cam_pos;
	
	float px = (2.0 * UV.x - 1.0) * tan(fov * PI / 360.0) * (_screen_size.x / _screen_size.y);
	float py = (1.0 - 2.0 * UV.y * tan(fov * PI / 360.0));
	vec3 ray_dir = vec3(px, py, -1);
	ray_dir = _cam_mat * normalize(ray_dir);
	
	COLOR.a = 0.0;
	// March through scene, bouncing at collisions to create reflections
	vec3 pixel_color = vec3(0.0);
	float pixel_depth = runaway_threshold;
	for (int i = 0; i < max_bounce; i++) {
		vec3 origin = ray_pos;
		
		int collider_id;
		vec3 collision_info;
		int iter = march(ray_pos, ray_dir, collider_id, collision_info);
		
		// If we iterated up to the maximum amount of times and still haven't collided,
		// we probably escaped any objects
		if (iter == max_iter) 
			break;
		
		COLOR.a = 1.0;
		
		float x = min(1.0, collision_info.r);
		fractal.albedo_color = fractal_color1 * x + (1.0 - x) * fractal_color2;
		
		Material surface_material = fractal;
		
		vec3 normal = get_normal(ray_pos);
		
		// Reflect the ray
		ray_dir = ray_dir - 2.0 * dot(ray_dir, normal) * normal;
		ray_pos += ray_dir * collision_threshold * 4.0;
		
		vec3 hit_color = surface_material.albedo_color;
		
		// Ambient occlusion
		hit_color *= vec3(1.0 - float(iter) / float(max_iter));
		
		// Shadows based on the normal vector at this surface
		hit_color *= 0.74 + 0.25 * pow(max(0.0, dot(normal, -normalize(light_ray))), 1.0/2.4) * 1.055 - 0.055;
		
		// Specular highlights
		float specular = dot(-normalize(light_ray), ray_dir);
		float specular_power = 8.0;
		hit_color += vec3(surface_material.specular_alpha) * pow(specular, specular_power);
		
		// Ray-traced shadows
		if (!mirror) {
			hit_color *= 0.55 + 0.45 * soft_shadow(ray_pos + normal * collision_threshold * 4.0, -normalize(light_ray), surface_material.shadow_sharpness);
		}
		if (i == 0) {
			pixel_color = hit_color;
			pixel_depth = length(origin - ray_pos);
		}
		
		// Mix reflections
		pixel_color = min(1.55, (6.0 / length(origin - ray_pos))) * mix(pixel_color, hit_color, surface_material.reflectivity);
	}
	pixel_color = clamp(pixel_color, 0.0, 1.0);
	COLOR.rgb = pixel_color;
}