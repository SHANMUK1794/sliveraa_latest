import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    try {
      final response = await ApiService().initDigiLocker();
      
      // The backend returns { data: { token, client_id, ... }, status_code: 200 }
      final String token = response.data['data']?['token'] ?? '';
      _clientId = response.data['data']?['client_id'];
      
      if (token.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid session token received';
          _isLoading = false;
        });
        return;
      }

      _initializeWebView(token);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _initializeWebView(String token) {
    const String gateway = "sandbox"; 

    final String sdkHtml = """
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <title>Digiboost SDK</title>
          <style>
              body, html { margin: 0; padding: 0; height: 100%; width: 100%; display: flex; align-items: center; justify-content: center; background-color: #f8f9fa; }
              #digilocker-button { width: 90%; max-width: 400px; }
              .loading-text { font-family: sans-serif; color: #666; font-size: 14px; }
          </style>
          <script src="https://cdn.jsdelivr.net/gh/surepassio/surepass-digiboost-web-sdk@latest/index.min.js"></script>
      </head>
      <body>
          <div id="digilocker-button">
              <p class="loading-text">Initializing verification...</p>
          </div>

          <script>
            try {
              window.DigiboostSdk({ 
                gateway: "$gateway", 
                token: "$token", 
                selector: "#digilocker-button",
                style: {
                  backgroundColor: "#613AF5",
                  color: "white",
                  padding: "15px 30px",
                  borderRadius: "12px",
                  fontSize: "16px",
                  fontWeight: "bold",
                  width: "100%",
                  textAlign: "center",
                  border: "none",
                  boxShadow: "0 4px 12px rgba(97, 58, 245, 0.3)"
                },
                onSuccess: function(data) {
                  if (window.SurepassHandler) {
                    window.SurepassHandler.postMessage(JSON.stringify({
                      status: 'SUCCESS',
                      data: data
                    }));
                  }
                },
                onFailure: function(error) {
                  if (window.SurepassHandler) {
                    window.SurepassHandler.postMessage(JSON.stringify({
                      status: 'FAILURE',
                      error: error
                    }));
                  }
                }
              });
            } catch (err) {
              if (window.SurepassHandler) {
                window.SurepassHandler.postMessage(JSON.stringify({
                  status: 'ERROR',
                  message: err.message
                }));
              }
            }
          </script>
      </body>
      </html>
    """;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'SurepassHandler',
        onMessageReceived: (JavaScriptMessage message) {
          _handleSdkCallback(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(sdkHtml);
  }

  void _handleSdkCallback(String message) {
    print('SDK Callback Received: $message');
    try {
      final data = jsonDecode(message);
      final String status = data['status'];

      if (status == 'SUCCESS') {
        print('Success signal detected - starting finalization...');
        _onVerificationComplete();
      } else if (status == 'FAILURE' || status == 'ERROR') {
        print('Error signal detected: ${data['error'] ?? data['message']}');
        setState(() {
          _errorMessage = data['error'] ?? data['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      print('Callback JSON Parsing Error: $e');
    }
  }

  Future<void> _onVerificationComplete() async {
    print('Finalizing KYC for Client ID: $_clientId');
    try {
      setState(() => _isLoading = true);
      
      if (_clientId != null) {
        try {
          final response = await ApiService().finalizeDigiLocker(_clientId!);
          if (mounted) {
            if (response.data['success'] == true) {
              // Responsibility: Instant feedback on success
              await context.read<AppState>().refreshStatus();
              _showSuccessDialog();
            } else {
              // Responsibility: Explaining WHY backend rejected it
              String message = response.data['message'] ?? 'Identity verification stalled. Please contact Silvra support.';
              _showErrorDialog(message);
            }
          }
        } catch (e) {
          if (mounted) {
            _showErrorDialog('Verification connection lost. Don\'t worry, your DigiLocker progress is saved. Please try refreshing your status later.');
          }
        }
      }
    } catch (e) {
      print('Finalization Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Server Sync Failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verification',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Smart Close: If they close it, we try to finalize anyway just in case
            _onVerificationComplete();
          },
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _onVerificationComplete,
              child: Text(
                'I HAVE COMPLETED',
                style: GoogleFonts.manrope(
                  color: Colors.blue,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey),
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
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else if (!_isLoading)
            WebViewWidget(controller: _controller)
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Securing verification...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
