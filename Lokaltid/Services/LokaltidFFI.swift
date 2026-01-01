import Foundation

// MARK: - Errors

public enum LokaltidError: Error {
    case invalidCoordinate
}

// MARK: - Data Types

public struct MobileSolarTime {
    public let timeString: String
    public let offsetSeconds: Double
    public let offsetMinutes: Double
    public let offsetHours: Double
    public let offsetFormatted: String
    public let unixTimestamp: Int64
    
    public init(timeString: String, offsetSeconds: Double, offsetMinutes: Double, 
                offsetHours: Double, offsetFormatted: String, unixTimestamp: Int64) {
        self.timeString = timeString
        self.offsetSeconds = offsetSeconds
        self.offsetMinutes = offsetMinutes
        self.offsetHours = offsetHours
        self.offsetFormatted = offsetFormatted
        self.unixTimestamp = unixTimestamp
    }
}

// MARK: - FFI Bindings

// Desse funksjonane må kallast inn til Rust-biblioteket
// For no lagar me ei Swift-basert implementasjon som placeholder

/// Calculate solar time for a specific location and timestamp
public func calculateSolarTimeForLocation(
    latitude: Double,
    longitude: Double,
    unixTimestamp: Int64
) throws -> MobileSolarTime {
    // Valider koordinatar
    guard latitude >= -90 && latitude <= 90 else {
        throw LokaltidError.invalidCoordinate
    }
    guard longitude >= -180 && longitude <= 180 else {
        throw LokaltidError.invalidCoordinate
    }
    
    // Berekn offset basert på lengdegrad
    // 15° = 1 time (3600 sekund), 1° = 4 minutt (240 sekund)
    let offsetSeconds = (longitude / 15.0) * 3600.0
    let offsetMinutes = offsetSeconds / 60.0
    let offsetHours = offsetSeconds / 3600.0
    
    // Formater offset
    let totalSeconds = abs(Int(offsetSeconds))
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    let sign = offsetSeconds >= 0 ? "+" : "-"
    let offsetFormatted = String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
    
    // Berekn soltid
    let solarTimestamp = unixTimestamp + Int64(offsetSeconds)
    let date = Date(timeIntervalSince1970: TimeInterval(solarTimestamp))
    
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let timeString = formatter.string(from: date)
    
    return MobileSolarTime(
        timeString: timeString,
        offsetSeconds: offsetSeconds,
        offsetMinutes: offsetMinutes,
        offsetHours: offsetHours,
        offsetFormatted: offsetFormatted,
        unixTimestamp: solarTimestamp
    )
}

/// Calculate solar time for current time
public func calculateSolarTimeNow(
    latitude: Double,
    longitude: Double
) throws -> MobileSolarTime {
    let now = Int64(Date().timeIntervalSince1970)
    return try calculateSolarTimeForLocation(
        latitude: latitude,
        longitude: longitude,
        unixTimestamp: now
    )
}
