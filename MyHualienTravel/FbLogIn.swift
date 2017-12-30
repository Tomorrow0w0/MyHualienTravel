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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                
                // 跳轉至GoUploadImage頁面
                self.performSegue(withIdentifier: "GoUploadImage", sender: self)
                
                // 使用FB登入成功
                print("使用FB登入成功")
                
            })
            
        }
        
    }
    
    
    @IBAction func FbLogoutBtn(_ sender: UIButton) {
        
         FBSDKLoginManager().logOut()
        // 使用FB登出
        print("使用FB登出")
        
    }
    
}
