shader_type spatial;
render_mode unshaded;

const int MAX_STEPS = 200;
const float MAX_DISTANCE = 1000.0;
const float MIN_DISTANCE = 0.01;

uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform int blob_count;
uniform vec4 blobs[50]; // vec4 where xyz is position and w is radius
uniform float blob_color[50]; // float array for blob color factor, 0.0 is color 1, 1.0 is color 2
uniform vec3 blob_color1 : source_color;
uniform vec3 blob_color2: source_color;

uniform float blob_blend_factor = 0.5; // smoothing factor between blobs
uniform float mesh_blend_factor = 1.0; // smoothing factor between blobs and non-raymarched mesh
uniform float color_blend_factor = 1.0; // color blending factor between blobs

uniform vec3 ambient_light : source_color = vec3(0.2, 0.2, 0.2); // Ambient light color

struct blend {
	float color_factor; // A value of 0 means color1, 1 means color2
	float distance; // The distance to the surface
};

// Smooth minimum function, returns the minimum of two distances smoothed by an interpolation factor
float smin(float dist1, float dist2, float interp_factor) {
    float smooth_diff = max(interp_factor - abs(dist1 - dist2), 0.0);
    return min(dist1, dist2) - smooth_diff * smooth_diff * 0.25 / interp_factor;
}

// Returns the signed distance from a point to the closest surface of a sphere, given its center and radius
float sdSphere(vec3 point, vec3 center, float radius) {
    return length(center - point) - radius;
}

blend blendBlobs(vec3 point) {
	blend result = blend(0.0, sdSphere(point, blobs[0].xyz, blobs[0].w));
    result.color_factor = blob_color[0];
    for (int i = 1; i < blob_count; i++) {

		// Smoothly blend between the two distances
        float distance = sdSphere(point, blobs[i].xyz, blobs[i].w);
		result.distance = smin(result.distance, distance, blob_blend_factor);

		// Blend the blobs color factors
		float weight = exp(-distance * distance / (2.0 * color_blend_factor * color_blend_factor));
        result.color_factor = mix(result.color_factor, blob_color[i], weight);
    }
    return result;
}

float meshDistance(vec3 point, vec3 world_pixel_position) {
	return length(point - world_pixel_position);
}

blend blendAll(vec3 point, vec3 world_pixel_position) {
	blend result = blendBlobs(point);
	result.distance = smin(result.distance, meshDistance(point, world_pixel_position), mesh_blend_factor);
	return result;
}

// Function to calculate the normal at a point using central difference
vec3 calculateNormal(vec3 point) {
    vec2 e = vec2(0.01, 0.0);
    return normalize(vec3(
        blendAll(point + e.xyy, point).distance - blendAll(point - e.xyy, point).distance,
        blendAll(point + e.yxy, point).distance - blendAll(point - e.yxy, point).distance,
        blendAll(point + e.yyx, point).distance - blendAll(point - e.yyx, point).distance
    ));
}

// Function to apply toon shading with ambient light
vec3 toonShade(vec3 normal, vec3 light_dir, vec3 light_color, vec3 base_color) {
    float NdotL = dot(normal, light_dir);
    float intensity = step(0.25, NdotL) * 0.25 + step(0.5, NdotL) * 0.25 + step(0.75, NdotL) * 0.25 + step(0.9, NdotL) * 0.25;
    vec3 color = base_color * light_color * intensity;

    // Add ambient light
    color += ambient_light * base_color;

    return color;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
    float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_raw, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
    float linear_depth = length(pixel_position);

    vec3 weird_uv = vec3(SCREEN_UV * 2.0 - 1.0, 0.0);
    vec4 camera = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(weird_uv, 1);

    vec3 ray_origin = INV_VIEW_MATRIX[3].xyz;
    vec3 ray_direction = normalize(camera.xyz);
    vec3 world_pixel_position = (INV_VIEW_MATRIX * vec4(pixel_position, 1.0)).xyz;

	float travel_dist = 0.0;
	vec3 point = ray_origin;
	vec4 hitColor = vec4(0.0);

	for (int i = 0; i < MAX_STEPS; i++) {
		blend a = blendAll(point, world_pixel_position);
		travel_dist += a.distance;
		if (travel_dist > MAX_DISTANCE || travel_dist >= linear_depth) {
			break;
		}
		point += a.distance * ray_direction;
		if (abs(a.distance) < MIN_DISTANCE) {
			vec3 normal = calculateNormal(point);
			vec3 light_dir = normalize(vec3(1.0, 1.0, 1.0)); // Example light direction
			vec3 light_color = vec3(1.0, 1.0, 1.0); // Example light color
			vec3 base_color = mix(blob_color1, blob_color2, a.color_factor);
			hitColor = vec4(toonShade(normal, light_dir, light_color, base_color), 1.0);
			break;
		}
	}

    ALBEDO = hitColor.rgb;
    ALPHA = hitColor.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
