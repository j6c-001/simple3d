
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:simple3d/vertex_model.dart';
import 'package:vector_math/vector_math.dart';



final  Vector3 up = Vector3(0,-1,0);


class Tri {
  Float32List v = Float32List(9);
  double depth = 0;
  int color = 0;

  void set(int i, int si, Float32List source) {
    v[i*3+0] = source[si*3+0];
    v[i*3+1] = source[si*3+1];
    v[i*3+2] = source[si*3+2];

  }

  double x(int i) => v[i*3+0];
  double y(int i) => v[i*3+1];
  double z(int i) => v[i*3+2];


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

  BlendMode blendMode = BlendMode.dst;

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
        tris = List.generate(maxTris, (index) => Tri()),
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

  Float32List screenSpaceWorking = Float32List(300);
  void addModelInstances(VertexModel m, Matrix4 mm) {
    VxMM.setFrom(matrix);
    VxMM.multiply(mm);

   for(int i = 0; i < m.vertices.length; ++i)
    {
      Vector3 v = m.vertices[i];
      tv.setValues(v.x, v.y, v.z, 1);
      VxMM.transform(tv);

      screenSpaceWorking[i*3+0] = (tv.x/tv.w+1)*dimensions.x/2;
      screenSpaceWorking[i*3+1] = (tv.y/tv.w+1)*dimensions.y/2;
      screenSpaceWorking[i*3+2] = tv.w;

    }

    for(int t = 0 ; t < m.indices.length;) {
      Tri tri = tris[triIndex];
      tri.color = m.colors[t ~/ 3];

      tri.set(0, m.indices[t++], screenSpaceWorking);
      tri.set(1, m.indices[t++], screenSpaceWorking);
      tri.set(2, m.indices[t++], screenSpaceWorking);

      tri.depth = (tri.z(0) + tri.z(1)  + tri.z(2))/3;

      cntPolys++;
      if (tri.depth < 1
          || (tri.x(0) > dimensions.x) || (tri.y(0) > dimensions.y)
          || (tri.x(1) > dimensions.x) || (tri.y(1) > dimensions.y)
          || (tri.x(2) > dimensions.x) || (tri.y(2) > dimensions.y)
          || (tri.x(0) < 0) || (tri.y(0) < 0)
          || (tri.x(1) < 0) || (tri.y(1) < 0)
          || (tri.x(2) < 0) || (tri.y(2) < 0)
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

    // write the duplicated vertices and indices into the array in the sorted order
    indiceIndex = 0;
    int vi = 0;
    for(int t = 0; t < triIndex; t++) {
       Tri tri = tris[t];
        vertices[vi++] = tri.x(0);
        vertices[vi++] = tri.y(0);
        vertices[vi++] = tri.x(1);
        vertices[vi++] = tri.y(1);
        vertices[vi++] = tri.x(2);
        vertices[vi++] = tri.y(2);

        colors[t*3+0] = tri.color;
        colors[t*3+1] = tri.color;
        colors[t*3+2] = tri.color;


        indices[indiceIndex++] = t*3;
        indices[indiceIndex++] = t*3+1;
        indices[indiceIndex++] = t*3+2;

    }
    vertexIndex = vi;
    colorIndex = vi ~/ 2;
    Vertices vs = Vertices.raw(VertexMode.triangles,
        Float32List.sublistView(vertices, 0, vertexIndex),
        indices: Uint16List.sublistView(indices, 0, indiceIndex),
        colors: colors.sublist(0, colorIndex) // Int32List.sublist(colors, 0, colorIndex),
    );


    c.drawVertices(vs, blendMode, paint);
  }

  update(double  cx,double cy,double cz, double tx,double ty, double tz) {
    cam.setValues(cx,cy,cz);
    target.setValues(tx,ty,tz);
    setViewMatrix(view, cam, target, up);
    matrix.setFrom(projection);
    matrix.multiply(view);
  }



}