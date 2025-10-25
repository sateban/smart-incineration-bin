import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
// import 'package:multicast_dns/multicast_dns.dart';

var _logger = Logger();

void main() {
  // runApp(const SmartBinDashboard());
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Bin',
      home: const GetStartedPage(), // 👈 start here first
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
                    onPressed: () {
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
  double timerValue = 0.5; // 30 min
  double tMin = 100;
double tMax = 1200;

  static const primaryColor = Color(0xFF38E07B);
  static const backgroundColor = Color(0xFFF7F8FA);
  static const mutedColor = Color(0xFFE5E7EB);
  static const mutedForeground = Color(0xFF6B7280);
  static const cardColor = Colors.white;
  static const foregroundColor = Color(0xFF1A1A1A);

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
          selectedItemColor: primaryColor,
          unselectedItemColor: mutedForeground,
          backgroundColor: cardColor,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Stats',
            ),
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
                  subText: "${(tMin + ((heatLevel - 1) / (100 - 1)) * (tMax - tMin)).round()}°C",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _controlCard(
                  icon: Icons.timer_outlined,
                  title: "Timer Set",
                  sliderValue: timerValue,
                  onChanged: (v) {
                    // setState(() => timerValue = v);
                    setState(() => timerValue = v);
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

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     color: cardColor,
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(color: mutedColor),
              //   ),
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: const [
              //           Text(
              //             "Incineration",
              //             style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: foregroundColor,
              //             ),
              //           ),
              //           Text(
              //             "Active",
              //             style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: primaryColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 8),
              //       ClipRRect(
              //         borderRadius: BorderRadius.circular(50),
              //         child: LinearProgressIndicator(
              //           value: 0.75,
              //           minHeight: 10,
              //           backgroundColor: mutedColor,
              //           valueColor: const AlwaysStoppedAnimation(primaryColor),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mutedColor),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ash Tray Full",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: foregroundColor,
                            ),
                          ),
                          Text(
                            "Please empty the ash tray to continue.",
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Empty",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mutedColor,
                    foregroundColor: foregroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () async {
                    setLedLight("OFF");
                  },
                  child: const Text(
                    "Stop",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () async {
                    setLedLight("ON");
                  },
                  child: const Text(
                    "Start",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // Helper for round icons
  static Widget _circleIcon(
    IconData icon,
    Color iconColor,
    Color bg,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  Future<void> setLedLight(status) async {
    try {
      final url = Uri.parse('http://esp8266-device.local/led');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'text/plain'},
        body: status, // e.g. 'ON' or 'OFF'
      );

      if (response.statusCode == 200) {
        _logger.i('LED updated successfully: ${response.body}');
      } else {
        _logger.w(
          'Unexpected status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error sending request to ESP8266: $e, $stackTrace');
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
