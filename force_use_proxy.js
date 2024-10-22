// Hardcoded proxy configuration
const PROXY_HOST = '127.0.0.1'; // Proxy server address
const PROXY_PORT = 8080;        // Proxy server port

Java.perform(() => {
    // Set default JVM system properties for proxy settings
    const System = Java.use('java.lang.System');
    System.setProperty('http.proxyHost', PROXY_HOST);
    System.setProperty('http.proxyPort', PROXY_PORT.toString());
    System.setProperty('https.proxyHost', PROXY_HOST);
    System.setProperty('https.proxyPort', PROXY_PORT.toString());

    // Clear non-proxy hosts
    System.clearProperty('http.nonProxyHosts');
    System.clearProperty('https.nonProxyHosts');

    // Prevent reset of proxy properties by Android internals
    const controlledProperties = [
        'http.proxyHost',
        'http.proxyPort',
        'https.proxyHost',
        'https.proxyPort',
        'http.nonProxyHosts',
        'https.nonProxyHosts'
    ];

    System.clearProperty.implementation = function (property) {
        if (controlledProperties.includes(property)) {
            console.log(`[*] Ignored attempt to clear ${property}`);
            return this.getProperty(property);
        }
        return this.clearProperty(...arguments);
    };

    System.setProperty.implementation = function (property) {
        if (controlledProperties.includes(property)) {
            console.log(`[*] Ignored attempt to override ${property}`);
            return this.getProperty(property);
        }
        return this.setProperty(...arguments);
    };

    // Configure app's proxy directly using ConnectivityManager
    const ConnectivityManager = Java.use('android.net.ConnectivityManager');
    const ProxyInfo = Java.use('android.net.ProxyInfo');
    ConnectivityManager.getDefaultProxy.implementation = () => ProxyInfo.$new(PROXY_HOST, PROXY_PORT, '');

    console.log(`== [*] Proxy system configuration set to ${PROXY_HOST}:${PROXY_PORT} ==`);

    // Override ProxySelector to ensure all traffic goes through our proxy
    const Collections = Java.use('java.util.Collections');
    const ProxyType = Java.use('java.net.Proxy$Type');
    const InetSocketAddress = Java.use('java.net.InetSocketAddress');
    const ProxyCls = Java.use('java.net.Proxy');

    const targetProxy = ProxyCls.$new(
        ProxyType.HTTP.value,
        InetSocketAddress.$new(PROXY_HOST, PROXY_PORT)
    );

    const getTargetProxyList = () => Collections.singletonList(targetProxy);
    const ProxySelector = Java.use('java.net.ProxySelector');

    // Scan for ProxySelector implementations and override them
    const proxySelectorClasses = Java.enumerateMethods('*!select(java.net.URI): java.util.List/s')
        .flatMap((matchingLoader) => matchingLoader.classes
            .map((classData) => Java.use(classData.name))
            .filter((Cls) => ProxySelector.class.isAssignableFrom(Cls.class))
        );

    proxySelectorClasses.forEach(ProxySelectorCls => {
        ProxySelectorCls.select.implementation = () => getTargetProxyList();
        console.log(`[*] Overrode ProxySelector in ${ProxySelectorCls}`);
    });

    console.log(`== Proxy configuration successfully set to ${PROXY_HOST}:${PROXY_PORT} ==`);
});
