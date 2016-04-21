//
//  ViewController.swift
//  CollectionViewPinchZoom
//
//  Created by Michal Lichwa on 4/21/16.
//  Copyright © 2016 Michal Lichwa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var gesture = UIPinchGestureRecognizer()
    
    
    let kScaleBoundLower: CGFloat = 0.3
    let kScaleBoundUpper: CGFloat = 4.0
    
    let fitCells: Bool = true
    let animatedZooming: Bool = true
    
    private var _scale: CGFloat? = nil
    var scale: CGFloat? {
        set {
            if _scale < kScaleBoundLower {
                _scale = kScaleBoundLower
            }
            else if _scale > kScaleBoundUpper {
                _scale = kScaleBoundUpper
            }
            else {
                
                _scale = scale
            }
        }
        get {
            return _scale
        }
    }
    var scaleStart = CGFloat()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default scale is the average between the lower and upper bound
        _scale = (kScaleBoundUpper + kScaleBoundLower) / 2.0
        // Register a random cell
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        // Add the pinch to zoom gesture
        self.gesture = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.didReceivePinchGesture(_:)))
        self.collectionView.addGestureRecognizer(self.gesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 80
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        // Alternate cells between red and blue
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0.7, alpha: 1.0)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Main use of the scale property
        let scaledWidth: CGFloat = 50 * _scale!
        if self.fitCells {
            let cols: Int = Int(floor(self.collectionView.frame.width / scaledWidth))
            let totalSpacingSize: CGFloat = CGFloat(10 * (cols - 1))
            // 10 is defined in the xib
            let temp: Int = Int(self.collectionView.frame.width - totalSpacingSize) / cols
            let fittedWidth: CGFloat = CGFloat(temp)
            return CGSizeMake(fittedWidth, fittedWidth)
        }
        else {
            return CGSizeMake(scaledWidth, scaledWidth)
        }
    }
    
    func didReceivePinchGesture(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .Began {
            // Take an snapshot of the initial scale
            scaleStart = _scale!
            return
        }
        if gesture.state == .Changed {
            // Apply the scale of the gesture to get the new scale
            _scale = scaleStart * gesture.scale
            if self.animatedZooming {
                // Animated zooming (remove and re-add the gesture recognizer to prevent updates during the animation)
                self.collectionView.removeGestureRecognizer(self.gesture)
                let newLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                self.collectionView.setCollectionViewLayout(newLayout, animated: true, completion: {(finished: Bool) -> Void in
                    self.collectionView.addGestureRecognizer(self.gesture)
                })
            }
            else {
                // Invalidate layout
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}

