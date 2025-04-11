import { relationalStore } from '@kit.ArkData';

import * as DataBaseController from '../../module/DataBaseController'
import { DragDynamicTabContents } from './DragDynamicTabContents'

// 获取页数据
async function createFatherTypeData(data: Array<string>): Promise<void>
{
  return new Promise((resolve, reject) => {
    // 获取父类型
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('MYFATHERTYPE');

            DataBaseController.queryInTable(store, predicates).then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  while (resultSet.goToNextRow()) {
                    const fathertype = resultSet.getString(resultSet.getColumnIndex('FATHERTYPE'));
                    data.push(fathertype)
                    console.info(`MS: 数据如下 fathertype=${fathertype}`);
                  }
                  resultSet.close()
                }else {
                  console.log("MS: 不存在此数据")
                }
              }).then(() => {
              console.info("MS: fatherTypeQueue的元素数" + `${data.length}`)
              resolve()
            })
          } else {
            console.error("Ability获取数据库失败")
          }
        })
  })
}

@Builder
export function DragDynamicTabsBuilder(name: string, param: Object){
  DragDynamicTabs()
}

@Component
export struct DragDynamicTabs{

  @State data: Array<string> = [];

  @State focusIndex: number = 0;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    createFatherTypeData(this.data).then(() => {
      console.info(`MS: 父类 总量为 ${this.data.length}`)
    })
  }

  // 自定义页签
  @Builder
  Tab(tabName: string, tabIndex: number) {
    Column({ space: 20 }) {
      Text(tabName)
        .fontSize(18)
    }
    .width(100)
    .height(40)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
    .backgroundColor(tabIndex === this.focusIndex ? $r('app.color.lightblue') : $r('app.color.white'))
    .margin(5)
  }

  build() {
    Column(){
      // 页签
      Row({ space: 6 }) {
        Scroll() {
          Row() {
            ForEach(this.data, (item: string, index: number) => {
              this.Tab(item, index);
            })
          }
          .justifyContent(FlexAlign.Start)
        }
        // 设置左对齐
        .align(Alignment.Start)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('85%')
        .backgroundColor($r('app.color.backWhite'))
      }
      .width('100%')
      .backgroundColor($r('app.color.backWhite'))
      .margin({bottom: 5})
      .height("24%")
      // 页面内容
      Tabs({barPosition: BarPosition.Start, controller: this.controller})
      {
        ForEach(
          this.data, (item: string, index: number) => {
            TabContent() {
              DragDynamicTabContents({fatherType: item as string})
            }
            .tabBar(new SubTabBarStyle(item))
          },
          (item: string, index: number) => index.toString()
        )
      }
      .barHeight(0)
      .animationDuration(100)
      .onChange((index: number) => {
        this.focusIndex = index;
      })
      .height("76%")
    }
  }
}
