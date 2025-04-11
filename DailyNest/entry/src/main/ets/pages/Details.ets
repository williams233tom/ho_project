
import { relationalStore } from '@kit.ArkData';
import { CompleteCounter } from '../component/CompleteCounter'
import { LengthMetrics, PromptAction } from '@kit.ArkUI';

import * as DataBaseController from '../module/DataBaseController'

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

// 插入project数据
async function insertDB(valueBucket: relationalStore.ValuesBucket): Promise<void> {
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")
          DataBaseController.insertInTable(store, 'PROJECTS', valueBucket).then(() => {
            resolve()
          })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  })
}

// 更新project数据
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

// 删除project数据
async function deleteDB(id: number):Promise<void>
{
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")

          let predicates = new relationalStore.RdbPredicates('PROJECTS');
          predicates.equalTo("ID", id)

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

// 读取数据
function queryDBForProject(): void{
  DataBaseController.getDataBase(getContext(), "MyDB.db").then(
    (store) => {
      if (store != undefined){
        let predicates = new relationalStore.RdbPredicates('PROJECTS');

        DataBaseController.queryInTable(store, predicates).then(
          (resultSet) => {
            if(resultSet != undefined)
            {
              while (resultSet.goToNextRow()) {
                const id = resultSet.getLong(resultSet.getColumnIndex('ID'));
                const title = resultSet.getString(resultSet.getColumnIndex('TITLE'));
                const description = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));
                const type = resultSet.getString(resultSet.getColumnIndex('TYPE'));
                const fathertype = resultSet.getString(resultSet.getColumnIndex('FATHERTYPE'));
                console.info(`MS: 数据如下 id=${id}, title=${title}, description=${description}, type=${type}, fathertype=${fathertype}`);
              }
              resultSet.close()
            }else {
              console.log("MS: 不存在此数据")
            }
          })
      } else {
        console.error("Ability获取数据库失败")
      }
    }
  )
}

// 读取类型数据
async function queryDBForType(data: Array<SelectOption>): Promise<void>
{
  return new Promise ((resolve,reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          let predicates = new relationalStore.RdbPredicates('MYTYPE');

          DataBaseController.queryInTable(store, predicates).then(
            (resultSet) => {
              if(resultSet != undefined)
              {
                while (resultSet.goToNextRow()) {
                  const type = resultSet.getString(resultSet.getColumnIndex('TYPE'));
                  data.push({value: type})
                  console.info(`MS: 数据如下 type=${type}`);
                }
                resultSet.close()
                resolve()
              }else {
                console.log("MS: 不存在此数据")
              }
            })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  })
}

// 读取父类型数据
function queryDBForFatherType(data: Array<SelectOption>): void{
  DataBaseController.getDataBase(getContext(), "MyDB.db").then(
    (store) => {
      if (store != undefined){
        let predicates = new relationalStore.RdbPredicates('MYFATHERTYPE');

        DataBaseController.queryInTable(store, predicates).then(
          (resultSet) => {
            if(resultSet != undefined)
            {
              while (resultSet.goToNextRow()) {
                const fathertype = resultSet.getString(resultSet.getColumnIndex('FATHERTYPE'));
                data.push({value: fathertype})
                console.info(`MS: 数据如下 fathertype=${fathertype}`);
              }
              resultSet.close()
            }else {
              console.log("MS: 不存在此数据")
            }
          })
      } else {
        console.error("Ability获取数据库失败")
      }
    }
  )
}

// 完成次数
class completeData {
  times: number = 0;

  constructor(times: number) {
    this.times = times;
  }
}

// 类型选择框信息
class typeSelectData {
  text: string = "类型"
  index: number = 2
  space: number = 8
  arrowPosition: ArrowPosition = ArrowPosition.END

  constructor(text: string = "类型") {
    this.text = text
  }
}

// 父类型选择框信息
class fatherTypeSelectData {
  text: string = "父类型"
  index: number = 2
  space: number = 8
  arrowPosition: ArrowPosition = ArrowPosition.END
  constructor(text: string = "父类型") {
    this.text = text
  }
}

@Builder
export function DetailsBuilder(){
  Details({isUpdate: false})
}



@Component
export struct Details {

  @Consume pageInfo: NavPathStack

  @Consume needTabsDataUpdate: boolean

  // 展示类型
  @Prop isUpdate: boolean

