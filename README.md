# Cosmic

Cosmic is a log reporting framework written in Swift.

## About

Cosmic provides a simple interface to rich logging functionality, including:

+ Pre-configured loggers for many use-cases
+ HTTP and Socket-based loggers for a number of services including Logz.io, Loggly and Papertrail.
+ Formatters for various logging standards including Syslog and JSON.
+ Filtering of logs by class or module

## Installation

Cocoapods:

```bash
pod 'Cosmic', '~> x.y.z'
```

SPM:

```swift
.Package(url: "https://github.com/jnewc/Cosmic", majorVersion: <MAJORVERSION>)
```
## Usage

The simplest way to support a logger in your class is to extend the `DefaultLogReporter` protocol:

```swift
	import Cosmic

 	class MyClass: DefaultLogReporter {
		// ...
	}
```

Extending the `DefaultLogReporter` protocol adds a logger property to your class that can be called to report log messages:

```swift
	func logSomething() {
		// Debug level
		self.logger.debug("Logging something")
		// Info level
		self.logger.info("Logging something")
		// Warn level
		self.logger.warn("Logging something")
		// Error level
		self.logger.error("Logging something")
	}
```

By default the logger provided by LogReporter will be an instance of `PrintLogger` - this can be changed by instead implementing the `LogReporter` protocol and it's `DefaultLoggerType` associated type:

```swift
	class MyClass: LogReporter {

		typealias DefaultLoggerType: Logger = PrintLogger

		// ...
	}
```

Alternatively, if you want to manage loggers yourself, you can simply instantiate them as needed:

```swift
	let myLogger: Logger = PrintLogger()
```

## Extension

You can create your own loggers by implementing the `LogReceiver` protocol:

```swift
	class MyLogger: LogReceiver {

		func onReceive(_ messages: [String], logLevel: LogLevel) {
			// Do something with the log
		}

	}
```

(The `onReceive` method will only be called for valid log levels so you don't need to filter based on log level here.)

You can add formatters in your initialiser:

```swift
	init() {
		formatters.append(SyslogFormatter())
	}
```

And you can format your messages using the `format` method:

```swift
	func onReceive(_ messages: [String], logLevel: LogLevel) {
		messages.forEach { print(format($0)) }
	}
```

## Composing loggers

Cosmic provides `CompositeLogger` for more complex use cases. `CompositeLogger` routes logs to multiple loggers.

The log level of the composite logger is used transitively for all its component loggers.

The example below describes a logger that logs to console, file, and a TCP socket:

```swift
	let printLogger = PrintLogger()
	let memoryLogger = MemoryLogger()
	let socketLogger = SocketLogger(...)

	let logger = CompositeLogger(printLogger, fileLogger, socketLogger)
```

## Filtering loggers

You can filter loggers by adding a `LogFilter` to the `LogFilters.global` cache. The following example excludes all instances of a `Logger` based class called `MyLogger`:

```swift
	let filter = ClassBasedLogFilter()
	filter.excluded.append(MyLogger.self)
	LogFilters.global.addFilter(filter: filter)
```

*NOTE: `included` and `excluded` are mutually exclusive when using `ClassBasedLogFilter`. If both contain types, `included` will be used
and `excluded` will be ignored
