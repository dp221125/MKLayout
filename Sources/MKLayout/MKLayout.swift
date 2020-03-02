#if canImport(UIKit)
import UIKit


//MARK: - KEY
private var MKLayoutKey: Int = 0
private var BuilderKey: Int = 1

public enum Comparer {
    case equal
    case less
    case greater
}
public enum Anchor {
    case x
    case y
    case width
    case height
    case all
}
//MARK: - AnchType
public enum AnchorType {
    
    public enum XType {
        case centerX
        case safeCenterX
        case marginCenterX
        
        case leading
        case safeLeading
        case marginLeading
        
        case left
        case safeLeft
        case marginLeft
        
        case trailing
        case safeTrailing
        case marginTrailing
        
        case right
        case safeRight
        case marginRight
        
        fileprivate func setAnchor(_ to: UIView) -> NSLayoutXAxisAnchor {
            switch self {
            case .centerX:
                return to.centerXAnchor
            case .safeCenterX:
                return to.safeAreaLayoutGuide.centerXAnchor
            case .leading:
                return to.leadingAnchor
            case .safeLeading:
                return to.safeAreaLayoutGuide.trailingAnchor
            case .trailing:
                return to.trailingAnchor
            case .safeTrailing:
                return to.safeAreaLayoutGuide.trailingAnchor
            case .left:
                return to.leftAnchor
            case .safeLeft:
                return to.safeAreaLayoutGuide.leftAnchor
            case .right:
                return to.rightAnchor
            case .safeRight:
                return to.safeAreaLayoutGuide.rightAnchor
            case .marginCenterX:
                return to.layoutMarginsGuide.trailingAnchor
            case .marginLeading:
                return to.layoutMarginsGuide.leadingAnchor
            case .marginLeft:
                return to.layoutMarginsGuide.leftAnchor
            case .marginTrailing:
                return to.layoutMarginsGuide.trailingAnchor
            case .marginRight:
                return to.layoutMarginsGuide.rightAnchor
            }
        }
    }
    
    public enum YType {
        case centerY
        case safeCenterY
        case marginCenterY
        
        case top
        case safeTop
        case marginTop
        
        case bottom
        case safeBottom
        case marginBottom
        
        case firstBaseline
        case lastBaseline
        
        
        fileprivate func setAnchor(_ to: UIView) -> NSLayoutYAxisAnchor {
            switch self {
            case .centerY:
                return to.centerYAnchor
            case .top:
                return to.topAnchor
            case .bottom:
                return to.bottomAnchor
            case .firstBaseline:
                return to.firstBaselineAnchor
            case .lastBaseline:
                return to.lastBaselineAnchor
            case .safeCenterY:
                return to.safeAreaLayoutGuide.centerYAnchor
            case .marginCenterY:
                return to.layoutMarginsGuide.centerYAnchor
            case .safeTop:
                return to.safeAreaLayoutGuide.topAnchor
            case .marginTop:
                return to.layoutMarginsGuide.topAnchor
            case .safeBottom:
                return to.safeAreaLayoutGuide.bottomAnchor
            case .marginBottom:
                return to.layoutMarginsGuide.bottomAnchor
            }
        }
    }
    
    public enum DimensionType {
        case width
        case height
        
        fileprivate func setAnchor(_ to: UIView) -> NSLayoutDimension {
            switch self {
            case .width:
                return to.widthAnchor
            case .height:
                return to.heightAnchor
            }
        }
    }
    
}

//MARK: - ViewBuilder
public class ViewBuilder<UIOwner> {
    private var uiOwner: UIOwner
    
    fileprivate init(uiOwner: UIOwner) {
        self.uiOwner = uiOwner
    }
}
extension ViewBuilder where UIOwner: UIView {
    public var mkLayout: MKLayOut<UIOwner> {
        return _mkLayout
    }
    
