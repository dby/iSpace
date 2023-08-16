//
//  SecurityBlurEffectView.swift
//  iSecrets
//
//  Created by dby on 2023/8/16.
//

import UIKit
import SnapKit

public class SecurityBlurEffectView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(self.mImageView)
        self.mImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Getter and Setter -
    lazy var mImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
}

extension SecurityBlurEffectView {
    func updateSecurityBlurEffectImage() {
        UIGraphicsBeginImageContextWithOptions(self.window!.bounds.size, true, 0.0)
        self.window?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            let inputImage = CIImage(cgImage: image!.cgImage!)
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(inputImage, forKey: kCIInputImageKey)
            filter?.setValue(20, forKey: "inputRadius")
            
            if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
               let cgImage = CIContext().createCGImage(result, from: inputImage.extent) {
                let blurImage = UIImage(cgImage: cgImage)
                self.mImageView.image = blurImage
            }
        }
    }
}
