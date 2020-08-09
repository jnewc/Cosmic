import Foundation


/// Describes a logging level used for filtering
/// output based on severity
public enum LogLevel: UInt {
    
    
	/// Debug logs capture information useful for debugging
    /// development builds of the calling library or application
	case debug  = 0b0001
    
	/// Info logs capture contextual information about the current 
    /// execution state for monitoring in production builds
	case info	= 0b0011
    
	/// Warning logs capture potential issues or known weaknesses
    /// in the calling library or application
	case warn	= 0b0111
    
	/// Error logs capture unrecoverable issues in the calling
    /// library or application
	case error	= 0b1111
    
    /// No logs are captured
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

    /// The Syslog severity value
    /// See: https://tools.ietf.org/html/rfc5424#section-6.2.1
    var syslogSeverity: Int {
        switch self {
        case .debug:    return 7
        case .info:     return 6
        case .warn:     return 4
        case .error:    return 3
        case .none:     return 0
        }
    }
}
