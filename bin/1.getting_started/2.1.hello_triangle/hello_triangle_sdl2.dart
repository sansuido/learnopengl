// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.1.hello_triangle/hello_triangle.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:glew/glew.dart';
import 'package:sdl2/sdl2.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;

final gVertexShaderSource = '#version 330 core'
    '\n'
    'layout (location = 0) in vec3 aPos;'
    '\n'
    'void main()'
    '\n'
    '{'
    '\n'
    '    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);'
    '\n'
    '}';

final gFragmentShaderSource = '#version 330 core'
    '\n'
    'out vec4 FragColor;'
    '\n'
    'void main()'
    '\n'
    '{'
    '\n'
    '    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);'
    '\n'
    '}';

int main() {
  // sdl: Initialize adnd configure
  // ------------------------------
  if (sdlInit(SDL_INIT_VIDEO) < 0) {
    return -1;
  }
  sdlGlSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  sdlGlSetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  // sdl window creation
  // -------------------
  var window = sdlCreateWindow('LearnOpenGL', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, gScrWidth, gScrHeight, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
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
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(sdlGlGetProcAddressEx);
  // build and compile our shader program
  // ------------------------------------
  // vertext shader
  var vertexShader = glCreateShader(GL_VERTEX_SHADER);
  gldtShaderSource(vertexShader, gVertexShaderSource);
  glCompileShader(vertexShader);
  if (gldtGetShaderiv(vertexShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::VERTEX::COMPILATIN_FALED');
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
  // check for linking errors
  if (gldtGetProgramiv(shaderProgram, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PROGRAM::LINKING_FAILED');
    var bufSize = gldtGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(gldtGetProgramInfoLog(shaderProgram, bufSize));
    }
  }
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  var vertices = [
    -0.5, -0.5, 0.0, // left
    0.5, -0.5, 0.0, // right
    0.0, 0.5, 0.0, // top
  ];
  var vao = gldtGenVertexArrays(1)[0];
  var vbo = gldtGenBuffers(1)[0];
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  gldtBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  gldtVertexAttribPointer(
      0, 3, GL_FLOAT, GL_FALSE, 3 * sizeOf<Float>(), 0 * sizeOf<Float>());
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
  var quit = false;
  while (quit == false) {
    // render
    // ------
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    sdlGlSwapWindow(window);
    var event = calloc<SdlEvent>();
    while (sdlPollEvent(event) != 0) {
      // render
      // ------
      glClearColor(0.2, 0.3, 0.3, 1);
      glClear(GL_COLOR_BUFFER_BIT);
      // draw our first triangle
      glUseProgram(shaderProgram);
      // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
      glBindVertexArray(vao);
      glDrawArrays(GL_TRIANGLES, 0, 3);
      // no need to unbind it every time
      //glBindVertexArray(0);

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
      }
    }
    calloc.free(event);
  }
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  sdlGlDeleteContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
