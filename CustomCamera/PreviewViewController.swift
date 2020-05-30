 //
 //  PreviewViewController.swift
 //  CustomCamera
 //
 //  Created by Sufiandy Elmy on 28/05/20.
 //  Copyright © 2020 Sufiandy Elmy. All rights reserved.
 //
 
 import UIKit
 import CoreML
 import Vision
 
 class PreviewViewController: UIViewController {
    
    @IBOutlet weak var ResultPhoto: UIImageView!
    @IBOutlet weak var photoView: UIImageView!
    var image:UIImage!
    var name:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = image
        // Do any additional setup after loading the view.
        detectPhoto(image: photoView.image!)
        view.showLoadingView(inView: view)
        name = "nodata"
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        guard let imageToSave = image else {
            return
        }
        guard let newData = CoreDataManager.shared.createWaste(name: name, image: imageToSave) else { return }
        print("Created \(newData)")
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    func detectPhoto(image: UIImage) {
        //load coreml model
        guard let ciImage = CIImage(image: image) else {
            fatalError("Couldn't convert UIImage to CIImage")
        }
        guard let model = try? VNCoreMLModel(for: WasteClassifier().model) else {
            fatalError("Can't load CoreML Model")
        }
        let request = VNCoreMLRequest(model: model) {
            (vnRequest, error) in
            print(vnRequest.results?.first as Any)
            guard let results = vnRequest.results as?
                [VNClassificationObservation], let firstResult = results.first else {
                    fatalError("Unexpected result")
            }
            DispatchQueue.main.async {
                if(firstResult.identifier.contains("Can")){
                    self.name = "Can"
                }else if(firstResult.identifier.contains("Bottle")){
                    self.name = "Bottle"
                }else if(firstResult.identifier.contains ("Glass")){
                    
                }else{
                   self.name = "No Waste"
                }
              
                self.ResultPhoto.image = UIImage(named: self.name)
                self.view.hideLoadingView()
               
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos:
            DispatchQoS.QoSClass.userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
        }
    }
 }
 var loadingView = UIView ()
 var animateImg = UIImageView(frame:  CGRect(x: 0, y: 0, width: 100, height: 100 ))
 extension UIView {
    func showLoadingView (inView v : UIView) {
        loadingView.frame = CGRect(x: 0, y: 0, width: v.frame.size.width, height: v.frame.size.height )
        loadingView.backgroundColor = UIColor.white
        loadingView.alpha = 0.9
        var nameArray: [String] = ["i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9"]
        var photos: [UIImage] = []
        for name in nameArray {
            photos.append(UIImage(named: name)!)
        }
        animateImg.animationImages = photos
        animateImg.center = loadingView.center
        animateImg.animationDuration = 90.0
        loadingView.addSubview(animateImg)
        animateImg.startAnimating()
        
        
        v.addSubview(loadingView)
    }
    func hideLoadingView () {
        loadingView.removeFromSuperview()
    }
 }
