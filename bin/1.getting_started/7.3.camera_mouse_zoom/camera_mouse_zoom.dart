// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/7.3.camera_mouse_zoom/camera_mouse_zoom.cpp
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:glew/glew.dart';
import 'package:glfw3/glfw3.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart';
import 'package:learnopengl/shader_m.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;
// camera
var gCameraPos = Vector3(0.0, 0.0, 3.0);
var gCameraFront = Vector3(0.0, 0.0, -1.0);
var gCameraUp = Vector3(0.0, 1.0, 0.0);
var gFirstMouse = true;
var gYaw = -90.0;
var gPitch = 0.0;
var gLastX = 800 / 2.0;
var gLastY = 600 / 2.0;
var gFov = 45.0;
// timing
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
  var ourShader = Shader(
    vertexFilePath: 'resources/shaders/7.3.camera.vs',
    fragmentFilePath: 'resources/shaders/7.3.camera.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    [-0.5, -0.5, -0.5, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 1.0],
    [0.5, 0.5, 0.5, 1.0, 1.0],
    [-0.5, 0.5, 0.5, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, 0.5, -0.5, 1.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, 0.5, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, -0.5, 1.0, 1.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, 0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
  ];
  // world space positions of our cubes
  var cubePositions = [
    Vector3(0.0, 0.0, 0.0),
    Vector3(2.0, 5.0, -15.0),
    Vector3(-1.5, -2.2, -2.5),
    Vector3(-3.8, -2.0, -12.3),
    Vector3(2.4, -0.4, -3.5),
    Vector3(-1.7, 3.0, -7.5),
    Vector3(1.3, -2.0, -2.5),
    Vector3(1.5, 2.0, -2.5),
    Vector3(1.5, 0.2, -1.5),
    Vector3(-1.3, 1.0, -1.5),
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(
      GL_ARRAY_BUFFER,
      vertices.expand((List<double> values) => values).toList(),
      GL_STATIC_DRAW);
  // position attribute
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 0 * sizeOf<Float>());
  glEnableVertexAttribArray(0);
  // texture coord attribute
  gldtVertexAttribPointer(
      1, 2, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 3 * sizeOf<Float>());
  glEnableVertexAttribArray(1);
  // texture 1
  // ---------
  var texture1 = gldtGenTextures(1)[0];
  glBindTexture(GL_TEXTURE_2D, texture1);
  // set the texture wrapping parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  // set texture filtering paramters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load image, create texture and generate mipmaps
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
  // set texture filtering paramters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load image, create texture and generate mipmaps
  var image2 =
      decodePng(File('resources/textures/awesomeface.png').readAsBytesSync())!;
  gldtTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image2.width, image2.height, 0,
      GL_RGBA, image2.getBytes());
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
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    // active shader
    ourShader.use();
    // pass projection matrix to shader (as projection matrix rarely changes there's no need to do this per frame)
    // -----------------------------------------------------------------------------------------------------------
    var projection = makePerspectiveMatrix(
        radians(gFov), gScrWidth / gScrHeight, 0.1, 100.0);
    ourShader.setMatrix4('projection', projection);
    // camera/view transformation
    var view = makeViewMatrix(gCameraPos, gCameraPos + gCameraFront, gCameraUp);
    ourShader.setMatrix4('view', view);
    // render boxes
    for (var i = 0; i < 10; i++) {
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
void processInput(Pointer<GLFWwindow> window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, GLFW_TRUE);
  }
  var cameraSpeed = 2.5 * gDeltaTime;
  if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
    gCameraPos += gCameraFront.scaled(cameraSpeed);
  }
  if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
    gCameraPos -= gCameraFront.scaled(cameraSpeed);
  }
  if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
    gCameraPos -= gCameraFront.cross(gCameraUp).scaled(cameraSpeed);
  }
  if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
    gCameraPos += gCameraFront.cross(gCameraUp).scaled(cameraSpeed);
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
  // change this value to your liking
  var sensitivity = 0.1;
  xoffset *= sensitivity;
  yoffset *= sensitivity;
  gYaw += xoffset;
  gPitch += yoffset;
  // make sure that when pitch is out of bounds, screen doesn't get flipped
  if (gPitch > 89.0) {
    gPitch = 89.0;
  }
  if (gPitch < -89.0) {
    gPitch = -89.0;
  }
  var front = Vector3(
    cos(radians(gYaw)) * cos(radians(gPitch)),
    sin(radians(gPitch)),
    sin(radians(gYaw)) * cos(radians(gPitch)),
  );
  gCameraFront = front.normalized();
}

// glfw: whenever the mouse scroll wheel scrolls, this callback is called
// ----------------------------------------------------------------------
void scrollCallback(
    Pointer<GLFWwindow> window, double xoffset, double yoffset) {
  gFov -= yoffset;
  if (gFov < 1.0) {
    gFov = 1.0;
  }
  if (gFov > 45.0) {
    gFov = 45.0;
  }
}
