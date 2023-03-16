
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:simple3d/vertex_model.dart';
import 'package:vector_math/vector_math.dart';



final  Vector3 up = Vector3(0,-1,0);


class Tri {
  int v0;
  int v1;
  int v2;
  double depth = 0;
  Tri(this.v0, this.v1, this.v2);
}

const sizes = 65000;
class View3d {
  Vector2 dimensions;

  final projection = makePerspectiveMatrix(57.3  , 16/9, 1, -1);

  Matrix4 matrix = Matrix4.zero(); // Projection * View.
  Matrix4 view = Matrix4.zero();
  Vector3 cam = Vector3.zero();
  Vector3 target = Vector3.zero();
  Vector3 camTemp = Vector3.zero();

  final Paint paint = Paint()..isAntiAlias = true;

  Float32List depth ;
  Float32List vertices;
  Float32List tex;
  Uint16List indices;
  Int32List colors;
  List<Tri> tris;

  // stats tracking
  int cntPolys = 0;  // # of polygons processed
  int cntPolysRendered = 0; // # of polygons rendered for a frame.

  final int maxTris;

  int colorIndex = 0;
  int vertexIndex = 0;
  int indiceIndex = 0;
  int triIndex = 0;
  

  View3d(this.maxTris, double sizeX, double sizeY):
        dimensions = Vector2(sizeX, sizeY),
        indices = Uint16List(maxTris * 3),
        tris = List.generate(maxTris, (index) => Tri(0,0,0)),
        depth = Float32List(maxTris),
        colors = Int32List(maxTris * 3),
        vertices = Float32List(maxTris * 3 * 2),
        tex = Float32List(maxTris * 3 * 2);



  prepareFrame() {
    vertexIndex = 0;
    colorIndex  = 0;
    indiceIndex = 0;
    triIndex = 0;
    cntPolys = 0;
  }


  Matrix4 VxMM = Matrix4.zero();
  Vector4 tv = Vector4.zero();
  void addModelInstances(VertexModel m, Matrix4 mm) {
    VxMM.setFrom(matrix);
    VxMM.multiply(mm);

    int vertexIndexOffset = vertexIndex ~/ 2;

   for(int i = 0; i < m.vertices.length; ++i)
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
      if (v.depth < 1 || (vertices[v.v0*2] > dimensions.x) || (vertices[v.v0*2+1] > dimensions.y)
        || (vertices[v.v1*2] > dimensions.x) || (vertices[v.v1*2+1] > dimensions.y)
        || (vertices[v.v2*2] > dimensions.x) || (vertices[v.v2*2+1] > dimensions.y)
        || (vertices[v.v0*2] < 0) || (vertices[v.v0*2+1] < 0 )
        || (vertices[v.v1*2] < 0) || (vertices[v.v1*2+1] < 0 )
        || (vertices[v.v2*2] < 0) || (vertices[v.v2*2+1] < 0 )
      )  {
        continue;
      }

      ++triIndex;
    }

  }

  renderFrame(Canvas c) {
    cntPolysRendered = triIndex;

    if (cntPolysRendered == 0) {
      return;
    }


    // sort the tri farthest to nearest
    mergeSort<Tri>(tris, start: 0, end: triIndex, compare: (Tri a, Tri b) => a.depth > b.depth ? -1 : 1);

    // write the indices into the array in the sorted order
    indiceIndex = 0;
    for(int t = 0; t < triIndex; t++) {
        indices[indiceIndex++] = tris[t].v0;
        indices[indiceIndex++] = tris[t].v1;
        indices[indiceIndex++] = tris[t].v2;
    }

    Vertices vs = Vertices.raw(VertexMode.triangles,
        Float32List.sublistView(vertices, 0, vertexIndex),
        indices: Uint16List.sublistView(indices, 0, indiceIndex),
        colors: colors.sublist(0, colorIndex) // Int32List.sublist(colors, 0, colorIndex),
    );


    c.drawVertices(vs, BlendMode.srcATop, paint);
  }

  update(double  cx,double cy,double cz, double tx,double ty, double tz) {
    cam.setValues(cx,cy,cz);
    target.setValues(tx,ty,tz);
    setViewMatrix(view, cam, target, up);
    matrix.setFrom(projection);
    matrix.multiply(view);
  }



}