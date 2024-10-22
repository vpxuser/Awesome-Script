const fs = require('fs');

// Certificate file path
const CERT_FILE_PATH = 'ca.crt'; // Replace with your certificate file path

// Read certificate content
let certContent;
try {
    certContent = fs.readFileSync(CERT_FILE_PATH);
} catch (error) {
    console.error('[-] Unable to read certificate file:', error.message);
    Java.use('java.lang.System').exit(1);
}

// Determine certificate format and parse
let cert;
try {
    const CertFactory = Java.use('java.security.cert.CertificateFactory');
    const ByteArrayInputStream = Java.use('java.io.ByteArrayInputStream');
    const certFactory = CertFactory.getInstance("X.509");

    // Attempt to parse PEM format
    try {
        const certPem = Java.use("java.lang.String").$new(certContent.toString());
        const certBytes = certPem.getBytes();
        cert = certFactory.generateCertificate(ByteArrayInputStream.$new(certBytes));
    } catch (pemError) {
        // If PEM parsing fails, try DER format
        try {
            cert = certFactory.generateCertificate(ByteArrayInputStream.$new(certContent));
        } catch (derError) {
            throw new Error('[-] Unsupported certificate format! Please provide a valid PEM or DER certificate.');
        }
    }
} catch (error) {
    console.error('[-] Error parsing certificate:', error.message);
    Java.use('java.lang.System').exit(1);
}

// Inject the certificate
Java.perform(() => {
    const trustedClasses = [
        'com.android.org.conscrypt.TrustedCertificateIndex',
        'org.conscrypt.TrustedCertificateIndex',
        'org.apache.harmony.xnet.provider.jsse.TrustedCertificateIndex'
    ];

    trustedClasses.forEach((TrustedCertificateIndexClassname) => {
        let TrustedCertificateIndex;
        try {
            TrustedCertificateIndex = Java.use(TrustedCertificateIndexClassname);
        } catch (error) {
            console.warn(`[*] Skipping certificate injection: ${TrustedCertificateIndexClassname} not found.`);
            return;
        }

        TrustedCertificateIndex.$init.overloads.forEach((overload) => {
            overload.implementation = function () {
                this.$init(...arguments);
                this.index(cert);
            };
        });

        TrustedCertificateIndex.reset.overloads.forEach((overload) => {
            overload.implementation = function () {
                const result = this.reset(...arguments);
                this.index(cert);
                return result;
            };
        });

        console.log(`[+] Successfully injected certificate into: ${TrustedCertificateIndexClassname}`);
    });

    console.log('== System certificate trust injection complete ==');
});
