import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/branding.dart';
import 'glass_card.dart';
import 'glass_controls.dart';

/// Photo proof (+ optional reason) for remote check-in or check-out.
class RemoteAttendancePanel extends StatefulWidget {
  const RemoteAttendancePanel({
    super.key,
    required this.actionLabel,
    required this.submitLabel,
    required this.onSubmit,
    this.reasonRequired = false,
    this.enabled = true,
  });

  final String actionLabel;
  final String submitLabel;
  final Future<void> Function({required String photoPath, String? reason}) onSubmit;
  final bool reasonRequired;
  final bool enabled;

  @override
  State<RemoteAttendancePanel> createState() => _RemoteAttendancePanelState();
}

class _RemoteAttendancePanelState extends State<RemoteAttendancePanel> {
  static bool _pickerInUse = false;

  final _picker = ImagePicker();
  final _reason = TextEditingController();
  String? _photoPath;
  bool _submitting = false;
  bool _picking = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_picking || _pickerInUse || _submitting || !widget.enabled) return;

    _picking = true;
    _pickerInUse = true;
    if (mounted) setState(() {});

    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() {
        _photoPath = file.path;
        _error = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'multiple_request') return;
      setState(() => _error = 'Could not open camera. Please try again.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not open camera. Please try again.');
    } finally {
      _pickerInUse = false;
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    if (_photoPath == null) {
      setState(() => _error = 'A proof photo is required.');
      return;
    }
    final reason = _reason.text.trim();
    if (widget.reasonRequired && reason.isEmpty) {
      setState(() => _error = 'Please provide a reason for early check-out.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(photoPath: _photoPath!, reason: reason.isEmpty ? null : reason);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save attendance.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.actionLabel,
          style: bodyStyle(size: 13, color: kTextMuted),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.enabled && !_submitting && !_picking ? _pickPhoto : null,
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            radius: 16,
            blur: 20,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kGlassInnerFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGlassInnerBorder),
                    image: _photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(_photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoPath == null
                      ? Icon(LucideIcons.camera, size: 22, color: kTextFaint)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _picking
                            ? 'Opening camera…'
                            : _photoPath == null
                                ? 'Add proof photo'
                                : 'Photo attached',
                        style: bodyStyle(size: 14, weight: 500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _picking ? 'Please wait' : 'Tap to open camera',
                        style: bodyStyle(size: 12, color: kTextFaint),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 16, color: kTextFaint),
              ],
            ),
          ),
        ),
        if (widget.reasonRequired) ...[
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: 14,
            blur: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason', style: bodyStyle(size: 11, color: kTextFaint)),
                TextField(
                  controller: _reason,
                  enabled: widget.enabled && !_submitting,
                  style: bodyStyle(size: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Why are you leaving before shift end?',
                    hintStyle: bodyStyle(size: 14, color: kTextFaint),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: bodyStyle(size: 12, color: kRedLight)),
        ],
        const SizedBox(height: 14),
        BridgePrimaryButton(
          label: _submitting ? 'Saving…' : widget.submitLabel,
          icon: LucideIcons.check,
          onPressed: widget.enabled && !_submitting ? _submit : null,
        ),
      ],
    );
  }
}