  // 展示数据
  @State titleText: string = ''
  @State describeText: string = ''
  @State completeData: completeData = new completeData(0)
  @State typeSelectData: typeSelectData = new typeSelectData()
  @State fatherTypeSelectData: fatherTypeSelectData = new fatherTypeSelectData()

  @State projectId: number = 0

  // TextArea控制器
  describeController: TextAreaController = new TextAreaController()
  titleController: TextAreaController = new TextAreaController()

  // 动态生成可选类型
  @State private type: Array<SelectOption> = []
  @State private fatherType: Array<SelectOption> = []

  // 路由参数
  getParamsPrint() {
    console.info('MS: 传入参数');
    if(this.pageInfo.getParamByName('updateDetails')[0] != null)
    {
      // 读入参数
      let data: projectsData = this.pageInfo.getParamByName('updateDetails')[0] as projectsData
      // 载入
      this.titleText = data.title
      this.describeText = data.description

      let complete: completeData = new completeData(data.times)
      this.completeData = complete

      let typeSelect: typeSelectData = new typeSelectData(data.type)
      this.typeSelectData = typeSelect

      let fatherTypeSelect: fatherTypeSelectData = new fatherTypeSelectData(data.fatherType)
      this.fatherTypeSelectData = fatherTypeSelect

      this.projectId = data.id
    }
  }

  // 弹窗
  private uiContext: UIContext = this.getUIContext()
  private promptAction: PromptAction = this.uiContext.getPromptAction()


  aboutToAppear() {
    queryDBForType(this.type).then(() => {
      console.info("MS: type状态" + `${this.type}`)
    })
    queryDBForFatherType(this.fatherType)
    this.getParamsPrint()
  }

