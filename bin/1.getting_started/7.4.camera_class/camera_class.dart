// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/7.4.camera_class/camera_class.cpp
import 'dart:ffi';
import 'dart:io';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart';
import '../../camera.dart';
import '../../shader_m.dart';
// settings
final SCR_WIDTH = 800;
final SCR_HEIGHT = 600;
// camera
var gCamera = Camera(position: Vector3(0.0, 0.0, 3.0));
var gLastX = SCR_WIDTH / 2.0;
var gLastY = SCR_HEIGHT / 2.0;
var gFirstMouse = true;
// timing
// time between current frame and last frame
var gDeltaTime = 0.0;
var gLastFrame = 0.0;

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
  var ourShader = Shader(
      vertexFilePath: 'resources/shaders/7.4.camera.vs',
      fragmentFilePath: 'resources/shaders/7.4.camera.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
      -0.5, -0.5, -0.5,  0.0, 0.0,
       0.5, -0.5, -0.5,  1.0, 0.0,
       0.5,  0.5, -0.5,  1.0, 1.0,
       0.5,  0.5, -0.5,  1.0, 1.0,
      -0.5,  0.5, -0.5,  0.0, 1.0,
      -0.5, -0.5, -0.5,  0.0, 0.0,

      -0.5, -0.5,  0.5,  0.0, 0.0,
       0.5, -0.5,  0.5,  1.0, 0.0,
       0.5,  0.5,  0.5,  1.0, 1.0,
       0.5,  0.5,  0.5,  1.0, 1.0,
      -0.5,  0.5,  0.5,  0.0, 1.0,
      -0.5, -0.5,  0.5,  0.0, 0.0,

      -0.5,  0.5,  0.5,  1.0, 0.0,
      -0.5,  0.5, -0.5,  1.0, 1.0,
      -0.5, -0.5, -0.5,  0.0, 1.0,
      -0.5, -0.5, -0.5,  0.0, 1.0,
      -0.5, -0.5,  0.5,  0.0, 0.0,
      -0.5,  0.5,  0.5,  1.0, 0.0,

       0.5,  0.5,  0.5,  1.0, 0.0,
       0.5,  0.5, -0.5,  1.0, 1.0,
       0.5, -0.5, -0.5,  0.0, 1.0,
       0.5, -0.5, -0.5,  0.0, 1.0,
       0.5, -0.5,  0.5,  0.0, 0.0,
       0.5,  0.5,  0.5,  1.0, 0.0,

      -0.5, -0.5, -0.5,  0.0, 1.0,
       0.5, -0.5, -0.5,  1.0, 1.0,
       0.5, -0.5,  0.5,  1.0, 0.0,
       0.5, -0.5,  0.5,  1.0, 0.0,
      -0.5, -0.5,  0.5,  0.0, 0.0,
      -0.5, -0.5, -0.5,  0.0, 1.0,

      -0.5,  0.5, -0.5,  0.0, 1.0,
       0.5,  0.5, -0.5,  1.0, 1.0,
       0.5,  0.5,  0.5,  1.0, 0.0,
       0.5,  0.5,  0.5,  1.0, 0.0,
      -0.5,  0.5,  0.5,  0.0, 0.0,
      -0.5,  0.5, -0.5,  0.0, 1.0,
  ];
  // world space positions of our cubes
  var cubePositions = [
      Vector3( 0.0,  0.0,  0.0),
      Vector3( 2.0,  5.0, -15.0),
      Vector3(-1.5, -2.2, -2.5),
      Vector3(-3.8, -2.0, -12.3),
      Vector3( 2.4, -0.4, -3.5),
      Vector3(-1.7,  3.0, -7.5),
      Vector3( 1.3, -2.0, -2.5),
      Vector3( 1.5,  2.0, -2.5),
      Vector3( 1.5,  0.2, -1.5),
      Vector3(-1.3,  1.0, -1.5),
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  // position attribute
  gldtVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  gldtVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 3 * sizeOf<Float>());
  glEnableVertexAttribArray(1);
  // load and create a texture 
  // -------------------------
  // texture 1
  // ---------
  var texture1 = gldtGenTextures(1)[0];
  glBindTexture(GL_TEXTURE_2D, texture1);
  // set the texture wrapping parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  // set texture filtering parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load image, crate texture and generate mipmaps
  var image1 = decodeJpg(File('resources/textures/container.jpg').readAsBytesSync());
  gldtTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image1.width, image1.height, 0, GL_RGB, image1.getBytes(format: Format.rgb));
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
  // load image, crate texture and generate mipmaps
  var image2 = decodePng(File('resources/textures/awesomeface.png').readAsBytesSync())!;
  gldtTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image2.width, image2.height, 0, GL_RGBA, image2.getBytes());
  glGenerateMipmap(GL_TEXTURE_2D);
  // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
  // -------------------------------------------------------------------------------------------
  ourShader.use();
  ourShader.setInt('texture1', 0);
  ourShader.setInt('texture2', 1);
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
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    // activate shader
    ourShader.use();
    // pass projection matrix to shader (note that in this case it could change every frame)
    var projection = makePerspectiveMatrix(radians(gCamera.zoom), SCR_WIDTH / SCR_HEIGHT, 0.1, 100.0);
    ourShader.setMatrix4('projection', projection);
    // camera/view transformation
    var view = gCamera.getViewMatrix();
    ourShader.setMatrix4('view', view);
    // render boxed
    glBindVertexArray(vao);
    for (var i = 0; i < 10; i++) {
      // calculate the model matrix for each object and pass it to shader before drawing
      var model = Matrix4.identity();
      model.translate(cubePositions[i]);
      var angle = 20.0 * i;
      model.rotate(Vector3(1.0, 0.3, 0.5), radians(angle));
      ourShader.setMatrix4('model', model);
      glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteTextures([texture1, texture2]);
  gldtDeleteVertexArrays([vao]);
  gldtDeleteBuffers([vbo]);
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
void framebufferSizeCallback(Pointer<GLFWwindow>? window, int width, int height) {
  // make sure the viewport matches the new window dimensions; note that width and 
  // height will be significantly larger than specified on retina displays.
  glViewport(0, 0, width, height);
}

// glfw: whenever the mouse moves, this callback is called
// -------------------------------------------------------
void cursorPosCallback(Pointer<GLFWwindow>? window, double xpos, double ypos) {
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
void scrollCallback(Pointer<GLFWwindow>? window, double xoffset, double yoffset) {
  gCamera.processMouseScroll(yoffset);
}