// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/includes/learnopengl/camera.h
import 'dart:math';
import 'package:vector_math/vector_math.dart';

// Defines several possible options for camera movement. Used as abstraction to stay away from window-system specific input methods
enum CameraMovement {
  forward,
  backward,
  left,
  right,
}
// Default camera values
const YAW = -90.0;
const PITCH = 0.0;
const SPEED = 2.5;
const SENSITIVITY = 0.1;
const ZOOM = 45.0;

class Camera {
  var position;
  var front = Vector3(0.0, 0.0, -1.0);
  var up;
  var right;
  var worldUp;
  var yaw;
  var pitch;
  var movementSpeed = SPEED;
  var mouseSensitivity = SENSITIVITY;
  var zoom = ZOOM;
  Camera({
    position: null,
    up: null,
    yaw: YAW,
    pitch: PITCH,
  }) {
    if (position != null) {
      this.position = position;
    } else {
      this.position = Vector3(0.0, 0.0, 0.0);
    }
    if (up != null) {
      this.worldUp = up;
    } else {
      this.worldUp = Vector3(0.0, 1.0, 0.0);
    }
    this.yaw = yaw;
    this.pitch = pitch;
    updateCameraVectors();
  }

  // returns the view matrix calculated using Euler Angles and the LookAt Matrix
  Matrix4 getViewMatrix() {
    return makeViewMatrix(position, position + front, up);
  }

  // processes input received from any keyboard-like input system. Accepts input parameter in the form of camera defined ENUM (to abstract it from windowing systems)
  void processKeyboard(CameraMovement direction, double deltaTime) {
    double velocity = movementSpeed * deltaTime;
    switch (direction) {
      case CameraMovement.forward:
        position += front.scaled(velocity);
        break;
      case CameraMovement.backward:
        position -= front.scaled(velocity);
        break;
      case CameraMovement.left:
        position -= right.scaled(velocity);
        break;
      case CameraMovement.right:
        position += right.scaled(velocity);
        break;
    }
  }

  void processMouseMovement(double xoffset, double yoffset,
      {constrainPitch: true}) {
    xoffset *= mouseSensitivity;
    yoffset *= mouseSensitivity;
    yaw += xoffset;
    pitch += yoffset;
    // make sure that when pitch is out of bounds, screen doesn't get flipped
    if (constrainPitch) {
      if (pitch > 89.0) {
        pitch = 89.0;
      }
      if (pitch < -89.0) {
        pitch = 89.0;
      }
    }
    // update Front, Right and Up Vectors using the updated Euler angles
    updateCameraVectors();
  }

  void processMouseScroll(double yoffset) {
    zoom -= yoffset;
    if (zoom < 1.0) {
      zoom = 1.0;
    }
    if (zoom > 45.0) {
      zoom = 45.0;
    }
  }

  // calculate the new Front vector
  void updateCameraVectors() {
    front.x = cos(radians(yaw)) * cos(radians(pitch));
    front.y = sin(radians(pitch));
    front.z = sin(radians(yaw)) * cos(radians(pitch));
    front.normalize();
    // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    right = front.cross(worldUp).normalized();
    up = right.cross(front).normalized();
  }
}
