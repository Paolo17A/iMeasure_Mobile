import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Icon? displayPrefixIcon;
  final bool enabled;
  final bool hasSearchButton;
  final Function? onSearchPress;
  final Color? fillColor;
  final Color? textColor;
  final double? borderRadius;
  const CustomTextField(
      {super.key,
      required this.text,
      required this.controller,
      required this.textInputType,
      required this.displayPrefixIcon,
      this.enabled = true,
      this.hasSearchButton = false,
      this.onSearchPress,
      this.fillColor,
      this.textColor,
      this.borderRadius});

  @override
  State<CustomTextField> createState() => _LiliwECommerceTextFieldState();
}

class _LiliwECommerceTextFieldState extends State<CustomTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        enabled: widget.enabled,
        controller: widget.controller,
        obscureText: isObscured,
        cursorColor: widget.textColor ?? Colors.black,
        onSubmitted: (value) {
          if (widget.onSearchPress != null &&
              widget.controller.text.isNotEmpty) {
            widget.onSearchPress!();
          }
        },
        style: TextStyle(
            color: widget.textColor != null
                ? widget.textColor
                : Colors.black.withOpacity(0.9)),
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.text,
            labelStyle: TextStyle(
                color: widget.textColor != null
                    ? widget.textColor!.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                fontStyle: FontStyle.italic),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: widget.fillColor ?? Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),
                borderSide: const BorderSide(color: Colors.black, width: 3.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            prefixIcon: widget.displayPrefixIcon,
            suffixIcon: widget.textInputType == TextInputType.visiblePassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      color: widget.textColor != null
                          ? widget.textColor!.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                    ))
                : widget.hasSearchButton && widget.onSearchPress != null
                    ? Transform.scale(
                        scale: 0.95,
                        child: ElevatedButton(
                            onPressed: () {
                              if (widget.controller.text.isEmpty) return;
                              widget.onSearchPress!();
                            },
                            child: const Icon(
                              Icons.search,
                              color: Colors.orange,
                            )),
                      )
                    : null),
        keyboardType: widget.textInputType,
        maxLines: widget.textInputType == TextInputType.multiline ? 6 : 1);
  }
}
