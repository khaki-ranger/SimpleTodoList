//
//  ViewController.swift
//  SimpleTodoList
//
//  Created by 寺島 洋平 on 2019/02/06.
//  Copyright © 2019年 YoheiTerashima. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // ToDo を格納した配列
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
            if let unarchiveTodoList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyTodo] {
                todoList.append(contentsOf: unarchiveTodoList)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ToDoの配列の長さを返却する
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        // 行番号に合ったToDoのタイトルを取得
        let myTodo = todoList[indexPath.row]
        
        // セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.todoTitle
        
        // セルのチェックマーク状態をセット
        if myTodo.todoDone {
            // チェックあり
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone {
            // 完了済みの場合は未完了に変更
            myTodo.todoDone = false
        } else {
            // 未完了の場合は完了済みに変更
            myTodo.todoDone = true
        }
        // セルの状態を保存
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        
        // データ保存
        // Data型にシリアライズする
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
        
        // UserDefaultsに保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
    // セルが編集可能であるかどうかを返却する
    // 今回は全てのセルが削除対象なので、一律でtrueを返却する
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうか
        if editingStyle == UITableViewCellEditingStyle.delete {
            // ToDoリストから削除
            todoList.remove(at: indexPath.row)
            
            // セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            // データを保存
            // Data型にシリアライズする
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
            
            // UserDefaultsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }
    }

    @IBAction func tapAddButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title: "TODO追加", message: "TODOを入力してください", preferredStyle: UIAlertControllerStyle.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            if let textField = alertController.textFields?.first {
                // ToDo 配列に入力値を先頭に挿入する
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
                
                // ToDo の保存処理
                let userDefaults = UserDefaults.standard
                
                // Data型にシリアライズする
                let data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            }
        }
        alertController.addAction(okAction)
        
        // CANCELボタンがタップされた時の処理
        let cancenButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancenButton)
        
        // アラートダイアログを表示
        present(alertController, animated: true, completion: nil)
    }
    
}

// 独自クラスをシリアライズする際には、NSObjectを継承し
// NSCodingプロトコルに準拠する必要がある
class MyTodo: NSObject, NSCoding {
    // ToDoのタイトル
    var todoTitle: String?
    
    // ToDoを完了したかどうかを表すフラグ
    var todoDone: Bool = false
    
    // コンストラクタ
    override init() {
        
    }
    
    // NSCodingプロトコルに宣言されているデシリアライズ処理
    // デコード処理とも呼ばれる
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
    
    // NSCodingプロトコルに宣言されているシリアライズ処理
    // エンコード処理とも呼ばれる
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
    }
}

