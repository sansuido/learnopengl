// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.3.hello_triangle_exercise1/hello_triangle_exercise1.cpp
import 'dart:ffi';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';

// settings
final SCR_WIDTH = 800;
final SCR_HEIGHT = 600;

var gVertexShaderSource =
'#version 330 core' '\n'
'layout (location = 0) in vec3 aPos;' '\n'
'void main()' '\n'
'{' '\n'
'    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);' '\n'
'}';

var gFragmentShaderSource =
'#version 330 core' '\n'
'out vec4 FragColor;' '\n'
'void main()' '\n'
'{' '\n'
'   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);' '\n'
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
  var window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, 'LearnOpenGL', nullptr, nullptr);
  if (window == nullptr) {
    print('Failed to create GLFW window');
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(window, Pointer.fromFunction(framebufferSizeCallback));
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(glfwGetProcAddress);
  // build and compile our shader program
  // ------------------------------------
  // vertex shader
  var vertexShader = glCreateShader(GL_VERTEX_SHADER);
  gldtShaderSource(vertexShader, gVertexShaderSource);
  glCompileShader(vertexShader);
  // check for shader compile errors
  if (gldtGetShaderiv(vertexShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::VERTEX::COMPILATION_FAILED');
    var bufSize = gldtGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetShaderInfoLog(vertexShader, bufSize));
    }
  }
  // fragment shader
  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  gldtShaderSource(fragmentShader, gFragmentShaderSource);
  glCompileShader(fragmentShader);
  if (gldtGetShaderiv(fragmentShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    var bufSize = gldtGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetShaderInfoLog(fragmentShader, bufSize));
    }
  }
  // link shaders
  var shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  // check linking errors
  if (gldtGetProgramiv(shaderProgram, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PRGRAM::LINKING_FAILED');
    var bufSize = gldtGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetProgramInfoLog(shaderProgram, bufSize));
    }
  }
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  // add a new set of vertices to form a second triangle (a total of 6 vertices); the vertex attribute configuration remains the same (still one 3-float position vector per vertex)
  var vertices = [
    // first triangle
    -0.9, -0.5, 0.0,  // left 
    -0.0, -0.5, 0.0,  // right
    -0.45, 0.5, 0.0,  // top 
    // second triangle
    0.0, -0.5, 0.0,  // left
    0.9, -0.5, 0.0,  // right
    0.45, 0.5, 0.0,  // top 
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  gldtVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  glBindVertexArray(0);
  // uncomment this call to draw in wireframe polygons.
  //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
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
    // draw our first triangle
    glUseProgram(shaderProgram);
    // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
    glBindVertexArray(vao);
    // set the count to 6 since we're drawing 6 vertices now (2 triangles); not 3!
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // no need to unbind it every time
    //glBindVertexArray(0);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteVertexArrays([vao]);
  gldtDeleteBuffers([vbo]);
  glDeleteProgram(shaderProgram);
  // glfw: terminate, clearing all previously allocated GLFW resources.
  // ------------------------------------------------------------------
  glfwTerminate();
  return 0;
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(Pointer<GLFWwindow>? window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, GLFW_TRUE);
  }
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
void framebufferSizeCallback(Pointer<GLFWwindow>? window, int width, int height) {
  // make sure the viewport matches the new window dimensions; note that width and 
  // height will be significantly larger than specified on retina displays.
  glViewport(0, 0, width, height);
}