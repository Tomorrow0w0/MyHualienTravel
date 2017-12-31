//
//  FbLogIn.swift
//  MyHualienTravel
//
//  Created by Chou on 2017/12/29.
//  Copyright © 2017年 NQU110410545. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class FbLogIn: UIViewController {
    
    
    
    @IBOutlet weak var LoadLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Label 換行
        LoadLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        LoadLabel.numberOfLines = 0
        
        self.LoadLabel.text = "花蓮之旅\n 2017/11/19~22"
        
    }
    
    @IBAction func FbLoginBtn(_ sender: UIButton) {
        
        let fbLoginManager = FBSDKLoginManager()
        // 使用FB登入的SDK，並請求可以讀取用戶的基本資料和取得用戶email的權限
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            // 登入失敗
            if error != nil {
                print("Failed to login: \(String(describing: error?.localizedDescription))")
                return
            }
            
            // 取得登入者的token失敗
            if FBSDKAccessToken.current() == nil {
                print("Failed to get access token")
                return
            }
            
            print("tokenString: \(FBSDKAccessToken.current().tokenString)")
            
            // 擷取用戶的access token，並通過調用將其轉換為Firebase的憑證
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            // 呼叫Firebase的API處理登入的動作
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                
                if error != nil {
                    print((error?.localizedDescription)!)
                    return
                }
                
                self.LoadLabel.text = "Welecome My Family."
                
                // 跳轉至GoUploadImage頁面
                self.performSegue(withIdentifier: "GoUploadImage", sender: self)
                
                // 使用FB登入成功
                print("使用FB登入成功")
                
            })
            
        }
        
    }
    
    @IBAction func FbLogoutBtn(_ sender: UIButton) {
        
         // FBSDKLoginManager().logOut()
        
        do {
            try Auth.auth().signOut()
            
            // 建立一個提示框
            let alertController = UIAlertController(
                title: "FaceBook",
                message: "登出",
                preferredStyle: .alert)
            
            // 建立[確認]按鈕
            let okAction = UIAlertAction(
                title: "確認",
                style: .default,
                handler: {
                    (action: UIAlertAction!) -> Void in
            })
            
            alertController.addAction(okAction)
            
            // 顯示提示框
            self.present(alertController, animated: true, completion: nil)
            
            // 使用FB登出
            print("使用FB登出")
            
        } catch let error {
            // error here
            print("Error trying to sign out of Firebase: \(error.localizedDescription)")
        }
        
    }
    
}
