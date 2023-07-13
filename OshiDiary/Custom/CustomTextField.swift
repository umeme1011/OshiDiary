//
//  CustomTextField.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/13.
//

import UIKit

class CustomTextField: UITextField {
    
    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }

    // コピー・ペースト・選択等のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
