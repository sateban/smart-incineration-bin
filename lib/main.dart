import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:multicast_dns/multicast_dns.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenGetStarted = prefs.getBool('hasSeenGetStarted') ?? false;
  
  runApp(SplashScreen(hasSeenGetStarted: hasSeenGetStarted));
}

class SplashScreen extends StatelessWidget {
  final bool hasSeenGetStarted;
  const SplashScreen({super.key, required this.hasSeenGetStarted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Bin',
      home: hasSeenGetStarted ? const SmartBinDashboard() : const GetStartedPage(),
    );
  }
}

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400], // gray background for the top
      body: Column(
        children: [
          // 🟩 Top section with icon
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                // child: const Icon(
                //   Icons.image_outlined,
                //   color: Colors.black54,
                //   size: 80,
                // ),
              ),
            ),
          ),

          // 🟦 Bottom section (white with rounded top)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Smart Home Solution',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // const SizedBox(height: 8),
                  const Text(
                    'Smart Hybrid Eco Incineration Bin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 56, 59, 65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32 * 2),
                  const Text(
                    'Advanced waste disposal technology for modern sustainable living',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 56, 59, 65),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size.fromHeight(70),
                    ),
                    onPressed: () async {
                      // Save that user has seen the get started page
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenGetStarted', true);
                      
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmartBinDashboard(),
                        ),
                      );
                    },
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class SmartBinDashboard extends StatefulWidget {
  const SmartBinDashboard({super.key});

  @override
  State<SmartBinDashboard> createState() => _SmartBinDashboardState();
}

class _SmartBinDashboardState extends State<SmartBinDashboard> {
  int _selectedIndex = 0;
  double heatLevel = 0.75; // 75%
  double timerValue = 0; // 30 min
  bool isTimerStarted = false;
  double tMin = 100;
  double tMax = 1200;

  // For Timer
  Timer? _timer;
  int _remainingSeconds = 0;

  // Progress Bar
  double progressValue = 0.0;

  // Chamber Temperature
  double temperature = 0.0;
  int gas = 0;

  // For checking
  bool isRunning = false;
  bool isRequestValid = false;

  // Request timer
  Timer? _requestTimer;

  static const primaryColor = Color(0xFF38E07B);
  static const backgroundColor = Color(0xFFF7F8FA);
  static const mutedColor = Color(0xFFE5E7EB);
  static const mutedForeground = Color(0xFF6B7280);
  static const cardColor = Colors.white;
  static const foregroundColor = Color(0xFF1A1A1A);

