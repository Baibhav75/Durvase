import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service/session_manager.dart';
import 'model/TodoModel.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  Map<String, dynamic>? _storedData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await SessionManager.debugGetStoredData();
      final isLoggedIn = await SessionManager.isLoggedIn();
      final userData = await SessionManager.getLoginData();

      setState(() {
        _storedData = {
          ...data,
          'isLoggedInMethod': isLoggedIn,
          'parsedUserData': userData?.toJson(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _storedData = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    await SessionManager.logout();
    _loadDebugInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Info', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loadDebugInfo,
              child: Text('Refresh Data', style: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Clear Session Data',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Session Debug Information:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_storedData != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _storedData!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SelectableText(
                                entry.value.toString(),
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              Text('No data available', style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }
}
