import i18n from '@ohos.i18n';
import { unifiedDataChannel, uniformTypeDescriptor, relationalStore } from '@kit.ArkData';

import {DayComponent} from './DayComponent'
import * as DataBaseController from '../../module/DataBaseController'

// 段信息
@Observed
class segmentData {
  @Track title: string;
  @Track describe: string;
  @Track color: string;
  @Track projectId: number;
  @Track completeCount: number;
  @Track myId: number;
  @Track isHead: boolean;
  @Track isOccupied: boolean;
  @Track year: number;
  @Track month: number;
  @Track day: number;

  constructor(title: string = "", describe: string = "", isHead: boolean = false,
    color: string = "", isOccupied: boolean = false, projectId: number = -1,
    completeCount: number = 0, myId: number = -1, year: number = 1145,
    month: number = 1, day: number = 4) {
    this.title = title;
    this.describe = describe;
    this.isHead = isHead;
    this.color = color;
    this.isOccupied = isOccupied;
    this.projectId = projectId;
    this.completeCount = completeCount;
    this.myId = myId;
    this.year = year;
    this.month = month;
    this.day = day;
  }
}

// 日期信息
@Observed
class dateData {
  year: number
  month: number
  day: number;
  week: number;
  constructor(year: number = 1145, month: number = 1, day: number = 4, week: number = 1) {
    this.year = year;
    this.month = month;
    this.day = day;
    this.week = week;
  }
}

// 基础数据源，提供数据监控与读取
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: dateData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): dateData {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations);
    })
  }
}

// 数据源，提供数据增删
@Observed
class DateDataSource extends BasicDataSource {
  @Track dataArray: dateData[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): dateData {
    return this.dataArray[index];
  }

  public pushData(data: dateData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clearAll(): void {
    while (this.dataArray.length > 0)
    {
      this.dataArray.pop()
      this.notifyDataDelete(this.dataArray.length - 1)
    }
  }
}

// 获取本月日期数据
async function creatMonthData(data: DateDataSource, delta: number = 0): Promise<void>
{
  return new Promise((resolve, reject) => {
    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans");
    let year = calendar.get("year");
    let month = calendar.get("month");
    month = (month + delta)%12
    let days = new Date(year, month, 0).getDate()
    calendar.set(year, month, 1);

    data.clearAll()

    for(let i= 1; i<=days; i++)
    {
      data.pushData(new dateData(year, month+1 ,calendar.get("date"),calendar.get("day_of_week")))
      calendar.add("date",1);
    }

    resolve()
  })
}

// 删除计划
async function deleteDB(id: number, year: number, month: number, day: number):Promise<void>
{
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")

          let predicates = new relationalStore.RdbPredicates('CALENDAR');
          predicates.equalTo("BEGIN", id)
          predicates.equalTo("YEAR", year)
          predicates.equalTo("MONTH", month)
          predicates.equalTo("DAY", day)

          DataBaseController.deleteInTable(store, predicates).then(() => {
            resolve()
          })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  })
}

// 查询日期
async function queryDBById(id: number): Promise<string>
{
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        async (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('PROJECTS');
            predicates.equalTo("ID",id)

            let time:string
            await DataBaseController.queryInTable(store, predicates)
              .then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  // 依次读取数据
                  while (resultSet.goToNextRow()) {
                    time = resultSet.getString(resultSet.getColumnIndex('CREATEDATE'));
                  }
                  console.info("MS: 获取数据")
                  resultSet.close()
                }else {
                  console.info("MS: 不存在此数据")
                }
              })
              .then(() => {
              resolve(time)
            })
          } else {
            console.error("MS: Ability获取数据库失败")
          }
        })
  })
}

const weekChar: string[] = ["Mon","Tue","Wen","Thu","Fri","Sat","Sun"];
const blankPercent: number = 30
const datePercent: number = 10
const deltaPercent: number = datePercent-1

