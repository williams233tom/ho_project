import { unifiedDataChannel, uniformTypeDescriptor} from '@kit.ArkData';

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


// 每小时部分组件
@Component
export struct SegmentComponent
{
  @ObjectLink data: segmentData

  @Consume isOpenSideBar: boolean
  @Consume showSegment: segmentData

  onDropSuccess?: (projectId: number, segmentId: number) => Promise<void>;

  build() {
    Column()
    {
      // 带标题
      if(this.data != undefined)
      {
        if(this.data.isOccupied)
        {
          Column()
          {
            if(this.data.isHead == true)
            {
              Text(`${this.data.title}`)
                .fontColor($r('app.color.white'))
              Text(`${this.data.describe}`)
                .fontSize(12)
            }else {
              Blank()
            }
          }
          .borderRadius(5)
          .width("100%")
          .height("100%")
          .backgroundColor($r('app.color.orange'))
        }else {
          Column()
          {
            Blank()
          }
          .width("100%")
          .height("100%")
          .backgroundColor($r('app.color.white'))
          .borderRadius(5)
          .borderColor('app.color.lightblue')
          .borderWidth(2)
          .transition(TransitionEffect.OPACITY
            .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 }))// 对每个方格的转场添加delay，实现组件的渐次出现消失效果
            .animation({ duration: 300, curve: Curve.Friction, delay: 30}))
        }
      } else {
        Blank()
      }
    }
    .allowDrop([uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
    .onDrop((event: DragEvent) => {
      console.log("MS: 进入拖拽放置")
      let dragData:UnifiedData = (event as DragEvent).getData() as UnifiedData;

      if(dragData != undefined) {
        // 获取数据
        let data: UnifiedData = event.getData();
        if (!data) {return;}
        let records: Array<unifiedDataChannel.UnifiedRecord> = data.getRecords();
        if (!records || records.length <= 0) {
          console.info("MS: 不存在拖拽入的数据")
          return;
        }

        // 读取数据
        let plainText: unifiedDataChannel.PlainText = records[0] as unifiedDataChannel.PlainText;
        let projectId = parseInt(plainText.textContent)

        // 数据处理
        this.data.projectId = parseInt(plainText.textContent)

        console.info("MS: 拖拽完成，项目ID为：" + `${plainText.textContent}`)
        if(this.onDropSuccess != undefined && this.data.isOccupied != true)
          this.onDropSuccess(projectId, this.data.myId)

        // 设置drop结果
        event.setResult(DragResult.DRAG_SUCCESSFUL);
      }
    })
    .onClick(() => {
      if(this.data.isOccupied == true)
      {
        this.showSegment = this.data
        animateTo({
          duration: 300,
          curve: Curve.Linear
        }, () => {
          if(this.isOpenSideBar == true)
          {
            this.isOpenSideBar = false
            setTimeout( () => {
              this.isOpenSideBar = true
            }, 10)
          }
          this.isOpenSideBar = true
        })
      }
    })
    .borderRadius(5)
  }
}