import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphx/graphx/geom/gxpoint.dart';
import 'package:vector_math/vector_math_64.dart';

class GxMatrix {
  double a, b, c, d, tx, ty;

  Matrix4 _native;

  @override
  String toString() {
    return 'GxMatrix {a: $a, b: $b, c: $c, d: $d, tx: $tx, ty: $ty}';
  }

  Matrix4 toNative() {
    _native ??= Matrix4.identity();
    _native.setValues(a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1);
    return _native;
  }

  static GxMatrix fromNative(Matrix4 m) {
    return GxMatrix(
      m.storage[0],
      m.storage[4],
      m.storage[1],
      m.storage[5],
      m.storage[12],
      m.storage[13],
    );
  }

  GxMatrix zoomAroundPoint(GxPoint center, double zoomFactor) {
    var t1 = GxMatrix();
    t1.translate(-center.x, -center.y);
    var sc = GxMatrix();
    sc.scale(zoomFactor, zoomFactor);
    var t2 = GxMatrix();
    t2.translate(center.x, center.y);
    var zoom = GxMatrix();
    zoom.concat(t1).concat(sc).concat(t2);
    return concat(zoom);
  }

  GxMatrix([
    this.a = 1,
    this.b = 0,
    this.c = 0,
    this.d = 1,
    this.tx = 0,
    this.ty = 0,
  ]);

  GxMatrix copyFrom(GxMatrix from) {
    a = from.a;
    b = from.b;
    c = from.c;
    d = from.d;
    tx = from.tx;
    ty = from.ty;
    return this;
  }

  GxMatrix setTo(double a, double b, double c, double d, double tx, double ty) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
    return this;
  }

  GxMatrix.fromList(List<double> value) {
    a = value[0];
    b = value[1];
    c = value[3];
    d = value[4];
    tx = value[2];
    ty = value[5];
  }

  GxMatrix identity() {
    a = 1;
    b = 0;
    c = 0;
    d = 1;
    tx = 0;
    ty = 0;
    return this;
  }

  GxMatrix setTransform(
    double x,
    double y,
    double pivotX,
    double pivotY,
    double scaleX,
    double scaleY,
    double skewX,
    double skewY,
    double rotation,
  ) {
    a = math.cos(rotation + skewY) * scaleX;
    b = math.sin(rotation + skewY) * scaleX;
    c = -math.sin(rotation - skewX) * scaleY;
    d = math.cos(rotation - skewX) * scaleY;
    tx = x - ((pivotX * a) + (pivotY * c));
    ty = y - ((pivotX * b) + (pivotY * d));
    return this;
  }

  GxMatrix append(GxMatrix matrix) {
    final a1 = a;
    final b1 = b;
    final c1 = c;
    final d1 = d;
//    a = (matrix.a * a1) + (matrix.b * c1);
//    b = (matrix.a * b1) + (matrix.b * d1);
//    c = (matrix.c * a1) + (matrix.d * c1);
//    d = (matrix.c * b1) + (matrix.d * d1);
//    tx = (matrix.tx * a1) + (matrix.ty * c1) + tx;
//    ty = (matrix.tx * b1) + (matrix.ty * d1) + ty;

    this.a = (matrix.a * a1) + (matrix.b * c1);
    this.b = (matrix.a * b1) + (matrix.b * d1);
    this.c = (matrix.c * a1) + (matrix.d * c1);
    this.d = (matrix.c * b1) + (matrix.d * d1);

    this.tx = (matrix.tx * a1) + (matrix.ty * c1) + this.tx;
    this.ty = (matrix.tx * b1) + (matrix.ty * d1) + this.ty;

    return this;
  }

  GxMatrix concat(GxMatrix matrix) {
    double a1, c1, tx1;
    a1 = a * matrix.a + b * matrix.c;
    b = a * matrix.b + b * matrix.d;
    a = a1;

    c1 = c * matrix.a + d * matrix.c;
    d = c * matrix.b + d * matrix.d;
    c = c1;

    tx1 = tx * matrix.a + ty * matrix.c + matrix.tx;
    ty = tx * matrix.b + ty * matrix.d + matrix.ty;
    tx = tx1;
    return this;

//    var a1 = a * p_matrix.a + b * p_matrix.c;
//    b = a * p_matrix.b + b * p_matrix.d;
//    a = a1;
//
//    var c1 = c * p_matrix.a + d * p_matrix.c;
//    d = c * p_matrix.b + d * p_matrix.d;
//
//    c = c1;
//
//    var tx1 = tx * p_matrix.a + ty * p_matrix.c + p_matrix.tx;
//    ty = tx * p_matrix.b + ty * p_matrix.d + p_matrix.ty;
//    tx = tx1;
  }

