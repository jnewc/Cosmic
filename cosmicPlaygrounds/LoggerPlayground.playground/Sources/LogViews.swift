
import UIKit

public class UILoggerView: UIView {
    
    public typealias SubmitHandler = () -> ()
    
    public var onSubmit: SubmitHandler?
    
    public let textField: UITextField = UITextField()
    
    public let serviceLabel: UILabel = UILabel()
    
    override required public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        layer.cornerRadius = 8

        let w = frame.width - 24
     
        serviceLabel.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        serviceLabel.font = UIFont(name: "HelveticaNeue-Light", size: 24.0)
        serviceLabel.textColor = .white
        
        let titleFrame = CGRect(x: 0, y: 0, width: w, height: 16.0)
        let titleLabel = UILabel(frame: titleFrame)
        titleLabel.textColor = .white
        titleLabel.font = titleLabel.font.withSize(14.0)
        titleLabel.text = "Message"
        
        textField.frame = CGRect(x: 0, y: 0, width: w, height: 36)
        textField.borderStyle = .roundedRect
        textField.inputView = UIView()
        
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 0, y: 0, width: w, height: 36)
        button.layer.cornerRadius = 5
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .darkGray
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSubmit))
        button.addGestureRecognizer(gestureRecognizer)
        
        let stackView = UIStackView(arrangedSubviews: [
            serviceLabel, titleLabel, textField, button
        ])
        stackView.axis = .vertical
        let height = frame.height //+ CGFloat(stackView.arrangedSubviews.count * 12)
        
        
        stackView.frame = CGRect(x: 12, y: 12, width: frame.width - 24, height: height - 24)
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .yellow
        
        self.addSubview(stackView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSubmit(sender: Any) {
        self.onSubmit?()
    }
}
