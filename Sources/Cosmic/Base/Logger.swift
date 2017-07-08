import Foundation

public enum LogLevel: UInt {
	case debug  = 0b0001
	case info	= 0b0011
	case warn	= 0b0111
	case error	= 0b1111
    case none   = 0xFFFF
    
    
    var simpleName: String {
        switch self {
        case .debug:    return "debug"
        case .info:     return "info"
        case .warn:     return "warn"
        case .error:    return "error"
        default:        return ""
        }
    }
}



public protocol Logger: class {

	init()

    // MARK: Logging properties
    
	/// Indicates the current level of logging.
    ///
    /// The log level of a Logger indicates:
    ///  - The class of logs that should be logged
    ///  - The classes of augmentation that should be applied to logs
    var logLevel: LogLevel { get set }
    
    
    /// A list of formatters to apply to logs
    ///
    /// Formatters transform logs from one string-based representation to another. Each
    /// formatter will be applied to every message, so any filtering should be done 
    /// within the formatter itself.
    var formatters: [LogFormatter] { get set }


    // MARK: Logging functions
    
	/// Logs a debug message or messages
    ///
    /// Debug messages are used to express useful diagnostic information. These messages
    /// should describe development details and can contain sensitive information, but
    /// should be disabled in production builds.
    ///
    /// Examples:
    ///     - Performance statistics
    ///     - Service operation messages
    ///     - Network request statuses and responses
	///
	/// - Parameter messages: The message or messages to log
	func debug(_ messages: String ...)
    
	/// Logs an info message or messages
	///
    /// Info messages are used to describe the general operation of a component. These
    /// messages should not contain sensitive information.
    ///
    /// Examples:
    ///     - Service start/stop messages
    ///     - Configuration details
    ///     - User interactions
    ///
	/// - Parameter messages: The message or messages to log
	func log(_ messages: String...)

    /// Logs a warning message or messages
    ///
    /// Warning messages are used to describe non-fatal issues that occur during general
    /// use of a component. These messages should not contain sensitive information.
    ///
    /// Examples:
    ///     - Missing configuration
    ///     - User input validation errors
    ///     - Low memory events
    ///
    /// - Parameter messages: The message or messages to log
	func warn(_ messages: String...)

    
	/// Logs an error message or messages
    ///
    /// Error messages indicate fatal or unrecoverable issues that occur during general use
    /// of a component. These messages should not contain sensitive information.
    ///
    /// Examples:
    ///     - Failed network request
    ///     - Missing required configuration
    ///     - Out of memory events
    ///     - Exceptions being thrown
	///
	/// - Parameter messages: The message or messages to log
	func error(_ messages: String...)

}



