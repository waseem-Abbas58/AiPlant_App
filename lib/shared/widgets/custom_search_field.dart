import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_sizes.dart';
import '../../core/helpers/permission_helper.dart';
import '../components/custom_snackbar.dart';
import 'custom_text_field.dart'; 

class CustomSearchField extends StatefulWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,   
    this.enableVoice = false,  
    this.fillColor,     
    this.borderRadius, 
    this.height,
    this.onVoiceResult,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool enableVoice;
  final Color? fillColor;
  final double? borderRadius;
  final double? height;
  final ValueChanged<String>? onVoiceResult;

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  TextEditingController? _internalController;
  final SpeechToText _speech = SpeechToText();
  var _listening = false; 
  TextEditingController get _controller => 
      widget.controller ?? _internalController!;   
  
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _internalController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    await PermissionHelper.request(AppPermission.microphone);
    if (!await PermissionHelper.isGranted(AppPermission.microphone)) {
      final locked =
          await PermissionHelper.isPermanentlyDenied(AppPermission.microphone);
      CustomSnackbar.warning(
        title: 'Microphone needed',
        message: locked
            ? 'Enable microphone in Settings to search by voice.'
            : 'Microphone permission is required for voice search.',
        actionLabel: locked ? 'Settings' : null,
        onAction: locked ? PermissionHelper.openSettings : null,
      );
      return;
    }

    final ready = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!ready) {
      CustomSnackbar.info(
        title: 'Voice unavailable',
        message: 'Speech is not available on this device right now.',
      );
      return;
    }

    if (mounted) setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        widget.onChanged?.call(_controller.text);
        if (result.finalResult) {
          final spoken = _controller.text.trim();
          if (spoken.isNotEmpty) {
            widget.onVoiceResult?.call(spoken);
          }
        }
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(
        minWidth: AppSizes.iconLg.w,
        minHeight: widget.height?.h ?? AppSizes.textFieldHeight.h,
      ),
      icon: Icon(icon, size: AppSizes.iconSm.sp + 2.sp, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.mutedText;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return CustomTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          hintText: _listening ? 'Listening…' : widget.hintText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          fillColor: widget.fillColor,
          borderRadius: widget.borderRadius ?? AppRadius.circular,
          enabledBorderColor: widget.fillColor,
          focusedBorderColor: _listening ? AppColors.lightGreen : null,
          height: widget.height,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 7.w), 
            child: SizedBox(
              width: 20.w,
              height: widget.height?.h ?? AppSizes.textFieldHeight.h,
              child: Center(
                child: Icon( 
                  Icons.search_rounded,
                  size: 20.sp,
                  color: iconColor,
                ),
              ),
            ),
          ),
          suffixIcon: hasText || widget.enableVoice
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasText)
                      _iconButton(
                        icon: Icons.close_rounded,
                        color: iconColor,
                        tooltip: 'Clear',
                        onPressed: widget.enabled ? _clear : null,
                      ),
                    if (widget.enableVoice)
                      _iconButton(
                        icon: _listening
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        color: _listening ? AppColors.error : iconColor,
                        tooltip: _listening ? 'Stop' : 'Voice search',
                        onPressed: widget.enabled
                            ? () {
                                HapticFeedback.selectionClick();
                                _toggleVoice();
                              }
                            : null,
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
