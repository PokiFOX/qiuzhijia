import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpflutter_core/mpflutter_core.dart';
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' as wechat_api;
import 'package:mpflutter_core/mpjs/mpjs.dart' as mpjs;
export './mpflutter_text_field.dart';
export './mpflutter_text_form_field.dart';

class MPFlutter_Wechat_EditableInput extends StatefulWidget {
  static final bool runOnDevtools = (() {
    try {
      return mpjs.context["platformViewManager"]['devtools'];
    } catch (e) {
      return false;
    }
  })();

  static final bool runOnAndroid = (() {
    try {
      return wechat_api.wx.getSystemInfoSync().platform == "android";
    } catch (e) {
      return false;
    }
  })();

  static bool shouldUseWechatComponent() {
    if (!kIsMPFlutter) return false;
    if (runOnDevtools) {
      return false;
    } else if (kIsMPFlutterDevmode) {
      return false;
    } else {
      return true;
    }
  }

  final Key? innerKey;
  final TextEditingController? controller;
  final bool forceShowHintText;
  final String? hintText;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Color? cursorColor;
  final Color? backgroundCursorColor;
  final bool obscureText;
  final TextAlign textAlign;
  final bool autofocus;
  final bool? keyboardTypeIDCard;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool disabled;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool? expands;
  final bool? showConfirmBar;

  MPFlutter_Wechat_EditableInput({
    Key? key,
    this.innerKey,
    this.controller,
    this.forceShowHintText = false,
    this.hintText,
    this.focusNode,
    this.style,
    this.cursorColor,
    this.backgroundCursorColor,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.autofocus = false,
    this.keyboardTypeIDCard,
    this.keyboardType,
    this.textInputAction,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.disabled = false,
    this.inputFormatters = const [],
    this.onFocus,
    this.onBlur,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.expands,
    this.showConfirmBar = true,
  }) : super(key: key);

  @override
  State<MPFlutter_Wechat_EditableInput> createState() =>
      _MPFlutter_Wechat_EditableInputState();
}

