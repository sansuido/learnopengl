// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/2.lighting/2.2.basic_lighting_specular/basic_lighting_specular.cpp
import 'dart:ffi';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import 'package:vector_math/vector_math.dart';
import 'package:learnopengl/camera.dart';
import 'package:learnopengl/shader_m.dart';

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
    vertexFilePath: 'resources/shaders/2.2.basic_lighting.vs',
    fragmentFilePath: 'resources/shaders/2.2.basic_lighting.fs',
  );
  var lightCubeShader = Shader(
    vertexFilePath: 'resources/shaders/2.2.light_cube.vs',
    fragmentFilePath: 'resources/shaders/2.2.light_cube.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    [-0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, 0.5, 0.5, -1.0, 0.0, 0.0],
    [-0.5, 0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, 0.5, -1.0, 0.0, 0.0],
    [-0.5, 0.5, 0.5, -1.0, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [-0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
  ];
  // first, configure the cube's VAO (and VBO)
  var cubeVao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(
      GL_ARRAY_BUFFER,
      vertices.expand((List<double> values) => values).toList(),
      GL_STATIC_DRAW);
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
