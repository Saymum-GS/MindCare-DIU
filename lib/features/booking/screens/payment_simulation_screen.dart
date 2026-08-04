import 'package:flutter/services.dart';
import '../providers/booking_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/data/audit_repository.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_surface.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../shared/models/booking_model.dart';

class PaymentSimulationScreen extends ConsumerStatefulWidget {
  final BookingSlot slot;
  final PsychologistProfile profile;
  final String sessionType;
  final String problemNote;

  const PaymentSimulationScreen({
    super.key,
    required this.slot,
    required this.profile,
    this.sessionType = 'video',
    this.problemNote = 'None',
  });

  @override
  ConsumerState<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState
    extends ConsumerState<PaymentSimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  String _processingStep = 'Connecting...';
  String _selectedMethod = 'bKash';

  final _accountCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _cardNumCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pinCtrl.dispose();
    _cardNumCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _processMockPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _isProcessing = true;
      _processingStep = 'Preparing your appointment...';
    });

    // Simulate multi-step network processing
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _processingStep = 'Confirming schedule...');

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _processingStep = 'Finalizing booking...');

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _processingStep = 'Almost there...');

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    try {
      final repository = ref.read(bookingRepositoryProvider);
      final txId = _generateMockRef();

      final bookingId = await repository.createBooking(
        slot: widget.slot,
        profile: widget.profile,
        sessionType: widget.sessionType,
        isDiuStudent: false,
        studentName: user.displayName,
        problemNote: widget.problemNote,
        paymentMethod: _selectedMethod,
        paymentReference: txId,
      );

      // Audit Log
      await AuditRepository().logAction(
        action: 'booking.created',
        targetUid: widget.profile.uid,
        targetCollection: 'bookings',
        targetDocId: bookingId,
        metadata: {
          'type': 'paid',
          'method': _selectedMethod,
          'amount': widget.profile.sessionFeeExternal,
          'txId': txId,
        },
      );

      if (!mounted) return;

      HapticFeedback.heavyImpact();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              icon: const Icon(Icons.check_circle_rounded,
                  color: AppColors.riskGreenFg, size: 64),
              title: Text('Payment Successful',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.gray900)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Your session with ${widget.profile.displayName} is confirmed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              isDark ? AppColors.gray300 : AppColors.gray700)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkSurface2 : AppColors.gray50,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text('Transaction ID',
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray500)),
                        const SizedBox(height: 4),
                        Text(txId,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    isDark ? Colors.white : AppColors.gray900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('A receipt has been saved to your history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? AppColors.gray500 : AppColors.gray500)),
                ],
              ),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.blue600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/home');
                        context.push('/bookings');
                      },
                      child: const Text('View My Bookings',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/home');
                      },
                      child: const Text('Return to Home'),
                    ),
                  ],
                ),
              ],
            );
          });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book after payment: $e')),
        );
      }
    }
  }

  String _generateMockRef() {
    final random = Random();
    return 'MC-${random.nextInt(900000) + 100000}${random.nextInt(900000) + 100000}';
  }

  InputDecoration _buildValidationDeco(
      String label, String hint, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          TextStyle(color: isDark ? AppColors.darkTextSub : AppColors.gray600),
      hintText: hint,
      hintStyle:
          TextStyle(color: isDark ? AppColors.darkTextTert : AppColors.gray400),
      prefixIcon: Icon(icon,
          color: isDark ? AppColors.darkTextTert : AppColors.gray500),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.gray300),
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.gray300),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.blue500, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Confirm Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    AppSurface(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long_rounded,
                                  color: AppColors.blue500),
                              const SizedBox(width: 8),
                              Text('Order Summary',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Professional:',
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextSub
                                          : AppColors.gray600)),
                              Text(widget.profile.displayName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date & Time:',
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextSub
                                          : AppColors.gray600)),
                              Text(
                                  '${DateFormat('MMM d').format(widget.slot.slotStart)}, ${DateFormat('h:mm a').format(widget.slot.slotStart)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Session Mode:',
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextSub
                                          : AppColors.gray600)),
                              Text(
                                  widget.sessionType == 'in_person'
                                      ? 'In-Person (DIU Campus)'
                                      : widget.sessionType.toUpperCase(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Divider(
                                color: isDark
                                    ? AppColors.darkBorderSoft
                                    : AppColors.gray200),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.gray900)),
                              Text(
                                '৳${widget.profile.sessionFeeExternal}',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blue500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('Select Payment Method',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.gray900)),
                    const SizedBox(height: 16),

                    _PaymentMethodCard(
                      title: 'bKash',
                      isSelected: _selectedMethod == 'bKash',
                      onTap: () => setState(() {
                        _selectedMethod = 'bKash';
                        _formKey.currentState?.reset();
                      }),
                      isDark: isDark,
                    ),
                    _PaymentMethodCard(
                      title: 'Nagad',
                      isSelected: _selectedMethod == 'Nagad',
                      onTap: () => setState(() {
                        _selectedMethod = 'Nagad';
                        _formKey.currentState?.reset();
                      }),
                      isDark: isDark,
                    ),
                    _PaymentMethodCard(
                      title: 'Credit / Debit Card',
                      isSelected: _selectedMethod == 'Card',
                      onTap: () => setState(() {
                        _selectedMethod = 'Card';
                        _formKey.currentState?.reset();
                      }),
                      isDark: isDark,
                    ),

                    // Payment input fields
                    const SizedBox(height: 24),
                    Text('Payment Details',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.gray900)),
                    const SizedBox(height: 16),
                    if (_selectedMethod == 'bKash' ||
                        _selectedMethod == 'Nagad') ...[
                      TextFormField(
                        controller: _accountCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.gray900),
                        decoration: _buildValidationDeco(
                            '$_selectedMethod Account Number',
                            '01XXXXXXXXX',
                            Icons.phone_android,
                            isDark),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your account number';
                          }
                          if (value.length < 11) {
                            return 'Enter a valid 11-digit number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pinCtrl,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.gray900),
                        decoration: _buildValidationDeco('$_selectedMethod PIN',
                                '', Icons.lock_outline, isDark)
                            .copyWith(counterText: ''),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'PIN is required';
                          }
                          if (value.length < 4) {
                            return 'PIN too short';
                          }
                          return null;
                        },
                      ),
                    ] else if (_selectedMethod == 'Card') ...[
                      TextFormField(
                        controller: _cardNumCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        style: TextStyle(
                            color: isDark ? Colors.white : AppColors.gray900),
                        decoration: _buildValidationDeco(
                                'Card Number',
                                'XXXX XXXX XXXX XXXX',
                                Icons.credit_card,
                                isDark)
                            .copyWith(counterText: ''),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Card number is required';
                          }
                          if (value.length < 16) {
                            return 'Invalid card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: TextFormField(
                          controller: _expiryCtrl,
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.gray900),
                          decoration: _buildValidationDeco('MM/YY', '12/27',
                                  Icons.calendar_today, isDark)
                              .copyWith(prefixIcon: null),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (!value.contains('/')) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        )),
                        const SizedBox(width: 16),
                        Expanded(
                            child: TextFormField(
                          controller: _cvvCtrl,
                          obscureText: true,
                          maxLength: 4,
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.gray900),
                          decoration: _buildValidationDeco(
                                  'CVV', '', Icons.security, isDark)
                              .copyWith(prefixIcon: null, counterText: ''),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 3) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        )),
                      ]),
                    ],

                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _processMockPayment,
                      icon: const Icon(Icons.lock_rounded, size: 18),
                      label: Text(
                          'Pay ৳${widget.profile.sessionFeeExternal} Securely',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.blue600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security,
                            size: 14, color: AppColors.gray500),
                        const SizedBox(width: 6),
                        const Text(
                          'Secured by SSLCommerz',
                          style: TextStyle(
                              color: AppColors.gray500,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: (isDark ? AppColors.darkBg : AppColors.gray50)
                  .withValues(alpha: 0.98),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingState(),
                    const SizedBox(height: 16),
                    Text(
                      'Processing Payment\n\n$_processingStep',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.gray500, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: AppColors.gray500, size: 16),
                        SizedBox(width: 8),
                        Text('256-bit SSL Encrypted Connection',
                            style: TextStyle(
                                color: AppColors.gray500, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PaymentMethodCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected
          ? (isDark
              ? AppColors.blue900.withValues(alpha: 0.3)
              : AppColors.blue50)
          : null,
      borderColor: isSelected ? AppColors.blue500 : null,
      borderWidth: isSelected ? 2.0 : 1.0,
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? AppColors.darkBg : AppColors.gray200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.payment_rounded,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : (isDark ? AppColors.gray400 : AppColors.gray600),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.blue400 : AppColors.blue700)
                  : (isDark ? Colors.white : AppColors.gray800),
            ),
          ),
        ],
      ),
    );
  }
}
