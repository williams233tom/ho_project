import { relationalStore } from '@kit.ArkData';

import * as DataBaseController from '../../module/DataBaseController'
import { DynamicTabContents } from './DynamicTabContents'

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

// 插入父类型
async function insertDB(valueBucket: relationalStore.ValuesBucket): Promise<void> {
  return new Promise((resolve, reject) => {
    DataBaseController.getDataBase(getContext(), "MyDB.db").then(
      (store) => {
        if (store != undefined){
          console.log("Ability获取数据库成功")
          DataBaseController.insertInTable(store, 'MYFATHERTYPE', valueBucket).then(() => {
            resolve()
          })
        } else {
          console.error("Ability获取数据库失败")
        }
      }
    )
  })
}

@Builder
export function DynamicTabsBuilder(name: string, param: Object){
  DynamicTabs()
}

// 自定义弹窗
@CustomDialog
struct CustomDialogExample {
  // TextArea控制器
  @State text: string = ''
  describeController: TextAreaController = new TextAreaController()

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  build() {
    Column() {
      Text('增加父类型')
        .fontSize(30)
        .margin({bottom: 20, top:20 })
        .fontColor($r('app.color.lightblue'))
      Row(){
        Text('名称：')
        TextArea({
            placeholder: '请输入名称',
            controller: this.describeController
          })
          .onChange((value: string) => {
            this.text = value
          })
          .width("60%")
      }
      .margin({bottom: 20})
      Row(){
        Button('取消')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
          })
          .margin({right: 10})
          .backgroundColor($r('app.color.deepblue'))

        Button('保存')
          .onClick(() => {
            if (this.controller != undefined) {

              if(this.text != '')
              {
                let valueBucket: relationalStore.ValuesBucket = {
                  FATHERTYPE: this.text
                }
                insertDB(valueBucket)
              }

              this.controller.close()
            }
          })
          .backgroundColor($r('app.color.deepblue'))
      }
    }
  }
}

@Component
export struct DynamicTabs{

  @State data: Array<string> = [];
  toUpdate?: (segData: projectsData) => void;

  // 函数传递中转
  mediumToUpdate(segData: projectsData): void{
    if(this.toUpdate != undefined)
    {
      this.toUpdate(segData)
    }
  }

  @State focusIndex: number = 0;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    createFatherTypeData(this.data).then(() => {
      console.info(`MS: 父类 总量为 ${this.data.length}`)
    })
  }

  // 自定义弹窗
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }

  // 弹窗
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 200,
    backgroundColor: $r('app.color.white'),
  })

  // 自定义页签
  @Builder
  Tab(tabName: string, tabIndex: number) {
    Column({ space: 20 }) {
      Text(tabName)
        .fontSize(18)
    }
    .width(100)
    .height("100%")
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
        // 页签
        Scroll() {
          Row() {
            ForEach(this.data, (item: string, index: number) => {
              this.Tab(item, index);
            })
          }
          .justifyContent(FlexAlign.Start)
        }
        .align(Alignment.Start)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('85%')
        .backgroundColor($r('app.color.backWhite'))
        // 增加父类型
        Image($r('app.media.smallPlus'))
          .width("10%")
          .aspectRatio(1)
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
      }
      .width('100%')
      .backgroundColor($r('app.color.backWhite'))
      .margin({bottom: 5})
      .height("7%")

      // 页面内容
      Tabs({barPosition: BarPosition.Start, controller: this.controller})
      {
        ForEach(this.data, (item: string, index: number) => {
            TabContent() {
              DynamicTabContents({fatherType: item as string,
                mediumToUpdate:(segData: projectsData) => this.mediumToUpdate(segData) })
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
      .height("93%")
    }
  }
}
