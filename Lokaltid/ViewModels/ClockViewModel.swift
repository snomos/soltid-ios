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
        solarOffset = result.offsetFormatted
        
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
