import Foundation
import Observation

/// ViewModel som handterer tidsoppdateringar og soltidsberekningar
@Observable
class ClockViewModel {
    private var timer: Timer?
    
    let locationManager = LocationManager()
    
    var standardTime = Date()
    var solarTime = Date()
    var solarOffset: String = ""
    var locationText: String = "Ventar på posisjon..."
    
    init() {
        locationManager.requestPermission()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    /// Start timer som oppdaterer kvar sekund
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimes()
        }
        updateTimes() // Initial oppdatering
    }
    
    /// Stopp timeren
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Oppdater begge tidene
    private func updateTimes() {
        standardTime = Date()
        
        guard let location = locationManager.location else {
            solarTime = standardTime
            solarOffset = "Ventar på GPS..."
            return
        }
        
        // Berekn soltid
        let result = SolarTimeCalculator.calculateNow(for: location)
        solarTime = result.date
        
        // Berekn offset mellom soltid (vist i UTC) og lokal tid (vist i lokal tidssone)
        // Me må samanlikna time-of-day verdiane i deira respektive tidssoner
        let calendar = Calendar.current
        let utcTimeZone = TimeZone(secondsFromGMT: 0)!
        let localTimeZone = TimeZone.current
        
        // Hent time/minutt/sekund for soltid (i UTC)
        let solarComponents = calendar.dateComponents(in: utcTimeZone, from: solarTime)
        let solarHour = solarComponents.hour ?? 0
        let solarMinute = solarComponents.minute ?? 0
        let solarSecond = solarComponents.second ?? 0
        
        // Hent time/minutt/sekund for lokal tid (i lokal tidssone)
        let standardComponents = calendar.dateComponents(in: localTimeZone, from: standardTime)
        let standardHour = standardComponents.hour ?? 0
        let standardMinute = standardComponents.minute ?? 0
        let standardSecond = standardComponents.second ?? 0
        
        // Berekn offset i sekund basert på klokkeslett som blir vist
        let solarTotalSeconds = solarHour * 3600 + solarMinute * 60 + solarSecond
        let standardTotalSeconds = standardHour * 3600 + standardMinute * 60 + standardSecond
        let offsetInSeconds = solarTotalSeconds - standardTotalSeconds
        
        let totalSeconds = abs(offsetInSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        let sign = offsetInSeconds >= 0 ? "+" : "-"
        solarOffset = String(format: "%@%02d:%02d:%02d", sign, hours, minutes, seconds)
        
        // Formater posisjon
        locationText = String(format: "%.4f°, %.4f°", 
                             location.latitude, 
                             location.longitude)
    }
    
    /// Formater tid for visning
    /// - Parameter date: Datoen som skal formaterast
    /// - Parameter useUTC: Om tida skal visast i UTC (for soltid) eller lokal tidssone (for standardtid)
    func formatTime(_ date: Date, useUTC: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if useUTC {
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return formatter.string(from: date)
    }
    
    /// Formater dato for visning
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
