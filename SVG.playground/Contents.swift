//: Playground - noun: a place where people can play

import UIKit

/*
 http://www.w3school.com.cn/svg/svg_circle.asp
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
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(frame: CGRect,filePath:String) {
        super.init(frame: frame)
        
        if let content = try? String(contentsOfFile: filePath)
        {
            print(content)
            //self.init(frame:frame,SVGString:content)
        }
    }
    init(frame: CGRect,SVGString:String) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SVGParser : NSObject,NSXMLParserDelegate
{
    var rootAttributeDict :[String : String]?
    var elements         = [(elementName:String,attributeDict:[String : String])]()
    
    
//    func parseSingleElement(string:String) -> (elementName:String,attributeDict:[String : String])?
//    {
//        let parse = NSXMLParser(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
//        parse.delegate = self
//        parse.parse()
//    
//    }
   
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "svg"
        {
            rootAttributeDict = attributeDict
        }else
        {
            elements.append((elementName:elementName,attributeDict:attributeDict))
        }
    }
    
    func parse(string:String) -> (rootAttributeDict:[String : String]?,elements:[(elementName:String,attributeDict:[String : String])])
    {
        let parse = NSXMLParser(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
        parse.delegate = self
        parse.parse()
        
        return (rootAttributeDict:rootAttributeDict,elements:elements)
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
                return SVGCircle(attributeDict: element.attributeDict)
            case "ellipse":
                return SVGEllipse(attributeDict: element.attributeDict)
            case "line":
                return SVGLine(attributeDict: element.attributeDict)
            case "polyline":
                return SVGPolyline(attributeDict: element.attributeDict)
            case "polygon":
                return SVGPolygon(attributeDict: element.attributeDict)
            case "path":
                return SVGPath(attributeDict: element.attributeDict)
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
    func parseCGPointValue(key:String) -> Array<CGPoint>
    {
        var result = [CGPoint]()
        
        if var value = attributeDict[key]
        {
            var points = [CGFloat]()
            
            value = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            value = value.stringByReplacingOccurrencesOfString(",", withString: " ")
            let valueArray = value.componentsSeparatedByString(" ")
            for point in valueArray
            {
                if point.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0
                {
                    points.append(CGFloat((point as NSString).floatValue))
                }
            }
            for i in 0 ..< points.count/2
            {
                let thePoint = CGPointMake(points[2*i], points[2*i+1])
                result.append(thePoint)
            }
        }
        return result
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

class SVGPolyline : SVGElement
{
    var points = [CGPoint]()
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
        points = parseCGPointValue("points")
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        
        if points.first != nil
        {
              CGContextMoveToPoint(context, points.first!.x, points.first!.y)
        }
        for i in 1 ..< points.count
        {
            CGContextAddLineToPoint(context, points[i].x, points[i].y)
        }
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
class SVGPolygon : SVGElement
{
    var points = [CGPoint]()
    
    override init(attributeDict:[String : String]) {
        super.init(attributeDict:attributeDict)
        
        points = parseCGPointValue("points")
    }
    
    override func drawElement(context:CGContext) {
        super.drawElement(context)
        
        if points.first != nil
        {
            CGContextMoveToPoint(context, points.first!.x, points.first!.y)
        }
        for i in 1 ..< points.count
        {
            print("CGContextAddLineToPoint \(points[i])")
            CGContextAddLineToPoint(context, points[i].x, points[i].y)
        }
        if points.first != nil
        {
            print("CGContextAddLineToPoint \(points[0])")
            CGContextAddLineToPoint(context, points.first!.x, points.first!.y)
        }
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



/*
https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
 http://www.w3school.com.cn/svg/svg_path.asp
 
 <svg width="200" height="250" version="1.1" xmlns="http://www.w3.org/2000/svg">
 

 
 <path d="M20,230 Q40,205 50,230 T90,230" fill="none" stroke="blue" stroke-width="5"/> <path d="M95.727,56.11c-2.29-3.814-4.565-6.092-4.617-6.146c-0.48-0.48-2.289,1.668-2.791,2.309   c-0.762,0.981-2.563,2.625-6.367,4.876c-3.802,2.255-9.599,5.132-18.35,8.687c-3.747,1.524-6.766,3.085-9.192,4.666   c3.136-0.364,6.856-0.784,7.613-0.815c2.007-0.082-0.404,4.203-9.474,2.116c-1.186,0.895-2.195,1.796-3.047,2.699   c-1.388,1.474-2.355,2.959-2.971,4.422c-0.617,1.463-0.877,2.9-0.876,4.246c0.005,3.039,1.285,3.753,2.512,5.495   c1.234,1.746,3.872,2.962,3.872,2.962s-0.704-1.33-1.719-2.789c-1.022-1.463-1.976-3.455-1.971-5.668   c0.001-1.004,0.188-2.065,0.665-3.201c0.275-0.653,0.652-1.335,1.149-2.038c0.466,2.206,1.478,6.081,3.454,10.021   c1.499,2.98,3.555,4.208,6.406,6.524c2.844,2.317,6.521,5.686,11.017,5.679c0.11,0,0.221-0.001,0.332-0.003   c3.876-0.057,7.15-3.391,9.724-5.757c3.87-3.555,6.308-7.082,7.847-12.521c1.531-5.446,2.713-11.542,3.009-15.689   c0.522-7.306,0.163-10.061-0.246-11.266c0.572,0.787,1.188,1.696,1.808,2.743c2.096,3.534,4.127,8.399,4.123,13.856   c-0.002,3.122-0.653,6.447-2.35,9.907c-1.698,3.459-4.452,7.06-8.7,10.68c0,0,9.238-5.66,11.119-9.493   c1.882-3.831,2.628-7.595,2.626-11.095C100.33,65.29,98.012,59.922,95.727,56.11z M77.582,69h11.677C89.259,69,89.259,75,77.582,69   z"/>
 <path d="M53.943,97.604c-0.348-0.031-0.705-0.008-1.062-0.028c-0.212-0.012-0.425-0.001-0.633-0.02   c-3.854-0.352-6.887-1.923-8.909-4.354c-2.018-2.434-3.053-5.744-2.744-9.682l0.018-0.214c0.262-2.885,1.129-5.415,2.495-7.631   c1.367-2.215,3.437-3.863,5.531-5.702c7.384-6.483,14.57-10.075,21.95-13.905c4.245-2.203,8.488-4.594,12.651-7.22   c0.93-0.589,1.652-1.372,2.303-2.16c0.65-0.79,1.234-1.593,1.838-2.262c0,0-8.906,4.272-12.152,5.812   c-9.81,4.656-19.593,9.548-28.099,16.587c-3.033,2.512-5.808,5.679-7.739,9.131c-1.279,2.286-2.037,4.649-2.252,7.027   c-0.347,3.803,0.713,7.618,3.108,11.164c1.28,1.9,2.797,3.31,4.487,4.276c1.689,0.967,3.541,1.487,5.471,1.66   c1.797,0.162,3.675-0.072,5.585-0.411l7.056-1.355l-7.128-0.644C55.143,97.622,54.545,97.659,53.943,97.604z"/>
 <path d="M49.823,71.043c0.97,0.317,1.875,0.565,2.726,0.76c0.576-0.435,1.197-0.869,1.86-1.301   C51.934,70.79,49.823,71.043,49.823,71.043z" fill="#FFFFFF"/>
 </g>
 </svg>
 */