  // Start sending request every 5 seconds
  void startAutoRequest() {
    // Cancel existing timer if running
    _requestTimer?.cancel();

    _requestTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final url = Uri.parse('http://esp8266-device.local/info');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'text/plain'},
          // body: status, // e.g. 'ON' or 'OFF'
        );

        if (response.statusCode == 200) {
          _logger.i('Info retrieved successfully: ${response.body}');
          String body = response.body;
          // _logger.d("${body.split(';')[0].split(':')[1]}");
          setState(() {
            temperature = double.parse(body.split(';')[0].split(':')[1]);
            gas = int.parse(body.split(';')[1].split(':')[1]);
            isRequestValid = true;
            _logger.d(
              "setState called: isRequestValid=$isRequestValid, temperature=$temperature",
            );
          });
        } else {
          _logger.w(
            'Unexpected status: ${response.statusCode} - ${response.body}',
          );

          isRequestValid = false;
        }

        _logger.d("isRequestValid: $isRequestValid");
      } catch (e, stacktrace) {
        _logger.e('Error sending request to ESP8266: $e, $stacktrace');
        setState(() {
          isRequestValid = false;
          _logger.d("setState called in error: isRequestValid=$isRequestValid");
        });
        // Fluttertoast.showToast(
        //   msg: 'Error sending request to ESP8266: $e',
        //   toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
        //   gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
        //   backgroundColor: Colors.black87,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
      } finally {
        _logger.i('Request to ESP8266 completed.');
      }
    });

    // Timer
    // if (_requestTimer != null && _requestTimer!.isActive) {
    //   isRunning = true;
    // } else {
    //   isRunning = false;
    // }
  }

  // Stop the auto request
  void stopAutoRequest() {
    _requestTimer?.cancel();
    _requestTimer = null;
    _logger.d("🛑 Auto request stopped");
  }

  @override
  void initState() {
    super.initState();
    // animateProgressBar(); // start animation automatically
    startAutoRequest();
  }

  // Status checker
  void checkStatus() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final response = await http.get(
        Uri.parse('http://esp8266-device.local/status'),
      );

      _logger.d("Check Status: ${response.body}");
      if (response.body == "done") {
        _logger.d("Timer completed!");
        timer.cancel();
        progressValue = 1.0;
        // 👉 You can show a Snackbar, Toast, or call setState() here
      } else if(response.body == "incinerating"){
        progressValue = 0.75;
      } else if(response.body == "heating"){
        progressValue = 0.25;
      } else {
        progressValue = 0.00;
      }
    });
  }

  // Timer
  void startTimer(int seconds) {
    setState(() {
      _remainingSeconds = seconds;
    });

    _timer?.cancel(); // cancel any existing timer before starting a new one

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Progress bar animation
  // 🔹 Function to animate progress from 0 → 1 in 5 seconds
  void animateProgressBar() async {
    const duration = Duration(milliseconds: 50); // how often to update
    const totalTime = Duration(seconds: 2); // total animation time
    final steps = totalTime.inMilliseconds ~/ duration.inMilliseconds;

    if (!isTimerStarted) {
      for (int i = 0; i <= steps; i++) {
        await Future.delayed(duration);
        setState(() {
          progressValue = i / steps;
        });
      }
    } else {
      progressValue = 0;
    }
  }

  // Function to compute color based on progress
  Color getProgressColor(double p) {
    // From blue (cool) → red (hot)
    // return Color.lerp(Colors.blue, Colors.red, progress)!;
    const c1 = Color(0xFF44A1FF); // cool blue
    const c2 = Color(0xFFFFB458); // orange
    const c3 = Color(0xFFFF5339); // red-orange
    const c4 = Color(0xFFFF0346); // deep red

    if (p <= 0.33) {
      // transition: blue → orange
      return Color.lerp(c1, c2, p / 0.33)!;
    } else if (p <= 0.66) {
      // transition: orange → red-orange
      return Color.lerp(c2, c3, (p - 0.33) / 0.33)!;
    } else {
      // transition: red-orange → deep red
      return Color.lerp(c3, c4, (p - 0.66) / 0.34)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildDashboard(), _buildStats(), _buildSettings()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text(
            "Smart Hybrid Eco Incineration Bin",
            style: TextStyle(
              color: foregroundColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          // leading: _circleIcon(
          //   Icons.menu,
          //   mutedForeground,
          //   cardColor,
          //   mutedColor,
          // ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8.0),
          //     child: _circleIcon(
          //       Icons.settings,
          //       mutedForeground,
          //       cardColor,
          //       mutedColor,
          //     ),
          //   ),
          // ],
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          unselectedItemColor: mutedForeground,
          backgroundColor: cardColor,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.bar_chart_outlined),
            //   label: 'Stats',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
     
      ),
    );
  }

  // -------------------
  // 🏠 PAGE 1: Dashboard
  // -------------------
  Widget _buildDashboard() {
    return Column(
      children: [
        Text(
          "Monitor and control operations",
          style: TextStyle(
            fontSize: 16,
            // color: primaryColor,
            // fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Heat Level and Timer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _controlCard(
                  icon: Icons.local_fire_department_outlined,
                  title: "Heat Level",
                  sliderValue: heatLevel,
                  onChanged: (v) {
                    setState(() => heatLevel = v);
                  },
                  // valueText: "${(heatLevel * 100).round()}%",
                  // subText: "${(heatLevel * 1200).round()}°C",
                  min: 0,
                  max: 100,
                  divisions: 100,
                  valueText: "${(heatLevel).round()}%",
                  subText:
                      "${(tMin + ((heatLevel - 1) / (100 - 1)) * (tMax - tMin)).round()}°C",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _controlCard(
                  icon: Icons.timer_outlined,
                  title: "Timer",
                  sliderValue: timerValue,
                  onChanged: (v) {
                    // setState(() => timerValue = v);
                    setState(() {
                      _logger.d("isTimerStarted: $isTimerStarted");

                      if (!isTimerStarted) {
                        timerValue = v;
                        _logger.d("timerValue: $timerValue");
                      }
                    });
                  },
                  // valueText: "${(timerValue * 60).round()} min",
                  min: 0,
                  max: 60,
                  divisions: 12,
                  valueText: "${(timerValue).round()} min",
                  subText: "Duration",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        // Chamber Temperature (full width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.thermostat, size: 40, color: Colors.black),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Chamber Temperature",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          isRequestValid ? "$temperature°C" : "OFFLINE",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        // value: 0.40,
                        value: temperature.toDouble(),
                        // value: progressValue,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 7),

        // Smoke and Timer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon(
                          //   // Icons.ac_unit_outlined,
                          //   Icons.ac_unit_outlined,
                          //   size: 20,
                          //   color: Colors.black,
                          // ),
                          SvgPicture.asset(
                            'assets/images/air-filter.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Smoke\nPurification",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // SliderTheme(
                      //   data: SliderThemeData(
                      //     trackHeight: 10,
                      //     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      //     overlayShape: SliderComponentShape.noOverlay,
                      //   ),
                      //   child: Slider(
                      //     min: min,
                      //     max: max,
                      //     divisions: divisions,
                      //     value: sliderValue,
                      //     onChanged: onChanged,
                      //     activeColor: Colors.black,
                      //     inactiveColor: Colors.grey[300],
                      //   ),
                      // ),
                      const SizedBox(height: 4),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "INACTIVE",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            // Text(
                            //   "System Standby",
                            //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Timer",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // SliderTheme(
                      //   data: SliderThemeData(
                      //     trackHeight: 10,
                      //     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      //     overlayShape: SliderComponentShape.noOverlay,
                      //   ),
                      //   child: Slider(
                      //     min: min,
                      //     max: max,
                      //     divisions: divisions,
                      //     value: sliderValue,
                      //     onChanged: onChanged,
                      //     activeColor: Colors.black,
                      //     inactiveColor: Colors.grey[300],
                      //   ),
                      // ),
                      const SizedBox(height: 4),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Time Remaining",
                              style: const TextStyle(
                                // fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              // "00:00:00",
                              formatTime(_remainingSeconds),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            // Text(
                            //   "System Standby",
                            //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Process Progress (full width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, size: 20, color: Colors.black),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Process Progress",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${(progressValue * 100).round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Progress Bar
                const SizedBox(height: 16),

                // Process Color bar
                Center(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        // value: 0.25,
                        value: progressValue,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        // valueColor: AlwaysStoppedAnimation(Colors.red),
                        // valueColor: getProgressColor(progressValue),
                        color: getProgressColor(progressValue),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ],
                    
                  ),
                ),

                const SizedBox(height: 4),

                // Process Info Texts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Idle",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      "Heating",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      "Incinerating",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      "Complete",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Start and Stop
        const Spacer(),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: timerValue != 0
                      ? () async {
                          Fluttertoast.showToast(
                            msg: "Starting",
                            toastLength:
                                Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
                            gravity: ToastGravity
                                .BOTTOM, // You can use CENTER or TOP
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );

                          bool start = await sendCommand(
                            "timer:${timerValue.toInt() * 60}",
                            // "timer:${12}",
                          );
                          // animateProgressBar();

                          _logger.i("Start Status: $start");
                          if (start) {
                            isTimerStarted = true;
                            startTimer(timerValue.toInt() * 60);
                            // _logger.i("Start Status: ${timerValue.toInt()}");

                            // Check status occassionaly
                            checkStatus();
                            // startTimer(timerValue.toInt() * 60);
                          } else {
                            isTimerStarted = false;
                          }
                        }
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // keeps button compact
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      SizedBox(width: 8), // spacing between icon and text
                      Text(
                        "Start",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mutedColor,
                    foregroundColor: foregroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: timerValue != 0
                      ? () async {
                          Fluttertoast.showToast(
                            msg: "Stopping, please wait...",
                            toastLength:
                                Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
                            gravity: ToastGravity
                                .BOTTOM, // You can use CENTER or TOP
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );

                          bool start = await sendCommand("timer:0");

                          _logger.i("Start Status: $start");
                          if (start) {
                            startTimer(0);
                          }

                          isTimerStarted = false;
                        }
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // keeps button compact
                    children: [
                      Icon(
                        Icons.stop_outlined,
                        color: Color.fromARGB(255, 94, 94, 94),
                        size: 24,
                      ),
                      SizedBox(width: 8), // spacing between icon and text
                      Text(
                        "Stop",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 94, 94, 94),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------
  // 📊 PAGE 2: Stats
  // -------------------
  Widget _buildStats() {
    return const Center(
      child: Text(
        "Statistics Page",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
    );
  }

  // -------------------
  // ⚙️ PAGE 3: Settings
  // -------------------
  Widget _buildSettings() {
    return const Center(
      child: Text(
        "Settings Page",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
    );
  }

  // Helper for round icons (removed unused helper to satisfy analyzer)

  Future<bool> sendCommand(status) async {
    bool responseStatus = false;

    try {
      final url = Uri.parse('http://esp8266-device.local/led');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'text/plain'},
        body: status, // e.g. 'ON' or 'OFF'
      );

      if (response.statusCode == 200) {
        if (status == "ON" || status == "OFF") {
          _logger.i('LED updated successfully: ${response.body}');

          Fluttertoast.showToast(
            msg: "${status == "ON" ? "Started" : "Stopped"} Incinerator",
            toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
            gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        responseStatus = true;
      } else {
        _logger.w(
          'Unexpected status: ${response.statusCode} - ${response.body}',
        );

        Fluttertoast.showToast(
          msg: 'Unexpected status: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
          gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error sending request to ESP8266: $e, $stackTrace');

      Fluttertoast.showToast(
        msg: 'Error sending request to ESP8266: $e',
        toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
        gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      _logger.i('Request to ESP8266 completed.');
    }

    return responseStatus;
  }

  Future<void> readSensorDetails() async {
    try {
      final url = Uri.parse('http://esp8266-device.local/info');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'text/plain'},
        // body: status, // e.g. 'ON' or 'OFF'
      );

      if (response.statusCode == 200) {
        _logger.i('Info retrieved successfully: ${response.body}');
      } else {
        _logger.w(
          'Unexpected status: ${response.statusCode} - ${response.body}',
        );

        Fluttertoast.showToast(
          msg: 'Unexpected status: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
          gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e, stacktrace) {
      _logger.e('Error sending request to ESP8266: $e, $stacktrace');

      Fluttertoast.showToast(
        msg: 'Error sending request to ESP8266: $e',
        toastLength: Toast.LENGTH_SHORT, // Auto-hides after ~2 sec
        gravity: ToastGravity.BOTTOM, // You can use CENTER or TOP
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      _logger.i('Request to ESP8266 completed.');
    }
  }

  Widget _controlCard({
    required IconData icon,
    required String title,
    required double sliderValue,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required int divisions,
    required String valueText,
    required String subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 10,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              min: min,
              max: max,
              divisions: divisions,
              value: sliderValue,
              onChanged: onChanged,
              activeColor: Colors.black,
              inactiveColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Column(
              children: [
                Text(
                  valueText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
