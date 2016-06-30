//: Playground - noun: a place where people can play

import UIKit

public extension UIColor
{
    
    public convenience init(css:String)
    {
        
        if css.hasPrefix("#") == true
        {
            self.init(hexString:css)
        }
        else if css.hasPrefix("rgb(") == true
        {
            self.init(hexString:css)
        }
        else if css.hasPrefix("rgba(") == true
        {
            self.init(hexString:css)
        }
        else if css.hasPrefix("hsl(") == true
        {
            //unsppourt
            self.init(red: 0, green:0,blue: 0,alpha: 1)
        }
        else if css.hasPrefix("hsla(") == true
        {
            //unsppourt
            self.init(red: 0, green:0,blue: 0,alpha: 1)
        }else if let hex = UIColor.colorWithKey(css)
        {
            self.init(hexString:hex)
        }else
        {
            self.init(red: 0, green:0,blue: 0,alpha: 1)
        }
        
        
    }
    
    class func colorWithKey(key:String) -> String?
    {
        //http://www.w3school.com.cn/cssref/css_colors.asp
        //http://www.computerhope.com/htmcolor.htm
        //http://www.zhangxinxu.com/wordpress/2015/07/know-css1-css3-color/
        let dict = [
            "transparent":"#00000000",
            "red":"#FF0000",
            "black":"#000000",
            "orange":"#FFA500"];
        return dict[key]
    }
    
    
    
    
    
    public convenience init(rgb r:Int,g:Int,b:Int) {
        self.init(red: CGFloat(r)/CGFloat(255.0), green: CGFloat(g)/CGFloat(255.0),blue: CGFloat(b)/CGFloat(255.0),alpha: 1)
    }
    
