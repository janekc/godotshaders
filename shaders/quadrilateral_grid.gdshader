//https://godotshaders.com/shader/quadrilateral-grid/
shader_type canvas_item;

// Simple version:
// https://www.shadertoy.com/view/43c3WB

#define pi 3.14159
#define dir(a) vec2(cos(a),sin(a))
#define normal(v) vec2(-v.y, v.x)
#define iTime TIME
uniform float zoom : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float size : hint_range(0.0, 5.0, 0.1) = 0.4;
uniform float speed1 : hint_range(0.0, 5.0, 0.1) = 1.;
uniform float speed2 : hint_range(0.0, 5.0, 0.1) = 1.;
void fragment()
{
    vec2 u = UV * zoom;

    // Space between parallel lines
    float k = size;

    // Line coefficients: L1 = a1 + t * b1,
    //                    L2 = a2 + s * b2
    // (b1, b2 are unit vectors)
    vec2 a1 = vec2(0), b1 = dir(.6*cos(iTime * speed1)),
         a2 = vec2(0), b2 = dir(.1 * iTime * speed2);

    // Unit normals
    vec2 n1 = normal(b1),
         n2 = normal(b2);

    // Signed distances from u to lines L1, L2
    float d1 = dot(n1, u - a1),
          d2 = dot(n2, u - a2);

    // Offset the lines L1, L2 in the normal direction
    //  e.g. u lies between L3 = L1 + floor(d1/k) * k * n1
    //                  and L4 = L1 +  ceil(d1/k) * k * n1
    //  we pick the centre line C1 = (L3 + L4) / 2,
    //  do the same for L2 to find a centre line C2
    //  then find the centre of the quadrilateral by
    //  intersecting C1 and C2
    a1 += (floor(d1 / k)+.5) * k * n1;
    a2 += (floor(d2 / k)+.5) * k * n2;

    // Centre of region bounded by 4 closest lines
    //  i.e. intersect lines C1 = a1 + t * b1 + offset1 * n1
    //                   and C2 = a2 + s * b2 + offset2 * n2
    vec2 centre = a1 + dot(a2-a1,n2) / dot(b1,n2) * b1;

    float d = length(u - centre);
    COLOR = 0.* COLOR + cos(160.*d) * exp(-8.*d*d);
}