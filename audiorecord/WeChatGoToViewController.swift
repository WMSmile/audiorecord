//
//  WeChatGoToViewController.swift
//  audiorecord
//
//  Created by apple on 2017/10/25.
//  Copyright © 2017年 wumeng. All rights reserved.
//

import UIKit
class ListModel: NSObject {
    var name:String?;
    var title:String?;
    
    override init() {
        super.init();
    }

    convenience init(_ name:String,_ title:String) {
        self.init();
        self.name = name;
        self.title = title;
    }
  
}

class WeChatGoToViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    var listTableView:UITableView?
    let identifer = "list"
//    朋友圈 weixin://dl/moments
//    扫一扫 weixin://dl/scan
    var listAry = [ListModel.init("朋友圈", "weixin://dl/moments"),ListModel.init("扫一扫", "weixin://dl/scan")]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        // Do any additional setup after loading the view.
        createTableView();
    }
    //MARK:- 创建tableview
    func createTableView() -> Void {
        listTableView = UITableView.init();
        listTableView?.delegate = self;
        listTableView?.dataSource = self;
        self.view.addSubview(listTableView!);
        listTableView?.frame = self.view.frame;
    }
    //MARK:- tableview dataSourceDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listAry.count;
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifer);
        
        if(!(cell != nil))
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifer);
            cell?.textLabel?.text = "";
        }
        cell?.textLabel?.text = listAry[indexPath.row].name;
        return cell!;
    }
    
    //MARK:- tableview delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIApplication.shared.open(URL.init(string: listAry[indexPath.row].title!)!, options: [:]) { (bool) in
            
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
