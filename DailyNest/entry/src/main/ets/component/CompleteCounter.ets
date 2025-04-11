
class completeData {
  times: number = 0;

  constructor(times: number) {
    this.times = times;
  }
}


// 主组件
@Component
export struct CompleteCounter{

  @Link data: completeData;

  aboutToAppear() {

  }
  build() {
    Column()
    {
      Row()
      {
        Image($r('app.media.tick'))
          .width(30)
          .aspectRatio(1)
        Text("完成次数: ")
          .height("100%")
          .fontSize(30)
          .fontColor($r('app.color.lightblue'))
          .margin({left: 20})
        Text(`${this.data.times}`)
          .height("100%")
          .fontSize(30)
          .fontColor($r('app.color.lightblue'))
          .fontWeight(800)
      }
      .height("40%")
      .width("100%")
      .align(Alignment.Start)
      .margin({left: 5})

      Row()
      {
        Progress({ value: this.data.times, total: 100, type: ProgressType.Linear })
          .style({ strokeWidth: 20, enableSmoothEffect: true })
          .width("50%")
          .height(30)
        Button('+')
          .width("15%")
          .margin({left:20})
          .fontSize(30)
          .backgroundColor($r('app.color.deepblue'))
          .onClick(() => {
            if(this.data.times < 100){this.data.times += 1}
          })
        Button('-')
          .width("15%")
          .margin({left:5})
          .fontSize(30)
          .backgroundColor($r('app.color.deepblue'))
          .onClick(() => {
            if(this.data.times > 0){this.data.times -= 1}
          })
      }
      .height("60%")
    }
  }
}