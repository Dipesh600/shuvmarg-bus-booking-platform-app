import re

content = r"""223:     _finalPrice = widget.totalPrice;
224:     _selectedBoardingPoint = null;
225:     _selectedDroppingPoint = null;
226:     _fetchUserDetails();
227:     
228:     _nameController = TextEditingController(text: widget.name);
229:     _phoneController = TextEditingController(text: widget.phone);
230:     _emailController = TextEditingController(text: widget.email);
231:     
232:     _startTimer();
233:   }
234: 
235:   void _startTimer() {
236:     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
237:       if (_remainingSeconds > 0) {
238:         setState(() {
239:           _remainingSeconds--;
240:         });
241:       } else {
242:         _timer?.cancel();
243:         // Handle timeout
244:         if (mounted) {
245:           ToastService.showToast(msg: "Booking session expired.", backgroundColor: Colors.red, context: context, type: ToastType.error);
246:           Navigator.pop(context);
247:         }
248:       }
249:     });
250:   }
251: 
252:   String _formatTime(int seconds) {
253:     int minutes = seconds ~/ 60;
254:     int remainingSeconds = seconds % 60;
255:     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
256:   }
257: 
258:   @override
259:   void dispose() {
260:     _timer?.cancel();
261:     _couponController.dispose();
262:     _yatraPointsController.dispose();
263:     _nameController.dispose();
264:     _phoneController.dispose();
265:     _emailController.dispose();
266:     super.dispose();
267:   }
268: 
269:   /// Build passengerDetails list for the API using the primary contact
270:   List<Map<String, dynamic>> _buildPassengerDetails() {
271:     final seats = widget.selectedSeats;
272:     return [{
273:       'name':   _nameController.text.trim().isEmpty ? widget.name : _nameController.text.trim(),
274:       'phone':  _phoneController.text.trim(),
275:       'email':  _emailController.text.trim(),
276:       'seatNo': seats,
277:     }];
278:   }
279: 
280:   /// Resolve selected StopPoint object by name
281:   StopPoint? _resolvePoint(List<StopPoint> points, String? name) {
282:     if (name == null) return null;
283:     try {
284:       return points.firstWhere((p) => p.pointName == name);
285:     } catch (_) {
286:       return null;
287:     }
288:   }
289: 
290:   Map<String, dynamic>? _buildBoardingPointMap() {
291:     final point = _resolvePoint(
292:         widget.busData.busDetail.boardingPoints, _selectedBoardingPoint);
293:     if (point == null) return null;
294:     return {
295:       'name': point.pointName,
296:       'time': point.time,
297:       if (point.lat != null) 'lat': point.lat,
298:       if (point.lng != null) 'lng': point.lng,
299:     };
300:   }
301: 
302:   Map<String, dynamic>? _buildDroppingPointMap() {
303:     final point = _resolvePoint(
304:         widget.busData.busDetail.droppingPoints, _selectedDroppingPoint);
305:     if (point == null) return null;
306:     return {
307:       'name': point.pointName,
308:       'time': point.time,
309:       if (point.lat != null) 'lat': point.lat,
310:       if (point.lng != null) 'lng': point.lng,
311:     };
312:   }
313: 
314:   Future<void> _directBookTicket() async {
315:     setState(() { _isBooking = true; });
316: 
317:     final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
318:     final tempId = 'TEMP_${DateTime.now().millisecondsSinceEpoch}';
319: 
320:     Map<String, dynamic> data = {
321:       'scheduleId':       widget.busData.id,
322:       'tempBookingId':    tempId,
323:       'paymentId':        'TEST_TXN_${DateTime.now().millisecondsSinceEpoch}',
324:       'transactionId':    'TEST_TXN_${DateTime.now().millisecondsSinceEpoch}',
325:       'paymentMethod':    'ESEWA',
326:       'bookedVia':        'APP',
327:       'paymentAmount':    _finalPrice,
328:       'originalAmount':   widget.totalPrice,
329:       'seatNumbers':      seats,
330:       'gateway':          'esewa',
331:       'passengerDetails': _buildPassengerDetails(),
332:       if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
333:       if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
334:       if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
335:       if (_isYatraPointsApplied) 'yatrapointsToUse': _yatraPointsUsed,
336:     };
337: 
338:     final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
339:     final response = await ticketProvider.bookTicket(data);
340: 
341:     setState(() { _isBooking = false; });
342: 
343:     if (response.status) {
344:       final ticketId = response.ticketId;
345:       _showBookingConfirmedDialog(ticketId ?? '', response.message);
346:     } else {
347:       if (response.caseId != null && response.caseId!.isNotEmpty) {
348:         DisputedPaymentDialog.show(
349:           context,
350:           message: response.message,
351:           caseId: response.caseId!,
352:         );
353:       } else {
354:         ToastService.showToast(
355:           msg: response.message,
356:           context: context,
357:           type: ToastType.error,
358:           title: 'Booking Failed',
359:           timeInSecForIosWeb: 4,
360:         );
361:       }
362:     }
363:   }
364: 
365:   Future<void> _fetchUserDetails() async {
366:     print("fetching user details");
367:     try {
368:       final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
369:       // Ensure profile is loaded
370:       await profileProvider.loadProfile();
371:       
372:       if (profileProvider.yatraPoints != null) {
373:         setState(() {
374:           _availableYatraPoints = profileProvider.yatraPoints!;
375:           _isLoadingYatraPoints = false;
376:         });
377:       } else {
378:         setState(() {
379:           _availableYatraPoints = 0;
380:           _isLoadingYatraPoints = false;
381:         });
382:       }
383:     } catch (e) {
384:       setState(() {
385:         _availableYatraPoints = 0;
386:         _isLoadingYatraPoints = false;
387:       });
388:       debugPrint("Error fetching user details: $e");
389:     }
390:   }
391: 
392:   Future<void> _applyCoupon() async {
393:     final couponCode = _couponController.text.trim();
394:     if (couponCode.isEmpty) {
395:       setState(() {
396:         _couponMessage = 'Please enter a coupon code';
397:       });
398:       return;
399:     }
400: 
401:     setState(() {
402:       _isApplyingCoupon = true;
403:       _couponMessage = null;
404:     });
405: 
406:     try {
407:       final couponProvider = Provider.of<CouponProvider>(context, listen: false);
408: 
409:       // Prepare request data
410:       Map<String, dynamic> data = {
411:         "couponCode": couponCode,
412:         "orderAmount": widget.totalPrice.toString(),
413:         "scheduleId": widget.busData.id
414:       };
415: 
416:       // Call the API via provider
417:       final CouponResponse response =
418:           await couponProvider.validateCoupon(data);
419: 
420:       setState(() {
421:         _isApplyingCoupon = false;
422: 
423:         if (response.success) {
424:           // Extract discount information from response
425:           // Assuming the response has discountAmount field
426:           // Adjust according to your actual response structure
427: 
428:           // Use the discount information from the response
429:           if (response.data != null) {
430:             final couponData = response.data!;
431: 
432:             // The API already calculated the discount amount for us
433:             _discountAmount = couponData.discountAmount;
434:             _finalPrice = couponData.finalAmount.round();
435: 
436:             _isCouponApplied = true;
437:             _couponMessage =
438:                 'Coupon applied successfully! You saved Rs. ${couponData.discountAmount.round()}';
439:           } else {
440:             // Handle case where response is successful but no data
441:             _isCouponApplied = true;
442:             // If no data, we'll calculate a simple discount (this is a fallback)
443:             _discountAmount = 0; // Default if we can't determine
444:             _finalPrice = widget.totalPrice;
445:             _couponMessage = 'Coupon applied';
446:           }
447:         } else {
448:           // Handle unsuccessful response
449:           _isCouponApplied = false;
450:           _discountAmount = 0;
451:           _finalPrice = widget.totalPrice;
452:           _couponMessage = response.message.isNotEmpty
453:               ? response.message
454:               : 'Invalid coupon code';
455:         }
456:       });
457:     } catch (e) {
458:       setState(() {
459:         _isApplyingCoupon = false;
460:         _isCouponApplied = false;
461:         _discountAmount = 0;
462:         _finalPrice = widget.totalPrice;
463:         _couponMessage = 'Error validating coupon. Please try again.';
464:       });
465:       debugPrint("Coupon validation error: $e");
466:     }
467:   }
468: 
469:   void _removeCoupon() {
470:     setState(() {
471:       _couponController.clear();
472:       _isCouponApplied = false;
473:       _discountAmount = 0;
474:       _finalPrice = widget.totalPrice;
475:       _couponMessage = null;
476:     });
477:   }
478: 
479:   Future<void> _applyYatraPoints() async {
480:     final pointsText = _yatraPointsController.text.trim();
481:     if (pointsText.isEmpty) {
482:       setState(() {
483:         _yatraPointsMessage = 'Please enter points to use';
484:       });
485:       return;
486:     }
487: 
488:     final pointsToUse = int.tryParse(pointsText);
489:     if (pointsToUse == null || pointsToUse <= 0) {
490:       setState(() {
491:         _yatraPointsMessage = 'Please enter valid points';
492:       });
493:       return;
494:     }
495: 
496:     if (_isLoadingYatraPoints) {
497:       setState(() {
498:         _yatraPointsMessage = 'Please wait while we load your points';
499:       });
500:       return;
501:     }
502: 
503:     if (pointsToUse > _availableYatraPoints) {
504:       setState(() {
505:         _yatraPointsMessage =
506:             'You only have $_availableYatraPoints points available';
507:       });
508:       return;
509:     }
510: 
511:     setState(() {
512:       _isApplyingYatraPoints = true;
513:       _yatraPointsMessage = null;
514:     });
515: 
516:     try {
517:       // Prepare request data for Yatra points validation
518:       Map<String, dynamic> validationData = {
519:         "yatrapointsToUse": pointsToUse,
520:         "scheduleId": widget.busData.id,
521:         "seatNumbers": [widget.selectedSeats]
522:       };
523: 
524:       final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
525:       
526:       // Call the API via provider
527:       final YatraPointsResponse response =
528:           await ticketProvider.validateYatraPoints(validationData);
529: 
530:       setState(() {
531:         _isApplyingYatraPoints = false;
532: 
533:         if (response.status && response.data != null) {
534:           // Update final price with the validated amount from server
535:           _finalPrice = response.data!.finalAmount;
536:           _yatraPointsUsed = pointsToUse;
537:           _isYatraPointsApplied = true;
538:           _yatraPointsMessage =
539:               'Yatra Points applied successfully! Final amount: Rs. ${response.data!.finalAmount}';
540:         } else {
541:           // Handle unsuccessful response
542:           _isYatraPointsApplied = false;
543:           _yatraPointsUsed = 0;
544:           _finalPrice = widget.totalPrice; // Reset to original price
545:           _yatraPointsMessage = response.message.isNotEmpty
546:               ? response.message
547:               : 'Failed to validate Yatra points';
548:         }
549:       });
550:     } catch (e) {
551:       setState(() {
552:         _isApplyingYatraPoints = false;
553:         _isYatraPointsApplied = false;
554:         _yatraPointsUsed = 0;
555:         _finalPrice = widget.totalPrice; // Reset to original price
556:         _yatraPointsMessage =
557:             'Error validating Yatra points. Please try again.';
558:       });
559:       debugPrint("Yatra points validation error: $e");
560:     }
561:   }
562: 
563:   void _removeYatraPoints() {
564:     setState(() {
565:       _yatraPointsController.clear();
566:       _isYatraPointsApplied = false;
567:       _finalPrice = widget.totalPrice; // Reset to original total price
568:       _yatraPointsUsed = 0;
569:       _yatraPointsMessage = null;
570:     });
571:   }
572: 
573: // eSewa — two-phase atomic payment
574:   _payThroughEsewa() async {
575:     // Validation
576:     if (_nameController.text.trim().isEmpty) {
577:       ToastService.showToast(msg: "Please provide a primary contact name.", backgroundColor: Colors.red, context: context, type: ToastType.error);
578:       return;
579:     }
580:     if (_phoneController.text.trim().isEmpty) {
581:       ToastService.showToast(msg: "Please provide a primary phone number.", backgroundColor: Colors.red, context: context, type: ToastType.error);
582:       return;
583:     }
584:     if (widget.busData.busDetail.boardingPoints.isNotEmpty && _selectedBoardingPoint == null) {
585:       ToastService.showToast(msg: "Please select a boarding point before proceeding.", backgroundColor: Colors.red, context: context, type: ToastType.error);
586:       return;
587:     }
588: 
589:     // Phase 1: prepareBooking — lock seats + get server-validated amount
590:     setState(() { _isBooking = true; });
591: 
592:     final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
593:     final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
594: 
595:     final PrepareBookingResponse prepareResp = await ticketProvider.prepareBooking({
596:       'scheduleId':       widget.busData.id,
597:       'seatNumbers':      seats,
598:       'paymentAmount':    _finalPrice,
599:       'originalAmount':   widget.totalPrice,
600:       'passengerDetails': _buildPassengerDetails(),
601:       if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
602:       if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
603:       if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
604:       if (_isYatraPointsApplied) 'yatrapointsToUse': _yatraPointsUsed,
605:     });
606: 
607:     setState(() { _isBooking = false; });
608: 
609:     if (!prepareResp.status) {
610:       ToastService.showToast(
611:         msg: prepareResp.message.isNotEmpty
612:             ? prepareResp.message
613:             : 'Seats unavailable. Please select different seats.',
614:         context: context,
615:         type: ToastType.error,
616:         title: 'Booking Failed',
617:         timeInSecForIosWeb: 4,
618:       );
619:       return;
620:     }
621: 
622:     // Store server-validated values for Phase 2 (confirmBooking)
623:     _tempBookingId       = prepareResp.tempBookingId;
624:     _serverPaymentAmount = prepareResp.paymentAmount ?? _finalPrice;
625: 
626:     // Phase 2: Launch eSewa SDK with server-validated amount
627:     try {
628:       EsewaFlutterSdk.initPayment(
629:         esewaConfig: EsewaConfig(
630:           environment: Environment.test,
631:           clientId: EsewaKeys.clientId,
632:           secretId: EsewaKeys.secretId,
633:         ),
634:         esewaPayment: EsewaPayment(
635:           productId: _tempBookingId ?? 'ESEWA_${DateTime.now().millisecondsSinceEpoch}',
636:           productName: widget.busData.busDetail.busName,
637:           // Use server-validated amount — NOT locally calculated price
638:           productPrice: _serverPaymentAmount.toString(),
639:           callbackUrl: 'https://developer.esewa.com.np',
640:         ),
641:         onPaymentSuccess: (EsewaPaymentSuccessResult data) {
642:           debugPrint(":::ESEWA SUCCESS::: => ${data.refId}");
643:           verifyTransactionStatus(data.refId);
644:         },
645:         onPaymentFailure: (data) {
646:           debugPrint(":::ESEWA FAILURE::: => $data");
647:           ToastService.showToast(
648:             msg: 'Payment was not completed. Please try again.',
649:             context: context,
650:             type: ToastType.error,
651:             title: 'Payment Failed',
652:             timeInSecForIosWeb: 3,
653:           );
654:         },
655:         onPaymentCancellation: (data) {
656:           debugPrint(":::ESEWA CANCELLATION::: => $data");
657:           // Clear temp booking state
658:           setState(() {
659:             _tempBookingId = null;
660:             _serverPaymentAmount = null;
661:           });
662:         },
663:       );
664:     } catch (e) {
665:       final msg = e.toString();
666:       if (msg.contains('MissingPluginException')) {
667:         debugPrint("eSewa SDK not available on this platform. Run on Android/iOS device.");
668:         ToastService.showToast(
669:           msg: "eSewa payment is only supported on Android & iOS devices.",
670:           context: context,
671:           type: ToastType.info,
672:           title: "Mobile Only",
673:           timeInSecForIosWeb: 4,
674:         );
675:       } else {
676:         debugPrint("ESEWA EXCEPTION: $e");
677:         ToastService.showToast(
678:           msg: "Could not launch eSewa. Please try again.",
679:           context: context,
680:           type: ToastType.error,
681:           title: "Payment Error",
682:           timeInSecForIosWeb: 3,
683:         );
684:       }
685:     }
686:   }
687: 
688:   void verifyTransactionStatus(String refId) async {
689:     setState(() { _isBooking = true; });
690: 
691:     final seats = widget.selectedSeats.split(',').map((s) => s.trim()).toList();
692: 
693:     // Use server-validated amount from prepareBooking (not locally calculated)
694:     // This ensures eSewa verify on backend matches the amount we sent to eSewa SDK
695:     final int confirmedAmount = _serverPaymentAmount ?? _finalPrice;
696:     final String confirmedTempId = _tempBookingId ?? 'ESEWA_${DateTime.now().millisecondsSinceEpoch}';
697: 
698:     Map<String, dynamic> data = {
699:       'scheduleId':       widget.busData.id,
700:       'tempBookingId':    confirmedTempId,
701:       'paymentId':        refId,          // eSewa refId — verified server-side
702:       'transactionId':    refId,
703:       'paymentMethod':    'ESEWA',
704:       'bookedVia':        'APP',
705:       'paymentAmount':    confirmedAmount,
706:       'originalAmount':   widget.totalPrice,
707:       'seatNumbers':      seats,
708:       'gateway':          'esewa',
709:       'passengerDetails': _buildPassengerDetails(),
710:       if (_buildBoardingPointMap() != null) 'boardingPoint': _buildBoardingPointMap(),
711:       if (_buildDroppingPointMap() != null) 'droppingPoint': _buildDroppingPointMap(),
712:       if (_isCouponApplied) 'couponCode': _couponController.text.trim(),
713:       if (_isYatraPointsApplied) 'yatrapointsToUse': _yatraPointsUsed,
714:     };
715: 
716:     final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
717:     final response = await ticketProvider.confirmBooking(data);
718: 
719:     setState(() {
720:       _isBooking = false;
721:       _tempBookingId = null;        // clear temp booking state
722:       _serverPaymentAmount = null;
723:     });
724: 
725:     if (response.status) {
726:       final ticketId = response.ticketId;
727:       _showBookingConfirmedDialog(ticketId ?? '', response.message);
728:     } else {
729:       if (response.caseId != null && response.caseId!.isNotEmpty) {
730:         DisputedPaymentDialog.show(
731:           context,
732:           message: response.message,
733:           caseId: response.caseId!,
734:         );
735:       } else {
736:         ToastService.showToast(
737:           msg: response.message,
738:           context: context,
739:           type: ToastType.error,
740:           title: 'Booking Failed',
741:           timeInSecForIosWeb: 4,
742:         );
743:       }
744:     }
745:   }
746: 
747:   void _showBookingConfirmedDialog(String ticketId, String message) {
748:     showGeneralDialog(
749:       context: context,
750:       barrierDismissible: false,
751:       barrierColor: Colors.black.withOpacity(0.7),
752:       transitionDuration: const Duration(milliseconds: 300),
753:       pageBuilder: (context, anim1, anim2) {
754:         return Center(
755:           child: Material(
756:             color: Colors.transparent,
757:             child: Container(
758:               margin: const EdgeInsets.symmetric(horizontal: 32),
759:               decoration: BoxDecoration(
760:                 color: AppTheme.primaryDark.withOpacity(0.88),
761:                 borderRadius: BorderRadius.circular(24),
762:                 border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
763:                 boxShadow: [
764:                   BoxShadow(color: AppTheme.primaryDark.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10)),
765:                 ],
766:               ),
767:               child: ClipRRect(
768:                 borderRadius: BorderRadius.circular(24),
769:                 child: BackdropFilter(
770:                   filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
771:                   child: Padding(
772:                     padding: const EdgeInsets.all(32),
773:                     child: Column(
774:                       mainAxisSize: MainAxisSize.min,
775:                       children: [
776:                         // Neon Success Icon
777:                         Container(
778:                           padding: const EdgeInsets.all(20),
779:                           decoration: BoxDecoration(
780:                             color: AppTheme.accentLime.withOpacity(0.15),
781:                             shape: BoxShape.circle,
782:                             boxShadow: [
783:                               BoxShadow(color: AppTheme.accentLime.withOpacity(0.3), blurRadius: 24, spreadRadius: 2),
784:                             ],
785:                           ),
786:                           child: const Icon(Icons.check_rounded, color: AppTheme.accentLime, size: 56),
787:                         ),
788:                         const SizedBox(height: 32),
789:                         const Text(
790:                           "Booking Confirmed!",
791:                           textAlign: TextAlign.center,
792:                           style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
793:                         ),
794:                         const SizedBox(height: 12),
795:                         Text(
796:                           message,
797:                           textAlign: TextAlign.center,
798:                           style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
799:                         ),
800:                         const SizedBox(height: 40),
801:                         // CTA Button
802:                         SizedBox(
803:                           width: double.infinity,
804:                           child: GestureDetector(
805:                             onTap: () {
806:                               Navigator.pop(context); // Close dialog
807:                               Navigator.pushReplacement(
808:                                 context,
809:                                 MaterialPageRoute(
810:                                   builder: (context) => TicketScreen(
811:                                     ticketId: ticketId,
812:                                     selectedSeats: widget.selectedSeats,
813:                                     busData: widget.busData,
814:                                     name: widget.name,
815:                                     profilePic: widget.profilePic,
816:                                     role: widget.role,
817:                                   ),
818:                                 ),
819:                               );
820:                             },
821:                             child: Container(
822:                               padding: const EdgeInsets.symmetric(vertical: 18),
823:                               decoration: BoxDecoration(
824:                                 color: AppTheme.accentLime,
825:                                 borderRadius: BorderRadius.circular(16),
826:                                 boxShadow: [
827:                                   BoxShadow(color: AppTheme.accentLime.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4)),
828:                                 ],
829:                               ),
830:                               alignment: Alignment.center,
831:                               child: const Text(
832:                                 "View Ticket",
833:                                 style: TextStyle(color: Color(0xFF003D38), fontSize: 16, fontWeight: FontWeight.w700),
834:                               ),
835:                             ),
836:                           ),
837:                         ),
838:                       ],
839:                     ),
840:                   ),
841:                 ),
842:               ),
843:             ),
844:           ),
845:         );
846:       },
847:       transitionBuilder: (context, anim1, anim2, child) {
848:         return SlideTransition(
849:           position: Tween<Offset>(
850:             begin: const Offset(0, 0.05),
851:             end: Offset.zero,
852:           ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
853:           child: FadeTransition(
854:             opacity: anim1,
855:             child: child,
856:           ),
857:         );
858:       },
859:     );
860:   }
861: 
862:   @override
863:   Widget build(BuildContext context) {
864:     return Stack(
865:       children: [
866:         // Main scrollable content
867:         ListView(
868:           padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 140), // Padding for floating bar + trust signal
869:           children: [
870:             // Countdown Timer Header
871:             Container(
872:               padding: const EdgeInsets.symmetric(vertical: 12),
873:               margin: const EdgeInsets.only(bottom: 16),
874:               decoration: BoxDecoration(
875:                 color: AppTheme.accentLime.withOpacity(0.1),
876:                 borderRadius: BorderRadius.circular(16),
877:                 border: Border.all(color: AppTheme.accentLime.withOpacity(0.3)),
878:               ),
879:               child: Row(
880:                 mainAxisAlignment: MainAxisAlignment.center,
881:                 children: [
882:                   const Icon(Icons.timer_outlined, color: AppTheme.accentLime, size: 20),
883:                   const SizedBox(width: 8),
884:                   const Text("Hold Expires In: ", style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
885:                   Text(
886:                     _formatTime(_remainingSeconds),
887:                     style: const TextStyle(color: AppTheme.accentLime, fontSize: 16, fontWeight: FontWeight.w800),
888:                   ),
889:                 ],
890:               ),
891:             ),
892:             
893:             // Ticket Summary Card
894:             TicketSummaryCard(
895:               busData: widget.busData,
896:               selectedSeats: widget.selectedSeats,
897:               nameController: _nameController,
898:               phoneController: _phoneController,
899:               emailController: _emailController,
900:             ),
901:             const SizedBox(height: 24),
902:             
903:             // Boarding Points Section
904:             BoardingPointSection(
905:               boardingPoints: widget.busData.busDetail.boardingPoints,
906:               selectedPoint: _selectedBoardingPoint,
907:               onChanged: (String? newValue) {
908:                 setState(() {
909:                   _selectedBoardingPoint = newValue;
910:                 });
911:               },
912:             ),
913:             const SizedBox(height: 24),
914: 
915:             // Coupon Section
916:             CouponSection(
917:               controller: _couponController,
918:               isExpanded: _isCouponDropdownExpanded,
919:               isApplying: _isApplyingCoupon,
920:               isApplied: _isCouponApplied,
921:               message: _couponMessage,
922:               onToggleExpanded: () {
923:                 setState(() {
924:                   _isCouponDropdownExpanded = !_isCouponDropdownExpanded;
925:                 });
926:               },
927:               onApply: _applyCoupon,
928:               onRemove: _removeCoupon,
929:             ),
930:             const SizedBox(height: 24),
931: 
932:             // Yatra Points Section
933:             YatraPointsSection(
934:               controller: _yatraPointsController,
935:               isExpanded: _isYatraPointsDropdownExpanded,
936:               isApplying: _isApplyingYatraPoints,
937:               isApplied: _isYatraPointsApplied,
938:               isLoadingPoints: _isLoadingYatraPoints,
939:               availablePoints: _availableYatraPoints,
940:               message: _yatraPointsMessage,
941:               onToggleExpanded: () {
942:                 setState(() {
943:                   _isYatraPointsDropdownExpanded = !_isYatraPointsDropdownExpanded;
944:                 });
945:               },
946:               onApply: _applyYatraPoints,
947:               onRemove: _removeYatraPoints,
948:             ),
949:             const SizedBox(height: 24),
950: 
951:             // Price Breakdown Section
952:             PriceBreakdownSection(
953:               subtotalPrice: widget.totalPrice,
954:               finalPrice: _finalPrice,
955:               isCouponApplied: _isCouponApplied,
956:               discountAmount: _discountAmount,
957:               isYatraPointsApplied: _isYatraPointsApplied,
958:             ),
959:             const SizedBox(height: 32),
960: 
961:             // Payment Method
962:             const Text(
963:               "Payment Method",
964:               style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
965:             ),
966:             const SizedBox(height: 16),
967:             GestureDetector(
968:               onTap: () {}, // Currently eSewa is the only option, so it's always selected
969:               child: Container(
970:                 height: 72,
971:                 decoration: BoxDecoration(
972:                   color: AppTheme.primaryDark,
973:                   borderRadius: BorderRadius.circular(20),
974:                   border: Border.all(color: AppTheme.accentLime, width: 1.5), // Highlighted border
975:                   boxShadow: [
976:                     BoxShadow(color: AppTheme.accentLime.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 4))
977:                   ],
978:                 ),
979:                 child: Row(
980:                   children: [
981:                     const SizedBox(width: 20),
982:                     Container(
983:                       padding: const EdgeInsets.all(8),
984:                       decoration: BoxDecoration(
985:                         color: Colors.white,
986:                         borderRadius: BorderRadius.circular(12),
987:                       ),
988:                       child: Image.asset("assets/logos/esewa.png", height: 24),
989:                     ),
990:                     const SizedBox(width: 16),
991:                     const Expanded(
992:                       child: Text(
993:                         "eSewa Mobile Wallet",
994:                         style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
995:                       ),
996:                     ),
997:                     const Icon(Icons.check_circle_rounded, color: AppTheme.accentLime, size: 24),
998:                     const SizedBox(width: 20),
999:                   ],
1000:                 ),
1001:               ),
1002:             ),
1003:           ],
1004:         ),
1005: 
1006:         // Floating Bottom Checkout Bar with Trust Signals
1007:         Positioned(
1008:           bottom: 0, left: 0, right: 0,
1009:           child: Column(
1010:             mainAxisSize: MainAxisSize.min,
1011:             children: [
1012:               // Trust Signal
1013:               Padding(
1014:                 padding: const EdgeInsets.only(bottom: 12),
1015:                 child: Row(
1016:                   mainAxisAlignment: MainAxisAlignment.center,
1017:                   children: [
1018:                     Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary.withOpacity(0.8), size: 14),
1019:                     const SizedBox(width: 6),
1020:                     Text(
1021:                       "Secure Checkout • Free Cancellation up to 12 hrs",
1022:                       style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
1023:                     ),
1024:                   ],
1025:                 ),
1026:               ),
1027:               Container(
1028:                 decoration: BoxDecoration(
1029:                   color: const Color(0xE000564E),
1030:                   border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
1031:                   boxShadow: [BoxShadow(color: AppTheme.primaryDarkest.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, -10))],
1032:                 ),
1033:             child: ClipRRect(
1034:               child: BackdropFilter(
1035:                 filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
1036:                 child: Padding(
1037:                   padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
1038:                   child: Row(
1039:                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
1040:                     children: [
1041:                       Column(
1042:                         mainAxisSize: MainAxisSize.min,
1043:                         crossAxisAlignment: CrossAxisAlignment.start,
1044:                         children: [
1045:                           const Text(
1046:                             "Total Payable",
1047:                             style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
1048:                           ),
1049:                           const SizedBox(height: 2),
1050:                           Text(
1051:                             "Rs. $_finalPrice",
1052:                             style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
1053:                           ),
1054:                         ],
1055:                       ),
1056:                       GestureDetector(
1057:                         onTap: _isBooking ? null : _payThroughEsewa,
1058:                         child: AnimatedContainer(
1059:                           duration: const Duration(milliseconds: 200),
1060:                           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
1061:                           decoration: BoxDecoration(
1062:                             color: _isBooking ? AppTheme.primary : AppTheme.accentLime,
1063:                             borderRadius: BorderRadius.circular(16),
1064:                             boxShadow: _isBooking ? [] : [BoxShadow(color: AppTheme.accentLime.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
1065:                           ),
1066:                           child: Row(
1067:                             children: [
1068:                               Text(
1069:                                 _isBooking ? "Processing..." : "Pay & Book",
1070:                                 style: TextStyle(
1071:                                   color: _isBooking ? AppTheme.textSecondary : const Color(0xFF003D38),
1072:                                   fontSize: 16,
1073:                                   fontWeight: FontWeight.w700,
1074:                                 ),
1075:                               ),
1076:                               if (!_isBooking) ...[
1077:                                 const SizedBox(width: 8),
1078:                                 const Icon(Icons.arrow_forward_rounded, color: Color(0xFF003D38), size: 18),
1079:                               ]
1080:                             ],
1081:                           ),
1082:                         ),
1083:                       ),
1084:                     ],
1085:                   ),
1086:                 ),
1087:               ),
1088:             ), // ClipRRect
1089:           ), // Container
1090:         ], // Column children
1091:       ), // Column
1092:     ), // Positioned
1093:   ], // Stack children
1094: ); // Stack
1095:   }
1096: }
1097: 
"""
lines = content.split('\n')
clean_lines = [re.sub(r'^\d+:\s?', '', line) for line in lines]

with open('lib/views/booking/proceeding_to_checkout.dart', 'r') as f:
    orig_lines = f.readlines()

new_content = "".join(orig_lines[:222]) + "\n".join(clean_lines)

with open('lib/views/booking/proceeding_to_checkout.dart', 'w') as f:
    f.write(new_content)

print("Restored successfully")
