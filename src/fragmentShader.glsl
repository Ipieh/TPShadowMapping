#version 330 core            // minimal GL version support expected from the GPU
#define light_numbers 3
struct LightSource {
  vec3 position;
  vec3 color;
  float intensity;
  int isActive;
};

int numberOfLights = light_numbers;
uniform LightSource lightSources[light_numbers];
uniform sampler2D shadowMap[light_numbers];
// TODO: shadow maps

struct Material {
  sampler2D albedo;
  sampler2D normalTex;
};

uniform Material material;

uniform vec3 camPos;
uniform bool isWooden;
uniform bool applyAlbedoTexture;
uniform vec3 defaultTexture;

in vec3 fPositionModel;
in vec3 fPosition;
in vec3 fNormal;
in vec2 fTexCoord;
in vec4 fragPosLightSpace[light_numbers];

out vec4 colorOut; // shader output: the color response attached to this fragment

float pi = 3.1415927;
float shadowCalculation(int light_index){
  //perspective divide
  vec3 projCoords =fragPosLightSpace[light_index].xyz/ fragPosLightSpace[light_index].w;
  //transform [0,1] range
  projCoords = projCoords * 0.5 + 0.5;
  //get closes depth valu from light's perspective
  float closestDepth = texture(shadowMap[light_index], projCoords.xy).r;
  //depth of current fragment from light's perspective
  float currentDepth = projCoords.z;
  //check whether  current frag pos is in shadow
  float shadow = currentDepth > closestDepth +0.01? 0.1:1.0;

  return shadow;
}
// TODO: shadows
void main() {
  vec3 n = normalize(fNormal);
  
  if (isWooden){
    n = normalize(texture(material.normalTex,fTexCoord).rgb*2-1);}
  
  vec3 wo = normalize(camPos - fPosition); // unit vector pointing to the camera
  vec3 mat_albedo = texture(material.albedo,fTexCoord).rgb;
  if (!applyAlbedoTexture){
    mat_albedo =defaultTexture;
  }
  vec3 radiance = vec3(0, 0, 0);
  for(int i=0; i<numberOfLights; ++i) {
    LightSource a_light = lightSources[i];
    if(a_light.isActive == 1) { // consider active lights only
      vec3 wi = normalize(a_light.position - fPosition); // unit vector pointing to the light
      float shadow =shadowCalculation(i);
      vec3 Li = a_light.color*a_light.intensity;
      vec3 albedo = mat_albedo;

      radiance += Li*albedo*max(dot(n, wi), 0)*shadow;
    }
  }

  colorOut = vec4(radiance, 1.0); // build an RGBA value from an RGB one
}