@Builder
export function CalenderBuilder(name: string, param: Object){
  Calender()
}

// 主组件
@Component
export struct Calender{
  @State private data: DateDataSource = new DateDataSource();

  @Provide @Watch('showSideBar')isOpenSideBar: boolean = false
  @Provide showSegment: segmentData = new segmentData()

  @Provide nowMonthDelta: number = 0
  @Provide todayDate: number = 0

  @Consume @Watch('updateCalendar') needCalendarUpdate: boolean
  @Consume @Watch('getBackMonth') needGetBack: boolean

  @State createTime: string = " "
  scroller: Scroller = new Scroller();

  showSideBar(): void {
    if(this.isOpenSideBar == true)
    {
      queryDBById(this.showSegment.projectId).then((result) => {
        this.createTime = result
      })
    }
  }
  updateCalendar(): void {
    this.changeMonth()
  }

  getBackMonth(): void {
    this.nowMonthDelta = 0
    creatMonthData(this.data, this.nowMonthDelta)

    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans")
    let date = calendar.get("date") - 2
    if(date< 0)date = 0

    this.scroller.scrollToIndex(date)
  }

  changeMonth(): void {

    console.info('MS: 切换' + `${this.nowMonthDelta}`)
    if(this.nowMonthDelta == 0)
    {
      let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans")
      let date = calendar.get("date") - 2
      if(date< 0)date = 0

      this.scroller.scrollToIndex(date)
    }else
    {
      this.scroller.scrollToIndex(0)
    }
    creatMonthData(this.data, this.nowMonthDelta)
  }

  async aboutToAppear() {
    await creatMonthData(this.data)

    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans")
    let date = calendar.get("date")
    this.todayDate = date
  }

  onDidBuild(): void {
    this.changeMonth()
  }

  build() {
    SideBarContainer(SideBarContainerType.Overlay) {
      // 侧边容器
      Column() {
        // 文本
        Column()
        {
          Row() {
            Column(){
              Text("标题")
                .fontSize(15)
            }
            .padding(6)
            .margin({right: 10})
            .borderRadius(10)
            .backgroundColor($r('app.color.white'))
            Text(`${this.showSegment.title}`)
          }
          .margin(10)
          .width("90%")
          Row() {
            Column(){
              Text("描述")
                .fontSize(15)
            }
            .margin({right: 10})
            .padding(6)
            .borderRadius(10)
            .backgroundColor($r('app.color.white'))
            Text(`${this.showSegment.describe}`)
              .width(100)
              .maxLines(5)
          }
          .margin(10)
          .width("90%")
          Row() {
            Column(){
              Text("完成次数")
                .fontSize(15)
            }
            .margin({right: 10})
            .padding(6)
            .borderRadius(10)
            .backgroundColor($r('app.color.white'))
            Text(`${this.showSegment.completeCount}`)
          }
          .margin(10)
          .width("90%")
          Row() {
            Column(){
              Text("创建日期")
                .fontSize(15)
            }
            .margin({right: 10})
            .padding(6)
            .borderRadius(10)
            .backgroundColor($r('app.color.white'))
            Text(this.createTime)
              .width(100)
              .maxLines(3)
          }
          .margin(10)
          .width("90%")
        }
        .align(Alignment.Start)
        // 按钮
        Row(){
          // 删除
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Row() {
              Image($r('app.media.delete'))
                .width(16)
                .aspectRatio(1)
              Text('删除')
                .fontSize(15)
                .fontColor(0xffffff)
                .margin(5)
            }
            .alignItems(VerticalAlign.Center)
          }
          .backgroundColor($r('app.color.red'))
          .width(80)
          .height(40)
          .margin({right: 18})
          .onClick(async () => {
            await deleteDB(this.showSegment.myId, this.showSegment.year, this.showSegment.month,
            this.showSegment.day)

            this.changeMonth()
            // 动画-关闭侧边栏
            animateTo({
              duration: 200,
              curve: Curve.Linear
            }, () => {
              this.isOpenSideBar = false
            })
          })
          // 关闭
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Row() {
              Text('关闭')
                .fontSize(15)
                .fontColor(0xffffff)
                .margin(5)
            }
            .alignItems(VerticalAlign.Center)
          }
          .width(60)
          .height(40)
          .backgroundColor($r('app.color.deepblue'))
          .onClick(() => {
            // 动画-关闭侧边栏
            animateTo({
              duration: 200,
              curve: Curve.Linear
            }, () => {
              this.isOpenSideBar = false
            })
          })
        }
        .margin({top: 20})
        // 图标
        Image($r('app.media.flag'))
          .width("100%")
          .rotate({ angle:270 })
          .opacity(0.2)
          .margin({left: -30})
      }
      .backgroundColor($r('app.color.lightPurple'))
      .borderRadius({ topLeft: 20, bottomLeft: 20 })
      .align(Alignment.Start)

