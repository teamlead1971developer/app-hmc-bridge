import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/branding.dart';
import 'glass_card.dart';
import 'glass_controls.dart';

enum JoyCodeFormat { qr, barcode }

/// QR / barcode switcher for Joy privileges and coupons.
class JoyCodeDisplay extends StatefulWidget {
  const JoyCodeDisplay({
    super.key,
    required this.code,
    required this.title,
    this.instruction =
        'Present this code at the storefront to redeem your benefit.',
    this.conditions = const [],
    this.expired = false,
  });

  final String code;
  final String title;
  final String instruction;
  final List<String> conditions;
  final bool expired;

  @override
  State<JoyCodeDisplay> createState() => _JoyCodeDisplayState();
}

class _JoyCodeDisplayState extends State<JoyCodeDisplay> {
  JoyCodeFormat _format = JoyCodeFormat.qr;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 26,
      shadows: kHeroCardShadows,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: displayStyle(size: 17, weight: 600)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilterChipButton(
                  label: 'QR code',
                  selected: _format == JoyCodeFormat.qr,
                  onTap: () => setState(() => _format = JoyCodeFormat.qr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChipButton(
                  label: 'Barcode',
                  selected: _format == JoyCodeFormat.barcode,
                  onTap: () => setState(() => _format = JoyCodeFormat.barcode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Opacity(
            opacity: widget.expired ? 0.45 : 1,
            child: Center(
              child: _format == JoyCodeFormat.qr
                  ? QrImageView(
                      data: widget.code,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    )
                  : BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: widget.code,
                      width: 260,
                      height: 72,
                      drawText: false,
                      color: kText,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.code,
            style: monoStyle(size: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            widget.instruction,
            style: bodyStyle(size: 13, color: kTextMuted, height: 1.45),
            textAlign: TextAlign.center,
          ),
          if (widget.conditions.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Conditions', style: bodyStyle(size: 12, weight: 600)),
            const SizedBox(height: 8),
            for (final line in widget.conditions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: kRedLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: bodyStyle(size: 12, color: kTextMuted, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
