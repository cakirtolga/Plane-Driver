import 'dart:math' as math;

import 'package:flame/components.dart';

/// A collision profile is intentionally composed from several convex pieces.
/// Aircraft never use one rectangle/triangle/bounding box as their gameplay mask.
class CollisionProfile {
  const CollisionProfile({required this.polygons});

  /// Polygon points are normalized around the visual center of the object.
  /// x/y values are in [-0.5, 0.5] and are scaled by the component size.
  final List<List<Vector2>> polygons;

  double maxRadiusForSize(Vector2 size) {
    var maxRadius = 0.0;
    for (final polygon in polygons) {
      for (final p in polygon) {
        final x = p.x * size.x;
        final y = p.y * size.y;
        maxRadius = math.max(maxRadius, math.sqrt(x * x + y * y));
      }
    }
    return maxRadius;
  }
}

class CollisionGeometry {
  CollisionGeometry._();

  static List<List<Vector2>> worldPolygons({
    required CollisionProfile profile,
    required Vector2 center,
    required Vector2 size,
    required double angle,
    double inset = 1.0,
  }) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return profile.polygons.map((polygon) {
      return polygon.map((p) {
        final lx = p.x * size.x * inset;
        final ly = p.y * size.y * inset;
        return Vector2(
          center.x + lx * c - ly * s,
          center.y + lx * s + ly * c,
        );
      }).toList(growable: false);
    }).toList(growable: false);
  }

  static bool profilesOverlap(
    List<List<Vector2>> a,
    List<List<Vector2>> b,
  ) {
    for (final pa in a) {
      for (final pb in b) {
        if (_convexOverlap(pa, pb)) return true;
      }
    }
    return false;
  }

  /// Exact minimum edge-to-edge distance between two composite profiles.
  /// Returns 0 when the profiles overlap.
  static double distanceBetweenProfiles(
    List<List<Vector2>> a,
    List<List<Vector2>> b,
  ) {
    if (profilesOverlap(a, b)) return 0;
    var minDistance = double.infinity;
    for (final pa in a) {
      for (final pb in b) {
        for (var i = 0; i < pa.length; i++) {
          final a1 = pa[i];
          final a2 = pa[(i + 1) % pa.length];
          for (var j = 0; j < pb.length; j++) {
            final b1 = pb[j];
            final b2 = pb[(j + 1) % pb.length];
            minDistance = math.min(
              minDistance,
              _segmentDistance(a1, a2, b1, b2),
            );
          }
        }
      }
    }
    return minDistance;
  }

  static bool _convexOverlap(List<Vector2> a, List<Vector2> b) {
    for (final polygon in [a, b]) {
      for (var i = 0; i < polygon.length; i++) {
        final p1 = polygon[i];
        final p2 = polygon[(i + 1) % polygon.length];
        final edge = p2 - p1;
        final axis = Vector2(-edge.y, edge.x);
        final axisLength = axis.length;
        if (axisLength <= 1e-9) continue;
        axis.scale(1 / axisLength);

        final projA = _project(a, axis);
        final projB = _project(b, axis);
        if (projA.$2 < projB.$1 || projB.$2 < projA.$1) return false;
      }
    }
    return true;
  }

  static (double, double) _project(List<Vector2> polygon, Vector2 axis) {
    var minValue = polygon.first.dot(axis);
    var maxValue = minValue;
    for (var i = 1; i < polygon.length; i++) {
      final value = polygon[i].dot(axis);
      minValue = math.min(minValue, value);
      maxValue = math.max(maxValue, value);
    }
    return (minValue, maxValue);
  }

  static double _segmentDistance(
    Vector2 a1,
    Vector2 a2,
    Vector2 b1,
    Vector2 b2,
  ) {
    if (_segmentsIntersect(a1, a2, b1, b2)) return 0;
    return math.min(
      math.min(_pointSegmentDistance(a1, b1, b2), _pointSegmentDistance(a2, b1, b2)),
      math.min(_pointSegmentDistance(b1, a1, a2), _pointSegmentDistance(b2, a1, a2)),
    );
  }

  static bool _segmentsIntersect(
    Vector2 a,
    Vector2 b,
    Vector2 c,
    Vector2 d,
  ) {
    const epsilon = 1e-8;
    double cross(Vector2 p, Vector2 q, Vector2 r) =>
        (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);
    bool onSegment(Vector2 p, Vector2 q, Vector2 r) =>
        q.x >= math.min(p.x, r.x) - epsilon &&
        q.x <= math.max(p.x, r.x) + epsilon &&
        q.y >= math.min(p.y, r.y) - epsilon &&
        q.y <= math.max(p.y, r.y) + epsilon;

    final c1 = cross(a, b, c);
    final c2 = cross(a, b, d);
    final c3 = cross(c, d, a);
    final c4 = cross(c, d, b);

    if (((c1 > epsilon && c2 < -epsilon) || (c1 < -epsilon && c2 > epsilon)) &&
        ((c3 > epsilon && c4 < -epsilon) || (c3 < -epsilon && c4 > epsilon))) {
      return true;
    }
    if (c1.abs() <= epsilon && onSegment(a, c, b)) return true;
    if (c2.abs() <= epsilon && onSegment(a, d, b)) return true;
    if (c3.abs() <= epsilon && onSegment(c, a, d)) return true;
    if (c4.abs() <= epsilon && onSegment(c, b, d)) return true;
    return false;
  }

  static double _pointSegmentDistance(Vector2 p, Vector2 a, Vector2 b) {
    final ab = b - a;
    final lengthSquared = ab.length2;
    if (lengthSquared <= 1e-9) return p.distanceTo(a);
    final t = ((p - a).dot(ab) / lengthSquared).clamp(0.0, 1.0).toDouble();
    final closest = a + ab * t;
    return p.distanceTo(closest);
  }
}
