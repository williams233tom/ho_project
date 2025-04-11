import { relationalStore, uniformTypeDescriptor } from '@kit.ArkData';

import * as DataBaseController from '../../module/DataBaseController'

// 数据结构
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
@Observed
// 基础数据源，提供数据监控与读取
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: projectsData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): projectsData {
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
// 数据源，提供数据增删
class MyDataSource extends BasicDataSource {
  dataArray: projectsData[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): projectsData {
    return this.dataArray[index];
  }

  public pushData(data: projectsData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clearData(): void{
    while (this.dataArray.length >0 ){
      this.dataArray.pop()
      this.notifyDataDelete(this.dataArray.length - 1)
    }
  }

  public exchangeData(index1: number, index2: number): void {
    let temp: projectsData = this.dataArray[index1]
    this.dataArray[index1] = this.dataArray[index2]
    this.dataArray[index2] = temp
    this.notifyDataMove(index1, index2)
  }
}


@Builder
export function DynamicTabContentsBuilder(name: string, param: Object){
  DynamicTabContents()
}

// 获取本类型所有计划
async function createProjectsTypeData(fatherType: string, data: MyDataSource): Promise<void>
{
  return new Promise((resolve, reject) => {
    // 获取类型下计划项
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        async (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('PROJECTS');
            predicates.equalTo("FATHERTYPE",fatherType)

            data.clearData()
            console.info(`MS: 更新 计划 总量为 清空= ${fatherType} ${data.totalCount()}`);
            DataBaseController.queryInTable(store, predicates).then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  data.clearData()
                  // 依次读取数据
                  while (resultSet.goToNextRow()) {
                    let title = resultSet.getString(resultSet.getColumnIndex('TITLE'));
                    let description = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));
                    let type = resultSet.getString(resultSet.getColumnIndex('TYPE'))
                    let fatherType = resultSet.getString(resultSet.getColumnIndex('FATHERTYPE'))
                    let times = resultSet.getLong(resultSet.getColumnIndex('TIMES'))
                    let fullTimes = resultSet.getLong(resultSet.getColumnIndex('FULLTIMES'))
                    let createDate = resultSet.getString(resultSet.getColumnIndex('CREATEDATE'))
                    let id = resultSet.getLong((resultSet.getColumnIndex('ID')))

                    let projectData: projectsData = new projectsData(title,description,times,
                    fullTimes,type,fatherType,createDate,id)

                    data.pushData(projectData)
                    console.info(`MS: 数据如下 projectData =${projectData}`);
                  }
                  resultSet.close()

                }else {
                  console.log("MS: 不存在此数据")
                }
              }).then(() => {
              console.info("MS: projectData的数量为" + `${data.totalCount()}`)
              resolve()
            })
          } else {
            console.error("MS: Ability获取数据库失败")
          }
        })
    console.info("MS: 顺序测试1")
  })
}

// 更新计划
async function updateDB(valueBucket: relationalStore.ValuesBucket, id: number): Promise<void> {
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")

          let predicates = new relationalStore.RdbPredicates('PROJECTS');
          predicates.equalTo("ID", id)

          DataBaseController.updateInTable(store, predicates, valueBucket).then(() => {
            resolve()
          })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  })
}

// 响应式更新用
function updateNum(data: MyDataSource): number {
  return data.totalCount()
}
// 主组件
@Component
export struct DynamicTabContents {
  @Prop fatherType: string;
  @State private data: MyDataSource = new MyDataSource()

  @Consume @Watch('onUpdate') needTabsDataUpdate: boolean
  @State isLoading: boolean = false
  @State num: number = 0

  mediumToUpdate?: (segData: projectsData) => void;

  onUpdate(): void {
    createProjectsTypeData(this.fatherType, this.data).then(() => {
      this.num = updateNum(this.data)
    })
  }

  aboutToAppear(): void {
    createProjectsTypeData(this.fatherType, this.data).then(() => {
      this.isLoading = true
      this.num = updateNum(this.data)
    })
  }

  @Builder
  pixelMapBuilder(item: projectsData) {
    ChildComponent({ data: item })
  }

  // 交换listArr数组中listItem的位置
  changeListItemIndex(index1: number, index2: number) {
    console.info("MS: 尝试交互 " + `${index1} and ${index2}`)
    if(index1 != index2)
    {
      this.data.exchangeData(index1, index2)
    }else{
      console.info("MS: 交互重复")
    }
  }

