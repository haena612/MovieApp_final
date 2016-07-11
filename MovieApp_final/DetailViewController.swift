//
//  DetailViewController.swift
//  MovieApp_final
//
//  Created by Haena Kim on 7/8/16.
//  Copyright © 2016 Haena Kim. All rights reserved.
//

import UIKit
import AFNetworking

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var overviewLabel: UITextView!
    @IBOutlet weak var releasedate: UITextField!
    @IBOutlet weak var titleDetailLabel: UITextField!

    var posterUrlString: String = ""
    @IBOutlet weak var titleDetail: UITextField!
    var overview: String = ""
    var date: String = ""
    var titledetail: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

//        posterImage.setImageWithURL(NSURL(string: posterUrlString)!)
        overviewLabel.text = overview
        releasedate.text = date
        titleDetailLabel.text = titledetail
        
        //posterImage.hidden = true
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.posterImage.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                
                //Once the label is completely invisible, set the text and fade it back in
                self.posterImage.setImageWithURL(NSURL(string: self.posterUrlString)!)
                
                // Fade in
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.posterImage.alpha = 1.0
                    }, completion: nil)
        })
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     */ 
        
    }

