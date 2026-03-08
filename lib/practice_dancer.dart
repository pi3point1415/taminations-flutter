/*

  Taminations Square Dance Animations
  Copyright (C) 2026 Brad Christie

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import 'common_flutter.dart';

class PracticeDancer extends Dancer {

  static const ANGLESENSITIVITY = 0.5;
  static const MOVESENSITIVITY = 1.0;
  static const DIRECTIONALPHA = 0.9;
  static const DIRECTIONTHRESHOLD = 0.002;
  static const NOPOINT = Vector();
  static const NODIRECTION = Vector();

  bool practiceMousePressed = true;

  var onTrack = true;

  //  For moving dancer with mouse and keys
  var shiftDown = false;
  var ctlDown = false;
  var _primaryDirection = NODIRECTION;

  var cardinalControl = true;

  var wDown = false;
  var sDown = false;
  var aDown = false;
  var dDown = false;

  var lDown = false;
  var rDown = false;

  //  For moving dancer with fingers
  var _primaryid = -1;
  var _secondaryid = -1;
  var _primaryTouch = NOPOINT;
  var _primaryMove = NOPOINT;
  var _secondaryTouch = NOPOINT;
  var _secondaryMove = NOPOINT;
  var primaryIsLeft = true;

  //  Need a val for original fill color, as we change it
  final Color _onTrackColor;
  @override
  Color get drawColor => _onTrackColor.darker();

  PracticeDancer(String number, String numberCouple, int gender, Color fillColor, Matrix mat, List<Movement> moves) :
        _onTrackColor = fillColor,
        super(
          number: number,
          numberCouple: numberCouple,
          gender: gender,
          fillColor: fillColor,
          startPosition: mat,
          geometryType: Geometry.SQUARE,
          moves: moves);

  factory PracticeDancer.fromData({required int gender,
    String number='', String couple='',
    required double x, required double y, required double angle,
    Color color = Color.WHITE,
    Geometry? geom,
    List<Movement> path = const <Movement>[]
  }) {
    final mat = Matrix.getTranslation(x,y) *
        Matrix.getRotation(angle.toRadians);
    return PracticeDancer(number, couple, gender, color, mat, path);
  }


  Matrix computeMatrix(double beat) {
    final savetx = tx.clone();
    super.animate(beat);
    final computetx = tx.clone();
    tx = savetx;
    return computetx;
  }

  @override
  void animate(double beat) {
    fillColor = (beat <= 0 || onTrack)
        ? _onTrackColor.veryBright()
        : Color.GRAY;
    if (beat <= -1.0) {
      tx = starttx;
      _primaryTouch = Vector();
      _primaryMove = Vector();
    } else {

      var trans = Matrix.getTranslation(
          ((wDown ? 0.02 : 0) - (sDown ? 0.02 : 0)) * MOVESENSITIVITY,
          ((aDown ? 0.02 : 0) - (dDown ? 0.02 : 0)) * MOVESENSITIVITY
      );

      // Movement relative to facing direction
      if (!cardinalControl) {
        final angle = tx.angle;
        trans = Matrix.getRotation(angle) * trans * Matrix.getRotation(-angle);
      }

      tx = trans * tx;

      var a2 = _primaryMove - tx.location;

      if (_primaryTouch != NOPOINT) {
        tx = tx * Matrix.getRotation(-tx.angle) * Matrix.getRotation(a2.angle);
      }
      else {
        tx = tx * Matrix.getRotation(((lDown ? 0.05 : 0) - (rDown ? 0.05 : 0)) * ANGLESENSITIVITY);
      }
    }
  }

  void touchDown(int id, Vector pos, {required bool isMouse}) {
    if (practiceMousePressed || !isMouse)
      _touchDownAction(id, pos, isMouse: isMouse);
    else
      _touchUpAction(id);
  }

  void _touchDownAction(int id, Vector pos, {required bool isMouse}) {
    _primaryTouch = pos;
  }

  void touchMove(int id, Vector pos) {
    _primaryMove = pos;
  }

  void touchUp(int id, Vector pos, {required bool isMouse}) {
    if (practiceMousePressed || !isMouse)
      _touchUpAction(id);
    else
      _touchDownAction(id, pos, isMouse: isMouse);
  }

  void _touchUpAction(int id) {
    _primaryTouch = NOPOINT;
  }


}