//
//  ViewController.swift
//  test
//
//  Created by Hoang Viet on 2018/08/06.
//  Copyright © 2018 Hoang Viet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var test: CustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test.attributedText = "{動物;どうぶつ}:動物-{園;えん}:園-へ-あし:あし-{毛;け}:毛-を-{見;み}:見る-に-{行;い}き:行く-ます".furigana()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class CustomLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let attributed = NSMutableAttributedString(attributedString: self.attributedText!)
        drawContext(attributed, textDrawRect: rect)
    }
    
    func drawContext(_ attributed:NSMutableAttributedString, textDrawRect:CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var path:CGPath
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: textDrawRect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        path = CGPath(rect: textDrawRect, transform: nil)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, nil)
        
        CTFrameDraw(frame, context)
    }
}

extension String {
    func furigana() -> NSMutableAttributedString {
        let attributed = self.replace(pattern: ":(.+?)-", template: "-")
                .components(separatedBy: "-")
                .map { x -> NSAttributedString in
                    if let pair = x.find(pattern: "\\{(.+?);(.+?)\\}(.*)") {
                        let kanji = (x as NSString).substring(with: pair.range(at: 1))
                        let ruby = (x as NSString).substring(with: pair.range(at: 2))
                        let tail = (x as NSString).substring(with: pair.range(at: 3))
                        
                        var text = [.passRetained(ruby as CFString) as Unmanaged<CFString>?, .none, .none, .none]
                        let annotation = CTRubyAnnotationCreate(.auto, .auto, 0.5, &text[0])
                        
                        let string = NSMutableAttributedString(
                            string: kanji,
                            attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation])
                        string.append(NSAttributedString(string: tail, attributes: nil))
                        return string
                    } else {
                        return NSAttributedString(string: x, attributes: nil)
                    }
                }
                .reduce(NSMutableAttributedString()) { $0.append($1); return $0 }
        
        return attributed
    }
    
    func find(pattern: String) -> NSTextCheckingResult? {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            return re.firstMatch(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count))
        } catch {
            return nil
        }
    }
    
    func replace(pattern: String, template: String) -> String {
        do {
            let re = try NSRegularExpression(pattern: pattern, options: [])
            return re.stringByReplacingMatches(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count),
                withTemplate: template)
        } catch {
            return self
        }
    }

}
