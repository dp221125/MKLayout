#if canImport(UIKit)
import UIKit


//MARK: - KEY
private var MkAnchorKey: Int = 0
private var BuilderKey: Int = 1

public enum Comparer {
    case equal
    case less
    case greater
}
public enum Anchor {
    case anyX
    case centerX
    case leading
    case left
    case trailing
    case right
    
    case anyY
    case centerY
    case top
    case bottom
    case firstBaseline
    case laseBaseline
    
    case width
    case height
    case all
    
    case automatic
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
                return to.safeAreaLayoutGuide.leadingAnchor
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
                return to.layoutMarginsGuide.centerXAnchor
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
        
        fileprivate func convertToAnchor() -> Anchor {
            switch self {
            case .centerX, .safeCenterX, .marginCenterX:
                return .centerX
            case .leading, .safeLeading,.marginLeading:
                return .leading
            case .left, .safeLeft, .marginLeft:
                return .left
            case .trailing, .safeTrailing, .marginTrailing:
                return .trailing
            case .right, .safeRight, .marginRight:
                return .right
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
        
        fileprivate func convertToAnchor() -> Anchor {
            switch self {
            case .centerY, .safeCenterY, .marginCenterY:
                return .centerY
            case .top, .safeTop, .marginTop:
                return .top
            case .bottom,.safeBottom, .marginBottom:
                return .bottom
            case .firstBaseline:
                return .firstBaseline
            case .lastBaseline:
                return .laseBaseline
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
    public var mkAnchor: MKAnchor<UIOwner> {
        return _mkAnchor
    }
    
    private var _mkAnchor: MKAnchor<UIOwner> {
        get {
            if let value = objc_getAssociatedObject(self, &MkAnchorKey) as? MKAnchor<UIOwner> {
                return value
            }
            
            let mkAnchor = MKAnchor(uiOwner)
            self._mkAnchor = mkAnchor
            return mkAnchor
        }
        set {
            objc_setAssociatedObject(self,&MkAnchorKey,
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
    
    @discardableResult
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self?>, on object: Root) -> Self  {
        object[keyPath: keyPath] = self
        return self
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
public class MKAnchor<Owner: UIView> {
    
    //MARK: - Instance
    public private(set) weak var owner: Owner?
    
    private var xAnchor = [Anchor: NSLayoutConstraint]()
    
    private var yAnchor = [Anchor: NSLayoutConstraint]()
    
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
    
    private var newXAnchor = Set<AnchorType.XType>()
    private var newYAnchor = Set<AnchorType.YType>()
    private var oldXAnchor = Set<AnchorType.XType>()
    private var oldYAnchor = Set<AnchorType.YType>()
    
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
        
        inActive([at.convertToAnchor()])
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
    
    private func equalTop(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.topAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
    }
    
    private func lessTop(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.topAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
    }
    
    private func greaterTop(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.topAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
    }
    
    //MARK: - Bottom
    @discardableResult
    public func bottom(to view: UIView, at: AnchorType.YType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalBottom(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.bottomAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
          self.newYAnchor.insert(type)
    }
    
    private func lesslBottom(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.bottomAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
          self.newYAnchor.insert(type)
    }
    
    private func greaterBottom(_ view: UIView, _ at: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[at.convertToAnchor()] = owner.bottomAnchor.constraint(greaterThanOrEqualTo: at.setAnchor(view), constant: constant ?? 0)
          self.newYAnchor.insert(at)
    }
    
    //MARK: - leading
    @discardableResult
    public func leading(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalleading(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leadingAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func lesslleading(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leadingAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func greaterleading(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leadingAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    //MARK: - Left
    @discardableResult
    public func left(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalleft(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil)  {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leftAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func lessleft(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leftAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func greaterleft(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.leftAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    //MARK: - trailing
    @discardableResult
    public func trailing(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equaltrailing(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil)  {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.trailingAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func lesstrailing(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.trailingAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func greatertrailing(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.trailingAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    //MARK: - Right
    @discardableResult
    public func right(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalRight(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.rightAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func lessRight(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.rightAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func greaterRight(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.rightAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    //MARK: - CenterX
    @discardableResult
    public func centerX(to view: UIView, at: AnchorType.XType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalCenterX(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.centerXAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func lessCenterX(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.centerXAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    private func greaterCenterX(_ view: UIView, _ type: AnchorType.XType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.xAnchor[type.convertToAnchor()] = owner.centerXAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newXAnchor.insert(type)
    }
    
    //MARK: - CenterY
    @discardableResult
    public func centerY(to view: UIView, at: AnchorType.YType, constant: CGFloat? = nil, comparer: Comparer) -> Self {
        
        inActive([at.convertToAnchor()])
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
    
    private func equalCenterY(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.centerYAnchor.constraint(equalTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
    }
    
    private func lesslCenterY(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.centerYAnchor.constraint(lessThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
    }
    
    private func greaterCenterY(_ view: UIView, _ type: AnchorType.YType, _ constant: CGFloat? = nil) {
        guard let owner = self.owner else { return }
        self.yAnchor[type.convertToAnchor()] = owner.centerYAnchor.constraint(greaterThanOrEqualTo: type.setAnchor(view), constant: constant ?? 0)
        self.newYAnchor.insert(type)
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
    public func active(isAutoResizeMask: Bool = false, anchor: [Anchor] = [.automatic])  -> Owner {
        owner?.translatesAutoresizingMaskIntoConstraints = isAutoResizeMask
        self.switchingActive(anchor, true)
        owner?.layoutIfNeeded()
        return owner!
    }
    
    @discardableResult
    public func safeActive(isAutoResizeMask: Bool = false, anchor: [Anchor] = [.automatic])  -> Owner? {
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
        
        if self.xAnchor.count > 0  {
            print("X Anchor Status: \(xAnchor)")
        }  else {
            print("X Anchor Status: nil")
        }
        
        if self.yAnchor.count > 0 {
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
    public func inActive(_ anchor: [Anchor]) -> Self {
        switchingActive(anchor, false)
        return self
    }
    
    private func switchingActive(_ anchors: [Anchor], _ isActive: Bool) {
        anchors.forEach { anchor in
            switch anchor {
            case .anyX:
                xAnchorSwitch(isActive)
            case .anyY:
                yAnchorSwitch(isActive)
            case .width:
                self.widthAnchor?.isActive = isActive
            case .height:
                self.heightAnchor?.isActive = isActive
            case .all:
                xAnchorSwitch(isActive)
                yAnchorSwitch(isActive)
                dimensionAnchorSwitch(isActive)
            case .centerX:
                self.xAnchor[.centerX]?.isActive = isActive
            case .leading:
                self.xAnchor[.leading]?.isActive = isActive
            case .left:
                self.xAnchor[.left]?.isActive = isActive
            case .trailing:
                self.xAnchor[.trailing]?.isActive = isActive
            case .right:
                self.xAnchor[.right]?.isActive = isActive
            case .centerY:
                self.yAnchor[.centerY]?.isActive = isActive
            case .top:
                self.yAnchor[.top]?.isActive = isActive
            case .bottom:
                self.yAnchor[.bottom]?.isActive = isActive
            case .firstBaseline:
                 self.yAnchor[.firstBaseline]?.isActive = isActive
            case .laseBaseline:
                self.yAnchor[.laseBaseline]?.isActive = isActive
            case .automatic:
                
                if isActive {
                    automaticActive()
                } else {
                    automaticInActive()
                }
                
                dimensionAnchorSwitch(isActive)
            }
        }
        

    }
    
    private func  automaticActive() {
        while !self.newXAnchor.isEmpty {
            if let anchor = self.newXAnchor.popFirst() {
                self.xAnchor[anchor.convertToAnchor()]?.isActive = true
                self.oldXAnchor.insert(anchor)
            }
        }
        
        while !self.newYAnchor.isEmpty {
            if let anchor = self.newYAnchor.popFirst() {
                self.yAnchor[anchor.convertToAnchor()]?.isActive = true
                self.oldYAnchor.insert(anchor)
            }
        }
    }
    
    private func  automaticInActive() {
        while !self.oldXAnchor.isEmpty {
            if let anchor = self.oldXAnchor.popFirst() {
                self.xAnchor[anchor.convertToAnchor()]?.isActive = false
            }
        }
        
        while !self.oldYAnchor.isEmpty {
            if let anchor = self.oldYAnchor.popFirst() {
                self.yAnchor[anchor.convertToAnchor()]?.isActive = false
            }
        }
    }
    
    private func xAnchorSwitch(_ isActive: Bool) {
        self.xAnchor[.centerX]?.isActive = isActive
        self.xAnchor[.leading]?.isActive = isActive
        self.xAnchor[.left]?.isActive = isActive
        self.xAnchor[.trailing]?.isActive = isActive
        self.xAnchor[.right]?.isActive = isActive
    }
    
    private func yAnchorSwitch(_ isActive: Bool) {
        self.yAnchor[.centerY]?.isActive = isActive
        self.yAnchor[.top]?.isActive = isActive
        self.yAnchor[.bottom]?.isActive = isActive
        self.yAnchor[.firstBaseline]?.isActive = isActive
        self.yAnchor[.laseBaseline]?.isActive = isActive
    }
    
    private func dimensionAnchorSwitch(_ isActive: Bool) {
        self.widthAnchor?.isActive = isActive
        self.heightAnchor?.isActive = isActive
    }
    
    //MARK: - Init
    fileprivate init(_ owner: Owner)  {
        self.owner = owner
    }
}
extension UIView: ViewBuilderable { }
#endif
