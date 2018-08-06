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
        test.attributedText = "{優勝;ゆうしょう}の{懸;か}かった{試合;しあい}。".furigana()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class CustomLabel: UILabel, SimpleVerticalGlyphViewProtocol {
    //override func draw(_ rect: CGRect) { // if not has drawText, use draw UIView etc
    override func drawText(in rect: CGRect) {
        let attributed = NSMutableAttributedString(attributedString: self.attributedText!)
        drawContext(attributed, textDrawRect: rect)
    }
}


protocol SimpleVerticalGlyphViewProtocol {
}

extension SimpleVerticalGlyphViewProtocol {
    
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
        
        // "｜": ルビを振る対象の文字列を判定し区切る為の記号(全角). ルビを振る文字列の先頭に挿入する
        // "《》": ルビを振る対象の漢字の直後に挿入しルビを囲う(全角)
        
        let attributed =
            self.replace(pattern: "(\\{.+?;.+?\\})", template: ",$1,")
                .components(separatedBy: ",")
                .map { x -> NSAttributedString in
                    if let pair = x.find(pattern: "\\{(.+?);(.+?)\\}") {
                        let string = (x as NSString).substring(with: pair.range(at: 1))
                        let ruby = (x as NSString).substring(with: pair.range(at: 2))
                        
                        var text = [.passRetained(ruby as CFString) as Unmanaged<CFString>?, .none, .none, .none]
                        let annotation = CTRubyAnnotationCreate(.auto, .auto, 0.5, &text[0])
                        
                        return NSAttributedString(
                            string: string,
                            attributes: [kCTRubyAnnotationAttributeName as NSAttributedStringKey: annotation])
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
