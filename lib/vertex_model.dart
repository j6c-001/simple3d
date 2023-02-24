
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math_lists.dart';

import 'view.dart';


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

  void prepareFrame(px,py,pz,  fx, fy, fz,  View view, double angle) {
    facing.setValues(fx,fy,fz);
    setModelMatrix(mm, facing, Vector3(0, -1, 0),px,py,pz);
    //mm.scale(scale.x, scale.y, scale.z);
    //mm.rotate(facing, angle);
    view.addModelInstances(model, mm);
/*
    for (var poly in model.polys) {
      view.addPoly(mm, poly);
    }
*/
  }
}





VertexModel makeVertexModel(List data, {bool swap = false}) {
  final  List<List> vertList = data[0];
  final List<Vector3> vectors = vertList.fold([], (c, v) {
      c.add(Vector3(v[2]*1.0, v[1]*1.0, v[0]*.1));
      return c;
  });
  final vertices = Vector3List.fromList(vectors);

  final List<List> faces = data[1];

  final indices =  Uint16List(3 *  faces.length);
  final colors = Int32List(vertices.length);

  int i = 0;
  for (List face in faces) {
      Color color = face[0];
      List<int> tri = face[1];
      indices[i*3] = tri[0];
      indices[i*3+1] = tri[1];
      indices[i*3+2] = tri[2];
      colors[i % vertices.length] = color.value;
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


