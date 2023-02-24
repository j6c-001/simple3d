
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:simple3d/vertex_model.dart';
import 'package:vector_math/vector_math.dart';

import 'constants.dart';
import 'poly.dart';

final  Vector3 up = Vector3(0,-1,0);


class Tri {
  int v0;
  int v1;
  int v2;
  double depth = 0;
  Tri(this.v0, this.v1, this.v2);
}

class View {
  Vector2 dimensions;
  Matrix4 matrix = Matrix4.zero();
  Matrix4 view = Matrix4.zero();
  List<Tri> tris = List.generate(60000, (index) => Tri(0,0,0));
  Vector3 cam = Vector3.zero();
  Vector3 target = Vector3.zero();
  Vector3 camTemp = Vector3.zero();

  final Paint paint = Paint();

  List<double> depth =   Float32List(60000);
  Float32List vertices = Float32List(60000);
  Uint16List indices;
  Int32List colors;


  // stats tracking
  int cntPolys = 0;  // # of polygons processed
  int cntPolysRendered = 0; // # of polygons rendered for a frame.

  final int maxTris;

  int colorIndex = 0;
  int vertexIndex = 0;
  int indiceIndex = 0;
  int triIndex = 0;

  View(this.maxTris, double sizeX, double sizeY):
        dimensions = Vector2(sizeX, sizeY),
        indices = Uint16List(maxTris * 3),
        colors = Int32List(60000);

  final p = makePerspectiveMatrix(57.3 * 2 , 16/9, 1, -1);

  prepareFrame() {
    vertexIndex = 0;
    colorIndex  = 0;
    indiceIndex = 0;
    triIndex = 0;
    cntPolys = 0;
  }

  void addModelInstances(VertexModel m, Matrix4 mm) {
    Matrix4 VxMM = Matrix4.copy(matrix);
    VxMM.multiply(mm);

    int vertexIndexOffset = vertexIndex ~/ 2;
    Vector4 tv = Vector4.zero();
    for(int i = 0; i < m.vertices.length; i++)
    {
      Vector3 v = m.vertices[i];
      tv.setValues(v.x, v.y, v.z, 1);
      VxMM.transform(tv);
      depth[vertexIndex ~/ 2] = tv.w;
      vertices[vertexIndex++] = (tv.x/tv.w+1)*dimensions.x/2;
      vertices[vertexIndex++] = (tv.y/tv.w+1)*dimensions.y/2;
      colors[colorIndex++] = m.colors[colorIndex % m.colors.length];
    }



    for(int t = 0 ; t < m.indices.length;) {
      var v = tris[triIndex];
      v.v0 = vertexIndexOffset + m.indices[t++];
      v.v1 = vertexIndexOffset + m.indices[t++];
      v.v2 = vertexIndexOffset + m.indices[t++];
      v.depth = (depth[v.v0] + depth[v.v1] + depth[v.v2]) / 3;

      cntPolys++;
      if (v.depth < 10 || (vertices[v.v0*2] > dimensions.x) || (vertices[v.v0*2+1] > dimensions.y)
        || (vertices[v.v1*2] > dimensions.x) || (vertices[v.v1*2+1] > dimensions.y)
        || (vertices[v.v2*2] > dimensions.x) || (vertices[v.v2*2+1] > dimensions.y)
        || (vertices[v.v0*2] < 0) || (vertices[v.v0*2+1] < 0 )
        || (vertices[v.v1*2] < 0) || (vertices[v.v1*2+1] < 0 )
        || (vertices[v.v2*2] < 0) || (vertices[v.v2*2+1] < 0 )
      )  {
        continue;
      }

      triIndex++;
    }



  }

  renderFrame(Canvas c) {

    if (vertexIndex == 0 ) {
      return;
    }

    cntPolysRendered = triIndex;
    // sort the tri farthest to nearest
    mergeSort<Tri>(tris, start: 0, end: triIndex, compare: (Tri a, Tri b) => a.depth > b.depth ? -1 : 1);

    // write the indices into the array in the sorted order
    indiceIndex = 0;
    for(int t = 0; t < triIndex; t++) {
        indices[indiceIndex++] = tris[t].v0;
        indices[indiceIndex++] = tris[t].v1;
        indices[indiceIndex++] = tris[t].v2;
    }

    final vs = Vertices.raw(VertexMode.triangles,
        Float32List.sublistView(vertices,0, vertexIndex),
        indices: Uint16List.sublistView(indices, 0, indiceIndex),
        colors:  Int32List.sublistView(colors, 0, colorIndex)
    );

     c.drawVertices(vs, BlendMode.dst, paint);
  }

  update(cx,cy,cz, tx,ty,tz) {
    cam.setValues(cx,cy,cz);
    target.setValues(tx,ty,tz);
    setViewMatrix(view, cam, target, up);
    matrix.setFrom(p);
    matrix.multiply(view);
  }



}