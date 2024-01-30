// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/7.4.camera_class/camera_class.cpp
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:glew/glew.dart';
import 'package:image/image.dart';
import 'package:sdl2/sdl2.dart';
import 'package:vector_math/vector_math.dart';
import 'package:learnopengl/camera.dart';
import 'package:learnopengl/shader_m.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;
// camera
var gCamera = Camera(position: Vector3(0.0, 0.0, 3.0));
var gLastX = gScrWidth / 2.0;
var gLastY = gScrHeight / 2.0;
var gFirstMouse = true;
// timing
// time between current frame and last frame
var gDeltaTime = 0.0;
var gLastFrame = 0.0;

int main() {
  // sdl: initialize and configure
  // -----------------------------
  if (sdlInit(SDL_INIT_VIDEO) < 0) {
    return -1;
  }
  sdlGlSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  sdlGlSetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  // sdl window creation
  // -------------------
  var window = sdlCreateWindow(
      'LearnOpenGL',
      SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED,
      gScrWidth,
      gScrHeight,
      SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
  if (window == nullptr) {
    print('Failed to create SDL window');
    sdlQuit();
    return -1;
  }
  var context = sdlGlCreateContext(window);
  if (context == nullptr) {
    print('Failed to create GL context');
    sdlDestroyWindow(window);
    sdlQuit();
    return -1;
  }
  // tell SDL to capture our mouse
  sdlSetRelativeMouseMode(true);
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(sdlGlGetProcAddressEx);
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
  gldtVertexAttribPointer(
      1, 2, GL_FLOAT, GL_FALSE, 5 * sizeOf<Float>(), 3 * sizeOf<Float>());
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
  // load image, crate texture and generate mipmaps
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
  var quit = false;
  while (quit == false) {
    // per-frame time logic
    // --------------------
    var currentFrame = sdlGetTicks() / 1000;
    gDeltaTime = currentFrame - gLastFrame;
    gLastFrame = currentFrame;
    // input
    // -----
    processInput();
    // render
    // ------
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
    var projection = makePerspectiveMatrix(
        radians(gCamera.zoom), gScrWidth / gScrHeight, 0.1, 100.0);
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
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    sdlGlSwapWindow(window);
    var event = calloc<SdlEvent>();
    while (sdlPollEvent(event) != 0) {
      switch (event.type) {
        case SDL_QUIT:
          quit = true;
          break;
        case SDL_KEYDOWN:
          switch (event.key.keysym.ref.sym) {
            case SDLK_ESCAPE:
              quit = true;
              break;
          }
          break;
        // sdl: whenever the window size changed (by OS or user resize) this callback function executes
        // --------------------------------------------------------------------------------------------
        case SDL_WINDOWEVENT:
          if (event.window.ref.event == SDL_WINDOWEVENT_RESIZED) {
            glViewport(0, 0, event.window.ref.data1, event.window.ref.data2);
          }
          break;
        // sdl: whenever the mouse moves, this callback is called
        // ------------------------------------------------------
        case SDL_MOUSEMOTION:
          var xpos = event.motion.ref.x.toDouble();
          var ypos = event.motion.ref.y.toDouble();
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
          break;
        // sdl: whenever the mouse scroll wheel scrolls, this callback is called
        // ---------------------------------------------------------------------
        case SDL_MOUSEWHEEL:
          gCamera.processMouseScroll(event.wheel.ref.y.toDouble());
          break;
      }
    }
    calloc.free(event);
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  gldtDeleteTextures([texture1, texture2]);
  gldtDeleteVertexArrays([vao]);
  gldtDeleteBuffers([vbo]);
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  sdlGlDeleteContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}

// process all input: query SDL whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput() {
  var keys = sdlGetKeyboardState(nullptr);
  if (keys[SDL_SCANCODE_W] != 0) {
    gCamera.processKeyboard(CameraMovement.forward, gDeltaTime);
  }
  if (keys[SDL_SCANCODE_S] != 0) {
    gCamera.processKeyboard(CameraMovement.backward, gDeltaTime);
  }
  if (keys[SDL_SCANCODE_A] != 0) {
    gCamera.processKeyboard(CameraMovement.left, gDeltaTime);
  }
  if (keys[SDL_SCANCODE_D] != 0) {
    gCamera.processKeyboard(CameraMovement.right, gDeltaTime);
  }
}
