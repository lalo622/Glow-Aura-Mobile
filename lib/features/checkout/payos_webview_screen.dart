import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';

const String kPayOSReturnUrl = 'https://glowaura.app/payment-success';
const String kPayOSCancelUrl = 'https://glowaura.app/payment-cancel';

enum PayOSResult { success, cancelled }

class PayOSWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const PayOSWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<PayOSWebViewScreen> createState() => _PayOSWebViewScreenState();
}

class _PayOSWebViewScreenState extends State<PayOSWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resultReturned = false; // tránh pop nhiều lần

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _handleUrl(url),
          onProgress: (progress) {
            if (mounted) setState(() => _isLoading = progress < 100);
          },
          onNavigationRequest: (request) {
            if (_matchAndHandle(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleUrl(String url) => _matchAndHandle(url);

  bool _matchAndHandle(String url) {
    if (_resultReturned) return false;

    if (url.startsWith(kPayOSReturnUrl)) {
      _resultReturned = true;
      Navigator.of(context).pop(PayOSResult.success);
      return true;
    }
    if (url.startsWith(kPayOSCancelUrl)) {
      _resultReturned = true;
      Navigator.of(context).pop(PayOSResult.cancelled);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Chặn back cứng để tránh thoát dở dang, hỏi xác nhận huỷ
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Huỷ thanh toán?'),
            content: const Text('Bạn có chắc muốn huỷ giao dịch này?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Tiếp tục thanh toán')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Huỷ')),
            ],
          ),
        );
        if (confirm == true && mounted) {
          Navigator.of(context).pop(PayOSResult.cancelled);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán PayOS'),
          backgroundColor: AppColors.surface,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}