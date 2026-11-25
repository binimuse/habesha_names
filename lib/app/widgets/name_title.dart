import 'package:flutter/material.dart';

import '../core/extensions/context_x.dart';
import '../data/models/name_model.dart';

/// Latin name (Fraunces) over the Ge'ez name (Noto Serif Ethiopic).
///
/// Always laid out at full "detail page" size and scaled down with a
/// [FittedBox] to fit [height]. Because cards and the detail page render the
/// same widget, the Hero flight between them scales smoothly.
class NameTitle extends StatelessWidget {
  const NameTitle({
    super.key,
    required this.name,
    this.height,
    this.alignment = Alignment.centerLeft,
    this.showGeez = true,
  });

  final NameModel name;

  /// Box height; null = natural (largest) size.
  final double? height;
  final Alignment alignment;
  final bool showGeez;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment cross = alignment.x < 0
        ? CrossAxisAlignment.start
        : alignment.x > 0
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center;
    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        Text(name.nameLatin, style: context.appText.nameDisplay, maxLines: 1),
        if (showGeez && name.nameGeez.isNotEmpty)
          Text(
            name.nameGeez,
            maxLines: 1,
            style: context.appText.nameGeez.copyWith(
              color: context.palette.inkMuted,
            ),
          ),
      ],
    );
    // Material keeps text styling intact while the Hero is in flight.
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: height,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: column,
        ),
      ),
    );
  }
}
