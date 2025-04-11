import { relationalStore } from '@kit.ArkData'; // 导入模块
import { BusinessError } from '@kit.BasicServicesKit';
import { Queue } from '@kit.ArkTS';

class CreateSQL {
  createTable_PROJECTS =
    'CREATE TABLE IF NOT EXISTS PROJECTS ' +
      '(ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'TITLE TEXT NOT NULL,' +
      'DESCRIPTION TEXT NOT NULL,' + // 修改为 DESCRIPTION
      'TYPE TEXT,' +
      'FATHERTYPE TEXT NOT NULL,' +
      'TIMES INTEGER, ' +
      'FULLTIMES INTEGER, ' +
      'CREATEDATE TEXT NOT NULL);'; // 添加分号

  createTable_CALENDAR =
    'CREATE TABLE IF NOT EXISTS CALENDAR ' +
      '(ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'YEAR INTEGER NOT NULL,' +
      'MONTH INTEGER NOT NULL,' +
      'DAY INTEGER NOT NULL,' +
      'BEGIN INTEGER NOT NULL,' +
      'LASTING INTEGER NOT NULL,' +
      'PROJECTID INTEGER NOT NULL,' +
      'FOREIGN KEY (PROJECTID) REFERENCES PROJECTS(ID));'; // 添加外键约束和分号

  createTable_MYTYPE =
    'CREATE TABLE IF NOT EXISTS MYTYPE' +
      '(ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'TYPE TEXT UNIQUE NOT NULL);';

  createTable_MYFATHERTYPE =
    'CREATE TABLE IF NOT EXISTS MYFATHERTYPE' +
      '(ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
      'FATHERTYPE TEXT UNIQUE NOT NULL);';
}


// 获取数据库
export async function getDataBase(context: Context, dbName: string): Promise<relationalStore.RdbStore | undefined> {
  let config: relationalStore.StoreConfig = {
    name: dbName,
    securityLevel: relationalStore.SecurityLevel.S3,
    customDir: 'customDir/subCustomDir', // 自定义路径。
  };

  try {
    const store = await new Promise<relationalStore.RdbStore>((resolve, reject) => {
      relationalStore.getRdbStore(context, config, (err, rdbStore) => {
        if (err) {
          console.error(`MS: 未能获取数据库. Code:${err.code}, message:${err.message}`);
          reject(err);
        } else {
          console.info('MS: 成功获取数据库.');
          resolve(rdbStore);
        }
      });
    });

    return store;
  } catch (error) {
    console.error('MS: 获取数据库时发生错误:', error);
    return undefined;
  }
}
// 插入数据
export async function insertInTable(store: relationalStore.RdbStore, tableName: string, valueBucket: relationalStore.ValuesBucket): Promise<void>
{
  return new Promise((resolve, reject) => {
    (store as relationalStore.RdbStore).insert(tableName, valueBucket, (err: BusinessError, rowId: number) => {
      if (err) {
        console.error(`MS:　数据插入失败, code is ${err.code},message is ${err.message}`);
      }
      console.info(`MS:　数据插入成功, tableName = ${tableName} rowId = ${rowId}`);
    })
    console.info("MS: calendar响应 插入数据")
    console.info("MS: calendar响应 insertInTable")
    resolve()
  })
}

// 删除数据
export async function deleteInTable(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates): Promise<void>
{
  return new Promise(async (resolve, reject) => {
    console.log("MS: 进入删除")

    store.delete(predicates, (err, resultSet) => {
      if (err) {
        console.error(`MS: 删除失败, code is ${err.code},message is ${err.message}`);
        reject(err);
      }
    })
    resolve()
  })
}

// 更新数据
export async function updateInTable(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates,
   valueBucket: relationalStore.ValuesBucket): Promise<void>
{
  return new Promise(async (resolve, reject) => {
    console.log("MS: 进入更新")

    store.update(valueBucket, predicates, (err, resultSet) => {
      if (err) {
        console.error(`MS: 更新失败, code is ${err.code},message is ${err.message}`);
        reject(err);
      }
    })
    resolve()
  })
}
// 访问数据
export async function queryInTable(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates): Promise<relationalStore.ResultSet | undefined>
{
  try {
    const resultSet: relationalStore.ResultSet = await new Promise<relationalStore.ResultSet>((resolve, reject) => {
        console.log("MS: 进入查询")

        store.query(predicates, (err, resultSet) => {
          if (err) {
           console.error(`MS: 查询失败, code is ${err.code},message is ${err.message}`);
           reject(err);
         }
          console.info(`MS: 查询数据集如下： names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);

          // 记得使用resultSet.close();
          resolve(resultSet)
        })
    });
    return resultSet;
  }catch (error) {
    console.error('MS: 获取数据库时发生错误:', error);
    return undefined;
  }
}
// 创建表
export function createTable(store: relationalStore.RdbStore): Promise<void>
{
  return new Promise((resolve, reject) => {
    let SQL: CreateSQL = new CreateSQL()

    store.executeSql(SQL.createTable_PROJECTS, (err) => {
      if (err) {
        console.error(`MS: SQL 执行失败. Code:${err.code}, message:${err.message}`);
      }
      console.info('MS: SQL 执行成功.');
    });

    store.executeSql(SQL.createTable_CALENDAR, (err) => {
      if (err) {
        console.error(`MS: SQL 执行失败. Code:${err.code}, message:${err.message}`);
      }
      console.info('MS: SQL 执行成功.');
    });

    store.executeSql(SQL.createTable_MYTYPE, (err) => {
      if (err) {
        console.error(`MS: SQL 执行失败. Code:${err.code}, message:${err.message}`);
      }
      console.info('MS: SQL 执行成功.');
    });

    store.executeSql(SQL.createTable_MYFATHERTYPE, (err) => {
      if (err) {
        console.error(`MS: SQL 执行失败. Code:${err.code}, message:${err.message}`);
      }
      console.info('MS: SQL 执行成功.');
    });

    store.version = 1;
    console.info('MS: 数据库创建成功')
    resolve();
  })
}
// 初始化表
export function iniTable(store: relationalStore.RdbStore): void
{
  let valueBucket1: relationalStore.ValuesBucket = {
    FATHERTYPE: "主要类型"
  }
  let valueBucket2: relationalStore.ValuesBucket = {
    FATHERTYPE: "学习"
  }
  let valueBucket3: relationalStore.ValuesBucket = {
    TYPE: "娱乐"
  }
  let valueBucket4: relationalStore.ValuesBucket = {
    TYPE: "工作"
  }

  let valueBucket5: relationalStore.ValuesBucket = {
    YEAR: 2025,
    MONTH: 3,
    DAY: 1,
    BEGIN: 1,
    LASTING: 1,
    PROJECTID: 1
  }
  insertInTable(store, 'MYFATHERTYPE', valueBucket1)
  insertInTable(store, "MYFATHERTYPE", valueBucket2)
  insertInTable(store, "MYTYPE", valueBucket3)
  insertInTable(store, "MYTYPE", valueBucket4)
  // insertInTable(store, "CALENDAR", valueBucket5)
  console.info("MS: 数据库")

}