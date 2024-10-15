setTimeout(function() {
	Java.perform(function() {
		console.log('');
		console.log('======');
		console.log('[#] Android Bypass for various Certificate Pinning methods [#]');
		console.log('======');

		var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
		var SSLContext = Java.use('javax.net.ssl.SSLContext');

		var TrustManager = Java.registerClass({
			name: 'dev.asd.test.TrustManager',
			implements: [X509TrustManager],
			methods: {
				checkClientTrusted: function(chain, authType) {},
				checkServerTrusted: function(chain, authType) {},
				getAcceptedIssuers: function() {
					return [];
				}
			}
		});

		var TrustManagers = [TrustManager.$new()];
		var SSLContext_init = SSLContext.init.overload(
			'[Ljavax.net.ssl.KeyManager;', '[Ljavax.net.ssl.TrustManager;', 'java.security.SecureRandom');
		try {
			SSLContext_init.implementation = function(keyManager, trustManager, secureRandom) {
				console.log('[+] Bypassing Trustmanager (Android < 7) request');
				SSLContext_init.call(this, keyManager, TrustManagers, secureRandom);
			};
		} catch (err) {
			console.log('[-] TrustManager (Android < 7) pinner not found');
		}

		var bypassOkHttpV3 = function(overload, version) {
			try {
				var okhttp3_CertificatePinner = Java.use('okhttp3.CertificatePinner');
				okhttp3_CertificatePinner.check.overload(overload)
					.implementation = function(a, b) {
					console.log('[+] Bypassing OkHTTPv3 {' + version + '}: ' + a);
					return true;
				};
			} catch (err) {
				console.log('[-] OkHTTPv3 {' + version + '} pinner not found');
			}
		};

		bypassOkHttpV3('java.lang.String', '1');
		bypassOkHttpV3('java.lang.String', 'java.security.cert.Certificate', '2');
		bypassOkHttpV3('java.lang.String', '[Ljava.security.cert.Certificate;', '3');

		try {
			var okhttp3_Activity_4 = Java.use('okhttp3.CertificatePinner');
			okhttp3_Activity_4[''].implementation = function(a, b) {
				console.log('[+] Bypassing OkHTTPv3 {4}: ' + a);
			};
		} catch (err) {
			console.log('[-] OkHTTPv3 {4} pinner not found');
		}

		var bypassTrustKit = function(overload, version) {
			try {
				var trustkit = Java.use('com.datatheorem.android.trustkit.pinning.OkHostnameVerifier');
				trustkit.verify.overload(overload).implementation = function(a, b) {
					console.log('[+] Bypassing Trustkit {' + version + '}: ' + a);
					return true;
				};
			} catch (err) {
				console.log('[-] Trustkit {' + version + '} pinner not found');
			}
		};

		bypassTrustKit('java.lang.String', 'javax.net.ssl.SSLSession', '1');
		bypassTrustKit('java.lang.String', 'java.security.cert.X509Certificate', '2');

		try {
			var trustkit_PinningTrustManager = Java.use('com.datatheorem.android.trustkit.pinning.PinningTrustManager');
			trustkit_PinningTrustManager.checkServerTrusted.implementation = function() {
				console.log('[+] Bypassing Trustkit {3}');
			};
		} catch (err) {
			console.log('[-] Trustkit {3} pinner not found');
		}

		try {
			var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
			TrustManagerImpl.verifyChain.implementation = function(untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
				console.log('[+] Bypassing TrustManagerImpl (Android > 7): ' + host);
				return untrustedChain;
			};
		} catch (err) {
			console.log('[-] TrustManagerImpl (Android > 7) pinner not found');
		}

		try {
			var appcelerator_PinningTrustManager = Java.use('appcelerator.https.PinningTrustManager');
			appcelerator_PinningTrustManager.checkServerTrusted.implementation = function() {
				console.log('[+] Bypassing Appcelerator PinningTrustManager');
			};
		} catch (err) {
			console.log('[-] Appcelerator PinningTrustManager pinner not found');
		}

		try {
			var OpenSSLSocketImpl = Java.use('com.android.org.conscrypt.OpenSSLSocketImpl');
			OpenSSLSocketImpl.verifyCertificateChain.implementation = function(certRefs, JavaObject, authMethod) {
				console.log('[+] Bypassing OpenSSLSocketImpl Conscrypt');
			};
		} catch (err) {
			console.log('[-] OpenSSLSocketImpl Conscrypt pinner not found');
		}

		try {
			var OpenSSLEngineSocketImpl_Activity = Java.use('com.android.org.conscrypt.OpenSSLEngineSocketImpl');
			OpenSSLEngineSocketImpl_Activity.verifyCertificateChain.overload('[Ljava.lang.Long;', 'java.lang.String')
				.implementation = function(a, b) {
				console.log('[+] Bypassing OpenSSLEngineSocketImpl Conscrypt: ' + b);
			};
		} catch (err) {
			console.log('[-] OpenSSLEngineSocketImpl Conscrypt pinner not found');
		}

		try {
			var OpenSSLSocketImpl_Harmony = Java.use('org.apache.harmony.xnet.provider.jsse.OpenSSLSocketImpl');
			OpenSSLSocketImpl_Harmony.verifyCertificateChain.implementation = function(asn1DerEncodedCertificateChain, authMethod) {
				console.log('[+] Bypassing OpenSSLSocketImpl Apache Harmony');
			};
		} catch (err) {
			console.log('[-] OpenSSLSocketImpl Apache Harmony pinner not found');
		}

		try {
			var phonegap_Activity = Java.use('nl.xservices.plugins.sslCertificateChecker');
			phonegap_Activity.execute.overload('java.lang.String', 'org.json.JSONArray', 'org.apache.cordova.CallbackContext')
				.implementation = function(a, b, c) {
				console.log('[+] Bypassing PhoneGap sslCertificateChecker: ' + a);
				return true;
			};
		} catch (err) {
			console.log('[-] PhoneGap sslCertificateChecker pinner not found');
		}

		var bypassIBM = function(className, methodName, version, overload) {
			try {
				var IBM_Class = Java.use(className);
				IBM_Class.getInstance()[methodName].overload(overload).implementation = function(cert) {
					console.log('[+] Bypassing IBM MobileFirst ' + version + ': ' + cert);
					return;
				};
			} catch (err) {
				console.log('[-] IBM MobileFirst ' + version + ' pinner not found');
			}
		};

		bypassIBM('com.worklight.wlclient.api.WLClient', 'pinTrustedCertificatePublicKey', '{1}', 'java.lang.String');
		bypassIBM('com.worklight.wlclient.api.WLClient', 'pinTrustedCertificatePublicKey', '{2}', '[Ljava.lang.String;');

		var bypassWorkLight = function(overload, version) {
			try {
				var worklight = Java.use('com.worklight.wlclient.certificatepinning.HostNameVerifierWithCertificatePinning');
				worklight.verify.overload(overload).implementation = function(a, b) {
					console.log('[+] Bypassing IBM WorkLight HostNameVerifierWithCertificatePinning {' + version + '}: ' + a);
				};
			} catch (err) {
				console.log('[-] IBM WorkLight HostNameVerifierWithCertificatePinning {' + version + '} pinner not found');
			}
		};

		bypassWorkLight('java.lang.String', 'javax.net.ssl.SSLSocket', '1');
		bypassWorkLight('java.lang.String', 'java.security.cert.X509Certificate', '2');
	});
}, 0);
