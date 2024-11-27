Java.perform(function () {
    // Hook java.security.KeyPairGenerator
    var KeyPairGenerator = Java.use("java.security.KeyPairGenerator");

    KeyPairGenerator.getInstance.overload('java.lang.String').implementation = function (algorithm) {
        console.log("[*] KeyPairGenerator.getInstance called with algorithm: " + algorithm);
        return this.getInstance(algorithm);
    };

    KeyPairGenerator.generateKeyPair.implementation = function () {
        console.log("[*] KeyPairGenerator.generateKeyPair called");
        return this.generateKeyPair();
    };

    // Hook java.security.Signature
    var Signature = Java.use("java.security.Signature");

    Signature.getInstance.overload('java.lang.String').implementation = function (algorithm) {
        console.log("[*] Signature.getInstance called with algorithm: " + algorithm);
        return this.getInstance(algorithm);
    };

    Signature.sign.implementation = function () {
        console.log("[*] Signature.sign called");
        return this.sign();
    };

    // Hook java.security.PrivateKey
    var RSAPrivateKey = Java.use("java.security.interfaces.RSAPrivateKey");

    RSAPrivateKey.sign.implementation = function (data) {
        console.log("[*] RSAPrivateKey.sign called with data: " + data);
        return this.sign(data);
    };

    // Hook java.security.PublicKey
    var RSAPublicKey = Java.use("java.security.interfaces.RSAPublicKey");

    RSAPublicKey.verify.implementation = function (data, signature) {
        console.log("[*] RSAPublicKey.verify called with data: " + data + ", signature: " + signature);
        return this.verify(data, signature);
    };
});
