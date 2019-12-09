//
//  ViewController.swift
//  TryXcode
//
//  Created by Vimal Das on 05/12/19.
//  Copyright © 2019 Vimal Das. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var codeEditor: UITextView!
    
    @IBOutlet weak var bgView: UIView! { didSet { bgView.layer.cornerRadius = 10 } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeEditor.delegate = self
        
     
    }

}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textView.attributedText = textView.text.attributedStringWithCodeColor()
    }
    
}
extension String {
    func attributedStringWithCodeColor() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        TakenKeywords.funcNames = []
        TakenKeywords.classNames = []
        for line in self.components(separatedBy: "\n") {
            let components = line.components(separatedBy: " ")
            for (index, string) in components.enumerated() {
                if string == "func", components.indices.contains(index+1) {
                    let funcName = components[index+1].contains("()") ? String(components[index+1].dropLast(2)) : components[index+1]
                    TakenKeywords.funcNames.append(funcName)
                }
                if string == "class", components.indices.contains(index+1) {
                    if let className = components[index+1].components(separatedBy: ":").first {
                        TakenKeywords.classNames.append(className)
                    }
                    
                }
            }
            for (keywords, color) in TakenKeywords.allvalues {
                for string in keywords {
                    for range in self.ranges(of: string) {
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
                    }
                }
            }
        }
        
        return attributedString
    }
}
extension String {
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of searchString: String) -> [NSRange] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        let _range = _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
        return _range.map({ nsRange(from: $0) })
    }
}

extension String {

    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }
}

struct TakenKeywords {
    static let red = ["var", "let", "import", "class", "weak", "override", "viewDidLoad", "func", "self", "extension"]
    static let purple = ["String", "NSRange", "utf16", "UITextView", "UIViewController"]
    static var funcNames = [String]()
    static var classNames = [String]()
    
    static var allvalues: [([String], UIColor)] { return [(red, UIColor.red), (purple, UIColor.purple), (funcNames, UIColor.systemBlue), (classNames, UIColor.systemBlue)] }
}
