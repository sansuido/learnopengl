// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/3.5.shaders_exercise2/shaders_exercise2.cpp
import 'dart:ffi';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import '../../shader_s.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;

var gVertexShaderSource = '#version 330 core'
    '\n'
    'layout (location = 0) in vec3 aPos;'
    '\n'
    'layout (location = 1) in vec3 aColor;'
    '\n'
    ''
    '\n'
    'out vec3 ourColor;'
    '\n'
    'uniform float xOffset;'
    '\n'
    ''
    '\n'
    'void main()'
    '\n'
    '{'
    '\n'
    '    // just add a - to the y position'
    '\n'
    '    gl_Position = vec4(aPos.x + xOffset, aPos.y, aPos.z, 1.0);'
    '\n'
    '    ourColor = aColor;'
    '\n'
    '}';

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
    print('Failed to crewate GLFW window');
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(
      window, Pointer.fromFunction(framebufferSizeCallback));
  // glad: load all OpenGL function pointers
  gladLoadGLLoader(glfwGetProcAddress);
  // build and compile our shader program
  // ------------------------------------
  var ourShader = Shader(
    vertexShaderSource: gVertexShaderSource,
//      vertexFilePath: 'resources/shaders/3.3.shader.vs',
    fragmentFilePath: 'resources/shaders/3.3.shader.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    // positions      // colors
    0.5, -0.5, 0.0, 1.0, 0.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // bottom left
    0.0, 0.5, 0.0, 0.0, 0.0, 1.0 // top
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  // position atribute
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 6 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // color attribute
  gldtVertexAttribPointer(
      1, 3, GL_FLOAT, GL_FALSE, 6 * sizeOf<Float>(), 3 * sizeOf<Float>());
  glEnableVertexAttribArray(1);
  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  //glBindVertexArray(0);
  // render loop
  // -----------
  while (glfwWindowShouldClose(window) == GLFW_FALSE) {
    // input
    // -----
    processInput(window);
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // render the triangle
    ourShader.use();
    var offset = 0.5;
    ourShader.setFloat('xOffset', offset);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteVertexArrays([vao]);
  gldtDeleteBuffers([vbo]);
  ourShader.delete();
  // glfw: terminate, clearing all previously allocated GLFW resources.
  // ------------------------------------------------------------------
  glfwTerminate();
  return 0;
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(Pointer<GLFWwindow> window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, GL_TRUE);
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
