// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.5.hello_triangle_exercise3/hello_triangle_exercise3.cpp
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

var gFragmentShader1Source =
'#version 330 core' '\n'
'out vec4 FragColor;' '\n'
'void main()' '\n'
'{' '\n'
'   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);' '\n'
'}';

var gFragmentShader2Source =
'#version 330 core' '\n'
'out vec4 FragColor;' '\n'
'void main()' '\n'
'{' '\n'
'   FragColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);' '\n'
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
  var fragmentShaderOrange = glCreateShader(GL_FRAGMENT_SHADER);
  gldtShaderSource(fragmentShaderOrange, gFragmentShader1Source);
  glCompileShader(fragmentShaderOrange);
  if (gldtGetShaderiv(fragmentShaderOrange, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    var bufSize = gldtGetShaderiv(fragmentShaderOrange, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetShaderInfoLog(fragmentShaderOrange, bufSize));
    }
  }
  var fragmentShaderYellow = glCreateShader(GL_FRAGMENT_SHADER);
  gldtShaderSource(fragmentShaderYellow, gFragmentShader2Source);
  glCompileShader(fragmentShaderYellow);
  if (gldtGetShaderiv(fragmentShaderYellow, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    var bufSize = gldtGetShaderiv(fragmentShaderYellow, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetShaderInfoLog(fragmentShaderYellow, bufSize));
    }
  }
  // link shaders
  var shaderProgramOrange = glCreateProgram();
  glAttachShader(shaderProgramOrange, vertexShader);
  glAttachShader(shaderProgramOrange, fragmentShaderOrange);
  glLinkProgram(shaderProgramOrange);
  // check linking errors
  if (gldtGetProgramiv(shaderProgramOrange, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PRGRAM::LINKING_FAILED');
    var bufSize = gldtGetProgramiv(shaderProgramOrange, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetProgramInfoLog(shaderProgramOrange, bufSize));
    }
  }
  var shaderProgramYellow = glCreateProgram();
  glAttachShader(shaderProgramYellow, vertexShader);
  glAttachShader(shaderProgramYellow, fragmentShaderYellow);
  glLinkProgram(shaderProgramYellow);
  // check linking errors
  if (gldtGetProgramiv(shaderProgramYellow, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PRGRAM::LINKING_FAILED');
    var bufSize = gldtGetProgramiv(shaderProgramYellow, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetProgramInfoLog(shaderProgramYellow, bufSize));
    }
  }
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShaderOrange);
  glDeleteShader(fragmentShaderYellow);
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var firstTriangle = [
      -0.9, -0.5, 0.0,  // left 
      -0.0, -0.5, 0.0,  // right
      -0.45, 0.5, 0.0,  // top 
  ];
  var secondTriangle = [
      0.0, -0.5, 0.0,  // left
      0.9, -0.5, 0.0,  // right
      0.45, 0.5, 0.0,  // top 
  ];
 // we can also generate multiple VAOs or buffers at the same time
  var vaos = gldtGenVertexArrays(2);
  var vbos = gldtGenBuffers(2);
  // first triangle setup
  // --------------------
  glBindVertexArray(vaos[0]);
  glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
  gldtBufferFloat(GL_ARRAY_BUFFER, firstTriangle, GL_STATIC_DRAW);
  gldtVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // no need to unbind at all as we directly bind a different VAO the next few lines
  //glBindVertexArray(0);
  // second triangle setup
  // ---------------------
	// note that we bind to a different VAO now
  glBindVertexArray(vaos[1]);
  // and a different VBO
  glBindBuffer(GL_ARRAY_BUFFER, vbos[1]);
  gldtBufferFloat(GL_ARRAY_BUFFER, secondTriangle, GL_STATIC_DRAW);
  gldtVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // not really necessary as well, but beware of calls that could affect VAOs while this one is bound (like binding element buffer objects, or enabling/disabling vertex attributes)
  //glBindVertexArray(0);
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
    // now when we draw the triangle we first use the vertex and orange fragment shader from the first program
    glUseProgram(shaderProgramOrange);
    // draw first triangle using the data from the first VAO
    glBindVertexArray(vaos[0]);
    // this call should output an orange triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // when we draw the second triangle we want to use a different shader program so we switch to the shader program with our yellow fragment shader.
    glUseProgram(shaderProgramYellow);
    // then we draw the second triangle using the data from the second VAO
    glBindVertexArray(vaos[1]);
    // this call should output a yellow triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteVertexArrays(vaos);
  gldtDeleteBuffers(vbos);
  glDeleteProgram(shaderProgramOrange);
  glDeleteProgram(shaderProgramYellow);
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