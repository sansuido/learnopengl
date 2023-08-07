// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/2.lighting/2.5.basic_lighting_exercise3/basic_lighting_exercise3.cpp
import 'dart:ffi';
import 'dart:math';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import 'package:vector_math/vector_math.dart';
import '../../camera.dart';
import '../../shader_m.dart';

// shaders
var gVertexShaderSouce = '#version 330 core'
    '\n'
    'layout (location = 0) in vec3 aPos;'
    '\n'
    'layout (location = 1) in vec3 aNormal;'
    '\n'
    ''
    '\n'
    'out vec3 LightingColor; // resulting color from lighting calculations'
    '\n'
    ''
    '\n'
    'uniform vec3 lightPos;'
    '\n'
    'uniform vec3 viewPos;'
    '\n'
    'uniform vec3 lightColor;'
    '\n'
    ''
    '\n'
    'uniform mat4 model;'
    '\n'
    'uniform mat4 view;'
    '\n'
    'uniform mat4 projection;'
    '\n'
    ''
    '\n'
    'void main()'
    '\n'
    '{'
    '\n'
    '    gl_Position = projection * view * model * vec4(aPos, 1.0);'
    '\n'
    '    '
    '\n'
    '    // gouraud shading'
    '\n'
    '    // ------------------------'
    '\n'
    '    vec3 Position = vec3(model * vec4(aPos, 1.0));'
    '\n'
    '    vec3 Normal = mat3(transpose(inverse(model))) * aNormal;'
    '\n'
    '    '
    '\n'
    '    // ambient'
    '\n'
    '    float ambientStrength = 0.1;'
    '\n'
    '    vec3 ambient = ambientStrength * lightColor;'
    '\n'
    '  	'
    '\n'
    '    // diffuse '
    '\n'
    '    vec3 norm = normalize(Normal);'
    '\n'
    '    vec3 lightDir = normalize(lightPos - Position);'
    '\n'
    '    float diff = max(dot(norm, lightDir), 0.0);'
    '\n'
    '    vec3 diffuse = diff * lightColor;'
    '\n'
    '    '
    '\n'
    '    // specular'
    '\n'
    '    float specularStrength = 1.0; // this is set higher to better show the effect of Gouraud shading '
    '\n'
    '    vec3 viewDir = normalize(viewPos - Position);'
    '\n'
    '    vec3 reflectDir = reflect(-lightDir, norm);  '
    '\n'
    '    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);'
    '\n'
    '    vec3 specular = specularStrength * spec * lightColor;      '
    '\n'
    ''
    '\n'
    '    LightingColor = ambient + diffuse + specular;'
    '\n'
    '}';

var gFragmentShaderSource = '#version 330 core'
    '\n'
    'out vec4 FragColor;'
    '\n'
    ''
    '\n'
    'in vec3 LightingColor; '
    '\n'
    ''
    '\n'
    'uniform vec3 objectColor;'
    '\n'
    ''
    '\n'
    'void main()'
    '\n'
    '{'
    '\n'
    '   FragColor = vec4(LightingColor * objectColor, 1.0);'
    '\n'
    '}'
    '\n'
    '/*'
    '\n'
    'So what do we see?'
    '\n'
    'You can see (for yourself or in the provided image) the clear distinction of the two triangles at the front of the '
    '\n'
    'cube. This \'stripe\' is visible because of fragment interpolation. From the example image we can see that the top-right '
    '\n'
    'vertex of the cube\'s front face is lit with specular highlights. Since the top-right vertex of the bottom-right triangle is '
    '\n'
    'lit and the other 2 vertices of the triangle are not, the bright values interpolates to the other 2 vertices. The same '
    '\n'
    'happens for the upper-left triangle. Since the intermediate fragment colors are not directly from the light source '
    '\n'
    'but are the result of interpolation, the lighting is incorrect at the intermediate fragments and the top-left and '
    '\n'
    'bottom-right triangle collide in their brightness resulting in a visible stripe between both triangles.'
    '\n'
    'This effect will become more apparent when using more complicated shapes.'
    '\n'
    '*/';

// settings
const gScrWidth = 800;
const gScrHeight = 600;
// camera
var gCamera = Camera(position: Vector3(0.0, 0.0, 3.0));
var gLastX = gScrWidth / 2;
var gLastY = gScrHeight / 2;
bool gFirstMouse = true;
// timing
var gDeltaTime = 0.0;
var gLastFrame = 0.0;
// lighting
var gLightPos = Vector3(1.2, 1.0, 2.0);

