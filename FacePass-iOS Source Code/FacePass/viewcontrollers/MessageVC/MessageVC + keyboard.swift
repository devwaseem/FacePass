//
//  MessageViewController + keyboard Configs.swift
//  FacePass
//
//  Created by Waseem Akram on 29/09/17.
//  Copyright © 2017 Haze. All rights reserved.
//

import UIKit
import ISEmojiView

extension MessageViewController:ISEmojiViewDelegate {
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        msgBox.msgField.insertText(emoji)
    }
    
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        msgBox.msgField.deleteBackward()
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                setupMsgBoxPosition()
            } else {
                msgBox.easy_clear()
                setupMsgBoxPosition(pushUpBy: endFrame?.size.height ?? 0.0)
                
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

