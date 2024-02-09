#version 330 core            // minimal GL version support expected from the GPU
#define light_numbers 3
layout(location=0) in vec3 vPosition; // the 1st input attribute is the position (CPU side: glVertexAttrib 0)
layout(location=1) in vec3 vNormal;
layout(location=2) in vec2 vTexCoord;

uniform mat4 modelMat, viewMat, projMat;
uniform mat3 normMat;
uniform mat4 mvpLight[light_numbers];

out vec3 fPositionModel;
out vec3 fPosition;
out vec3 fNormal;
out vec2 fTexCoord;
out vec4 fragPosLightSpace[light_numbers];

void main() {
  fPositionModel = vPosition;
  fPosition = (modelMat*vec4(vPosition, 1.0)).xyz;
  fNormal = normMat*vNormal;
  fTexCoord = vTexCoord;

  for (int i = 0; i < light_numbers ; i++){
    fragPosLightSpace[i] = mvpLight[i]*modelMat*vec4(vPosition,1.0);
  }

  gl_Position =  projMat*viewMat*modelMat*vec4(vPosition, 1.0); // mandatory
}
