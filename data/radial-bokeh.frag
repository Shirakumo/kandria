#define GOLDEN_ANGLE 2.39996
#define ITERATIONS 150

uniform sampler2D previous_pass;
uniform float strength = 1.0;
out vec4 color;

mat2 rot = mat2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

vec3 bokeh(sampler2D tex, vec2 uv, float radius){
    vec3 acc = vec3(0), div = acc;
    float r = 1.;
    vec2 vangle = vec2(0.0,radius*.01 / sqrt(float(ITERATIONS)));
    
    for (int j = 0; j < ITERATIONS; j++){
        r += 1. / r;
        vangle = rot * vangle;
        vec3 col = texture(tex, uv + (r-1.) * vangle).xyz;
        col = col * col *1.8;
        vec3 bokeh = pow(col, vec3(4));
        acc += col * bokeh;
        div += bokeh;
    }
    return acc / div;
}

void main(){
  vec2 uv = gl_FragCoord.xy / textureSize(previous_pass, 0).x;
  color = vec4(bokeh(previous_pass, uv, strength), 1);
}