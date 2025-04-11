import i18n from '@ohos.i18n';
import { unifiedDataChannel, uniformTypeDescriptor, relationalStore } from '@kit.ArkData';

import * as DataBaseController from '../../module/DataBaseController'
import {SegmentComponent} from  './SegmentComponent'


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

// 基础数据源，提供数据监控与读取
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: segmentData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): segmentData {
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

@Observed
class segmentDataSource extends BasicDataSource {
  @Track dataArray: segmentData[] = []

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): segmentData {
    return this.dataArray[index];
  }

  public pushData(data: segmentData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clearAll(): void{
    while (this.dataArray.length > 0)
    {
      this.dataArray.pop()
      this.notifyDataDelete(this.dataArray.length - 1)
    }
  }

  public setDataArray(newArray: segmentData[]): void {
    this.dataArray = newArray;
    this.notifyDataReload(); // 触发数据重新加载通知
  }
}

// 每日计划信息
@Observed
class dayProjectData
{
  begin: number
  lasting: number
  id: number
  constructor(begin: number, lasting: number, id: number) {
    this.begin = begin
    this.lasting = lasting
    this.id = id
  }
}

// 基础数据源，提供数据监控与读取
class BasicDataSourceDay implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: dayProjectData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): dayProjectData {
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

@Observed
class dayProjectDataSource extends BasicDataSourceDay
{
  @Track dataArray: dayProjectData[] = []

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): dayProjectData {
    return this.dataArray[index];
  }

