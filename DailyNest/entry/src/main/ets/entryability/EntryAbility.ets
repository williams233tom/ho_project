import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

import * as DataBaseController from '../module/DataBaseController'

const DOMAIN = 0x0000;

// Ability类似android的Activity
export default class EntryAbility extends UIAbility {

  // Ability创建时调用
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');  // 输出日志
  }

  // Ability销毁时调用
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // 窗口创建时调用
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 1. 载入窗口
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    // 2. 创建关系型数据库
    DataBaseController.getDataBase(this.context, "MyDB.db").then(
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

  // 窗口创建时调用
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  // Ability 回到前台时调用
  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  // Ability 回到后台时调用
  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

}