class _MPFlutter_Wechat_EditableInputState
    extends State<MPFlutter_Wechat_EditableInput> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool _focused = false;
  int _currentLineCount = 1;
  int _cursor = 0;
  bool _inputFromNative = false;
  String _lastNativeValue = '';

  @override
  void initState() {
    super.initState();
    _focused = widget.autofocus;
    _currentLineCount = widget.minLines ?? 1;
    controller = widget.controller ?? TextEditingController(text: "");
    _cursor = controller.text.length;
    _lastNativeValue = controller.text;
    focusNode = widget.focusNode ?? FocusNode();
    if (!MPFlutter_Wechat_EditableInput.shouldUseWechatComponent()) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          widget.onFocus?.call();
        } else {
          widget.onBlur?.call();
        }
      });
    } else {
      controller.addListener(_onControllerChangedFromDart);
    }
  }

  void _onControllerChangedFromDart() {
    if (_inputFromNative) {
      return;
    }
    _cursor = controller.selection.extentOffset;
    _lastNativeValue = controller.text;
    setState(() {});
  }

  @override
  void dispose() {
    if (MPFlutter_Wechat_EditableInput.shouldUseWechatComponent()) {
      controller.removeListener(_onControllerChangedFromDart);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MPFlutter_Wechat_EditableInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller = widget.controller ?? TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    if (!MPFlutter_Wechat_EditableInput.shouldUseWechatComponent()) {
      return Align(
        alignment: Alignment.centerLeft,
        child: EditableText(
          key: widget.innerKey,
          controller: controller,
          focusNode: focusNode,
          style: widget.style ?? TextStyle(),
          cursorColor: widget.cursorColor ?? Colors.black,
          backgroundCursorColor: widget.backgroundCursorColor ?? Colors.black,
          obscureText: widget.obscureText,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          minLines: widget.minLines,
          expands: widget.expands ?? false,
        ),
      );
    }
    final fontSize = widget.style?.fontSize ?? 12;
    final maxLines = widget.maxLines ?? 1;
    final minLines = widget.minLines ?? 1;
    final lineHeight = fontSize * 1.25;
    final singleLineHeight = max(lineHeight, 20.0);
    final visibleLines = _currentLineCount.clamp(minLines, maxLines);
    final contentHeight = visibleLines == 1
        ? singleLineHeight
        : lineHeight * visibleLines;
    final useAutoHeight = maxLines > 1 &&
        (widget.expands == true || widget.minLines != null);
    final nativeAutoHeight = useAutoHeight && visibleLines > 1;
    final paddingTop = visibleLines == 1
        ? max(0.0, (contentHeight - lineHeight) / 2)
        : 0.0;
    final nativeFixedStyle = nativeAutoHeight
        ? ''
        : 'height:${contentHeight}px;padding-top:${paddingTop}px;';
    final placeholderStyle = visibleLines == 1
        ? 'line-height:${contentHeight}px;'
        : 'line-height:${lineHeight}px;';
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: lineHeight * maxLines),
      child: SizedBox(
        height: contentHeight,
        child: Align(
          alignment: visibleLines > 1
              ? Alignment.topLeft
              : Alignment.centerLeft,
          child: MPFlutterPlatformView(
        viewClazz: "MPFlutter_Wechat_EditableInput",
        viewProps: {
          "textarea": maxLines > 1,
          "maxLength": widget.maxLength ?? -1,
          "defaultText": _focused ? _lastNativeValue : controller.text,
          "cursor": _cursor,
          "autoHeight": nativeAutoHeight,
          "lineHeight": lineHeight,
          "contentHeight": contentHeight,
          "paddingTop": paddingTop,
          "nativeFixedStyle": nativeFixedStyle,
          "placeholderStyle": placeholderStyle,
          "hintText": widget.forceShowHintText
              ? widget.hintText
              : (focusNode.hasFocus ? widget.hintText : ""),
          "obscureText": widget.obscureText,
          "cursorColor": _colorToHex(widget.cursorColor, "#000000"),
          "fontSize": fontSize,
          "textColor": _colorToHex(widget.style?.color, "#000000"),
          "textAlign": (() {
            final name = widget.textAlign.name;
            final textDirection = Directionality.of(context);
            if (name == "end") {
              if (textDirection == TextDirection.ltr)
                return "right";
              else
                return "left";
            } else if (name == "start") {
              if (textDirection == TextDirection.ltr)
                return "left";
              else
                return "right";
            }
            return name;
          })(),
          "autofocus": _focused,
          "keyboardType": (() {
            if (widget.keyboardTypeIDCard == true) {
              return "idcard";
            }
            final keyboardType = widget.keyboardType;
            if (keyboardType == null) return "text";
            if (keyboardType == TextInputType.number) {
              if (keyboardType.decimal == true) {
                return "digit";
              }
              return "number";
            }
            if (keyboardType == TextInputType.phone) {
              return "number";
            }
            if (keyboardType == TextInputType.name) {
              return "nickname";
            }
            return "text";
          })(),
          "textInputAction": (() {
            if (maxLines > 1) {
              final action = widget.textInputAction?.name ?? 'return';
              return action == 'newline' ? 'return' : action;
            }
            return widget.textInputAction?.name ?? "done";
          })(),
          "disabled": widget.disabled,
          "showConfirmBar": widget.showConfirmBar ?? true,
        },
        eventCallback: (originEvent, detail) {
          final event = originEvent.toLowerCase();
          switch (event) {
            case "input":
              final value = detail["value"] as String;
              final cursor = detail["cursor"] as int? ?? value.length;
              _cursor = cursor;
              final oldValue = controller.value;
              var newValue = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: cursor),
              );
              widget.inputFormatters.forEach((element) {
                newValue = element.formatEditUpdate(oldValue, newValue);
              });
              if (newValue.text != oldValue.text ||
                  newValue.selection != oldValue.selection) {
                _inputFromNative = true;
                controller.value = newValue;
                _cursor = newValue.selection.extentOffset;
                _lastNativeValue = newValue.text;
                _inputFromNative = false;
                if (maxLines > 1) {
                  final hardLineCount = newValue.text.split('\n').length;
                  final nextLineCount =
                      hardLineCount.clamp(minLines, maxLines);
                  if (nextLineCount > _currentLineCount) {
                    _currentLineCount = nextLineCount;
                    setState(() {});
                  }
                }
                if (newValue.text != oldValue.text) {
                  widget.onChanged?.call(newValue.text);
                }
              }
              return newValue.text;
            case "focus":
              setState(() {
                _focused = true;
                _cursor = controller.selection.extentOffset;
                _lastNativeValue = controller.text;
              });
              widget.onFocus?.call();
              if (widget.maxLines != null && widget.maxLines! > 1) {
                mpjs.context["FlutterHostView"]['shared']['textareaHasFocus'] =
                    true;
              }
              break;
            case "blur":
              setState(() {
                _focused = false;
                _lastNativeValue = controller.text;
                _cursor = controller.text.length;
              });
              widget.onBlur?.call();
              widget.onEditingComplete?.call();
              focusNode.unfocus();
              if (widget.maxLines != null && widget.maxLines! > 1) {
                mpjs.context["FlutterHostView"]['shared']['textareaHasFocus'] =
                    false;
              }
              break;
            case "confirm":
              final value = detail["value"];
              final oldValue = TextEditingValue(text: this.controller.text);
              var newValue = TextEditingValue(text: value);
              widget.inputFormatters.forEach((element) {
                newValue = element.formatEditUpdate(oldValue, newValue);
              });
              if (newValue.text != oldValue.text) {
                this.controller.text = newValue.text;
              }
              widget.onSubmitted?.call(newValue.text);
              break;
            case "linechange":
              if (maxLines > 1) {
                final lineCount = _readLineCountFromDetail(detail);
                if (lineCount != null) {
                  setState(() {
                    _currentLineCount =
                        lineCount.clamp(minLines, maxLines);
                  });
                  if (lineCount > 1 &&
                      widget.maxLines != null &&
                      widget.maxLines! > 1) {
                    mpjs.context["FlutterHostView"]['shared']
                        ['textareaHasFocus'] = true;
                  }
                }
              }
              break;
            default:
              break;
          }
        },
        placeholder: IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: visibleLines > 1
                ? Alignment.topLeft
                : Alignment.centerLeft,
            child: Stack(
              children: [
                EditableText(
                  controller: controller,
                  focusNode: FocusNode(),
                  style: widget.style ?? TextStyle(),
                  showCursor: false,
                  cursorColor: Colors.transparent,
                  backgroundCursorColor:
                      widget.backgroundCursorColor ?? Colors.black,
                  obscureText: widget.obscureText,
                  textAlign: widget.textAlign,
                  autofocus: false,
                  maxLines: widget.maxLines,
                ),
                Positioned.fill(
                  child: Visibility(
                    visible:
                        widget.forceShowHintText && controller.text.isEmpty,
                    child: Opacity(
                      opacity: 0.6,
                      child: Align(
                        alignment: visibleLines > 1
                            ? Alignment.topLeft
                            : Alignment.centerLeft,
                        child: Text(
                          widget.hintText ?? "",
                          style: widget.style ?? TextStyle(),
                          textAlign: widget.textAlign,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

int? _readLineCountFromDetail(Object? detail) {
  if (detail == null) {
    return null;
  }
  for (final key in ['lineCount', 'linecount', 'line_count']) {
    Object? value;
    if (detail is Map) {
      value = detail[key];
    } else {
      try {
        value = (detail as dynamic)[key];
      } catch (_) {
        continue;
      }
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

String _colorToHex(Color? color, String defaultValue) {
  if (color == null) {
    return defaultValue;
  }
  return '#${color.value.toRadixString(16).padLeft(6, '0').substring(2)}';
}
