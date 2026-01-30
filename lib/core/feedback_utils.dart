import 'package:flutter/material.dart';

void showTopSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => _TopSnackBar(
          message: message,
          isError: isError,
          onDismiss: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        ),
  );

  overlay.insert(overlayEntry);
}

class _TopSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopSnackBar({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto dismiss logic
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _close();
      }
    });
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _close, // Allow tap to dismiss
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    widget.isError
                        ? Colors.red.shade600
                        : Colors.green.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontFamily:
                            'Cairo', // Assuming Cairo font based on app context
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
