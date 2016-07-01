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
            //unsppourtted
            self.init(red: 0, green:0,blue: 0,alpha: 1)
        }
        else if css.hasPrefix("hsla(") == true
        {
            //unsppourtted
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
