import { Platform } from '@ionic/angular';
import { Component } from '@angular/core';


@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  nativeScreens = {
    ios: {
      viewControllerName: 'MyViewController'
    },
    android: {
      packageName: 'org.example',
      className: 'MyActivity'
    }
  };

  constructor(protected platform: Platform) {}

  openNative() {
    this.platform.ready().then(_ => {
      (cordova.plugins as any).NativeView.show(this.nativeScreens[this.currentPlatform])
      .then(result => {
        console.dir(result);
      });
    });
  }

  get currentPlatform(): string {
    return this.platform.platforms().find(p => p === 'android' || p === 'ios');
  }
}
