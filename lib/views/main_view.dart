import 'package:flutter/material.dart';
import 'package:trashwisecollector/views/accepted_request_view.dart';
import 'package:trashwisecollector/views/pending_requests_view.dart';
import 'package:trashwisecollector/views/history_view.dart';

class MainView extends StatefulWidget {
  static const routeName = '/main-view';

  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  // Pages connected to the bottom nav bar
  final List<Widget> _pages = const [
    PendingRequestsView(),      // HOME
    AcceptedRequestsView(),     // ACCEPTED
    HistoryView(),              // COMPLETED HISTORY
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "Accepted",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: "History",
          ),
        ],

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
