//https://godotshaders.com/shader/bae-016-slab-steps/
shader_type canvas_item;

#define iTime TIME
#define PI 3.14159
#define iResolution 1.0/SCREEN_PIXEL_SIZE

uniform vec4 color1 = vec4(1.0, 0.66, 0.33, 3.0);
uniform float speed : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float height : hint_range(0.0, 0.5, 0.1) = 0.2;
uniform float edge : hint_range(0.0, 0.5, 0.01) = 0.02;
uniform float shadow_transparent : hint_range(0.0, 2.0, 0.1) = 0.5;
uniform vec2 disp = vec2(0.5);
uniform vec3 camera1 = vec3(0., 1., 0.);
uniform vec2 coordination = vec2(123.345, 734.6897);
uniform float color_remap : hint_range(0.0, 5.0, 0.1) = 0.;
uniform float unity : hint_range(0.0, 2.0, 0.01) = 1.;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = color1;
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float hash(vec2 p)
{
    p = fract(p * coordination);
    p += dot(p, p - color_remap);
    return fract(p.x * p.y);
}

mat2 rot2D(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat2(vec2(c, -s), vec2(s, c));
}

mat3 _rot3D(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1. - c;

    return mat3(
        vec3(oc * axis.x * axis.x + c,
        oc * axis.x * axis.y - axis.z * s,
        oc * axis.z * axis.x + axis.y * s),
        vec3(oc * axis.x * axis.y + axis.z * s,
        oc * axis.y * axis.y + c,
        oc * axis.y * axis.z - axis.x * s),
        vec3(oc * axis.z * axis.x - axis.y * s,
        oc * axis.y * axis.z + axis.x * s,
        oc * axis.z * axis.z + c)
    );
}

vec3 rot3D(vec3 p, vec3 axis, float angle)
{
    return mix(dot(axis, p) * axis, p, cos(angle)) + cross(axis, p) * sin(angle);
}

float sdBox(vec3 p, vec3 b)
{
    vec3 q = abs(p) - b;
    return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.);
}

float smin(float a, float b, float k)
{
    float h = max(k - abs(a - b), 0.) / k;
    return min(a, b) - h * h * h * k * (1. / 6.);
}

float map(vec3 p)
{
    vec3 q = p;

    vec2 id = floor(q.xz);

    q.x = fract(q.x) - .5;
    q.z = fract(q.z) - .5;

    float n = hash(id);

    n = fract(n * 47.13);

    float s = sin(iTime * speed+ n * PI * 2.* unity);
    s = smoothstep(0.5, 1., s) * height;
    q.y -= s;

    float r = edge;
    float w = .5 - r;
    float box = sdBox(q, vec3(w, .1 - r, w)) - r;

    return box;
}

float rayMarch(vec3 ro, vec3 rd)
{
    float t = 0.; // total distance travelled
    for (int i = 0; i < 80 * 4; ++i)
    {
        vec3 p = ro + rd * t;

        float d = map(p) * .1;

        t += d;

        if (abs(d) < .001 || t > 100.) break;
    }
    return t;
}

vec3 normal(vec3 p)
{
    float d = map(p);
    vec2 e = vec2(.01, .0);
    vec3 n = d - vec3(
        map(p - e.xyy),
        map(p - e.yxy),
        map(p - e.yyx)
    );

    return normalize(n);
}

uniform float scrollFactor = .8;
float getLight(vec3 p)
{
    float a = 3.4;

    vec3 lightPos = vec3(
        12. * sin(a),
        16.,
        12.0*cos(a)
    ); // Light Position
    lightPos.x -= iTime * scrollFactor;
    lightPos.x += 30.;

    vec3 l = normalize(lightPos - p);
    vec3 n = normal(p);

    float dif = dot(n, l);
    dif = clamp(dif, 0., 1.);

    float d = rayMarch(p + n * .01, l);
    if (d < length(lightPos - p)) dif *= shadow_transparent;

    return dif;
}

void fragment()
{
    vec2 uv = UV - disp;
	uv.y *= -1.0;

    vec3 Y = camera1;

    float cameraY = 2.;
    vec3 ro = vec3(1., 1.8, -2); // ray origin

    vec3 lookat = vec3(0.);

    ro.x -= iTime * scrollFactor;
    lookat.x -= iTime * scrollFactor;

    vec3 F = normalize(lookat - ro);
    vec3 R = cross(Y, F);
    vec3 U = cross(F, R);

    float zoom = 3.2;
    R *= zoom;
    U *= zoom;
    ro += uv.x * R + uv.y * U;
    vec3 rd = F;

    vec3 col = vec3(0);

    float t = rayMarch(ro, rd);

    vec3 p = ro + rd * t;
    float dif = getLight(p);

    float n = hash(floor(p.xz) * 75.6);
    vec3 c = hsv2rgb(vec3(mod(n, .5), .6, 1.));
    c = pow(c, vec3(1./1.16));

    col = vec3(dif) * c;

    COLOR = vec4(col, 1.0);
}