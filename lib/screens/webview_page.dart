import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.title});

  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  final GlobalKey webViewKey = GlobalKey();
  bool isLoading = true;
  bool hasError = false;
  String currentUrl = AppConfig.webUrl;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _checkAndRequestPermissions();
    } else {
      // On web, we'll display a message instead of using WebView
      isLoading = false;
    }
  }

  // Comprehensive permission handling for both Android and iOS
  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Android permissions - only request the essential ones
      await [Permission.photos, Permission.camera, Permission.videos].request();
    } else if (Platform.isIOS) {
      // iOS permissions - only request the essential ones
      await [
        Permission.photos,
        Permission.camera,
        Permission.mediaLibrary,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: kIsWeb || _webViewController == null,
      onPopInvoked: (didPop) async {
        if (!didPop &&
            !kIsWeb &&
            _webViewController != null &&
            await _webViewController!.canGoBack()) {
          _webViewController!.goBack();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (!kIsWeb)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(AppConfig.webUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      mediaPlaybackRequiresUserGesture: false,
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      supportZoom: true,
                      useShouldOverrideUrlLoading: true,
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true,
                      useHybridComposition: true,
                      useOnLoadResource: true,
                      supportMultipleWindows: true,
                      verticalScrollBarEnabled: true,
                      horizontalScrollBarEnabled: true,
                      preferredContentMode:
                          UserPreferredContentMode.RECOMMENDED,
                      userAgent:
                          "Mozilla/5.0 (Linux; Android 10; SM-A205U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36",
                      allowsInlineMediaPlayback: true,
                      useShouldInterceptRequest: true,
                      useShouldInterceptAjaxRequest: true,
                      cacheEnabled: true,
                      clearCache: false,
                      domStorageEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      useWideViewPort: true,
                      mixedContentMode:
                          MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      allowContentAccess: true,
                      safeBrowsingEnabled: false,
                      disableDefaultErrorPage: true,
                      // Enable file selection and access
                      allowFileAccess: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      _injectFormDataLogger(controller);
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        isLoading = true;
                        hasError = false;
                        currentUrl = url?.toString() ?? '';
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        isLoading = false;
                        currentUrl = url?.toString() ?? '';
                      });
                      _injectFormDataLogger(controller);
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        loadingProgress = progress / 100;
                        if (progress == 100) {
                          isLoading = false;
                        }
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      setState(() {
                        hasError = true;
                        isLoading = false;
                        if (error.description.contains(
                          'ERR_NAME_NOT_RESOLVED',
                        )) {
                          currentUrl = "ERR_NAME_NOT_RESOLVED: ${request.url}";
                        } else {
                          currentUrl =
                              "ERROR: ${error.description} - ${request.url}";
                        }
                      });
                      debugPrint(
                        'WebView error: ${error.description} for URL: ${request.url}',
                      );
                    },
                    onEnterFullscreen: (controller) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    onExitFullscreen: (controller) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    // Handle file uploads
                    onCreateWindow: (controller, createWindowAction) async {
                      // Allow new windows (like file chooser popups)
                      return true;
                    },
                    // Handle file chooser
                    androidOnPermissionRequest: (
                      controller,
                      origin,
                      resources,
                    ) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT,
                      );
                    },
                    // Handle file selection
                    onReceivedHttpAuthRequest: (controller, challenge) async {
                      // Allow all auth requests
                      return HttpAuthResponse(
                        action: HttpAuthResponseAction.PROCEED,
                        username: '',
                        password: '',
                      );
                    },
                    shouldOverrideUrlLoading: (
                      controller,
                      navigationAction,
                    ) async {
                      final uri = navigationAction.request.url;

                      // Log all navigation attempts
                      debugPrint('Navigation to: ${uri.toString()}');

                      // Handle API requests specially
                      if (uri?.host == 'api.zynoflixott.com') {
                        debugPrint('API request detected: ${uri.toString()}');
                        // Let the JavaScript handler handle API requests
                        return NavigationActionPolicy.ALLOW;
                      }

                      // Handle special schemes like file uploads
                      if (uri?.scheme == 'intent' ||
                          uri?.scheme == 'mailto' ||
                          uri?.scheme == 'tel' ||
                          uri?.scheme == 'sms') {
                        debugPrint('Special scheme detected: ${uri?.scheme}');
                        // Let the system handle these special schemes
                        return NavigationActionPolicy.ALLOW;
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppConfig.newLogoPath),
                    const SizedBox(height: 40),
                    Text(
                      'ShortFilm OTT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'For the best experience, please visit ${AppConfig.webUrl} directly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConfig.textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Visit Website'),
                    ),
                  ],
                ),
              ),
            if (isLoading && !kIsWeb)
              Container(
                color: AppConfig.backgroundColor.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppConfig.newLogoPath,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 40),
                      CircularProgressIndicator(
                        value: loadingProgress > 0 ? loadingProgress : null,
                        color: AppConfig.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading... ${(loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppConfig.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasError && !kIsWeb)
              Container(
                color: AppConfig.backgroundColor,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppConfig.newLogoPath,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 32),
                      Icon(
                        Icons.error_outline,
                        color: AppConfig.secondaryColor,
                        size: 60,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentUrl.contains('ERR_NAME_NOT_RESOLVED')
                            ? 'Domain Not Found'
                            : 'Connection Error',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUrl.contains('ERR_NAME_NOT_RESOLVED')
                            ? 'The domain name "${Uri.parse(AppConfig.webUrl).host}" could not be resolved. Please check your internet connection and try again.'
                            : 'Unable to connect to the website. Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          _webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _injectFormDataLogger(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source: r'''
      (function() {
        if (window.formDataLoggerInjected) return;
        window.formDataLoggerInjected = true;
        
        console.log("Video support, link handler, and CORS fixes injected");
        
        try {
          // Fix CORS issues with API requests
          const originalFetch = window.fetch;
          window.fetch = function(url, options = {}) {
            console.log("Fetch intercepted:", url);
            
            try {
              // Handle CORS for API requests
              if (url && url.toString().includes('api.zynoflixott.com')) {
                console.log("API request detected, adding CORS headers");
                
                // Create options if not provided
                options = options || {};
                options.headers = options.headers || {};
                
                // Convert Headers object to plain object if needed
                if (options.headers instanceof Headers) {
                  const headerObj = {};
                  for (const pair of options.headers.entries()) {
                    headerObj[pair[0]] = pair[1];
                  }
                  options.headers = headerObj;
                }
                
                // Add headers that help with CORS
                options.headers['X-Requested-With'] = 'XMLHttpRequest';
                options.mode = 'cors';
                options.credentials = 'include';
                
                // For POST requests, ensure proper content type and format
                if (options.method === 'POST' || options.method === 'PUT') {
                  // Handle FormData
                  if (options.body instanceof FormData) {
                    console.log("FormData being submitted to API");
                    
                    // Convert FormData to JSON for API
                    const jsonData = {};
                    for (const pair of options.body.entries()) {
                      const key = pair[0];
                      const value = pair[1];
                      
                      // Skip logging passwords
                      const logValue = key.includes('password') ? '****' : value;
                      console.log(key + ': ' + logValue);
                      
                      // Handle arrays (fields with [] in their name)
                      if (key.endsWith('[]')) {
                        const baseKey = key.slice(0, -2);
                        if (!jsonData[baseKey]) {
                          jsonData[baseKey] = [];
                        }
                        jsonData[baseKey].push(value);
                      } else {
                        // Convert values to appropriate types
                        if (value === "true") {
                          jsonData[key] = true;
                        } else if (value === "false") {
                          jsonData[key] = false;
                        } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                          jsonData[key] = parseFloat(value);
                        } else {
                          jsonData[key] = value;
                        }
                      }
                    }
                    
                    // Replace FormData with JSON
                    options.body = JSON.stringify(jsonData);
                    options.headers['Content-Type'] = 'application/json';
                    console.log("Converted FormData to JSON:", options.body);
                  } 
                  // Handle string data (likely form encoded)
                  else if (typeof options.body === 'string') {
                    // If it looks like form data, convert to JSON
                    if (options.body.includes('=') && !options.body.startsWith('{')) {
                      try {
                        const formData = new URLSearchParams(options.body);
                        const jsonData = {};
                        
                        for (const [key, value] of formData.entries()) {
                          // Convert values to appropriate types
                          if (value === "true") {
                            jsonData[key] = true;
                          } else if (value === "false") {
                            jsonData[key] = false;
                          } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                            jsonData[key] = parseFloat(value);
                          } else {
                            jsonData[key] = value;
                          }
                        }
                        
                        // Replace with JSON
                        options.body = JSON.stringify(jsonData);
                        options.headers['Content-Type'] = 'application/json';
                        console.log("Converted form string to JSON:", options.body);
                      } catch (e) {
                        console.error("Error converting form string to JSON:", e);
                      }
                    } 
                    // If it's already JSON, ensure content type is set
                    else if (options.body.startsWith('{')) {
                      if (!options.headers['Content-Type']) {
                        options.headers['Content-Type'] = 'application/json';
                      }
                      
                      try {
                        // Log the data (hiding passwords)
                        const jsonData = JSON.parse(options.body);
                        console.log("JSON data being submitted:", 
                          Object.fromEntries(
                            Object.entries(jsonData)
                              .map(([k, v]) => [k, k.includes('password') ? '****' : v])
                          )
                        );
                      } catch (e) {
                        console.log("Form data (non-JSON):", options.body.substring(0, 100) + '...');
                      }
                    }
                  }
                }
              }
              
              return originalFetch(url, options).catch(error => {
                console.error("Fetch error:", error);
                
                // If it's a CORS error for our API, try with a proxy approach
                if (error.message && error.message.includes('CORS') && 
                    url && url.toString().includes('api.zynoflixott.com')) {
                  console.log("CORS error detected, trying alternative approach");
                  
                  // Create a form to submit the request through the WebView
                  const form = document.createElement('form');
                  form.style.display = 'none';
                  form.method = options.method || 'GET';
                  form.action = url;
                  form.target = '_self';
                  
                  // Add data as hidden fields
                  if (options.body instanceof FormData) {
                    for (const pair of options.body.entries()) {
                      const input = document.createElement('input');
                      input.type = 'hidden';
                      input.name = pair[0];
                      input.value = pair[1];
                      form.appendChild(input);
                    }
                  } else if (typeof options.body === 'string') {
                    try {
                      const data = JSON.parse(options.body);
                      for (const key in data) {
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = key;
                        input.value = data[key];
                        form.appendChild(input);
                      }
                    } catch (e) {
                      // Not JSON, use as is
                      const input = document.createElement('input');
                      input.type = 'hidden';
                      input.name = 'data';
                      input.value = options.body;
                      form.appendChild(input);
                    }
                  }
                  
                  // Add to document and submit
                  document.body.appendChild(form);
                  form.submit();
                  document.body.removeChild(form);
                  
                  // Return a promise that never resolves since we're navigating
                  return new Promise(() => {});
                }
                
                throw error;
              });
            } catch (err) {
              console.error("Error in fetch interceptor:", err);
              return originalFetch(url, options);
            }
          };
          
          // Fix XMLHttpRequest for CORS
          const originalXHROpen = XMLHttpRequest.prototype.open;
          const originalXHRSend = XMLHttpRequest.prototype.send;
          
          XMLHttpRequest.prototype.open = function(method, url, ...rest) {
            this._url = url;
            this._method = method;
            return originalXHROpen.apply(this, [method, url, ...rest]);
          };
          
          XMLHttpRequest.prototype.send = function(body) {
            try {
              // If it's an API request
              if (this._url && this._url.toString().includes('api.zynoflixott.com')) {
                console.log("XHR to API detected:", this._method, this._url);
                
                // Set headers that help with CORS
                this.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                
                // For POST requests, process the data
                if ((this._method === 'POST' || this._method === 'PUT') && body) {
                  // Handle FormData with files
                  if (body instanceof FormData) {
                    // Check if FormData contains files
                    let hasFiles = false;
                    const jsonData = {};
                    const filePromises = [];
                    
                    for (const [key, value] of body.entries()) {
                      if (value instanceof File) {
                        hasFiles = true;
                        // Process file later
                        filePromises.push(
                          readFileAsBase64(value).then(base64Data => {
                            jsonData[key] = {
                              name: value.name,
                              type: value.type,
                              size: value.size,
                              data: base64Data
                            };
                          }).catch(err => {
                            console.error(`Error converting file ${key} to base64:`, err);
                          })
                        );
                      } else {
                        // Handle arrays (fields with [] in their name)
                        if (key.endsWith('[]')) {
                          const baseKey = key.slice(0, -2);
                          if (!jsonData[baseKey]) {
                            jsonData[baseKey] = [];
                          }
                          jsonData[baseKey].push(value);
                        } else {
                          // Convert values to appropriate types
                          if (value === "true") {
                            jsonData[key] = true;
                          } else if (value === "false") {
                            jsonData[key] = false;
                          } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                            jsonData[key] = parseFloat(value);
                          } else {
                            jsonData[key] = value;
                          }
                        }
                      }
                    }
                    
                    if (hasFiles) {
                      // If there are files, we need to handle them asynchronously
                      console.log("XHR contains files, handling specially");
                      
                      // Store the XHR instance for later use
                      const xhr = this;
                      
                      // Process all files and then send the request
                      Promise.all(filePromises).then(() => {
                        console.log("All files processed, sending as JSON");
                        
                        // Convert to JSON
                        const jsonBody = JSON.stringify(jsonData);
                        
                        // Set the content type to JSON
                        xhr.setRequestHeader('Content-Type', 'application/json');
                        
                        // Save the processed data for retry if needed
                        xhr._processedData = jsonBody;
                        
                        // Call the original send with the JSON body
                        originalXHRSend.call(xhr, jsonBody);
                      }).catch(err => {
                        console.error("Error processing files:", err);
                        // Fall back to original behavior
                        originalXHRSend.apply(xhr, arguments);
                      });
                      
                      // Return early - the actual send will be called after file processing
                      return;
                    }
                    
                    // If no files, continue with regular FormData processing
                    // Convert FormData to JSON
                    const jsonBody = JSON.stringify(jsonData);
                    console.log("Converted FormData to JSON:", jsonBody);
                    
                    // Set the content type to JSON
                    this.setRequestHeader('Content-Type', 'application/json');
                    
                    // Save the processed data for retry if needed
                    this._processedData = jsonBody;
                    
                    // Use the JSON body instead
                    return originalXHRSend.call(this, jsonBody);
                  } else if (typeof body === 'string' && body.includes('=')) {
                    try {
                      // Convert form data string to JSON
                      const formData = new URLSearchParams(body);
                      const jsonData = {};
                      
                      for (const [key, value] of formData.entries()) {
                        // Convert values to appropriate types
                        if (value === "true") {
                          jsonData[key] = true;
                        } else if (value === "false") {
                          jsonData[key] = false;
                        } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                          jsonData[key] = parseFloat(value);
                        } else {
                          jsonData[key] = value;
                        }
                      }
                      
                      // Replace the body with JSON
                      const jsonBody = JSON.stringify(jsonData);
                      console.log("Converted form data to JSON:", jsonBody);
                      
                      // Set the content type to JSON
                      this.setRequestHeader('Content-Type', 'application/json');
                      
                      // Save the processed data for retry if needed
                      this._processedData = jsonBody;
                      
                      // Use the JSON body instead
                      return originalXHRSend.call(this, jsonBody);
                    } catch (e) {
                      console.error("Error converting form data to JSON:", e);
                    }
                  }
                }
                
                // Handle CORS errors
                this.addEventListener('error', (e) => {
                  console.error("XHR error (possibly CORS):", e);
                  
                  // Try form submission as fallback
                  if ((this._method === 'POST' || this._method === 'PUT') && 
                      (this._processedData || body)) {
                    console.log("Trying form submission as fallback for XHR");
                    
                    // Create a form
                    const form = document.createElement('form');
                    form.style.display = 'none';
                    form.method = this._method;
                    form.action = this._url;
                    
                    // Add data
                    let dataToUse = null;
                    if (this._processedData) {
                      try {
                        dataToUse = JSON.parse(this._processedData);
                      } catch (e) {
                        console.error("Error parsing processed data:", e);
                      }
                    } else if (body instanceof FormData) {
                      dataToUse = {};
                      for (const [key, value] of body.entries()) {
                        dataToUse[key] = value;
                      }
                    } else if (typeof body === 'string') {
                      try {
                        if (body.startsWith('{')) {
                          dataToUse = JSON.parse(body);
                        } else {
                          const formData = new URLSearchParams(body);
                          dataToUse = {};
                          for (const [key, value] of formData.entries()) {
                            dataToUse[key] = value;
                          }
                        }
                      } catch (e) {
                        console.error("Error parsing body:", e);
                      }
                    }
                    
                    // Add fields to form
                    if (dataToUse) {
                      for (const key in dataToUse) {
                        if (Array.isArray(dataToUse[key])) {
                          // Handle arrays
                          dataToUse[key].forEach(value => {
                            const input = document.createElement('input');
                            input.type = 'hidden';
                            input.name = key + '[]';
                            input.value = value;
                            form.appendChild(input);
                          });
                        } else {
                          const input = document.createElement('input');
                          input.type = 'hidden';
                          input.name = key;
                          input.value = dataToUse[key];
                          form.appendChild(input);
                        }
                      }
                    }
                    
                    // Submit
                    document.body.appendChild(form);
                    form.submit();
                    document.body.removeChild(form);
                  }
                });
              }
            } catch (err) {
              console.error("Error in XHR interceptor:", err);
            }
            
            return originalXHRSend.apply(this, arguments);
          };
          
          // Fix form submissions
          function enhanceFormSubmissions() {
          const forms = document.querySelectorAll('form');
          forms.forEach(form => {
              if (!form.hasAttribute('data-enhanced')) {
                form.setAttribute('data-enhanced', 'true');
              
                // Check for signup/register forms and ensure they have logo field with correct name
                if (form.action && (form.action.includes('/signup') || form.action.includes('/register'))) {
                  const fileInputs = form.querySelectorAll('input[type="file"]');
                  fileInputs.forEach(input => {
                    // If this is likely a logo input, ensure it has the correct name
                    if (input.name.toLowerCase().includes('logo') || 
                        input.id.toLowerCase().includes('logo') ||
                        (input.parentElement && input.parentElement.innerText.toLowerCase().includes('logo'))) {
                      console.log("Found logo input, ensuring correct name");
                      input.name = 'logo';
                    }
                  });
                }
                
                // Add submit handler
              form.addEventListener('submit', function(e) {
                  const formAction = this.action || '';
                  const formMethod = this.method || 'GET';
                  
                  console.log(`Form submission: ${formMethod} ${formAction}`);
                  
                  // If it's an API form
                  if (formAction.includes('api.zynoflixott.com')) {
                    console.log("API form detected, ensuring proper submission");
                    
                    // Check if form has file inputs
                    const fileInputs = this.querySelectorAll('input[type="file"]');
                    const hasFiles = Array.from(fileInputs).some(input => input.files && input.files.length > 0);
                    
                    // For signup forms or forms with files, ensure they work
                    if (formAction.includes('/signup') || formAction.includes('/register') || hasFiles) {
                    e.preventDefault();
                      
                      // Handle form with files differently
                      if (hasFiles) {
                        console.log("Form contains files, using FormData for submission");
                        handleFormWithFiles(this, formAction, formMethod);
                        return;
                      }
                      
                      // Get form data for regular forms
                    const formData = new FormData(this);
                      const data = {};
                      
                      // Process form data properly
                      for (const [key, value] of formData.entries()) {
                        // Handle arrays (fields with [] in their name)
                        if (key.endsWith('[]')) {
                          const baseKey = key.slice(0, -2);
                          if (!data[baseKey]) {
                            data[baseKey] = [];
                          }
                          data[baseKey].push(value);
                        } else {
                          // Convert string "true"/"false" to boolean
                          if (value === "true") {
                            data[key] = true;
                          } else if (value === "false") {
                            data[key] = false;
                          } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                            // Convert numeric strings to numbers
                            data[key] = parseFloat(value);
                          } else {
                            data[key] = value;
                          }
                        }
                      }
                      
                      console.log("Form data:", Object.fromEntries(
                        Object.entries(data)
                          .map(([k, v]) => [k, k.includes('password') ? '****' : v])
                      ));
                      
                      // Submit via fetch with proper headers
                    fetch(formAction, {
                        method: formMethod,
                      headers: {
                          'Content-Type': 'application/json',
                          'X-Requested-With': 'XMLHttpRequest',
                          'Accept': 'application/json'
                        },
                        body: JSON.stringify(data),
                        credentials: 'include'
                    })
                    .then(response => {
                        console.log("Form submission response:", response.status);
                        return response.text().then(text => {
                          try {
                            // Try to parse as JSON
                            const data = JSON.parse(text);
                            console.log("Response data:", data);
                            
                            if (response.ok) {
                              // Success handling
                              if (data.redirectUrl) {
                                window.location.href = data.redirectUrl;
                      } else {
                                // Show success message
                                alert('Registration successful!');
                              }
                              return data;
                            } else {
                              // Handle error with details
                              console.error("API error:", data);
                              if (data.message) {
                                alert('Error: ' + data.message);
                              } else if (data.error) {
                                alert('Error: ' + data.error);
                              }
                              throw new Error(JSON.stringify(data));
                            }
                          } catch (e) {
                            // Not JSON or other error
                            console.log("Raw response:", text);
                            if (!response.ok) {
                              throw new Error('Form submission failed');
                            }
                            return { success: true, raw: text };
                          }
                        });
                    })
                    .catch(error => {
                        console.error("Form submission error:", error);
                        // Try alternative approach for submission
                        tryAlternativeSubmission(this, formAction, formMethod, data);
                      });
                    }
                  }
                });
                
                console.log("Enhanced form:", form.action);
              }
            });
          }
          
          // Handle forms with file uploads
          async function handleFormWithFiles(form, url, method) {
            console.log("Handling form with file uploads");
            
            // Create FormData from the form
            const formData = new FormData(form);
            
            // Log what's being uploaded (but not the actual file contents)
            let totalFileSize = 0;
            for (const [key, value] of formData.entries()) {
              if (value instanceof File) {
                console.log(`File field: ${key}, filename: ${value.name}, type: ${value.type}, size: ${value.size} bytes`);
                totalFileSize += value.size;
                    } else {
                console.log(`Field: ${key}, value: ${value}`);
              }
            }
            
            // For large files, always use direct form submission
            const MAX_SIZE = 1 * 1024 * 1024; // 1MB - much stricter limit
            if (totalFileSize > MAX_SIZE) {
              console.log(`Total file size (${totalFileSize} bytes) exceeds ${MAX_SIZE} bytes, using direct form submission`);
              // Skip JSON approach completely for large files
              tryDirectFormSubmission(form, url, method);
              return;
            }
            
            try {
              // Check if we need to convert any values
              const fileFields = [];
              const jsonData = {};
              
              // First pass - identify file fields and convert other values
              for (const [key, value] of formData.entries()) {
                if (value instanceof File) {
                  fileFields.push(key);
                } else {
                  // Handle arrays (fields with [] in their name)
                  if (key.endsWith('[]')) {
                    const baseKey = key.slice(0, -2);
                    if (!jsonData[baseKey]) {
                      jsonData[baseKey] = [];
                    }
                    jsonData[baseKey].push(value);
                  } else {
                    // Convert string "true"/"false" to boolean
                    if (value === "true") {
                      jsonData[key] = true;
                    } else if (value === "false") {
                      jsonData[key] = false;
                    } else if (!isNaN(value) && value !== "" && !isNaN(parseFloat(value))) {
                      // Convert numeric strings to numbers
                      jsonData[key] = parseFloat(value);
                    } else {
                      jsonData[key] = value;
                    }
                  }
                }
              }
              
              // For each file field, read the file and convert to base64
              for (const field of fileFields) {
                const file = formData.get(field);
                if (file instanceof File) {
                  try {
                    // Check individual file size - use very aggressive compression for all images
                    if (file.type.startsWith('image/')) {
                      console.log(`Compressing image ${file.name} (${file.size} bytes)`);
                      // For images, always compress before uploading
                      const compressedFile = await compressImage(file, 0.5); // 50% quality
                      const base64Data = await readFileAsBase64(compressedFile);
                      
                      // Ensure logo files are properly named as 'logo'
                      const fieldName = field.toLowerCase().includes('logo') ? 'logo' : field;
                      
                      jsonData[fieldName] = {
                        name: file.name,
                        type: compressedFile.type,
                        size: compressedFile.size,
                        data: base64Data
                      };
                      console.log(`Compressed file ${field} from ${file.size} to ${compressedFile.size} bytes`);
                    } else {
                      // For non-images, just convert to base64
                      const base64Data = await readFileAsBase64(file);
                      
                      // Ensure logo files are properly named as 'logo'
                      const fieldName = field.toLowerCase().includes('logo') ? 'logo' : field;
                      
                      jsonData[fieldName] = {
                        name: file.name,
                        type: file.type,
                        size: file.size,
                        data: base64Data
                      };
                    }
                    console.log(`Converted file ${field} to base64`);
                  } catch (err) {
                    console.error(`Error converting file ${field} to base64:`, err);
                  }
                }
              }
              
              console.log("Submitting form with files as JSON");
              
              // Submit as JSON with file data included
              fetch(url, {
                method: method,
                headers: {
                  'Content-Type': 'application/json',
                  'X-Requested-With': 'XMLHttpRequest',
                  'Accept': 'application/json'
                },
                body: JSON.stringify(jsonData),
                credentials: 'include'
              })
              .then(response => {
                console.log("File upload response:", response.status);
                if (response.status === 413) {
                  console.error("413 Request Entity Too Large error - file too big");
                  alert("The file is too large to upload. Please try a smaller file or compress it first.");
                  // Try direct form submission as fallback
                  tryDirectFormSubmission(form, url, method);
                  return { error: "File too large" };
                }
                
                return response.text().then(text => {
                  try {
                    // Try to parse as JSON
                    const data = JSON.parse(text);
                    console.log("Response data:", data);
                    
                    if (response.ok) {
                      // Success handling
                      if (data.redirectUrl) {
                        window.location.href = data.redirectUrl;
                  } else {
                        // Show success message
                        alert('Upload successful!');
                      }
                    } else {
                      // Handle error with details
                      console.error("API error:", data);
                      if (data.message) {
                        alert('Error: ' + data.message);
                      } else if (data.error) {
                        alert('Error: ' + data.error);
                      } else {
                        alert('Upload failed');
                      }
                      
                      // Try direct form submission as fallback
                      tryDirectFormSubmission(form, url, method);
                    }
                  } catch (e) {
                    console.log("Raw response:", text);
                    if (!response.ok) {
                      // Try direct form submission as fallback
                      tryDirectFormSubmission(form, url, method);
                    }
                  }
                });
              })
              .catch(error => {
                console.error("File upload error:", error);
                // Try direct form submission as fallback
                tryDirectFormSubmission(form, url, method);
              });
            } catch (err) {
              console.error("Error in file upload handling:", err);
              // Try direct form submission as fallback
              tryDirectFormSubmission(form, url, method);
            }
          }
          
          // Compress image file
          async function compressImage(file, quality = 0.7) {
            return new Promise((resolve, reject) => {
              try {
                const img = new Image();
                img.onload = () => {
                  URL.revokeObjectURL(img.src); // Clean up
                  
                  // Calculate new dimensions - maintain aspect ratio but be more aggressive
                  let width = img.width;
                  let height = img.height;
                  const MAX_WIDTH = 800; // Reduced from 1280
                  const MAX_HEIGHT = 800; // Reduced from 1280
                  
                  if (width > height) {
                    if (width > MAX_WIDTH) {
                      height = Math.round(height * MAX_WIDTH / width);
                      width = MAX_WIDTH;
                    }
                  } else {
                    if (height > MAX_HEIGHT) {
                      width = Math.round(width * MAX_HEIGHT / height);
                      height = MAX_HEIGHT;
                    }
                  }
                  
                  // Create canvas for resizing
                  const canvas = document.createElement('canvas');
                  canvas.width = width;
                  canvas.height = height;
                  
                  // Draw and compress
                  const ctx = canvas.getContext('2d');
                  ctx.drawImage(img, 0, 0, width, height);
                  
                  // Convert to blob with compression
                  canvas.toBlob((blob) => {
                    if (!blob) {
                      reject(new Error('Canvas to Blob conversion failed'));
                      return;
                    }
                    
                    // Create new file from blob
                    const compressedFile = new File([blob], file.name, {
                      type: 'image/jpeg',
                      lastModified: Date.now()
                    });
                    
                    resolve(compressedFile);
                  }, 'image/jpeg', quality); // Lower quality (0.5 = 50%)
                };
                
                img.onerror = () => {
                  URL.revokeObjectURL(img.src);
                  reject(new Error('Error loading image for compression'));
                };
                
                // Load image from file
                img.src = URL.createObjectURL(file);
              } catch (err) {
                reject(err);
              }
            });
          }
          
          // Try direct form submission (skipping JSON)
          function tryDirectFormSubmission(form, url, method) {
            console.log("Trying direct form submission");
            
            // Create a hidden iframe to target the form submission
            const iframeName = 'upload_iframe_' + Date.now();
            const iframe = document.createElement('iframe');
            iframe.name = iframeName;
            iframe.style.display = 'none';
            document.body.appendChild(iframe);
            
            // Create a new form with compressed images
            compressFormImages(form).then(compressedFormData => {
              // Create a new form element
              const newForm = document.createElement('form');
              newForm.action = url;
              newForm.method = method;
              newForm.enctype = 'multipart/form-data';
              newForm.target = iframeName; // Target the hidden iframe
              newForm.style.display = 'none';
              
              // Add all form fields from the compressed FormData
              for (const [key, value] of compressedFormData.entries()) {
                if (value instanceof File) {
                  // For files, we need to create a file input
                  const input = document.createElement('input');
                  input.type = 'file';
                  
                  // Ensure logo files are properly named as 'logo'
                  const fieldName = key.toLowerCase().includes('logo') ? 'logo' : key;
                  input.name = fieldName;
                  
                  // Create a DataTransfer to set the file
                  const dataTransfer = new DataTransfer();
                  dataTransfer.items.add(value);
                  input.files = dataTransfer.files;
                  
                  newForm.appendChild(input);
                } else {
                  // For other fields, create hidden inputs
                  const input = document.createElement('input');
                  input.type = 'hidden';
                  input.name = key;
                  input.value = value;
                  newForm.appendChild(input);
                }
              }
              
              // Add the form to the document and submit it
              document.body.appendChild(newForm);
              
              // Listen for iframe load event to detect completion
              iframe.onload = function() {
                try {
                  const iframeContent = iframe.contentDocument || iframe.contentWindow.document;
                  const responseText = iframeContent.body.innerText || iframeContent.body.textContent;
                  
                  console.log("Form submission response received");
                  
                  try {
                    // Try to parse as JSON
                    const data = JSON.parse(responseText);
                    if (data.redirectUrl) {
                      window.location.href = data.redirectUrl;
                    } else {
                      alert('Upload successful!');
                    }
                  } catch (e) {
                    // Not JSON, check if it contains success message
                    if (responseText.includes('success') || responseText.includes('Success')) {
                      alert('Upload successful!');
                    } else if (responseText.includes('error') || responseText.includes('Error')) {
                      alert('Upload failed: ' + responseText);
                    } else {
                      alert('Upload completed');
                    }
                  }
                  
                  // Clean up
                  setTimeout(() => {
                    document.body.removeChild(iframe);
                    document.body.removeChild(newForm);
                  }, 100);
                    } catch (e) {
                  console.error("Error processing iframe response:", e);
                  alert('Upload completed, but response could not be processed');
                  
                  // Clean up
                  document.body.removeChild(iframe);
                  document.body.removeChild(newForm);
                }
              };
              
              // Submit the form
              console.log("Submitting form via iframe");
              newForm.submit();
            }).catch(err => {
              console.error("Error preparing form for submission:", err);
              
              // Fallback to traditional form submission
              submitMultipartForm(form, url, method);
            });
          }
          
          // Try uploading with multipart form data as fallback
          function tryMultipartFormUpload(form, url, method) {
            console.log("Trying multipart form data upload");
            
            // Check if we need to compress images first
            const fileInputs = form.querySelectorAll('input[type="file"]');
            let hasImages = false;
            
            for (const input of fileInputs) {
              if (input.files && input.files.length > 0) {
                for (const file of input.files) {
                  if (file.type.startsWith('image/')) {
                    hasImages = true;
                    break;
                  }
                }
              }
            }
            
            if (hasImages) {
              console.log("Images detected, compressing before upload");
              compressFormImages(form, 0.4).then(compressedForm => { // More aggressive compression (40%)
                submitMultipartForm(compressedForm, url, method);
              }).catch(err => {
                console.error("Error compressing images:", err);
                submitMultipartForm(form, url, method);
              });
            } else {
              submitMultipartForm(form, url, method);
            }
          }
          
          // Compress images in a form
          async function compressFormImages(form, quality = 0.5) {
            // Create a new FormData object
            const compressedFormData = new FormData();
            
            // Get all form fields
            for (const [key, value] of new FormData(form).entries()) {
              if (value instanceof File && value.type.startsWith('image/')) {
                try {
                  // Compress image
                  const compressedFile = await compressImage(value, quality);
                  
                  // Ensure logo files are properly named as 'logo'
                  const fieldName = key.toLowerCase().includes('logo') ? 'logo' : key;
                  compressedFormData.append(fieldName, compressedFile);
                  
                  console.log(`Compressed image ${value.name} from ${value.size} to ${compressedFile.size} bytes`);
                } catch (err) {
                  console.error(`Error compressing image ${value.name}:`, err);
                  
                  // Ensure logo files are properly named as 'logo'
                  const fieldName = key.toLowerCase().includes('logo') ? 'logo' : key;
                  compressedFormData.append(fieldName, value);
                }
              } else {
                compressedFormData.append(key, value);
              }
            }
            
            return compressedFormData;
          }
          
          // Submit form with multipart/form-data
          function submitMultipartForm(formData, url, method) {
            // If formData is a form element, convert to FormData object
            const data = formData instanceof FormData ? formData : new FormData(formData);
            
            // Submit with FormData (multipart/form-data)
            fetch(url, {
              method: method,
              headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
              },
              body: data,
              credentials: 'include'
            })
            .then(response => {
              console.log("Multipart upload response:", response.status);
              if (response.status === 413) {
                alert("The file is still too large to upload. Please try a smaller file.");
                return;
              }
              
              if (response.ok) {
                alert('Upload successful!');
              } else {
                alert('Upload failed. Please try again.');
              }
            })
            .catch(error => {
              console.error("Multipart upload error:", error);
              alert('Upload failed. Please try again.');
            });
          }
          
          // Read a file as base64
          function readFileAsBase64(file) {
            return new Promise((resolve, reject) => {
              const reader = new FileReader();
              reader.onload = () => {
                // Get base64 string (remove the data:mime/type;base64, prefix)
                const base64String = reader.result.split(',')[1];
                resolve(base64String);
              };
              reader.onerror = () => {
                reject(new Error('Error reading file'));
              };
              reader.readAsDataURL(file);
            });
          }
          
          // Alternative submission method
          function tryAlternativeSubmission(form, url, method, data) {
            console.log("Trying alternative submission method");
            
            // Create a hidden form for submission
            const hiddenForm = document.createElement('form');
            hiddenForm.method = method;
            hiddenForm.action = url;
            hiddenForm.style.display = 'none';
            
            // Add all data as hidden fields
            for (const key in data) {
              if (Array.isArray(data[key])) {
                // Handle arrays
                data[key].forEach(value => {
                  const input = document.createElement('input');
                  input.type = 'hidden';
                  input.name = key + '[]';
                  input.value = value;
                  hiddenForm.appendChild(input);
                });
              } else {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = key;
                input.value = data[key];
                hiddenForm.appendChild(input);
              }
            }
            
            // Add to document and submit
            document.body.appendChild(hiddenForm);
            console.log("Submitting alternative form");
            hiddenForm.submit();
            document.body.removeChild(hiddenForm);
          }
          
          // Fix link clicking issues
          document.addEventListener('click', function(e) {
            const closestLink = e.target.closest('a');
            if (closestLink && closestLink.href) {
              console.log('Link clicked:', closestLink.href);
              // Ensure link gets proper click handling
              if (e.defaultPrevented) {
                console.log('Default prevented, forcing navigation');
                window.location.href = closestLink.href;
              }
            }
          }, true);
          
          // Fix file input issues
          const fileInputs = document.querySelectorAll('input[type="file"]');
          fileInputs.forEach(input => {
            if (!input.hasAttribute('data-file-enhanced')) {
              input.setAttribute('data-file-enhanced', 'true');
              
              // Make file inputs more tappable
              const enhanceFileInput = (input) => {
                // Create a larger clickable area
                const wrapper = document.createElement('div');
                wrapper.style.position = 'relative';
                wrapper.style.display = 'inline-block';
                
                // Insert wrapper before input
                input.parentNode.insertBefore(wrapper, input);
                
                // Move input into wrapper
                wrapper.appendChild(input);
                
                // Create overlay to increase tap area
                const overlay = document.createElement('div');
                overlay.style.position = 'absolute';
                overlay.style.top = '-10px';
                overlay.style.left = '-10px';
                overlay.style.right = '-10px';
                overlay.style.bottom = '-10px';
                overlay.style.zIndex = '1';
                
                overlay.addEventListener('click', function(e) {
                  console.log('File input overlay clicked');
                  e.preventDefault();
                  e.stopPropagation();
                  input.click();
                });
                
                wrapper.appendChild(overlay);
                
                console.log('Enhanced file input for better tapping');
              };
              
              // Only enhance if not already in a special framework
              if (!input.closest('.dropzone') && !input.closest('[data-file-upload]')) {
                enhanceFileInput(input);
              }
            }
          });
          
          // Monitor DOM for new file inputs
          const fileInputObserver = new MutationObserver(function(mutations) {
            const newFileInputs = document.querySelectorAll('input[type="file"]:not([data-file-enhanced])');
            newFileInputs.forEach(input => {
              if (!input.hasAttribute('data-file-enhanced')) {
                input.setAttribute('data-file-enhanced', 'true');
                console.log('Found new file input, enhancing it');
                
                // Make it more tappable
                input.style.opacity = '1';
                input.style.pointerEvents = 'auto';
                input.style.cursor = 'pointer';
                
                // Ensure it's clickable
                input.addEventListener('click', function(e) {
                  console.log('File input clicked directly');
                });
              }
            });
            
            // Check for new forms
            enhanceFormSubmissions();
          });
          
          fileInputObserver.observe(document.body, { 
            childList: true, 
            subtree: true 
          });
          
          function setupVideoFullscreenSupport() {
            try {
              const videos = document.querySelectorAll('video');
              videos.forEach(video => {
                if (!video.hasAttribute('data-fullscreen-enabled')) {
                  video.setAttribute('data-fullscreen-enabled', 'true');
                  video.setAttribute('playsinline', 'true');
                  video.setAttribute('webkit-playsinline', 'true');
                  video.setAttribute('controls', 'true');
                  
                  video.addEventListener('click', function() {
                    if (this.paused) {
                      this.play();
                    }
                  });
                  
                  let lastTapTime = 0;
                  video.addEventListener('touchend', function(e) {
                    const currentTime = new Date().getTime();
                    const tapLength = currentTime - lastTapTime;
                    if (tapLength < 300 && tapLength > 0) {
                      e.preventDefault();
                      if (document.fullscreenElement) {
                        document.exitFullscreen();
                      } else {
                        if (this.requestFullscreen) {
                          this.requestFullscreen();
                        } else if (this.webkitRequestFullscreen) {
                          this.webkitRequestFullscreen();
                        } else if (this.mozRequestFullScreen) {
                          this.mozRequestFullScreen();
                        } else if (this.msRequestFullscreen) {
                          this.msRequestFullscreen();
                        }
                      }
                    }
                    lastTapTime = currentTime;
                  });
                }
              });
            } catch (err) {
              console.error("Video setup error:", err);
            }
          }
          
          // Run immediately
          setupVideoFullscreenSupport();
          enhanceFormSubmissions();
          
          const observer = new MutationObserver(function() {
            setupVideoFullscreenSupport();
            enhanceFormSubmissions();
          });
          
          observer.observe(document.body, { 
            childList: true, 
            subtree: true 
          });
        } catch (e) {
          console.error("Script error:", e);
        }
      })();
      ''',
    );
  }
}
