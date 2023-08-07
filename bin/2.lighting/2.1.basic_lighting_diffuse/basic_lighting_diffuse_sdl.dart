// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/2.lighting/2.1.basic_lighting_diffuse/basic_lighting_diffuse.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:glew/glew.dart';
import 'package:sdl2/sdl2.dart';
import 'package:vector_math/vector_math.dart';
import '../../camera.dart';
import '../../shader_m.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;
// camera
var gCamera = Camera(position: Vector3(0.0, 0.0, 3.0));
var gLastX = gScrWidth / 2;
var gLastY = gScrHeight / 2;
var gFirstMouse = true;
// timing
var gDeltaTime = 0.0;
var gLastFrame = 0.0;
// lighting
var gLightPos = Vector3(1.2, 1.0, 2.0);

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
  // --------------------
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
  sdlSetRelativeMouseMode(SDL_TRUE);
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(sdlGlGetProcAddressEx);
  // configure global opengl state
  // -----------------------------
  glEnable(GL_DEPTH_TEST);
  // build and compile our shader zprogram
  // ------------------------------------
  var lightingShader = Shader(
    vertexFilePath: 'resources/shaders/2.1.basic_lighting.vs',
    fragmentFilePath: 'resources/shaders/2.1.basic_lighting.fs',
  );
  var lightCubeShader = Shader(
    vertexFilePath: 'resources/shaders/2.1.light_cube.vs',
    fragmentFilePath: 'resources/shaders/2.1.light_cube.fs',
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
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // be sure to activate shader when setting uniforms/drawing objects
    lightingShader.use();
    lightingShader.setVector3('objectColor', Vector3(1.0, 0.5, 0.31));
    lightingShader.setVector3('lightColor', Vector3(1.0, 1.0, 1.0));
    lightingShader.setVector3('lightPos', gLightPos);
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
  gldtDeleteVertexArrays([cubeVao, lightCubeVao]);
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
