import {MainPage} from './MainPage'

@Component
export struct SplashScreen {
  @State private showSplash: boolean = true;

  pageInfo: NavPathStack = new NavPathStack()

  build() {
      Column() {
        if (this.showSplash) {
          // 启动页内容
          Image($r('app.media.loading'))
            .width(200)
            .height(200)
          Row()
          {
            Text('欢迎来到')
              .fontSize(24)
            Text('日程小筑')
              .fontSize(24)
              .fontColor($r('app.color.lightblue'))
          }
          .margin(20)

        } else {
          // 跳转到主功能页面
          MainPage()
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .onAppear(() => {
        // 3 秒后隐藏启动页
        setTimeout(() => {
          this.showSplash = false;
        }, 1000); // 3000 毫秒 = 3 秒
      })
  }

}