let canvas = SVGCanvas(frame: CGRectMake(0,0,300,300))
canvas.backgroundColor = UIColor(red: 0.1, green: 0.6, blue: 0.6, alpha: 1)



let s = [
"<rect x=\"40\" y=\"10\" width=\"30\" height=\"30\" stroke=\"black\" fill=\"black\" stroke-width=\"5\"/>",
"<rect x=\"180\" y=\"10\" width=\"30\" height=\"30\" stroke=\"black\" fill=\"red\" stroke-width=\"5\"/>",
"<circle cx=\"125\" cy=\"75\" r=\"20\" stroke=\"red\" fill=\"red\" stroke-width=\"5\"/>",
"<ellipse cx=\"75\" cy=\"75\" rx=\"20\" ry=\"5\" stroke=\"red\" fill=\"red\" stroke-width=\"5\"/>",
"<line x1=\"10\" x2=\"50\" y1=\"110\" y2=\"150\" stroke=\"orange\" fill=\"transparent\" stroke-width=\"5\"/>",
"<polyline points=\"60 110 65 120 70 115 75 130 80 125 85 140 90 135 95 150 100 145\" stroke=\"orange\" fill=\"transparent\" stroke-width=\"5\"/>",
"<polygon points=\"150 150,200 200, 200 250, 220 280\" stroke=\"green\" fill=\"transparent\" stroke-width=\"5\"/>"
]


s.forEach {
    canvas.addElement(SVGElement.element($0))
}




canvas



let path = NSBundle.mainBundle().pathForResource("demo", ofType: "svg")
let canvas2 = SVGCanvas(frame: CGRectMake(0,0,300,300),filePath:path!)
