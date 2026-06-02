import sys

with open('lib/views/booking/proceeding_to_checkout.dart', 'r') as f:
    lines = f.readlines()

new_method = """
  void _showBookingConfirmedDialog(String ticketId, String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryDark.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLime.withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppTheme.accentLime.withOpacity(0.3), blurRadius: 24, spreadRadius: 2),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: AppTheme.accentLime, size: 56),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Booking Confirmed!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketScreen(
                                    ticketId: ticketId,
                                    selectedSeats: widget.selectedSeats,
                                    busData: widget.busData,
                                    name: widget.name,
                                    profilePic: widget.profilePic,
                                    role: widget.role,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppTheme.accentLime,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.accentLime.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4)),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "View Ticket",
                                style: TextStyle(color: Color(0xFF003D38), fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
"""

# Find the last `  @override\n  Widget build(BuildContext context) {`
target_index = -1
for i, line in enumerate(lines):
    if line.strip() == "Widget build(BuildContext context) {":
        if i > 0 and lines[i-1].strip() == "@override":
            target_index = i - 1

if target_index != -1:
    lines.insert(target_index, new_method + "\n")
    with open('lib/views/booking/proceeding_to_checkout.dart', 'w') as f:
        f.writelines(lines)
    print("Method injected successfully.")
else:
    print("Could not find target line to inject method.")