  build() {
    Column() {
      if(this.isLoading == true)
      {
        if(this.num == 0)
        {
          Text("暂时没有数据哦")
            .fontSize(40)
          Text("创建计划吧")
            .fontSize(40)
            .fontColor($r('app.color.lightblue'))
        }else {
          List({ space: 3 }) {
            LazyForEach(
              this.data,
              (item: projectsData, index: number) => {
                ListItem() {
                  ChildComponent({ data: item })
                    .align(Alignment.Center)
                    .onClick(() => {
                      if(this.mediumToUpdate != undefined)
                        this.mediumToUpdate(item)
                    })
                }
              },
              (item: projectsData, index: number) => index.toString()
            )
          }
          .cachedCount(5)
          .listDirection(Axis.Vertical)
          .height('100%')
          .onItemDragStart((event: ItemDragInfo, index: number) => {
            console.info("MS: 开始拖拽")
            return this.pixelMapBuilder(this.data.dataArray[index]);
          })
          .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
            if (!isSuccess || insertIndex >= this.data.dataArray.length) {
              console.info("MS: 拖拽失败" + `${isSuccess} and ${insertIndex} and ${this.data.dataArray.length}`)
              return;
            }
            console.info("MS: 拖拽成功")
            this.changeListItemIndex(itemIndex, insertIndex);
          })
          .align(Alignment.Center)
        }

      }
    }
  }
}

@Component
struct ChildComponent
{
  @ObjectLink data: projectsData

  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  @State isUpdate: boolean = true

  @State scaleValue: number = 1
  @State backColor: string = 'app.color.white'
  @State myAnimation: AnimateParam = {
    duration: 1000,
    curve: Curve.EaseOut,
    iterations: 1,
    playMode: PlayMode.Normal
  }

  build() {
    Column()
    {
      Row()
      {
        // 文本
        Column()
        {
          Text(`${this.data.title}`)
            .maxLines(1)
            .fontSize(30)
            .fontColor($r('app.color.orange'))
            .align(Alignment.Start)
            .width("100%")
          Text(`${this.data.description}`)
            .maxLines(1)
            .fontSize(15)
            .align(Alignment.Start)
            .width("100%")
        }
        .margin({left: 25})
        .align(Alignment.Start)
        .width("60%")
        // 完成次数
        Text(`${this.data.times}`)
          .fontSize(40)
          .fontColor($r('app.color.lightblue'))
          .opacity(0.6)
          .width("20%")
          .align(Alignment.End)
        // 按钮
        Column()
        {
          Button({type:ButtonType.Circle})
            .backgroundColor($r(this.backColor))
            .width(40)
            .borderRadius(10)
            .align(Alignment.Center)
            .onClick(() => {

              this.data.times += 1

              let nowTime = new Date()

              let ValueBucket: relationalStore.ValuesBucket = {
                TITLE: this.data.title,
                DESCRIPTION: this.data.description,
                TYPE: this.data.type,
                FATHERTYPE: this.data.fatherType,
                TIMES: this.data.times,
                FULLTIMES: 100,
                CREATEDATE: nowTime.toUTCString(),
              };

              updateDB(ValueBucket, this.data.id)

              // 进入动画
              this.scaleValue = 0
              this.myAnimation = {
                duration: 300,
                curve: Curve.EaseOut,
                iterations: 1,
                playMode: PlayMode.Normal
              }
              this.backColor = 'app.color.lightblue'

              // 退出动画
              setTimeout(() => {
                this.backColor = 'app.color.white'
                this.scaleValue = 1
                this.myAnimation = {
                  duration: 0,
                  curve: Curve.EaseOut,
                  iterations: 1,
                  playMode: PlayMode.Normal
                }
              }, 300)
            })
            .scale({x: this.scaleValue, y: this.scaleValue})
            .animation(this.myAnimation)
        }
        .backgroundColor($r('app.color.white'))
        .borderWidth(1)
        .width(40)
        .aspectRatio(1)
        .borderRadius(20)
      }
      .height("100%")
      .width("100%")
      .align(Alignment.Center)
    }
    .height("15%")
    .width("96%")
    .padding(5)
    .margin(5)
    .backgroundColor($r('app.color.white'))
    .borderRadius(6)
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))// 对每个方格的转场添加delay，实现组件的渐次出现消失效果
      .animation({ duration: 300, curve: Curve.Friction, delay: 30}))
  }
}