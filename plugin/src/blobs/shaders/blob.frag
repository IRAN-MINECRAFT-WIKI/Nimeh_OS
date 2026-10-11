#version 440

// NimehOS blob.frag — SDF rounded-rectangle with 2x2 deformation matrix.
// Renders a single BlobRect with an organic deformation driven by the
// spring-physics on the C++ side. The shader is intentionally minimal vs
// caelestia's multi-rect smin shader; merging between blobs is approximated
// by sibling BlobRect items in the scene graph (BlobGroup) rather than by
// a fragment-shader smooth-min pass.
//
// Inputs:
//   qt_TexCoord0 : 0..1 across the item's bounding rect
//   u_color      : RGBA fill colour (premultiplied by caller)
//   u_size       : pixel size of the BlobRect (width, height)
//   u_radius     : corner radius in pixels
//   u_deform     : 2x2 symmetric deformation matrix (column-major)
//                  rest state is identity (no deformation)

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 u_color;
    vec2 u_size;
    float u_radius;
    mat2 u_deform;
};

// 2D signed-distance function for a rounded box centred at the origin,
// half-extents b and corner radius r. Standard Inigo Quilez formulation.
float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
    // Map texcoord into pixel space centred on the blob centre.
    vec2 p = (qt_TexCoord0 - 0.5) * u_size;

    // Apply the inverse deformation so the SDF sample is taken in the
    // deformed frame. (For a symmetric SPD matrix the matrix and its
    // inverse have the same eigenvectors, so this preserves the rounded
    // shape but stretches/compresses it along the eigen-axes.)
    p = u_deform * p;

    // Half-extents of the rounded box. 0.45 * u_size leaves a 5% margin so
    // the smoothstep anti-alias edge isn't clipped at the item boundary.
    float d = sdRoundedBox(p, u_size * 0.45, u_radius);

    // 1-pixel anti-alias band (u_size is in pixels).
    float aa = 1.0;
    float alpha = 1.0 - smoothstep(-aa, aa, d);

    // Premultiplied output so it composites correctly with Qt Quick's
    // default blend state.
    fragColor = vec4(u_color.rgb * alpha, alpha) * qt_Opacity;
}
