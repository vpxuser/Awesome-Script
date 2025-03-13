Java.perform(function () {
    var WebView = Java.use("android.webkit.WebView");
    var WebViewClient = Java.use("android.webkit.WebViewClient");
    var SslError = Java.use("android.net.http.SslError");

    // SSL 错误类型映射
    var sslErrorTypes = {
        0: "证书尚未生效 (NOT_YET_VALID)",
        1: "证书已过期 (EXPIRED)",
        2: "证书与服务器名称不匹配 (ID_MISMATCH)",
        3: "证书不受信任 (UNTRUSTED)",
        4: "证书日期无效 (DATE_INVALID)",
        5: "证书无效 (INVALID)"
    };

    console.log("[*] WebView Debugging Hook Installed!");

    // Hook WebView.loadUrl(String)
    WebView.loadUrl.overload("java.lang.String").implementation = function (url) {
        console.log("[*] WebView.loadUrl() → " + url);
        this.loadUrl(url);
    };

    // Hook WebView.loadUrl(String, Map)
    WebView.loadUrl.overload("java.lang.String", "java.util.Map").implementation = function (url, additionalHttpHeaders) {
        console.log("[*] WebView.loadUrl() with Headers:");
        console.log("    └── URL: " + url);
        this.loadUrl(url, additionalHttpHeaders);
    };

    // Hook shouldOverrideUrlLoading(WebView, WebResourceRequest)
    var WebResourceRequest = Java.use("android.webkit.WebResourceRequest");
    WebViewClient.shouldOverrideUrlLoading.overload("android.webkit.WebView", "android.webkit.WebResourceRequest").implementation = function (view, request) {
        var url = request.getUrl().toString();
        console.log("[*] shouldOverrideUrlLoading() → URL: " + url);
        console.log("    ├── Method: " + request.getMethod());
        console.log("    └── Is Secure? " + (url.startsWith("https") ? "Yes" : "No"));
        return this.shouldOverrideUrlLoading(view, request);
    };

    // Hook shouldInterceptRequest(WebView, WebResourceRequest)
    WebViewClient.shouldInterceptRequest.overload("android.webkit.WebView", "android.webkit.WebResourceRequest").implementation = function (view, request) {
        var url = request.getUrl().toString();
        console.log("[*] shouldInterceptRequest() → URL: " + url);
        console.log("    ├── Method: " + request.getMethod());
        console.log("    └── Is Secure? " + (url.startsWith("https") ? "Yes" : "No"));
        return this.shouldInterceptRequest(view, request);
    };

    // Hook onReceivedSslError(WebView, SslErrorHandler, SslError)
    WebViewClient.onReceivedSslError.implementation = function (view, handler, error) {
        var errorType = error.getPrimaryError();
        var errorDesc = sslErrorTypes[errorType] || "UNKNOWN";

        console.log("[!] SSL Error in WebView");
        console.log("    ├── URL: " + view.getUrl());
        console.log("    ├── Error Type: " + errorType + " (" + errorDesc + ")");
        console.log("    ├── Certificate: " + error.getCertificate());
        // 监听是否调用了 handler.proceed()
        var proceedCalled = false;
        var originalProceed = handler.proceed;

        handler.proceed = function () {
            proceedCalled = true;
            originalProceed.call(this);
        };

        // 执行原始逻辑
        this.onReceivedSslError(view, handler, error);

        console.log("    └── Ignoring SSL Error? " + (proceedCalled ? "Yes" : "No"));
    };

    // Hook onPageStarted(WebView, String, Bitmap)
    WebViewClient.onPageStarted.implementation = function (view, url, favicon) {
        console.log("[*] WebView onPageStarted() → " + url);
        this.onPageStarted(view, url, favicon);
    };

    // Hook onPageFinished(WebView, String)
    WebViewClient.onPageFinished.implementation = function (view, url) {
        console.log("[*] WebView onPageFinished() → " + url);
        this.onPageFinished(view, url);
    };
});