      Row(){
        // 时间轴
        TimeComponent({changeMonth: () => this.changeMonth()})
        // 每日单项
        List({ space: 3, scroller: this.scroller }) {
          LazyForEach(
            this.data,
            (item: dateData, index: number) => {
              ListItem() {
                DayComponent({datesData: item, changeMonth: () => this.changeMonth()} )
              }
            },
            (item: dateData, index: number) => index.toString()
          )
        }
        .cachedCount(5)
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }
    }
    .showSideBar(this.isOpenSideBar)
    .sideBarPosition(SideBarPosition.End)
    .showControlButton(false)
    .sideBarWidth(200)
  }
}

// 左侧时间轴
@Component
struct TimeComponent
{
  @Consume @Watch('getMonth')nowMonthDelta: number
  @Consume @Watch('getMonth') needGetBack: boolean

  changeMonth?: () => void

  @State nowMonth: number = -1

  getMonth(): void {
    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans");
    let month = calendar.get("month");

    let showMonth = month + this.nowMonthDelta
    while(showMonth < 0)
    {
      showMonth += 12
    }
    this.nowMonth = (showMonth) % 12
  }

  aboutToAppear(): void {
    let calendar: i18n.Calendar = i18n.getCalendar("zh-Hans");
    let month = calendar.get("month");
    this.nowMonth = month
  }

  build() {
    Column()
    {
      Column()
      {
        Row(){
          Image($r('app.media.left'))
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.nowMonthDelta -= 1
              if(this.changeMonth != undefined)
                this.changeMonth()
              this.getMonth()
            })
          Image($r('app.media.right'))
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.nowMonthDelta += 1
              if(this.changeMonth != undefined)
                this.changeMonth()
              this.getMonth()
            })
        }
      }
      .height(deltaPercent+'%')
      .backgroundColor($r('app.color.totalWhite'))
      //6-11
      Column(){
        Text("6:00")
      }
      .height(blankPercent+'%')
      .width('100%')
      .backgroundColor($r('app.color.totalWhite'))
      //12-17
      Column(){
        Text("12:00")
      }
      .height(blankPercent+'%')
      .width('100%')
      .backgroundColor($r('app.color.totalWhite'))
      //18-21
      Column(){
        Text("18:00")
      }
      .height('15%')
      .width('100%')
      .backgroundColor($r('app.color.totalWhite'))
      Column(){
        Row()
        {
          Text(`${this.nowMonth +1}`)
            .fontSize(40)
            .opacity(0.6)
            .fontColor($r('app.color.darkBlue'))
          Text("月")
            .fontSize(40)
            .opacity(0.6)
            .fontColor($r('app.color.darkBlue'))
        }
      }
      .height('15%')
      .width('100%')
      .backgroundColor($r('app.color.totalWhite'))
    }
    .height('100%')
    .width(80)
    .backgroundColor($r('app.color.totalWhite'))
  }
}

