import './index.d';

// $ExpectType Promise
cordova.plugins.NativeView.show({
    package: 'my.package.test',
    className: 'MyClass'
});

// $ExpectError
cordova.plugins.NativeView.show({
    package: 'aaa'
});
