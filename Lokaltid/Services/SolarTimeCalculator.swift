import Foundation

/// Resultat frå soltidsutrekning
struct SolarTime {
    let date: Date
    let offsetSeconds: Double
    
    var offsetMinutes: Double {
        offsetSeconds / 60.0
    }
    
    var offsetHours: Double {
        offsetSeconds / 3600.0
    }
    
    var offsetFormatted: String {
        let totalSeconds = abs(Int(offsetSeconds))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let sign = offsetSeconds >= 0 ? "+" : "-"
        return String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
    }
}

/// Bereknar soltid basert på geografisk posisjon
/// Bruker lokaltid Rust-biblioteket via FFI
class SolarTimeCalculator {
    
    /// Bereknar soltid for gitt posisjon og tid
    /// Bruker lokaltid-biblioteket for presis berekningar
    static func calculate(for location: Location, at date: Date = Date()) -> SolarTime {
        do {
            // Kall Rust-biblioteket via FFI
            let timestamp = Int64(date.timeIntervalSince1970)
            let result = try calculateSolarTimeForLocation(
                latitude: location.latitude,
                longitude: location.longitude,
                unixTimestamp: timestamp
            )
            
            // Rust returnerer unix_timestamp som er UTC + solar_offset
            // Me brukar dette direkte - det representerer soltida
            let solarDate = Date(timeIntervalSince1970: TimeInterval(result.unixTimestamp))
            return SolarTime(date: solarDate, offsetSeconds: result.offsetSeconds)
            
        } catch {
            // Fallback til enkel berekning om noko går gale
            let offsetSeconds = (location.longitude / 15.0) * 3600.0
            let solarDate = date.addingTimeInterval(offsetSeconds)
            return SolarTime(date: solarDate, offsetSeconds: offsetSeconds)
        }
    }
    
    /// Bereknar soltid for noverande tidspunkt
    static func calculateNow(for location: Location) -> SolarTime {
        do {
            // Kall Rust-biblioteket via FFI
            let result = try calculateSolarTimeNow(
                latitude: location.latitude,
                longitude: location.longitude
            )
            
            // Rust returnerer unix_timestamp som er UTC + solar_offset
            let solarDate = Date(timeIntervalSince1970: TimeInterval(result.unixTimestamp))
            return SolarTime(date: solarDate, offsetSeconds: result.offsetSeconds)
            
        } catch {
            // Fallback til enkel berekning
            return calculate(for: location, at: Date())
        }
    }
}