int main() {
  // glfw: initialize and configure
  // ------------------------------
  if (glfwInit() != GLFW_TRUE) {
    return -1;
  }
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
  // for apple
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  // glfw window creation
  // --------------------
  var window =
      glfwCreateWindow(gScrWidth, gScrHeight, 'LearnOpenGL', nullptr, nullptr);
  if (window == nullptr) {
    print('Failed to create GLFW window');
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(
      window, Pointer.fromFunction(framebufferSizeCallback));
  glfwSetCursorPosCallback(window, Pointer.fromFunction(cursorPosCallback));
  glfwSetScrollCallback(window, Pointer.fromFunction(scrollCallback));
  // tell GLFW to capture our mouse
  glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(glfwGetProcAddress);
  // configure global opengl state
  // -----------------------------
  glEnable(GL_DEPTH_TEST);
  // build and compile our shader zprogram
  // ------------------------------------
  var lightingShader = Shader(
    vertexShaderSource: gVertexShaderSouce,
    fragmentShaderSource: gFragmentShaderSource,
//      vertexFilePath: 'resources/shaders/2.2.basic_lighting.vs',
//      fragmentFilePath: 'resources/shaders/2.2.basic_lighting.fs',
  );
  var lightCubeShader = Shader(
    vertexFilePath: 'resources/shaders/2.2.light_cube.vs',
    fragmentFilePath: 'resources/shaders/2.2.light_cube.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    -0.5,
    -0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    0.5,
    -0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    0.5,
    0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    0.5,
    0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    -0.5,
    0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    -0.5,
    -0.5,
    -0.5,
    0.0,
    0.0,
    -1.0,
    -0.5,
    -0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    0.5,
    -0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    0.5,
    0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    0.5,
    0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    -0.5,
    0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    -0.5,
    -0.5,
    0.5,
    0.0,
    0.0,
    1.0,
    -0.5,
    0.5,
    0.5,
    -1.0,
    0.0,
    0.0,
    -0.5,
    0.5,
    -0.5,
    -1.0,
    0.0,
    0.0,
    -0.5,
    -0.5,
    -0.5,
    -1.0,
    0.0,
    0.0,
    -0.5,
    -0.5,
    -0.5,
    -1.0,
    0.0,
    0.0,
    -0.5,
    -0.5,
    0.5,
    -1.0,
    0.0,
    0.0,
    -0.5,
    0.5,
    0.5,
    -1.0,
    0.0,
    0.0,
    0.5,
    0.5,
    0.5,
    1.0,
    0.0,
    0.0,
    0.5,
    0.5,
    -0.5,
    1.0,
    0.0,
    0.0,
    0.5,
    -0.5,
    -0.5,
    1.0,
    0.0,
    0.0,
    0.5,
    -0.5,
    -0.5,
    1.0,
    0.0,
    0.0,
    0.5,
    -0.5,
    0.5,
    1.0,
    0.0,
    0.0,
    0.5,
    0.5,
    0.5,
    1.0,
    0.0,
    0.0,
    -0.5,
    -0.5,
    -0.5,
    0.0,
    -1.0,
    0.0,
    0.5,
    -0.5,
    -0.5,
    0.0,
    -1.0,
    0.0,
    0.5,
    -0.5,
    0.5,
    0.0,
    -1.0,
    0.0,
    0.5,
    -0.5,
    0.5,
    0.0,
    -1.0,
    0.0,
    -0.5,
    -0.5,
    0.5,
    0.0,
    -1.0,
    0.0,
    -0.5,
    -0.5,
    -0.5,
    0.0,
    -1.0,
    0.0,
    -0.5,
    0.5,
    -0.5,
    0.0,
    1.0,
    0.0,
    0.5,
    0.5,
    -0.5,
    0.0,
    1.0,
    0.0,
    0.5,
    0.5,
    0.5,
    0.0,
    1.0,
    0.0,
    0.5,
    0.5,
    0.5,
    0.0,
    1.0,
    0.0,
    -0.5,
    0.5,
    0.5,
    0.0,
    1.0,
    0.0,
    -0.5,
    0.5,
    -0.5,
    0.0,
    1.0,
    0.0,
  ];
  // first, configure the cube's VAO (and VBO)
  var cubeVao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glBindVertexArray(cubeVao);
  // position attribute
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 6 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // normal attribute
  gldtVertexAttribPointer(
      1, 3, GL_FLOAT, GL_FALSE, 6 * sizeOf<Float>(), 3 * sizeOf<Float>());
  glEnableVertexAttribArray(1);
  // second, configure the light's VAO (VBO stays the same; the vertices are the same for the light object which is also a 3D cube)
  var lightCubeVao = gldtGenVertexArrays(1)[0];
  glBindVertexArray(lightCubeVao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  // note that we update the lamp's position attribute's stride to reflect the updated buffer data
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 6 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // render loop
  // -----------
  while (glfwWindowShouldClose(window) == GLFW_FALSE) {
    // per-frame time logic
    // --------------------
    var currentFrame = glfwGetTime();
    gDeltaTime = currentFrame - gLastFrame;
    gLastFrame = currentFrame;
    // input
    // -----
    processInput(window);
    // render
    // ------
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // change the light's position values over time (can be done anywhere in the render loop actually, but try to do it at least before using the light source positions)
    gLightPos.x = 1.0 + sin(glfwGetTime()) * 2.0;
    gLightPos.y = sin(glfwGetTime() / 2.0) * 1.0;
    // be sure to activate shader when setting uniforms/drawing objects
    lightingShader.use();
    lightingShader.setVector3('objectColor', Vector3(1.0, 0.5, 0.31));
    lightingShader.setVector3('lightColor', Vector3(1.0, 1.0, 1.0));
    lightingShader.setVector3('lightPos', gLightPos);
    lightingShader.setVector3('viewPos', gCamera.position);
    // view/projection transformations
    var projection = makePerspectiveMatrix(
        radians(gCamera.zoom), gScrWidth / gScrHeight, 0.1, 100.0);
    var view = gCamera.getViewMatrix();
    lightingShader.setMatrix4('projection', projection);
    lightingShader.setMatrix4('view', view);
    // world transformation
    var model = Matrix4.identity();
    lightingShader.setMatrix4('model', model);
    // render the cube
    glBindVertexArray(cubeVao);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    // also draw the lamp object
    lightCubeShader.use();
    lightCubeShader.setMatrix4('projection', projection);
    lightCubeShader.setMatrix4('view', view);
    model.translate(gLightPos);
    model.scale(Vector3.all(0.2));
    lightCubeShader.setMatrix4('model', model);
    glBindVertexArray(lightCubeVao);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteVertexArrays([cubeVao, lightCubeVao]);
  gldtDeleteBuffers([vbo]);
  // glfw: terminate, clearing all previously allocated GLFW resources.
  // ------------------------------------------------------------------
  glfwTerminate();
  return 0;
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(Pointer<GLFWwindow> window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, GLFW_TRUE);
  }
  if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
    gCamera.processKeyboard(CameraMovement.forward, gDeltaTime);
  }
  if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
    gCamera.processKeyboard(CameraMovement.backward, gDeltaTime);
  }
  if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
    gCamera.processKeyboard(CameraMovement.left, gDeltaTime);
  }
  if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
    gCamera.processKeyboard(CameraMovement.right, gDeltaTime);
  }
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
void framebufferSizeCallback(
    Pointer<GLFWwindow> window, int width, int height) {
  // make sure the viewport matches the new window dimensions; note that width and
  // height will be significantly larger than specified on retina displays.
  glViewport(0, 0, width, height);
}

// glfw: whenever the mouse moves, this callback is called
// -------------------------------------------------------
void cursorPosCallback(Pointer<GLFWwindow> window, double xpos, double ypos) {
  if (gFirstMouse) {
    gLastX = xpos;
    gLastY = ypos;
    gFirstMouse = false;
  }
  var xoffset = xpos - gLastX;
  // reversed since y-coordinates go from bottom to top
  var yoffset = gLastY - ypos;
  gLastX = xpos;
  gLastY = ypos;
  gCamera.processMouseMovement(xoffset, yoffset);
}

// glfw: whenever the mouse scroll wheel scrolls, this callback is called
// ----------------------------------------------------------------------
void scrollCallback(
    Pointer<GLFWwindow> window, double xoffset, double yoffset) {
  gCamera.processMouseScroll(yoffset);
}