    public convenience init(rgba r:Int,g:Int,b:Int,a:Float) {
        self.init(red: CGFloat(r)/CGFloat(255.0), green: CGFloat(g)/CGFloat(255.0),blue: CGFloat(b)/CGFloat(255.0),alpha: CGFloat(a))
    }
    
    
    public convenience init(hexString: String) {
        
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        var color = hexString
        if color.hasPrefix("#") == true
        {
            color = color.substringFromIndex(color.startIndex.advancedBy(1))
        }
        
        var hex:UInt64 = 0
        
        if NSScanner(string: color).scanHexLongLong(&hex)
        {
            if color.characters.count == 6
            {
                red   = CGFloat((hex & 0x8FF0000) >> 16)  / 255.0
                green = CGFloat((hex & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hex & 0x0000FF)           / 255.0
            }else if color.characters.count == 8
            {
                red   = CGFloat((hex & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hex & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hex & 0x000000FF)         / 255.0
            }
        }else
        {
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}



/*
 
 http://www.w3school.com.cn/svg/svg_circle.asp
 
 
<rect width="30" height="100" style="fill:rgb(255,255,55);stroke-width:1;stroke:rgb(200,50,100)" />
 
 矩形 <rect>
 圆形 <circle>
 椭圆 <ellipse>
 线 <line>
 折线 <polyline>
 多边形 <polygon>
 路径 <path>
 */

class SVGCanvas : UIView
{
    var elements = [SVGElement](){
        didSet{
            self.setNeedsDisplay()
        }
    }
    func addElement(element:SVGElement?)
    {
        if element != nil
        {
            self.elements.append(element!)
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        for element in self.elements
        {
            element.drawElement(context!)
        }
    }
}

class SVGParser : NSObject,NSXMLParserDelegate
{
    var elementName:String?
    var attributeDict:[String : String]!
    
    func parse(string:String) -> (elementName:String,attributeDict:[String : String])?
    {
        let parse = NSXMLParser(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        parse.delegate = self
        parse.parse()
        
        if elementName != nil
        {
            return (elementName:elementName!,attributeDict:attributeDict)
        }else
        {
            return nil
        }
    }
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.elementName = elementName
        self.attributeDict = attributeDict
    }
}
class SVGElement : NSObject
{
    var attributeDict:[String : String]
    
    var width   : CGFloat = 0
    var height  : CGFloat = 0
    var x       : CGFloat = 0
    var y       : CGFloat = 0
    
    //style
    var fill           : UIColor?
    var stroke         : UIColor?
    var strokeWidth    : CGFloat = 0
    

    
    class func element(string:String) -> SVGElement?
    {
        if let element = SVGParser().parse(string)
        {
            print(element.elementName)
            print(element.attributeDict)
            switch element.elementName {
            case "rect":
                return SVGRect(attributeDict: element.attributeDict)
            case "circle":
                print("ccc")
                return SVGCircle(attributeDict: element.attributeDict)
            case "ellipse":
                return SVGEllipse(attributeDict: element.attributeDict)
            case "line":
                return SVGLine(attributeDict: element.attributeDict)
            default:
                return nil
            }
        }
        return nil
    }
    
    
    override init() {
        self.attributeDict = [String : String]()

        super.init()
    }
    
    init(attributeDict:[String : String]) {
        self.attributeDict = attributeDict
        super.init()
        
        print("root init")
        print(attributeDict)
        
        setCGFloatValue("x")
        setCGFloatValue("y")
        setCGFloatValue("width")
        setCGFloatValue("height")
        setCGFloatValue("strokeWidth",realName:"stroke-width")
        
        for (k,v) in attributeDict
        {
            switch k {
            case "fill":
                fill   = UIColor(css: v)
            case "stroke":
                stroke = UIColor(css: v)
                
            default:
                break
            }
        }
    }
    
    func setCGFloatValue(key:String,realName:String? = nil)
    {
        let name = (realName == nil) ? key : realName!
        if let value = attributeDict[name]
        {
            self.setValue(CGFloat((value as NSString).floatValue), forKeyPath: key)
        }
    }
    

    func drawElement(context:CGContext) {
        
        fill?.setFill()
        stroke?.setStroke()
        CGContextSetLineWidth(context, strokeWidth)

    }
}
class SVGRect : SVGElement
{
    var rx  : CGFloat = 0
    var ry  : CGFloat = 0
    
    override func drawElement(context:CGContext) {
        
        super.drawElement(context)
        
        if rx == 0 && ry == 0
        {
            CGContextAddRect(context, CGRectMake(x, y, width, height))
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        }
    }
}
class SVGCircle : SVGElement
{
    var cx  : CGFloat = 0
    var cy  : CGFloat = 0
    var r   : CGFloat = 0
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
        print("SVGCircle init")
        setCGFloatValue("cx")
        setCGFloatValue("cy")
        setCGFloatValue("r")
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        CGContextAddEllipseInRect(context, CGRectMake(cx - r, cy - y , 2*r,2*r))
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGEllipse : SVGElement
{
    var cx  : CGFloat = 0
    var cy  : CGFloat = 0
    var rx  : CGFloat = 0
    var ry  : CGFloat = 0
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
        setCGFloatValue("cx")
        setCGFloatValue("cy")
        setCGFloatValue("rx")
        setCGFloatValue("ry")
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        CGContextAddEllipseInRect(context, CGRectMake(cx - rx, cy - ry , 2*rx,2*ry))
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGLine : SVGElement
{
    var x1  : CGFloat = 0
    var y1  : CGFloat = 0
    var x2  : CGFloat = 0
    var y2  : CGFloat = 0
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
        setCGFloatValue("x1")
        setCGFloatValue("y1")
        setCGFloatValue("x2")
        setCGFloatValue("y2")
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        
        CGContextMoveToPoint(context, x1, y1)
        CGContextAddLineToPoint(context, x2, y2)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGPath : SVGElement
{

    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        

        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGPolyline : SVGElement
{
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGPolygon : SVGElement
{
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}




/*
https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
 http://www.w3school.com.cn/svg/svg_path.asp
 
 <svg width="200" height="250" version="1.1" xmlns="http://www.w3.org/2000/svg">
 
 <rect x="10" y="10" width="30" height="30" stroke="black" fill="transparent" stroke-width="5"/>
 <rect x="60" y="10" rx="10" ry="10" width="30" height="30" stroke="black" fill="transparent" stroke-width="5"/>
 
 <circle cx="25" cy="75" r="20" stroke="red" fill="transparent" stroke-width="5"/>
 <ellipse cx="75" cy="75" rx="20" ry="5" stroke="red" fill="transparent" stroke-width="5"/>
 
 <line x1="10" x2="50" y1="110" y2="150" stroke="orange" fill="transparent" stroke-width="5"/>
 <polyline points="60 110 65 120 70 115 75 130 80 125 85 140 90 135 95 150 100 145"
 stroke="orange" fill="transparent" stroke-width="5"/>
 
 <polygon points="50 160 55 180 70 180 60 190 65 205 50 195 35 205 40 190 30 180 45 180"
 stroke="green" fill="transparent" stroke-width="5"/>
 
 <path d="M20,230 Q40,205 50,230 T90,230" fill="none" stroke="blue" stroke-width="5"/>
 </svg>
 */





let canvas = SVGCanvas(frame: CGRectMake(0,0,300,300))
canvas.backgroundColor = UIColor(red: 0.1, green: 0.6, blue: 0.6, alpha: 1)



let s = [
"<rect x=\"40\" y=\"10\" width=\"30\" height=\"30\" stroke=\"black\" fill=\"black\" stroke-width=\"5\"/>",
"<rect x=\"180\" y=\"10\" width=\"30\" height=\"30\" stroke=\"black\" fill=\"red\" stroke-width=\"5\"/>",
"<circle cx=\"125\" cy=\"75\" r=\"20\" stroke=\"red\" fill=\"red\" stroke-width=\"5\"/>",
"<ellipse cx=\"75\" cy=\"75\" rx=\"20\" ry=\"5\" stroke=\"red\" fill=\"red\" stroke-width=\"5\"/>",
"<line x1=\"10\" x2=\"50\" y1=\"110\" y2=\"150\" stroke=\"orange\" fill=\"transparent\" stroke-width=\"5\"/>"
]


s.forEach {
    canvas.addElement(SVGElement.element($0))
}




canvas





