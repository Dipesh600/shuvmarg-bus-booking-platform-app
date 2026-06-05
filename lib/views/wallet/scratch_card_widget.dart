import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import 'dart:ui' as ui;

class ScratchCardWidget extends StatefulWidget {
  final String cardId;
  final double amount;
  final bool isScratched;
  final String? imageUrl;
  final VoidCallback onScratchComplete;

  const ScratchCardWidget({
    super.key,
    required this.cardId,
    required this.amount,
    this.isScratched = false,
    this.imageUrl,
    required this.onScratchComplete,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final scratchKey = GlobalKey<ScratcherState>();
  bool isRevealed = false;
  double scratchProgress = 0.0;

  @override
  void initState() {
    super.initState();
    isRevealed = widget.isScratched;
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF00564E);
    const accentLime = Color(0xFFD3D925);
    
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cashback',
            style: TextStyle(
              color: Color(0xFFB7C7C3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${widget.amount.toInt()}',
            style: const TextStyle(
              color: accentLime,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003D38).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: isRevealed 
            ? content 
            : Stack(
                children: [
                  Scratcher(
                    key: scratchKey,
                    brushSize: 30,
                    threshold: 50,
                    color: accentLime, 
                    image: widget.imageUrl != null 
                        ? Image.network(widget.imageUrl!, fit: BoxFit.cover) 
                        : null,
                    onChange: (value) {
                      setState(() {
                        scratchProgress = value;
                      });
                    },
                    onThreshold: () {
                      if (!isRevealed) {
                        scratchKey.currentState?.reveal(duration: const Duration(milliseconds: 300));
                        setState(() => isRevealed = true);
                        widget.onScratchComplete();
                      }
                    },
                    child: Container(
                      height: 120,
                      width: 150,
                      color: Colors.transparent, 
                      child: content,
                    ),
                  ),
                  if (scratchProgress < 5)
                    IgnorePointer(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stars_rounded, color: const Color(0xFF003D38).withOpacity(0.8), size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'Scratch Here',
                              style: TextStyle(
                                color: const Color(0xFF003D38).withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
