import {Calender} from "../component/calendar/Calendar"
import {DynamicTabs} from "../component/dynamicTab/DynamicTabs"
import {DragDynamicTabs} from "../component/dragDynamicTab/DragDynamicTabs"
import {Test} from "../component/Test"
import {Details} from  './Details'
import * as DataBaseController from '../module/DataBaseController'

import i18n from '@ohos.i18n';
import { LengthMetrics, PromptAction } from '@kit.ArkUI';
@Observed
class projectsData {
  title: string;
  description: string;
  type: string;
  fatherType: string;
  times: number;
  fullTimes: number;
  createDate: string;
  id: number;
  constructor(title: string, description: string, times: number, fullTimes: number
    , type: string, fatherType: string, createDate: string, id: number) {
    this.title = title;
    this.description = description;
    this.times = times;
    this.type = type;
    this.fatherType = fatherType;
    this.createDate = createDate;
    this.fullTimes = fullTimes;
    this.id = id;
  }
}


interface paramType {
  param: string;
}

let paramA: paramType = {
  param: 'test1'
}

@Builder
export function MainPageBuilder(){
  MainPage()
}

// 主组件
@Component
export struct MainPage {

  @Provide needTabsDataUpdate: boolean = false
  @Provide needCalendarUpdate: boolean = false
  @Provide needGetBack: boolean = false

  @Provide pageInfo: NavPathStack = new NavPathStack()

  @State focusIndex: number = 0;
  private controller: TabsController = new TabsController();

  @State isUpdate: boolean = false

  @State bottomTab:Array<string> = ["日程", "计划"]

  @State year: number = 0
  @State month: number = 0
  @State day: number = 0

  // 弹窗
  private uiContext: UIContext = this.getUIContext()
  private promptAction: PromptAction = this.uiContext.getPromptAction()

  @State rotateAngle: number = 0

  // 自定义路由
  @Builder
  myRouter(name: string) {
    if( name === 'test') {
      Test()
    }
    else if (name === 'updateDetails') {
      Details({ isUpdate: true })
    }
    else{
      Details({ isUpdate: false })
    }
  }

  // 自定义页签
  @Builder
  Tab(tabName: string, tabIndex: number) {
    Column({ space: 20 }) {
      if(tabName == "日程") {
        Image($r("app.media.calendar"))
          .width(30)
          .aspectRatio(1)
        Text(tabName)
          .fontSize(18)
          .margin({top: -8})
      }
      else if(tabName == "计划"){
        Image($r("app.media.project"))
          .width(30)
          .aspectRatio(1)
        Text(tabName)
          .fontSize(18)
          .margin({top: -8})
      }
    }
    .layoutWeight(1)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.focusIndex = tabIndex;
    })
    .backgroundColor(tabIndex === this.focusIndex ? $r('app.color.lightblue') : $r('app.color.white'))
    .height("100%")
  }


  toUpdate(segData: projectsData): void {
    this.pageInfo.pushPathByName('updateDetails',segData,(type) => {
      if(type.result == "删除")
      {
        this.needCalendarUpdate = !this.needCalendarUpdate
        this.promptAction.showToast({
          message: '删除成功',
          duration: 1000,
          textColor: $r('app.color.red')
        });
      }else if (type.result == "保存")
      {
        this.promptAction.showToast({
          message: '保存成功',
          duration: 1000,
          textColor: $r('app.color.lightblue')
        });
      }else if (type.result == "新建")
      {
        this.promptAction.showToast({
          message: '创建成功',
          duration: 1000,
          textColor: $r('app.color.lightblue')
        });
      }
    })
  }

  async aboutToAppear(): Promise<void> {
    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans");
    this.year = calendar.get("year");
    this.month = calendar.get("month") + 1;
    this.day = calendar.get('date')

    await DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")
          DataBaseController.createTable(store)
            .then(() => {
              DataBaseController.iniTable(store);
            })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  }

  build() {
    Navigation(this.pageInfo)
    {
      Column(){
        // 自定义顶部栏
        Row({ space: 10 }) {
          Image($r('app.media.smallCalendar'))
            .aspectRatio(1)
            .width(35)

          Text(`${this.year}.${this.month}.${this.day}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .flexGrow(1)
            .textAlign(TextAlign.Start)

          Image($r('app.media.refresh'))
            .aspectRatio(1)
            .width(30)
            .rotate({angle: this.rotateAngle})
            .onClick(() => {
              this.needGetBack = !this.needGetBack

              this.rotateAngle = 360

              setTimeout(() => {
                this.rotateAngle = 0
              }, 1000)
            })
            .animation({
              duration: 1000,
              curve: Curve.EaseOut,
              iterations: 1,
              playMode: PlayMode.Normal
            })
        }
        .width('100%')
        .height('8%') // 设置顶部栏高度
        .padding(10)
        .backgroundColor($r('app.color.grassGreen'))

        Column()
        {
          Blank()
        }
        .height("2%")
        .backgroundColor($r('app.color.grassGreen'))

        // 主要内容
        Tabs({barPosition:BarPosition.End, controller:this.controller})
        {
          // 主页面
          TabContent(){
            Column() {
              // 日历
              Column(){
                Calender()
              }
              .height('70%')
              // 拖动计划项
              Column() {
                DragDynamicTabs()
              }
              .height("30%")
              .backgroundColor($r('app.color.grassGreen'))
            }
            .width('100%')
            .height('100%')
            .align(Alignment.TopStart)
          }

          // 计划页面
          TabContent(){
            Column() {
              // 计划列表
              Column(){
                DynamicTabs({ toUpdate:(segData: projectsData) => this.toUpdate(segData) })
                  .height("100%")
              }
              .height("100%")
              // 悬浮按钮
              Button() {
                Image($r('app.media.plus'))
                  .width(60)
                  .aspectRatio(1)
              }
              .width(60)
              .aspectRatio(1)
              .position({x: '80%', y: "85%"})
              .onClick(()=> {
                // 页面跳转
                this.pageInfo.pushPathByName('details',"null",(popInfo) => {

                })
              })
              .backgroundColor($r('app.color.totalWhite'))
            }
            .width('100%')
            .height('100%')
            .align(Alignment.TopStart)
          }

        }
        .width('100%')
        .animationDuration(300)
        .height('82%')
        .barGridAlign({})
        .backgroundColor($r('app.color.backWhite'))
        .barHeight(0)
        .onChange((index: number) => {
          this.focusIndex = index;
        })

        // 页签
        Row({ space: 6 }) {
          Scroll() {
            Row() {
              ForEach(this.bottomTab, (item: string, index: number) => {
                this.Tab(item, index);
              })
            }
            .justifyContent(FlexAlign.Center)
          }
          .align(Alignment.Center)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          .backgroundColor($r('app.color.backWhite'))
        }
        .height('8%')
        .width('100%')
        .backgroundColor($r('app.color.backWhite'))
        .margin({bottom: 5})
      }
    }
    .navDestination(this.myRouter)
  }
}