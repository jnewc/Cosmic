import UIKit
import PlaygroundSupport

import Cosmic

let logglyToken: String = ""

let papertrailHost: String = ""
let papertrailPort: UInt16 = 0

let logzToken: String = ""

let width = 400.0
let height = 320.0

let itemWidth = width - 24
let itemHeight = height / 2.0

// -- LogglyLogger ---------------------------------------------------------------

let logglyLoggerFrame = CGRect(x: 12, y: 12, width: 400 - 24, height: itemHeight)
let logglyLoggerView = UILoggerView(frame: logglyLoggerFrame)

let logglyBackgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
logglyLoggerView.backgroundColor = logglyBackgroundColor
logglyLoggerView.serviceLabel.text = "Loggly"

logglyLoggerView.onSubmit = {
    let logger = LogglyLogger(token: logglyToken)
    logger.logLevel = .info
    
    if let text = logglyLoggerView.textField.text {
        logger.log(text)
    }
}


// -- Papertrail Logger ----------------------------------------------------------

let papertrailLoggerFrame = CGRect(x: 12.0, y: Double(logglyLoggerView.frame.maxY + 12.0), width: itemWidth, height: itemHeight)
let papertrailLoggerView = UILoggerView(frame: papertrailLoggerFrame)

let papertrailColor = UIColor(colorLiteralRed: 0.1, green: 0.9, blue: 0.1, alpha: 0.75)
papertrailLoggerView.backgroundColor = papertrailColor
papertrailLoggerView.serviceLabel.text = "Papertrail"

papertrailLoggerView.onSubmit = {
    let logger = PapertrailLogger(config: SocketLoggerConfig(host: papertrailHost, port: papertrailPort))
    logger.logLevel = .info
    
    if let text = papertrailLoggerView.textField.text {
        logger.log(text)
    }
}

// -- Logz.io Logger --------------------------------------------------------------

let logzLoggerFrame = CGRect(x: 12.0, y: Double(papertrailLoggerView.frame.maxY) + 12.0, width: itemWidth, height: itemHeight)
let logzLoggerView = UILoggerView(frame: logzLoggerFrame)

let logzColor = UIColor(colorLiteralRed: 0.9, green: 0.1, blue: 0.1, alpha: 0.75)
logzLoggerView.backgroundColor = logzColor
logzLoggerView.serviceLabel.text = "Logz.io"

logzLoggerView.onSubmit = {
    let logger = LogzLogger(withToken: logzToken)
    logger.logLevel = .info
    
    if let text = logzLoggerView.textField.text {
        logger.log()
    }
}

// -- Live View Setup ------------------------------------------------------------

let rootView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
var rootFrame = rootView.frame
rootFrame.size.height = papertrailLoggerView.frame.height + logglyLoggerView.frame.height + logzLoggerView.frame.height + (12 * 4)
rootView.frame = rootFrame

rootView.addSubview(logglyLoggerView)
rootView.addSubview(papertrailLoggerView)
rootView.addSubview(logzLoggerView)

PlaygroundPage.current.liveView = rootView

