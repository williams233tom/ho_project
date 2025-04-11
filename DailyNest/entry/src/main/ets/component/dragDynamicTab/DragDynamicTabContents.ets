import { relationalStore, uniformTypeDescriptor, unifiedDataChannel } from '@kit.ArkData';

import * as DataBaseController from '../../module/DataBaseController'
// 数据结构
@Observed
class projectsData {
  id: number;
  title: string;
  description: string;
  constructor(id:number, title: string, description: string) {
    this.id = id
    this.title = title;
    this.description = description;
  }
}

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
export function DragDynamicTabContentsBuilder(name: string, param: Object){
  DragDynamicTabContents()
}

async function createProjectsTypeData(fatherType: string, data: MyDataSource): Promise<void>
{
  return new Promise((resolve, reject) => {
    // 获取类型下计划项
    DataBaseController.getDataBase(getContext(), "MyDB.db")
      .then(
        (store) => {
          if (store != undefined){
            let predicates = new relationalStore.RdbPredicates('PROJECTS');
            predicates.equalTo("FATHERTYPE",fatherType)

            DataBaseController.queryInTable(store, predicates).then(
              (resultSet) => {
                if(resultSet != undefined)
                {
                  data.clearData()
                  // 依次读取数据
                  while (resultSet.goToNextRow()) {
                    let id = resultSet.getLong(resultSet.getColumnIndex('ID'));
                    let title = resultSet.getString(resultSet.getColumnIndex('TITLE'));
                    let description = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));
                    let projectData: projectsData = new projectsData(id,title,description)

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
  })
}

@Component
export struct DragDynamicTabContents {
  @Prop fatherType: string;
  @State private data: MyDataSource = new MyDataSource()

  @Consume @Watch('onUpdate') needTabsDataUpdate: boolean

  onUpdate(): void {
    createProjectsTypeData(this.fatherType, this.data).then(() => {
      console.info(`MS: 更新 计划 总量为 ${this.data.totalCount()}`)
    })
  }

  aboutToAppear(): void {
    createProjectsTypeData(this.fatherType, this.data).then(() => {
      console.info(`MS: 计划 总量为 ${this.data.totalCount()}`)
    })
  }

  @Builder
  pixelMapBuilder(item: projectsData) {
    ChildComponent({ data: item })
  }

  build() {
    Column() {
      List({ space: 3 }) {
        LazyForEach(
          this.data,
          (item: projectsData, index: number) => {
            ListItem() {
              ChildComponent({ data: item })
            }
          },
          (item: projectsData, index: number) => index.toString()
        )
      }
      .cachedCount(5)
      .listDirection(Axis.Vertical)
      .height('100%')
    }
  }
}

@Component
struct ChildComponent
{
  @ObjectLink data: projectsData
  build() {
    Row()
    {
      Column()
      {
        Text(`${this.data.title}`)
          .maxLines(1)
          .fontSize(30)
          .fontColor($r('app.color.orange'))
        Text(`${this.data.description}`)
          .maxLines(1)
          .fontSize(15)
      }
      .width("90%")
      .align(Alignment.TopStart)

      Image($r('app.media.drag'))
        .width(20)
        .aspectRatio(1)
        .opacity(60)
        .draggable(false)
    }
    .width("96%")
    .padding(5)
    .margin(5)
    .backgroundColor($r('app.color.white'))
    .align(Alignment.TopStart)
    .draggable(true)
    .onDragStart((event: DragEvent) => {
      let data: unifiedDataChannel.PlainText = new unifiedDataChannel.PlainText();
      data.textContent = `${this.data.id}`
      event.setData(new unifiedDataChannel.UnifiedData(data));
    })
    .borderRadius(10)
    .transition(TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))// 对每个方格的转场添加delay，实现组件的渐次出现消失效果
      .animation({ duration: 300, curve: Curve.Friction, delay: 30}))
  }
}