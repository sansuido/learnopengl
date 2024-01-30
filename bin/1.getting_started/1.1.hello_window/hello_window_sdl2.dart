// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/1.1.hello_window/hello_window.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:glew/glew.dart';
import 'package:sdl2/sdl2.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;

int main() {
  // sdl: Initialize and configure
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
  // glad: load all OpenGL function pointers
  // ---------------------------------------
  gladLoadGLLoader(sdlGlGetProcAddressEx);
  // render loop
  // -----------
  var quit = false;
  while (quit == false) {
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