  build() {
    NavDestination()
    {
      // 主体
      Column()
      {
        // 标题
        Row()
        {
          Text("Title")
            .width("100%")
            .fontColor($r('app.color.orange'))
            .align(Alignment.Start)
            .fontSize(40)
            .width("30%")
            .height("100%")
          TextArea({
            text: this.titleText,
            placeholder: '请输入标题',
            controller: this.describeController
          })
            .placeholderFont({ size: 20})
            .width("70%")
            .height("100%")
            .margin(5)
            .fontSize(30)
            .fontColor($r('app.color.darkBlue'))
            .onChange((value: string) => {
              this.titleText = value
            })
            .maxLines(1)
        }
        .height("10%")
        .margin(10)
        .padding(10)
        .borderRadius(40)
        .backgroundColor($r('app.color.white'))

        // 选择框
        Row() {
          // 类型下拉框
          Select(this.type)
            .selected(this.typeSelectData.index)
            .value(this.typeSelectData.text)
            .space(this.typeSelectData.space)
            .arrowPosition(this.typeSelectData.arrowPosition)
            .onSelect((index: number, text?: string | undefined) => {
              this.typeSelectData.index = index;
              if (text) {
                this.typeSelectData.text = text;
              }
            })
            .border({ width: 5, color: $r('app.color.white'), radius: 15})
            .backgroundColor($r('app.color.orange'))
            .height("100%")
            .width("40%")
            .align(Alignment.Center)
          // 父类型下拉框
          Select(this.fatherType)
            .selected(this.fatherTypeSelectData.index)
            .value(this.fatherTypeSelectData.text)
            .space(this.fatherTypeSelectData.space)
            .arrowPosition(this.fatherTypeSelectData.arrowPosition)
            .onSelect((index: number, text?: string | undefined) => {
              console.info('Select:' + index)
              this.fatherTypeSelectData.index = index;
              if (text) {
                this.fatherTypeSelectData.text = text;
              }
            })
            .border({ width: 5, color: $r('app.color.white'), radius: 15})
            .backgroundColor($r('app.color.orange'))
            .height("100%")
            .width("40%")
            .align(Alignment.Center)
        }
        .height("10%")
        .align(Alignment.Center)

        // 描述
        Column()
        {
          Row()
          {
            Image($r('app.media.describe'))
              .width(25)
              .aspectRatio(1)
              .margin({left: 3})
            Text("Describe")
              .align(Alignment.Start)
              .fontSize(30)
              .fontColor($r('app.color.lightblue'))
              .margin({left: 20})
              .width("80%")
          }
          .height("30%")
          .width("100%")
          TextArea({
            text: this.describeText,
            placeholder: '请输入',
            controller: this.describeController
          })
            .placeholderFont({ size: 20})
            .width("100%")
            .height("60%")
            .margin(5)
            .fontSize(20)
            .fontColor($r('app.color.darkBlue'))
            .onChange((value: string) => {
              this.describeText = value
            })
        }
        .height("40%")
        .width("100%")
        .backgroundColor($r('app.color.white'))
        .margin({top: 10})
        .padding(10)
        .borderRadius(40)

        // 完成次数
        Column()
        {
          CompleteCounter({ data: $completeData })
        }
        .height("20%")
        .width("100%")
        .backgroundColor($r('app.color.white'))
        .margin({top: 10})
        .padding(10)
        .borderRadius(40)

        // 保存
        if(this.isUpdate === false)
        {
          // 新建
          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Row() {
              LoadingProgress()
                .width(30)
                .height(30)
                .margin({ left: 12 })
                .color(0xFFFFFF)
              Text('新建')
                .fontSize(30)
                .fontColor(0xffffff)
                .margin({ left: 5, right: 12 })
            }
            .alignItems(VerticalAlign.Center)
            .width(120)
            .height(50)
          }
          .backgroundColor($r('app.color.deepblue'))
          .onClick(() => {
            let nowTime = new Date()

            let ValueBucket: relationalStore.ValuesBucket = {
              TITLE: this.titleText,
              DESCRIPTION: this.describeText,
              TYPE: this.typeSelectData.text,
              FATHERTYPE: this.fatherTypeSelectData.text,
              TIMES: this.completeData.times,
              FULLTIMES: 100,
              CREATEDATE: nowTime.toUTCString(),
            };

            insertDB(ValueBucket).then(()=>{
              setTimeout(() => {
                this.needTabsDataUpdate = !this.needTabsDataUpdate
              },1000)
            })

            let allPathName: Array<string> = this.pageInfo.getAllPathName();
            let pathNameBefore: string = allPathName[allPathName.length - 1];

            if(this.titleText == '')
            {
              this.promptAction.showToast({
                message: '请填写标题~',
                duration: 1000,
                textColor: $r('app.color.red')
              })
            }else if(this.typeSelectData.text == '类型')
            {
              this.promptAction.showToast({
                message: '请选择类型~',
                duration: 1000,
                textColor: $r('app.color.red')
              })
            }else if(this.fatherTypeSelectData.text == '父类型')
            {
              this.promptAction.showToast({
                message: '请选择父类型~',
                duration: 1000,
                textColor: $r('app.color.red')
              })
            }else {
              this.pageInfo.pop("新建")
            }
          })
        }
        else {
          Row()
          {
            // 保存
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Row() {
                LoadingProgress()
                  .width(30)
                  .height(30)
                  .margin({ left: 12 })
                  .color(0xFFFFFF)
                Text('保存')
                  .fontSize(30)
                  .fontColor(0xffffff)
                  .margin({ left: 5, right: 12 })
              }
              .alignItems(VerticalAlign.Center)
              .width(120)
              .height(50)
            }
            .margin({right: 15})
            .backgroundColor($r('app.color.deepblue'))
            .onClick(() => {
              let nowTime = new Date()

              let ValueBucket: relationalStore.ValuesBucket = {
                TITLE: this.titleText,
                DESCRIPTION: this.describeText,
                TYPE: this.typeSelectData.text,
                FATHERTYPE: this.fatherTypeSelectData.text,
                TIMES: this.completeData.times,
                FULLTIMES: 100,
                CREATEDATE: nowTime.toUTCString(),
              };

              updateDB(ValueBucket, this.projectId)
              setTimeout(() => {
                this.needTabsDataUpdate = !this.needTabsDataUpdate
              },1000)
              this.pageInfo.pop("保存")
            })

            // 删除
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Row() {
                Image($r('app.media.delete'))
                  .width(30)
                  .aspectRatio(1)
                  .margin({ left: 12 })
                Text('删除')
                  .fontSize(30)
                  .fontColor(0xffffff)
                  .margin({ left: 5, right: 12 })
              }
              .alignItems(VerticalAlign.Center)
              .width(120)
              .height(50)
            }
            .backgroundColor($r('app.color.red'))
            .onClick(() => {
              deleteDB(this.projectId)
              setTimeout(() => {
                this.needTabsDataUpdate = !this.needTabsDataUpdate
              },1000)
              this.pageInfo.pop("删除")
            })

          }
          .align(Alignment.Center)

        }
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
    })
  }
}