    private var _mkLayout: MKLayOut<UIOwner> {
        get {
            if let value = objc_getAssociatedObject(self, &MKLayoutKey) as? MKLayOut<UIOwner> {
                return value
            }
            
            let layout = MKLayOut(uiOwner)
            self._mkLayout = layout
            return layout
        }
        set {
            objc_setAssociatedObject(self,&MKLayoutKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
//MARK: - ViewBuilderable
public protocol ViewBuilderable: class { }
extension ViewBuilderable {
    public var builder: ViewBuilder<Self> {
        return _builder
    }
    
    private var _builder: ViewBuilder<Self> {
        get {
            if let value = objc_getAssociatedObject(self, &BuilderKey) as? ViewBuilder<Self> {
                return value
            }
            
            let chain = ViewBuilder(uiOwner: self)
            self._builder = chain
            return chain
        }
        set {
            objc_setAssociatedObject(self,&BuilderKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
public struct AnchorSize {
    fileprivate var size: CGFloat
    fileprivate var comparer: Comparer
    
    public init(_ size: CGFloat, _ comparer: Comparer) {
        self.size = size
        self.comparer = comparer
    }
}
//MARK: - MKLayOut
public class MKLayOut<Owner: UIView> {
    
    //MARK: - Instance
    private weak var owner: Owner?
    
    private var xAnchor: NSLayoutConstraint? {
        willSet {
            self.xAnchor?.isActive = false
        }
    }
    
    private var yAnchor: NSLayoutConstraint? {
        willSet {
            self.yAnchor?.isActive = false
        }
    }
    
    private var widthAnchor: NSLayoutConstraint? {
        willSet {
            self.widthAnchor?.isActive = false
        }
    }
    
    private var heightAnchor: NSLayoutConstraint? {
        willSet {
            self.heightAnchor?.isActive = false
        }
    }
    
    //MARK: - ADD
    @discardableResult
    public func add(at view: UIView) -> Self {
        guard let owner = self.owner else { return self }
        view.addSubview(owner)
        return self
    }
    
    
    //MARK: - Top
    @discardableResult
    public func top(to view: UIView, at: AnchorType.YType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalTop(view, at, constant)
        case .less:
            lessTop(view, at, constant)
        case .greater:
            greaterTop(view, at, constant)
        }
        
        return self
    }
    
    private func equalTop(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.topAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lessTop(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.topAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterTop(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.topAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - Bottom
    @discardableResult
    public func bottom(to view: UIView, at: AnchorType.YType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalBottom(view, at, constant)
        case .less:
            lesslBottom(view, at, constant)
        case .greater:
            greaterBottom(view, at, constant)
        }
        return self
    }
    
    private func equalBottom(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.bottomAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lesslBottom(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.bottomAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterBottom(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.bottomAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - leading
    @discardableResult
    public func leading(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalleading(view, at, constant)
        case .less:
            lesslleading(view, at, constant)
        case .greater:
            greaterleading(view, at, constant)
        }
        
        return self
    }
    
    private func equalleading(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.leadingAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lesslleading(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.leadingAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterleading(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.leadingAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - Left
    @discardableResult
    public func left(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
            
        case .equal:
            equalleft(view, at, constant)
        case .less:
            lessleft(view, at, constant)
        case .greater:
            greaterleft(view, at, constant)
        }
        return self
    }
    
    private func equalleft(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil)  {
        guard let owner = owner else { return }
        self.xAnchor = owner.leftAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lessleft(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor = owner.leftAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterleft(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor = owner.leftAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - trailing
    @discardableResult
    public func trailing(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equaltrailing(view, at, constant)
        case .less:
            lesstrailing(view, at, constant)
        case .greater:
            greatertrailing(view, at, constant)
        }
        return self
    }
    
    private func equaltrailing(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil)  {
        guard let owner = owner else { return }
        self.xAnchor = owner.trailingAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lesstrailing(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor = owner.trailingAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greatertrailing(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor = owner.trailingAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - Right
    @discardableResult
    public func right(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalRight(view, at, constant)
        case .less:
            lessRight(view, at, constant)
        case .greater:
            greaterRight(view, at, constant)
        }
        
        return self
    }
    
    private func equalRight(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.rightAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lessRight(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.rightAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterRight(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.rightAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - CenterX
    @discardableResult
    public func centerX(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalCenterX(view, at, constant)
        case .less:
            lessCenterX(view, at, constant)
        case .greater:
            greaterCenterX(view, at, constant)
        }
        
        return self
    }
    
    private func equalCenterX(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.centerXAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lessCenterX(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.centerXAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterCenterX(_ view: UIView, _ at: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor = owner.centerXAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - CenterY
    @discardableResult
    public func centerY(to view: UIView, at: AnchorType.YType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        switch comparer {
        case .equal:
            equalCenterY(view, at, constant)
        case .less:
            lesslCenterY(view, at, constant)
        case .greater:
            greaterCenterY(view, at, constant)
        }
        return self
    }
    
    private func equalCenterY(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.centerYAnchor.constraint(equalTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func lesslCenterY(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.centerYAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    private func greaterCenterY(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor = owner.centerYAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
    }
    
    //MARK: - Size
    @discardableResult
    public func size(width: AnchorSize? = nil, height: AnchorSize? = nil) -> Self {
        guard let owner = self.owner else { return self }
        if let width = width {
            switch width.comparer {
            case .equal:
                self.widthAnchor = owner.widthAnchor.constraint(equalToConstant: width.size)
            case .less:
                self.widthAnchor = owner.widthAnchor.constraint(lessThanOrEqualToConstant: width.size)
            case .greater:
                self.widthAnchor = owner.widthAnchor.constraint(greaterThanOrEqualToConstant: width.size)
            }
        }
        
        if let height = height {
            switch height.comparer {
            case .equal:
                self.heightAnchor = owner.heightAnchor.constraint(equalToConstant: height.size)
            case .less:
                self.heightAnchor = owner.heightAnchor.constraint(lessThanOrEqualToConstant: height.size)
            case .greater:
                self.heightAnchor = owner.heightAnchor.constraint(greaterThanOrEqualToConstant: height.size)
            }
        }
        
        return self
    }
    
    //MARK: - Width
    @discardableResult
    public func width(to view: UIView, at: AnchorType.DimensionType, constant: CGFloat? = nil, multiplier: CGFloat? = nil, comparer: Comparer) -> Self {
        guard multiplier != 0 else { return self }
        
        switch comparer {
        case .equal:
            equalWidth(view, at, constant, multiplier)
        case .less:
            lessWidth(view, at, constant, multiplier)
        case .greater:
            greaterWidth(view, at, constant, multiplier)
        }
        
        return self
    }
    
    private func equalWidth(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.widthAnchor = owner.widthAnchor.constraint(equalTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    private func lessWidth(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.widthAnchor = owner.widthAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    private func greaterWidth(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.widthAnchor = owner.widthAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    //MARK: - Height
    @discardableResult
    public func height(to view: UIView, at: AnchorType.DimensionType, constant: CGFloat? = nil, multiplier: CGFloat? = nil, comparer: Comparer) -> Self {
        guard multiplier != 0 else { return self }
        
        switch comparer {
        case .equal:
            equalHeight(view, at, constant, multiplier)
        case .less:
            lessHeight(view, at, constant, multiplier)
        case .greater:
            greaterHeight(view, at, constant, multiplier)
        }
        
        return self
    }
    
    private func equalHeight(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.heightAnchor = owner.heightAnchor.constraint(equalTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    private func lessHeight(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.heightAnchor = owner.heightAnchor.constraint(lessThanOrEqualTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    private func greaterHeight(_ view: UIView, _ at: AnchorType.DimensionType, _ constant: CGFloat? = nil, _ multiplier: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.heightAnchor = owner.heightAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), multiplier: multiplier ?? 1, constant: constant ?? 0)
    }
    
    
    
    //MARK: - EqualAToB
    public func equalWidthToHeight(constant: CGFloat? = nil, multiplier: CGFloat? = nil) -> Self  {
        guard let owner = self.owner, multiplier != 0 else { return self }
        self.widthAnchor = owner.widthAnchor.constraint(equalTo: owner.heightAnchor, multiplier: multiplier ?? 1, constant: constant ?? 0)
        return self
    }
    
    public func equalHeightToWidth(constant: CGFloat? = nil, multiplier: CGFloat? = nil) -> Self  {
        guard let owner = self.owner, multiplier != 0 else { return self }
        self.heightAnchor = owner.heightAnchor.constraint(equalTo: owner.widthAnchor, multiplier: multiplier ?? 1, constant: constant ?? 0)
        return self
    }
    
    //MARK: - Active
    @discardableResult
    public func active(isAutoResizeMask: Bool = false, anchor: [Anchor] = [.all])  -> Owner {
        owner?.translatesAutoresizingMaskIntoConstraints = isAutoResizeMask
        self.switchingActive(anchor, true)
        owner?.layoutIfNeeded()
        return owner!
    }
    
    @discardableResult
    public func safeActive(isAutoResizeMask: Bool = false, anchor: [Anchor] = [.all])  -> Owner? {
        owner?.translatesAutoresizingMaskIntoConstraints = isAutoResizeMask
        self.switchingActive(anchor, true)
        owner?.layoutIfNeeded()
        return owner
    
    }
    
    @discardableResult
    public func status() -> Self {
        if let owner = self.owner {
            print("View Status: \(owner)")
        }  else {
            print("View Status: nil")
        }
        
        if let xAnchor = self.xAnchor {
            print("X Anchor Status: \(xAnchor)")
        }  else {
            print("X Anchor Status: nil")
        }
        
        if let yAnchor = self.yAnchor {
            print("Y Anchor Status: \(yAnchor)")
        }  else {
            print("Y Anchor Status: nil")
        }
        
        if let widthAnchor = self.widthAnchor {
            print("Width Anchor Status: \(widthAnchor)")
        }  else {
            print("Width Anchor Status: nil")
        }
        
        
        if let heightAnchor = self.heightAnchor {
            print("Height Anchor Status: \(heightAnchor)")
        }  else {
            print("Height Anchor Status: nil")
        }
        
        return self
    }
    
    @discardableResult
    public func inactive(_ anchor: [Anchor]) -> Self {
        switchingActive(anchor, false)
        return self
    }
    
    private func switchingActive(_ anchors: [Anchor], _ isActive: Bool) {
        anchors.forEach { anchor in
            switch anchor {
            case .x:
                self.xAnchor?.isActive = isActive
            case .y:
                self.yAnchor?.isActive = isActive
            case .width:
                self.widthAnchor?.isActive = isActive
            case .height:
                self.heightAnchor?.isActive = isActive
            case .all:
                self.xAnchor?.isActive = isActive
                self.yAnchor?.isActive = isActive
                self.widthAnchor?.isActive = isActive
                self.heightAnchor?.isActive = isActive
            }
        }
       
    }
    
    //MARK: - Init
    fileprivate init(_ owner: Owner)  {
        self.owner = owner
    }
}
extension UIView: ViewBuilderable { }
#endif
