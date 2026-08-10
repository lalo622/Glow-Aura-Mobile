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
  static final Uri _returnUri = Uri.parse(kPayOSReturnUrl);
  static final Uri _cancelUri = Uri.parse(kPayOSCancelUrl);

  WebViewController? _controller;
  bool _isLoading = true;
  bool _resultReturned = false; 
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final uri = Uri.tryParse(widget.checkoutUrl);
    if (widget.checkoutUrl.trim().isEmpty || uri == null || !uri.hasScheme) {
      setState(() {
        _isLoading = false;
        _loadError = 'Đường dẫn thanh toán không hợp lệ.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _isLoading = progress < 100);
          },
          onNavigationRequest: (request) {
            if (_matchAndHandle(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame == false) return;
            setState(() {
              _isLoading = false;
              _loadError = 'Không tải được trang thanh toán (${error.description}). '
                  'Vui lòng kiểm tra kết nối mạng và thử lại.';
            });
          },
        ),
      )
      ..loadRequest(uri);

    setState(() {}); 
  }

  bool _matchAndHandle(String url) {
    if (_resultReturned) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (_isSameEndpoint(uri, _returnUri)) {
      _resultReturned = true;
      Navigator.of(context).pop(PayOSResult.success);
      return true;
    }
    if (_isSameEndpoint(uri, _cancelUri)) {
      _resultReturned = true;
      Navigator.of(context).pop(PayOSResult.cancelled);
      return true;
    }
    return false;
  }

  bool _isSameEndpoint(Uri actual, Uri target) {
    return actual.host == target.host && actual.path == target.path;
  }

  void _retry() {
    setState(() => _resultReturned = false);
    _initController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (_isLoading && _loadError == null)
              const Center(child: CircularProgressIndicator()),
            if (_loadError != null) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(PayOSResult.cancelled),
                child: const Text('Huỷ'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _retry,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}