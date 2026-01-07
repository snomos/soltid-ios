import SwiftUI

struct ContentView: View {
    @State private var viewModel = ClockViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient bakgrunn
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Hovudklokke
                    AnalogClockView(
                        solarTime: viewModel.solarTime,
                        standardTime: viewModel.standardTime,
                        radius: min(geometry.size.width, geometry.size.height) * 0.35
                    )
                    
                    // Forklaring
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Soltid")
                                        .font(.headline)
                                    Text(viewModel.formatTime(viewModel.solarTime, useUTC: true))
                                        .font(.system(.title2, design: .monospaced))
                                }
                            } icon: {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Lokal tid")
                                        .font(.headline)
                                    Text(viewModel.formatTime(viewModel.standardTime, useUTC: false))
                                        .font(.system(.title2, design: .monospaced))
                                }
                            } icon: {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Info om offset og posisjon
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Offset: \(viewModel.solarOffset)")
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Image(systemName: "location.fill")
                                Text(viewModel.locationText)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Info-tekst
                    Text("Soltid: Klokka 12:00 er når sola står i sør")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
