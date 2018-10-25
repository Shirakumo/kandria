uniform sampler2D previous_pass;
uniform float strength = 1.0;
uniform vec2 blurdir = vec2( 0.0, 1.0 );
out vec4 color;

// ====

const int NUM_SAMPLES = 16;
const float THRESHOLD = 0.0;

vec3 srgb2lin(vec3 c) { return c*c; }
vec3 lin2srgb(vec3 c) { return sqrt(c); }

//note: uniform pdf rand [0;1[
float hash12n(vec2 p){
  p  = fract(p * vec2(5.3987, 5.4421));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4307);
}

vec3 sampletex( vec2 uv ){
  return srgb2lin( texture( previous_pass, uv, -10.0 ).rgb );    
}

void main(){
  ivec2 iResolution = textureSize(previous_pass, 0);
  vec2 fragCoord = gl_FragCoord.xy;
  vec2 blurvec = normalize(blurdir) / iResolution.xx;
  vec2 uv = fragCoord / iResolution.xy;
  float aspect = iResolution.x/iResolution.y;
  
  float mult = mix(0.25, 2.0, strength/100.0);
  float threshold = mix(0.0, 0.3, strength/100.0);
    
  vec2 p0 = uv;
  vec2 p1 = uv + strength * blurvec;
  vec2 stepvec = (p1-p0) / float(NUM_SAMPLES);
  vec2 p = p0;
  p += (hash12n(uv+blurdir.x*blurdir.y)) * stepvec;
    
  vec3 sumcol = vec3(0.0);
  for (int i=0;i<NUM_SAMPLES;++i){
    vec3 smpl = (sampletex(p) - threshold ) / (1.0-threshold);
    sumcol += smpl;
    p += stepvec;
  }
  sumcol /= float(NUM_SAMPLES);
  sumcol = max( sumcol, 0.0 );
  
  color = vec4( lin2srgb( sumcol * mult ), 1.0 );
}
