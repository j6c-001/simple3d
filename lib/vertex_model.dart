
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';

import 'view3d.dart';


class VertexModel {
  VertexModel(this.vertices, this.indices, this.colors):
      numFaces = indices.length ~/ 3;

  final Vector3List vertices;
  final Uint16List indices;
  final List colors;
  final int numFaces;

}


class VertexModelInstance {
  late VertexModel model;
  final Matrix4 mm = Matrix4.zero();
  Vector3 scale = Vector3(1, 1, 1);
  Vector3 facing = Vector3.all(1);

  VertexModelInstance();

  void prepareFrame(double px,double py,double pz,  double fx, double fy, double fz,  View3d view, double angle) {
    final  l = sqrt(fx*fx + fy*fy + fz *fz);
    facing.setValues(fx/l,fy/l, fz/l);
    setModelMatrix(mm, facing, up,px,py,pz);
    mm.scale(scale.x, scale.y, scale.z);
    mm.rotate(Vector3(facing.y,facing.x, facing.z), angle); // TO DO
    view.addModelInstances(model, mm);

  }
}

VertexModel makeVertexModel(List data, {bool swap = false}) {
  final  List<List> vertList = data[0];
  final List<Vector3> vectors = vertList.fold([], (c, v) {
      c.add(Vector3(v[0]*1.0, v[1]*1.0, v[2]*1.0));
      return c;
  });
  final vertices = Vector3List.fromList(vectors);

  final List<List> faces = data[1];

  final indices =  Uint16List(3 *  faces.length);
  final colors = Int32List(faces.length);

  int i = 0;
  for (List face in faces) {
      Color color = face[0];
      List<int> tri = face[1];
      indices[i*3] = tri[0];
      indices[i*3+1] = tri[1];
      indices[i*3+2] = tri[2];
      colors[i] = color.value;
      i++;
  }
  return VertexModel(vertices, indices, colors);
}


List wedgeDef = [
  [
    [0,0,0],
    [1,2,2],
    [2,1,1]
  ],
  [
    [ Colors.green, [0, 1, 2] ],
    [ Colors.red, [1, 1, 2] ]
  ]
];


