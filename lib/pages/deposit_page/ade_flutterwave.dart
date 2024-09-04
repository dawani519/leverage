import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class AdeFlutterWavePay extends StatefulWidget {
  final Map<String, String> data;
  const AdeFlutterWavePay(this.data, {super.key});

  @override
  _AdeFlutterWavePayState createState() => _AdeFlutterWavePayState();
}

class _AdeFlutterWavePayState extends State<AdeFlutterWavePay> {
  late WebViewController _webViewController;
  bool isGeneratingCode = true;

  @override
  void initState() {
    super.initState();
    // Ensure WebView is initialized before usage
    if (WebView.platform is SurfaceAndroidWebView) {
      // Initialize the WebViewController on Android
      WebView.platform = SurfaceAndroidWebView();
    }
    _loadPaymentPage();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isGeneratingCode,
      opacity: 1,
      color: Colors.black54,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh_sharp),
          onPressed: _loadPaymentPage,
        ),
        appBar: AppBar(
          title: Text(widget.data["title"] ?? 'Payment'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'messageHandler',
              onMessageReceived: (JavascriptMessage message) {
                _handlePaymentResponse(message.message);
              },
            ),
          },
        ),
      ),
    );
  }

  void _loadPaymentPage() async {
    final htmlContent = _buildHtmlContent();
    _webViewController.loadUrl(Uri.dataFromString(htmlContent,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());

    setState(() {
      isGeneratingCode = true;
    });
    _initiatePayment(); // Initiate payment after loading the page
  }

  String _buildHtmlContent() {
    return '''
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>${widget.data["title"] ?? "Payment"}</title>
        <script src="https://checkout.flutterwave.com/v3.js"></script>
      </head>
      <body>
        <h2 style="text-align:center;">Please wait, initializing payment...</h2>
        <script>
          function makePayment(tx_ref, amount, currency, public_key, payment_options) {
            FlutterwaveCheckout({
              public_key: public_key,
              tx_ref: tx_ref,
              amount: amount,
              currency: currency,
              payment_options: payment_options,
              callback: function (data) {
                window.stop();
                messageHandler.postMessage(JSON.stringify(data));
              },
              onclose: function () {
                messageHandler.postMessage(JSON.stringify({ status: "cancelled" }));
              },
              customizations: {
                title: "${widget.data["title"] ?? "Payment"}",
              }
            });
          }
        </script>
      </body>
    </html>
    ''';
  }

  void _initiatePayment() {
    _webViewController.runJavascript(
      'makePayment("${widget.data["tx_ref"]}", "${widget.data["amount"]}", "${widget.data["currency"]}", "${widget.data["public_key"]}", "${widget.data["payment_options"]}")',
    );
    setState(() {
      isGeneratingCode = false;
    });
  }

  void _handlePaymentResponse(String message) async {
    final response = jsonDecode(message);

    if (response["status"] == "cancelled") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction cancelled!")),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Verifying transaction, please wait...")),
    );

    try {
      final verificationResponse = await http.get(
        Uri.parse(
          "https://api.flutterwave.com/v3/transactions/${response["transaction_id"]}/verify",
        ),
        headers: {
          "Authorization": "Bearer ${widget.data["sk_key"]}",
          "Content-Type": "application/json",
        },
      );

      final verificationResult = jsonDecode(verificationResponse.body);

      if (verificationResult["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction verified! Redirecting..."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, verificationResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaction verification failed!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred during verification."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isGeneratingCode = false;
      });
    }
  }
}
