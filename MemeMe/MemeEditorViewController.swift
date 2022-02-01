//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Julia Rozum on 26/01/2022.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
   
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var textTop: UITextField!
    @IBOutlet var textBottom: UITextField!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var navigationBar: UINavigationBar!
    

    let memeTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!, NSAttributedString.Key.strokeWidth: -3.0]
    
    func prepareTextField(textField: UITextField, defaultText: String) {
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(textField: textTop, defaultText: "TOP")
        prepareTextField(textField: textBottom, defaultText: "BOTTOM")
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func pickImage(sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum() {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera() {
        pickImage(sourceType: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if textBottom.isEditing, view.frame.origin.y == 0 {
        view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_notification: Notification) {
        if textBottom.isEditing, view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func save() {
        let memedImageView: UIImage = generateMemedImage()
        _ = Meme(topText: textTop.text!, bottomText: textBottom.text!, originalImage: imageView.image!, memedImage: memedImageView)

    }
    
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        navigationBar.isHidden = true
        toolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        navigationBar.isHidden = false
        toolBar.isHidden = false
        return memedImage
    }
    
    //sent the generated meme to the activity view controller and present the controller
    @IBAction func share() {
      let memedImage: UIImage = generateMemedImage()
        let shareFile = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            shareFile.completionWithItemsHandler = { (activity, completed, items, error) in self.save()
        if (completed) {
            self.save()
            }
        }
            self.present(shareFile, animated: true, completion: nil)
    }
    
    @IBAction func cancelImage(_ sender: Any) {
        shareButton.isEnabled = false
        imageView.image = nil
        textTop.text = "TOP"
        textBottom.text = "BOTTOM"
    }
}


