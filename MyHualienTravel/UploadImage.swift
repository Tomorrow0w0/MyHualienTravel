//
//  UploadImage.swift
//  MyHualienTravel
//
//  Created by Chou on 2017/12/30.
//  Copyright © 2017年 NQU110410545. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class  UploadImage: UIViewController {
    
    @IBOutlet weak var UserPhoto: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 取的用戶基本資訊
         Auth.auth().addStateDidChangeListener { (auth, user) in
            
            let user = Auth.auth().currentUser
            
            if let user = user {
                
                let photoURL = user.photoURL
                let name = user.displayName
            
                // 加載Fb頭像
                let URLdata = try? Data(contentsOf:  photoURL!)
                self.UserPhoto.image = UIImage(data: URLdata!)!
                
                // 設置圓角
                self.UserPhoto.layer.cornerRadius = 50
                self.UserPhoto.clipsToBounds = true
                                
                // 設置陰影
                self.UserPhoto.layer.shadowOpacity = 0.5 //不透明度
                self.UserPhoto.layer.shadowOffset = CGSize(width: 0, height: 50) // 設置陰影的偏移量
                self.UserPhoto.layer.shadowRadius = 50 //設置陰影所照射的範圍
                
                self.NameLabel.text = "Hi!  " + name!
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadBtnAction(_ sender: UIButton) {
        
        // 建立一個 UIImagePickerController 的實體
        let imagePickerController = UIImagePickerController()
        
        // 委任代理
        imagePickerController.delegate = self
        
        // 建立一個 UIAlertController 的實體
        // 設定 UIAlertController 的標題與樣式為 動作清單 (actionSheet)
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        // 建立三個 UIAlertAction 的實體
        // 新增 UIAlertAction 在 UIAlertController actionSheet 的 動作 (action) 與標題
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            
            // 判斷是否可以從照片圖庫取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            
            // 判斷是否可以從相機取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
}

extension  UploadImage: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            
            let storageRef = FIRStorage.storage().reference().child("images").child("\(uniqueString).png")
            
            if let uploadData = UIImagePNGRepresentation(selectedImage) {
                // 這行就是 FirebaseStroge 關鍵的存取方法。
                storageRef.put(uploadData, metadata: nil, completion: { (data, error) in
                    
                    if error != nil {
                        
                        // 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    
                    // 連結取得方式就是：data?.downloadURL()?.absoluteString。
                    if let uploadImageUrl = data?.downloadURL()?.absoluteString {
                        
                        // 我們可以 print 出來看看這個連結事不是我們剛剛所上傳的照片。
                        print("Photo Url: \(uploadImageUrl)")
                        
                        let databaseRef = Database.database().reference().child("images").child(uniqueString)
                        
                        databaseRef.setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in
                            
                            if error != nil {
                                
                                print("Database Error: \(error!.localizedDescription)")
                            }
                            else {
                                
                                print("圖片已儲存")
                            }
                            
                        })
                    }
                })
            }
        }
        
        dismiss(animated: true, completion: nil)
        
        }
    }



