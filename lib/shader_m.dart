//https://github.com/JoeyDeVries/LearnOpenGL/blob/master/includes/learnopengl/shader_m.h
import 'dart:io';
import 'package:glew/glew.dart';
import 'package:vector_math/vector_math.dart';

class Shader {
  var id = 0;
  Shader(
      {String? vertexShaderSource,
      String? vertexFilePath,
      String? fragmentShaderSource,
      String? fragmentFilePath}) {
    id = glCreateProgram();
    if (vertexShaderSource == null && vertexFilePath != null) {
      vertexShaderSource = File(vertexFilePath).readAsStringSync();
    }
    if (vertexShaderSource != null) {
      var vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
      gldtShaderSource(vertexShaderID, vertexShaderSource);
      glCompileShader(vertexShaderID);
      if (_checkCompileErrors(vertexShaderID, 'VERTEX') == true) {
        glAttachShader(id, vertexShaderID);
      }
      glDeleteShader(vertexShaderID);
    }
    if (fragmentShaderSource == null && fragmentFilePath != null) {
      fragmentShaderSource = File(fragmentFilePath).readAsStringSync();
    }
    if (fragmentShaderSource != null) {
      var fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);
      gldtShaderSource(fragmentShaderID, fragmentShaderSource);
      glCompileShader(fragmentShaderID);
      if (_checkCompileErrors(fragmentShaderID, 'FRAGMENT') == true) {
        glAttachShader(id, fragmentShaderID);
      }
      glDeleteShader(fragmentShaderID);
    }
    glLinkProgram(id);
    if (_checkCompileErrors(id, 'PROGRAM') == false) {
      glDeleteProgram(id);
      id = 0;
    }
  }

  void use() {
    glUseProgram(id);
  }

  void delete() {
    if (id != 0) {
      glDeleteProgram(id);
      id = 0;
    }
  }

  void setBool(String name, bool value) {
    glUniform1i(glGetUniformLocation(id, name), value ? GL_TRUE : GL_FALSE);
  }

  void setInt(String name, int value) {
    glUniform1i(glGetUniformLocation(id, name), value);
  }

  void setFloat(String name, double value) {
    glUniform1f(glGetUniformLocation(id, name), value);
  }

  void setVector2(String name, Vector2 value) {
    gldtUniform2fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setVector3(String name, Vector3 value) {
    gldtUniform3fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setVector4(String name, Vector4 value) {
    gldtUniform4fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setMatrix2(String name, Matrix2 value) {
    gldtUniformMatrix2fv(
        glGetUniformLocation(id, name), 1, GL_FALSE, value.storage);
  }

  void setMatrix3(String name, Matrix3 value) {
    gldtUniformMatrix3fv(
        glGetUniformLocation(id, name), 1, GL_FALSE, value.storage);
  }

  void setMatrix4(String name, Matrix4 value) {
    gldtUniformMatrix4fv(
        glGetUniformLocation(id, name), 1, GL_FALSE, value.storage);
  }

  bool _checkCompileErrors(int shader, String type) {
    var success = GL_FALSE;
    var bufSize = 0;
    switch (type) {
      case 'PROGRAM':
        success = gldtGetProgramiv(shader, GL_LINK_STATUS);
        if (success != GL_TRUE) {
          print('ERROR::PROGRAM_LINKING_ERROR of type: ' '$type');
          bufSize = gldtGetProgramiv(shader, GL_INFO_LOG_LENGTH);
          if (bufSize > 1) {
            print(gldtGetProgramInfoLog(shader, bufSize));
          }
        }
        break;
      default:
        success = gldtGetShaderiv(shader, GL_COMPILE_STATUS);
        if (success != GL_TRUE) {
          print('ERROR::SHADER_COMPILATION_ERROR of type: ' '$type');
          bufSize = gldtGetShaderiv(shader, GL_INFO_LOG_LENGTH);
          if (bufSize > 1) {
            print(gldtGetShaderInfoLog(shader, bufSize));
          }
        }
        break;
    }
    return success == GL_TRUE;
  }
}
