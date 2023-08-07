// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/6.1.coordinate_systems/coordinate_systems.cpp
import 'dart:ffi';
import 'dart:io';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart';
import '../../shader_m.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;

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
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(glfwGetProcAddress);
  // build and compile our shader zprogram
  // ------------------------------------
  var ourShader = Shader(
    vertexFilePath: 'resources/shaders/6.1.coordinate_systems.vs',
    fragmentFilePath: 'resources/shaders/6.1.coordinate_systems.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    // positions       // texture coords
    0.5, 0.5, 0.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 0.0, // bottom left
    -0.5, 0.5, 0.0, 0.0, 1.0, // top left
  ];
  var indices = [
    0, 1, 3, // first triangle
    1, 2, 3 // second triangle
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  var ebo = gldtGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  gldtBufferUint32(GL_ELEMENT_ARRAY_BUFFER, indices, GL_STATIC_DRAW);
  // position attribute
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // texture coord attribute
  gldtVertexAttribPointer(
      1, 2, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 3 * sizeOf<Float>());
  glEnableVertexAttribArray(1);
  // load and create a texture
  // -------------------------
  var texture1 = gldtGenTextures(1)[0];
  glBindTexture(GL_TEXTURE_2D, texture1);
  // set the texture wrapping parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  // set texture filtering parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  var image1 =
      decodeJpg(File('resources/textures/container.jpg').readAsBytesSync())!;
  gldtTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image1.width, image1.height, 0,
      GL_RGB, image1.getBytes(order: ChannelOrder.rgb));
  glGenerateMipmap(GL_TEXTURE_2D);
  // texture 2
  // ---------
  var texture2 = gldtGenTextures(1)[0];
  glBindTexture(GL_TEXTURE_2D, texture2);
  // set the texture wrapping parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  // set texture filtering parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  var image2 =
      decodePng(File('resources/textures/awesomeface.png').readAsBytesSync());
  gldtTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image2!.width, image2.height, 0,
      GL_RGBA, image2.getBytes());
  glGenerateMipmap(GL_TEXTURE_2D);
  ourShader.use();
  ourShader.setInt('texture1', 0);
  ourShader.setInt('texture2', 1);
  // render loop
  // -----------
  while (glfwWindowShouldClose(window) == GL_FALSE) {
    // input
    // -----
    processInput(window);
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    // activate shader
    ourShader.use();
    // create transformations
    var model = Matrix4.identity();
    var view = Matrix4.identity();
    model.rotate(Vector3(1.0, 0.0, 0.0), radians(-55.0));
    view.translate(0.0, 0.0, -3.0);
    var projection = makePerspectiveMatrix(
        radians(45.0), gScrWidth / gScrHeight, 0.1, 100.0);
    // use shader_m methods
    ourShader.setMatrix4('model', model);
    ourShader.setMatrix4('view', view);
    ourShader.setMatrix4('projection', projection);
    //// retrieve the matrix uniform locations
    //var modelLoc = glGetUniformLocation(ourShader.id, 'model');
    //var viewLoc = glGetUniformLocation(ourShader.id, 'view');
    //var projectionLoc = glGetUniformLocation(ourShader.id, 'projection');
    //// pass them to the shaders
    //gldtUniformMatrix4fv(modelLoc, 1, GL_FALSE, model.storage);
    //gldtUniformMatrix4fv(viewLoc, 1, GL_FALSE, view.storage);
    //// note: currently we set the projection matrix each frame, but since the projection matrix rarely changes it's often best practice to set it outside the main loop only once.
    //gldtUniformMatrix4fv(projectionLoc, 1, GL_FALSE, projection.storage);
    // renader container
    glBindVertexArray(vao);
    gldtDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0 * sizeOf<Uint32>());
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteTextures([texture1, texture2]);
  gldtDeleteVertexArrays([vao]);
  gldtDeleteBuffers([vbo, ebo]);
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
