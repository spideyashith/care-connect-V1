import 'dart:async';
import 'package:flutter/material.dart';
import '../services/emergency_service.dart';

class EmergencyHoldButton extends StatefulWidget {
  const EmergencyHoldButton({super.key});

  @override
  State<EmergencyHoldButton> createState() =>
      _EmergencyHoldButtonState();
}

class _EmergencyHoldButtonState
    extends State<EmergencyHoldButton> {

  double progress = 0;

  Timer? timer;

  bool alertSent = false;

  final EmergencyService emergencyService =
  EmergencyService();

  void startHolding() {

    progress = 0;

    timer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) async {


            setState(() {
              progress += 0.05;
            });

            print(progress);


        if (progress >= 1) {

          timer.cancel();

          await emergencyService.sendEmergencyAlert(
            patientId: "patient_001",
          );

          setState(() {
            alertSent = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Emergency Alert Sent"),
              ),
            );
          }
        }
      },
    );
  }

  void stopHolding() {

    timer?.cancel();

    if (!alertSent) {

      setState(() {
        progress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        startHolding();
      },

      onTapUp: (_) {
        stopHolding();
      },

      onTapCancel: () {
        stopHolding();
      },


      child: Column(

        children: [

          SizedBox(
            width: 170,
            height: 170,

            child: Stack(
              alignment: Alignment.center,

              children: [

                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  color: Colors.red,
                  backgroundColor:
                  Colors.red.shade100,
                ),

                Container(
                  width: 120,
                  height: 120,

                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 55,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            alertSent
                ? "Emergency Sent"
                : "Press & Hold",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}