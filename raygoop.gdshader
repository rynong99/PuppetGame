shader_type spatial;
render_mode unshaded;

uniform vec3 blobColor : source_color = vec3(0.278, 0.443, 0.012);
uniform float blobStickiness = 0.75;
uniform int numBlobs;
uniform vec4[200] blobs;

const float LARGE = 9e+9;
const float MAX_DIST = 100.0;
const int MAX_STEPS = 100;
const float EPSILON = 0.001;

float sphereSdf(vec3 p, vec3 pos, float r) {
    return length(pos - p) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float mapSdf(vec3 p) {
    float k = blobStickiness;
    float d = LARGE;

    for (int i = 0; i < numBlobs; i++) {
        vec4 blob = blobs[i];
        float sdf = sphereSdf(p, blob.xyz, blob.w);
        if (sdf < 100.0)
            d = smin(d, sdf, k);
    }

    return d;
}

vec3 mapNormal(vec3 p) {
    float e = EPSILON;
    vec2 d = vec2(e, 0.0);
    float sdf0 = mapSdf(p);
    float dx = mapSdf(p + vec3(d.x, d.y, d.y)) - sdf0;
    float dy = mapSdf(p + vec3(d.y, d.x, d.y)) - sdf0;
    float dz = mapSdf(p + vec3(d.y, d.y, d.x)) - sdf0;
    return normalize(vec3(dx, dy, dz));
}

float trace(vec3 ro, vec3 rd) {
    float dist = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dist;
        float d = mapSdf(p);
        if (d < EPSILON) return dist;
        dist += d;
        if (dist >= MAX_DIST) break;
    }
    return -1.0;
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / VIEWPORT_SIZE;
    uv = uv * 2.0 - 1.0;
    uv.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;

    vec3 ro = vec3(0.0, 0.0, 5.0);
    vec3 rd = normalize(vec3(uv, -1.0));

    float dist = trace(ro, rd);
    if (dist > 0.0) {
        vec3 p = ro + rd * dist;
        vec3 normal = mapNormal(p);
        vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
        float diff = max(dot(normal, lightDir), 0.0);
        vec3 color = blobColor * diff;
        ALBEDO = color;
    } else {
        discard;
    }
}
