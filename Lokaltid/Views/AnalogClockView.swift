import SwiftUI

/// Ein analog urskive med to sett visarar
struct AnalogClockView: View {
    let solarTime: Date
    let standardTime: Date
    let radius: CGFloat
    let solarCalendar: Calendar
    let standardCalendar: Calendar
    
    init(solarTime: Date, standardTime: Date, radius: CGFloat = 150) {
        self.solarTime = solarTime
        self.standardTime = standardTime
        self.radius = radius
        
        // Soltid skal visast i UTC
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.solarCalendar = utcCalendar
        
        // Standardtid skal visast i lokal tidssone
        self.standardCalendar = Calendar.current
    }
    
    var body: some View {
        ZStack {
            // Bakgrunn og ramme
            Circle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            Circle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 2)
            
            // Timetall
            ForEach(1...12, id: \.self) { hour in
                HourMarker(hour: hour, radius: radius)
            }
            
            // Minuttmarkeringar
            ForEach(0..<60, id: \.self) { minute in
                if minute % 5 != 0 {
                    MinuteMarker(minute: minute, radius: radius)
                }
            }
            
            // Senter-prikk
            Circle()
                .fill(Color.primary)
                .frame(width: 12, height: 12)
            
            // STANDARDTID (gråe visarar) - teiknar desse først så dei er bak
            ClockHands(time: standardTime,
                      calendar: standardCalendar,
                      hourColor: .gray, 
                      minuteColor: .gray.opacity(0.8), 
                      secondColor: .gray.opacity(0.6),
                      radius: radius)
            
            // SOLTID (kvite visarar) - teiknar desse sist så dei er framme
            ClockHands(time: solarTime,
                      calendar: solarCalendar,
                      hourColor: .white, 
                      minuteColor: .white.opacity(0.9), 
                      secondColor: .white.opacity(0.7),
                      radius: radius)
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

/// Visarar for klokka
struct ClockHands: View {
    let time: Date
    let calendar: Calendar
    let hourColor: Color
    let minuteColor: Color
    let secondColor: Color
    let radius: CGFloat
    
    private var hour: Int {
        calendar.component(.hour, from: time)
    }
    
    private var minute: Int {
        calendar.component(.minute, from: time)
    }
    
    private var second: Int {
        calendar.component(.second, from: time)
    }
    
    // Rotasjonsvinklar (0° er oppe, går med klokka)
    private var hourAngle: Angle {
        let hourRotation = Double(hour % 12) * 30.0 // 360/12 = 30° per time
        let minuteRotation = Double(minute) * 0.5   // 30/60 = 0.5° per minutt
        return Angle(degrees: hourRotation + minuteRotation)
    }
    
    private var minuteAngle: Angle {
        let rotation = Double(minute) * 6.0 // 360/60 = 6° per minutt
        return Angle(degrees: rotation)
    }
    
    private var secondAngle: Angle {
        let rotation = Double(second) * 6.0 // 360/60 = 6° per sekund
        return Angle(degrees: rotation)
    }
    
    var body: some View {
        ZStack {
            // Timevisar
            Capsule()
                .fill(hourColor)
                .frame(width: 6, height: radius * 0.5)
                .offset(y: -radius * 0.25)
                .rotationEffect(hourAngle)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Minuttvisar
            Capsule()
                .fill(minuteColor)
                .frame(width: 4, height: radius * 0.7)
                .offset(y: -radius * 0.35)
                .rotationEffect(minuteAngle)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Sekundvisar
            Capsule()
                .fill(secondColor)
                .frame(width: 2, height: radius * 0.8)
                .offset(y: -radius * 0.4)
                .rotationEffect(secondAngle)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 0.5)
        }
    }
}

/// Timemarkering på urskiva
struct HourMarker: View {
    let hour: Int
    let radius: CGFloat
    
    private var angle: Angle {
        Angle(degrees: Double(hour) * 30) // 360/12 = 30° per time
    }
    
    var body: some View {
        VStack {
            Text("\(hour)")
                .font(.system(size: radius * 0.12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .rotationEffect(-angle) // Roter tilbake teksten
        }
        .offset(y: -radius * 0.75)
        .rotationEffect(angle)
    }
}

/// Minutt-markering på urskiva
struct MinuteMarker: View {
    let minute: Int
    let radius: CGFloat
    
    private var angle: Angle {
        Angle(degrees: Double(minute) * 6 - 90) // 360/60 = 6° per minutt
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.3))
            .frame(width: 1, height: radius * 0.04)
            .offset(y: -radius * 0.88)
            .rotationEffect(angle)
    }
}

#Preview("Analog Clock") {
    VStack(spacing: 30) {
        // Eksempel med forskjellige tider
        AnalogClockView(
            solarTime: Date(),
            standardTime: Date().addingTimeInterval(-1200) // 20 min forskjell
        )
        
        Text("Kvit = Soltid | Grå = Standardtid")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding()
}
