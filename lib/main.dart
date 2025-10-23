import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartBinDashboard());
}

class SmartBinDashboard extends StatefulWidget {
  const SmartBinDashboard({super.key});

  @override
  State<SmartBinDashboard> createState() => _SmartBinDashboardState();
}

class _SmartBinDashboardState extends State<SmartBinDashboard> {
  int _selectedIndex = 0;

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
            "Bin",
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
        const SizedBox(height: 24),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: mutedColor, width: 20),
                ),
              ),
              Transform.rotate(
                angle: 0.785, // 45 degrees
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 20),
                  ),
                ),
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.local_fire_department,
                      color: primaryColor,
                      size: 64,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "750°C",
                      style: TextStyle(
                        fontSize: 32,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mutedColor),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Incineration",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: foregroundColor,
                          ),
                        ),
                        Text(
                          "Active",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 10,
                        backgroundColor: mutedColor,
                        valueColor: const AlwaysStoppedAnimation(primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                        color: Colors.yellow.withOpacity(0.2),
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
    final url = Uri.parse('http://192.168.1.8/led');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'text/plain'},
      body: status, // or 'OFF'
    );

    print('Response: ${response.body}');
  }

}
