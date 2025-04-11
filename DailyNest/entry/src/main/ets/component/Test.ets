import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';

@Builder
export function TestBuilder(name: string, param: Object){
  Test()
}

@Component
export struct Test{
  @State focusIndex: number = 0;
  private controller: TabsController = new TabsController();
  tabArray = [0, 1];

  // 自定义页签
  @Builder
  Tab(tabName: string, tabItem: number, tabIndex: number) {
    Column({ space: 20 }) {
      Text(tabName).fontSize(18)
      Image($r('app.media.app_icon')).width(20).height(20)
    }
    .width(100)
    .height(60)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
    .backgroundColor(tabIndex === this.focusIndex ? '#ffffffff' : '#ffb7b7b7')
  }

  build() {
    NavDestination(){
      Column() {
        Column() {
          // 页签
          Row({ space: 6 }) {
            Scroll() {
              Row() {
                ForEach(this.tabArray, (item: number, index: number) => {
                  this.Tab('页' + item, item, index);
                })
              }
              .justifyContent(FlexAlign.Start)
            }
            // 设置左对齐
            .align(Alignment.Start)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('80%')
            .backgroundColor('#ffb7b7b7')
          }
          .width('100%')
          .backgroundColor('#ffb7b7b7')

          // tabs
          Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
            ForEach(this.tabArray, (item: number, index: number) => {
              TabContent() {
                Text('我是页面 ' + item + ' 的内容')
                  .height(300)
                  .width('100%')
                  .fontSize(30)
              }
              .backgroundColor(Color.Pink)
            })
          }
          .barHeight(0)
          .animationDuration(100)
          .onChange((index: number) => {
            console.log('foo change');
            this.focusIndex = index;
          })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .height('100%')
    }

  }
}
