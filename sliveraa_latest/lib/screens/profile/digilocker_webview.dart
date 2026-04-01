import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class DigiLockerWebView extends StatefulWidget {
  const DigiLockerWebView({super.key});

  @override
  State<DigiLockerWebView> createState() => _DigiLockerWebViewState();
}

class _DigiLockerWebViewState extends State<DigiLockerWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  String? _clientId;
  String? _url;

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    try {
      final response = await ApiService().initDigiLocker();
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _url = data['url'];
          _clientId = data['client_id'];
          _initWebViewController();
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to initialize KYC session';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _initWebViewController() {
    if (_url == null) return;
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            print('Page Finished: $url');
          },
          onWebResourceError: (error) {
            print('Web Resource Error: ${error.description}');
          },
          onUrlChange: (change) {
            final url = change.url ?? '';
            print('URL Change detected: $url');
            
            // Intercept our unique callback URL or generic status parameters
            if (url.startsWith('https://silvra.app/kyc/callback') || url.contains('status=')) {
               _handleCallback(url);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_url!));
  }

  void _handleCallback(String url) {
    print('Processing Callback URL: $url');
    try {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];
      
      if (status == 'SUCCESS') {
        _onVerificationComplete();
      } else if (status == 'FAILURE' || status == 'ERROR') {
        setState(() {
          _errorMessage = uri.queryParameters['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      print('Callback Handling Error: $e');
    }
  }

  Future<void> _onVerificationComplete() async {
    if (_clientId == null) return;
    
    try {
      setState(() => _isLoading = true);
      final response = await ApiService().finalizeDigiLocker(_clientId!);
      
      if (mounted) {
        if (response.data['success'] == true) {
          // Responsibility: Success Guidance
          final appState = Provider.of<AppState>(context, listen: false);
          // Actual status update from backend
          final profileResponse = await ApiService().getUserProfile();
          if (profileResponse.data != null) {
             appState.updateFromMap(profileResponse.data);
          }
          _showSuccessDialog();
        } else {
          // Responsibility: Explain Why it failed
          _showErrorDialog(response.data['message'] ?? 'Identity verification stalled. Please contact support.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Verification connection lost. Your progress is saved. Please check your profile status later.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Identity Verified!',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Your KYC has been successfully completed. You can now start investing in your vault.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit WebView
              },
              child: Text(
                'CONTINUE TO PORTFOLIO',
                style: GoogleFonts.manrope(color: AppColors.primaryBrownGold, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verification Stalled',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.manrope(color: AppColors.primaryBrownGold, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DigiLocker Verification',
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isLoading = true;
                        });
                        _fetchSession();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrownGold),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else if (_url != null)
            WebViewWidget(controller: _controller)
          else if (!_isLoading)
            const Center(child: Text('Unable to load KYC session')),
            
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryBrownGold)),
        ],
      ),
    );
  }
}
