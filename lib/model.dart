
import 'package:vector_math/vector_math_64.dart';

import 'poly.dart';
import 'view3d.dart';


class Model {
  Model() {
    polys = getModel();
  }

  List<Poly> polys = [];
  getModel() {}

  getWireframe() {
    return true;
  }
}


mixin ModelInstance {
  late  Model model;
  final Matrix4 mm = Matrix4.zero();

  Vector3 scale = Vector3(1, 1, 1);

  void prepareFrame(Vector3 position, Vector3 heading,  View3d view, double angle) {
    setModelMatrix(mm, heading.normalized() , Vector3(0, -1, 0),
        position.x, position.y, position.z);
    mm.scale(scale.x, scale.y, scale.z);
    mm.rotate(heading.normalized(), angle);
   /* for (var poly in model.polys) {
      view.addPoly(mm, poly);
    }*/
  }
}



/*

List<Poly> makeModel(List<List> polys, bool wireFrame, {bool swap = false}) {
  return polys.map((poly) {
    final pts = poly[1].map<Vector3>((List<num> point) {
      return swap ? Vector3(point[0] * 1.0, point[2] * 1.0, point[1] * 1.0) :
      Vector3(point[0] * 1.0, point[1] * 1.0, point[2] * 1.0);
    }).toList();
    final Color color = poly[0];
    return Poly(pts, color, wireFrame);
  }).toList();
}
*/