  public pushData(data: dayProjectData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  public clearData(): void{
    while (this.dataArray.length > 0)
    {
      this.dataArray.pop()
      this.notifyDataDelete(this.dataArray.length - 1)
    }
  }
}

// 日期信息
@Observed
class dateData {
  year: number
  month: number
  day: number;
  week: number;
  constructor(year: number, month: number, day: number, week: number) {
    this.year = year;
    this.month = month;
    this.day = day;
    this.week = week;
  }
}

// 本日所有Segment初始化
async function iniSegData(segData: segmentDataSource): Promise<void>
{
  return new Promise((resolve, reject) => {
    segData.clearAll()
    for (let i = 0; i < 9; i++) {
      segData.pushData(new segmentData("", "", false, "", false, -1, 0, i))
    }
    resolve()
  })
}
// 根据日计划加载Segment
async function createSegmentData(segData: segmentDataSource, projectData: dayProjectDataSource, dateData: dateData): Promise<void>
{
  return new Promise(async (resolve, reject) => {

    // 初始化
    await iniSegData(segData);

    // 整个替换
    const newDataArray = [...segData.dataArray];
    segData.clearAll()

    console.info("MS: 进入替换")
    // 依次插入数据（foreach会并行执行）
    for (const element of projectData.dataArray) {
      let index = element.begin;
      let lasting = element.lasting;

      newDataArray[index].isHead = true;
      newDataArray[index].year = dateData.year;
      newDataArray[index].month = dateData.month;
      newDataArray[index].day = dateData.day;

      while (lasting > 0) {
        // 插入计划数据
        await queryDBById(element.id, newDataArray[index]);
        // newDataArray[index].isOccupied = true;
        lasting -= 1;
        index += 1;
      }


    }

    // segData.dataArray = newDataArray;
    segData.setDataArray(newDataArray); // 替换直接赋值
    console.info("MS: createSegmentData 全部完成");
    resolve()
  })
}
// 查询日计划
async function queryDBByDate(year: number, month: number, day: number, data: dayProjectDataSource): Promise<void>
{
  return new Promise((resolve, reject) => {
    console.info("MS: calendar响应 queryDBByDate")
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('CALENDAR');
            predicates.equalTo("YEAR",year)
            predicates.equalTo("MONTH",month)
            predicates.equalTo("DAY",day)

            DataBaseController.queryInTable(store, predicates).then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  data.clearData()
                  // 依次读取数据
                  while (resultSet.goToNextRow()) {
                    let begin = resultSet.getLong(resultSet.getColumnIndex('BEGIN'));
                    let lasting = resultSet.getLong(resultSet.getColumnIndex('LASTING'));
                    let projectId = resultSet.getLong(resultSet.getColumnIndex('PROJECTID'));

                    let recordYear = resultSet.getLong(resultSet.getColumnIndex('YEAR'));
                    let recordMonth = resultSet.getLong(resultSet.getColumnIndex('MONTH'));
                    let recordDay = resultSet.getLong(resultSet.getColumnIndex('DAY'));

                    if(day == 1) console.info("MS: 查询本日数据如下：" + `${recordYear} ${recordMonth} ${recordDay}`)

                    let dayProjectDatas: dayProjectData = new dayProjectData(begin, lasting, projectId)
                    data.pushData(dayProjectDatas)
                  }
                  resultSet.close()
                }else {
                  console.log("MS: 不存在此数据")
                }
              }).then(() => {
              console.info("MS: queryDBByDate, projectData的数量为" + `${data.totalCount()}`)
              resolve()
              // console.info("MS: 进入替换 时序")
            })
          } else {
            console.error("MS: Ability获取数据库失败")
          }
        })
  })

}
// 根据计划id查询具体计划
async function queryDBById(id: number, data: segmentData): Promise<void>
{
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        async (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('PROJECTS');
            predicates.equalTo("ID",id)

            await DataBaseController.queryInTable(store, predicates).then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  // 依次读取数据
                  while (resultSet.goToNextRow()) {
                    data.projectId = resultSet.getLong(resultSet.getColumnIndex('ID'));
                    data.title = resultSet.getString(resultSet.getColumnIndex('TITLE'));
                    data.describe = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));
                    data.color = ('app.color.orange')
                    data.completeCount = resultSet.getLong(resultSet.getColumnIndex('TIMES'));
                    data.isOccupied = true
                  }
                  console.info("MS: 获取数据")
                  resultSet.close()
                }else {
                  console.info("MS: 不存在此数据")
                }
              }).then(() => {
              resolve()
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

// 每日单项
@Component
export struct DayComponent {
  @ObjectLink datesData: dateData

  @State dayProjectData: dayProjectDataSource = new dayProjectDataSource()
  @State segmentData: segmentDataSource = new segmentDataSource()

  @Consume todayDate: number

  @Consume nowMonthDelta: number

  @State backColor: string = 'app.color.totalWhite'

  changeMonth?: () => void

  // 拖拽处理
  async onDropProcess(projectId: number, segmentId: number):Promise<void> {

    // 数据集
    let valueBucket: relationalStore.ValuesBucket = {
      YEAR: this.datesData.year,
      MONTH: this.datesData.month,
      DAY: this.datesData.day,
      BEGIN: segmentId,
      LASTING: 1,
      PROJECTID: projectId,
    }

    await DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      async (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")
          // 插入
          await DataBaseController.insertInTable(store, 'CALENDAR', valueBucket)
          await queryDBByDate(this.datesData.year, this.datesData.month, this.datesData.day, this.dayProjectData)
          // 创建全新segmentData实例
          const newSegmentData = new segmentDataSource();
          await createSegmentData(newSegmentData, this.dayProjectData, this.datesData);

          this.segmentData = newSegmentData

          console.info("MS: 数据拖动完毕")
          if(this.changeMonth != undefined)
            this.changeMonth()
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  }

  aboutToAppear(): void {
    queryDBByDate(this.datesData.year, this.datesData.month, this.datesData.day, this.dayProjectData).then(
      async () => {
        await createSegmentData(this.segmentData, this.dayProjectData, this.datesData)
      })
    if(this.todayDate == this.datesData.day)
    {
      this.backColor = 'app.color.lightPurple'
    }
  }

  build() {
    Column(){
      // 日期
      Column(){
        Column() {
          Text(weekChar[Number(this.datesData.week)-1])
            .fontSize(15)
            .fontColor($r('app.color.orange'))
          Text(`${this.datesData.day}`)
            .fontSize(20)
        }
      }
      .border({ style: { bottom: BorderStyle.Solid }, width: { bottom: 2 }, color: { bottom: $r('app.color.lightblue') } })
      .height(datePercent+'%')
      .width('100%')
      // 空白占位
      //6-11
      Column(){
        SegmentComponent({ data: this.segmentData.dataArray[0], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[1], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[2], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId)})
          .height("30%")
          .width("90%")
          .margin(2)
      }
      .border({ style: { bottom: BorderStyle.Solid }, width: { bottom: 2 }, color: { bottom: $r('app.color.lightblue') } })
      .height(blankPercent+'%')
      .width('100%')
      //12-17
      Column(){
        SegmentComponent({ data: this.segmentData.dataArray[3], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[4], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[5], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId)})
          .height("30%")
          .width("90%")
          .margin(2)
      }
      .border({ style: { bottom: BorderStyle.Solid }, width: { bottom: 2 }, color: { bottom: $r('app.color.lightblue') } })
      .height(blankPercent+'%')
      .width('100%')
      //17-21
      Column(){
        SegmentComponent({ data: this.segmentData.dataArray[6], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[7], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId) })
          .height("30%")
          .width("90%")
          .margin(2)
        SegmentComponent({ data: this.segmentData.dataArray[8], onDropSuccess: (projectId: number, segmentId: number) => this.onDropProcess(projectId, segmentId)})
          .height("30%")
          .width("90%")
          .margin(2)
      }
      .height(blankPercent+'%')
      .width('100%')
      .border({ style: { bottom: BorderStyle.Solid }, width: { bottom: 2 }, color: { bottom: $r('app.color.deepblue') } })
    }
    .height('100%')
    .width(100)
    .backgroundColor($r(this.backColor))
  }
}