//  public function concat(p_matrix:GMatrix):Void {
//  var a1:Float = a * p_matrix.a + b * p_matrix.c;
//  b = a * p_matrix.b + b * p_matrix.d;
//  a = a1;
//
//  var c1:Float = c * p_matrix.a + d * p_matrix.c;
//  d = c * p_matrix.b + d * p_matrix.d;
//
//  c = c1;
//
//  var tx1:Float = tx * p_matrix.a + ty * p_matrix.c + p_matrix.tx;
//  ty = tx * p_matrix.b + ty * p_matrix.d + p_matrix.ty;
//  tx = tx1;
//}

  GxMatrix invert() {
    double n = a * d - b * c;
    if (n == 0) {
      a = b = c = d = 0;
      tx = -tx;
      ty = -ty;
    } else {
      n = 1 / n;
      double a1 = d * n;
      d = a * n;
      a = a1;
      b *= -n;
      c *= -n;
      double tx1 = -a * tx - c * ty;
      ty = -b * tx - d * ty;
      tx = tx1;
    }
    return this;
  }

  GxMatrix scale(double scaleX, [double scaleY]) {
    scaleY ??= scaleX;
    a *= scaleX;
    b *= scaleY;
    c *= scaleX;
    d *= scaleY;
    tx *= scaleX;
    ty *= scaleY;
    return this;
  }

  void skew(double skewX, double skewY) {
//    print("Skews: $skewX, $skewY");
//    c = math.tan(skewX);
//    b = math.tan(skewY);
    var sinX = math.sin(skewX);
    var cosX = math.cos(skewX);
    var sinY = math.sin(skewY);
    var cosY = math.cos(skewY);
    setTo(
      a * cosY - b * sinX,
      a * sinY + b * cosX,
      c * cosY - d * sinX,
      c * sinY + d * cosX,
      tx * cosY - ty * sinX,
      tx * sinY + ty * cosX,
    );
  }

  void rotate(double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);

    var a1 = a * cos - b * sin;
    b = a * sin + b * cos;
    a = a1;

    var c1 = c * cos - d * sin;
    d = c * sin + d * cos;
    c = c1;

    var tx1 = tx * cos - ty * sin;
    ty = tx * sin + ty * cos;
    tx = tx1;
  }

  GxMatrix translate(double x, double y) {
    tx += x;
    ty += y;
    return this;
  }

  GxPoint transformPoint(GxPoint point, [GxPoint out]) {
    return transformCoords(point.x, point.y, out);
  }

  GxPoint transformInversePoint(GxPoint point, [GxPoint out]) {
    return transformInverseCoords(point.x, point.y, out);
  }

  GxPoint transformInverseCoords(double x, double y, [GxPoint out]) {
    out ??= GxPoint();
    final id = 1 / ((a * d) + (c * -b));
    out.x = (d * id * x) + (-c * id * y) + (((ty * c) - (tx * d)) * id);
    out.y = (a * id * y) + (-b * id * x) + (((-ty * a) + (tx * b)) * id);
    return out;
  }

  GxPoint transformCoords(double x, double y, [GxPoint out]) {
    out ??= GxPoint();
    out.x = a * x + c * y + tx;
    out.y = d * y + b * x + ty;
    return out;
  }
}
