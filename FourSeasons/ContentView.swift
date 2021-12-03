//
//  ContentView.swift
//  FourSeasons
//
//  Created by Sabina Huseynova on 03.12.21.
//

import SwiftUI

/// A particle emitter that creates a series of `ParticleView` instances for individual particles.
struct EmitterView: View {
    /// A pair of values representing the before and after state for a given piece of particle data
    private struct ParticleState<T> {
        var start: T
        var end: T
        
        init(_ start: T, _ end: T) {
            self.start = start
            self.end = end
        }
    }
    
    /// One particle in the emitter
    private struct ParticleView: View {
        /// Flip to true to move this particle between its start and end state
        @State var isActive: Bool = false
        
        let image: Image
        let position: ParticleState<CGPoint>
        let opacity: ParticleState<Double>
        let scale: ParticleState<CGFloat>
        let rotation: ParticleState<Angle>
        let color: Color
        let animation: Animation
        let blendMode: BlendMode
        
        var body: some View {
            image
                .colorMultiply(color)
                .blendMode(blendMode)
                .opacity(isActive ? opacity.end : opacity.start)
                .scaleEffect(isActive ? scale.end : scale.start)
                .rotationEffect(isActive ? rotation.end : rotation.start)
                .position(isActive ? position.end : position.start)
                .onAppear {
                    withAnimation(self.animation) {
                        self.isActive = true
                    }
                }
        }
    }
    
    var images: [String]
    var particleCount = 100
    
    var creationPoint = UnitPoint.center
    var creationRange = CGSize.zero
    
    var colors = [Color.white]
    
    var alpha: Double = 1
    var alphaRange: Double = 0
    var alphaSpeed: Double = 0
    
    var angle = Angle.zero
    var angleRange = Angle.zero
    
    var rotation = Angle.zero
    var rotationRange = Angle.zero
    var rotationSpeed = Angle.zero
    
    var scale: CGFloat = 1
    var scaleRange: CGFloat = 0
    var scaleSpeed: CGFloat = 0
    
    var speed = 50.0
    var speedRange = 0.0
    
    var animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    var animationDelayThreshold = 0.0
    
    var blendMode = BlendMode.normal
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<self.particleCount, id: \.self) { i in
                    ParticleView(
                        image: Image(self.images.randomElement()!),
                        position: self.position(in: geo),
                        opacity: self.makeOpacity(),
                        scale: self.makeScale(),
                        rotation: self.makeRotation(),
                        color: self.colors.randomElement() ?? .white,
                        animation: self.animation.delay(Double.random(in: 0...self.animationDelayThreshold)),
                        blendMode: self.blendMode
                    )
                }
            }
        }
    }
    
    private func position(in proxy: GeometryProxy) -> ParticleState<CGPoint> {
        let halfCreationRangeWidth = creationRange.width / 2
        let halfCreationRangeHeight = creationRange.height / 2
        
        let creationOffsetX = CGFloat.random(in: -halfCreationRangeWidth...halfCreationRangeWidth)
        let creationOffsetY = CGFloat.random(in: -halfCreationRangeHeight...halfCreationRangeHeight)
        
        let startX = (proxy.size.width * (creationPoint.x + creationOffsetX))
        let startY = (proxy.size.height * (creationPoint.y + creationOffsetY))
        let start = CGPoint(x: startX, y: startY)
        
        let halfSpeedRange = speedRange / 2
        let actualSpeed  = Double.random(in: speed - halfSpeedRange...speed + halfSpeedRange)
        
        let halfAngleRange = angleRange.radians / 2
        let totalRange = Double.random(in: angle.radians - halfAngleRange...angle.radians + halfAngleRange)
        
        let finalX = cos(totalRange - .pi / 2) * actualSpeed
        let finalY = sin(totalRange - .pi / 2) * actualSpeed
        let end = CGPoint(x: Double(startX) + finalX, y: Double(startY) + finalY)
        
        return ParticleState(start, end)
    }
    
    private func makeOpacity() -> ParticleState<Double> {
        let halfAlphaRange = alphaRange / 2
        let randomAlpha = Double.random(in: -halfAlphaRange...halfAlphaRange)
        return ParticleState(alpha + randomAlpha, alpha + alphaSpeed + randomAlpha)
    }
    
    private func makeScale() -> ParticleState<CGFloat> {
        let halfScaleRange = scaleRange / 2
        let randomScale = CGFloat.random(in: -halfScaleRange...halfScaleRange)
        return ParticleState(scale + randomScale, scale + scaleSpeed + randomScale)
    }
    
    private func makeRotation() -> ParticleState<Angle> {
        let halfRotationRange = (rotationRange / 2).degrees
        let randomRotation = Double.random(in: -halfRotationRange...halfRotationRange)
        let randomRotationAngle = Angle(degrees: randomRotation)
        return ParticleState(rotation + randomRotationAngle, rotation + rotationSpeed + randomRotationAngle)
    }
}

struct ContentView: View {
    @State private var particleMode = 0
    @State private var pulsate = false
    let modes = [ "Winter", "Spring", "Summer", "Autumn"]
    
    var body: some View {
        VStack {
            ZStack {
                if particleMode == 0 {
                    // winter
                    ZStack {
                        HStack {
                            ForEach(0..<2){_ in
                                ZStack {
                                    Capsule()
                                        .foregroundColor(.gray)
                                        .frame(width: 180, height: 70)
                                        .shadow(color: .gray, radius: 30, x: 0, y: 1)
                                        .scaleEffect(pulsate ? 1 : 1.2)
                                    Circle()
                                        .foregroundColor(.gray)
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .gray, radius: 30, x: 0, y: 1)
                                        .scaleEffect(pulsate ? 1 : 1.2)
                                }
                            }.position(x: 100, y: 100)
                        }
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1), value: pulsate)
                        .onAppear() {
                            self.pulsate.toggle()
                        }
                        EmitterView(images: ["snowFlake"], particleCount: 100, creationPoint: .init(x: 0.5, y: -0.1), creationRange: CGSize(width: 1, height: 0), colors: [.gray], alphaRange: 1, angle: Angle(degrees: 180), angleRange: Angle(degrees: 10), scale: 0.4, scaleRange: 0.4, speed: 1200, speedRange: 1200, animation: Animation.linear(duration: 5).repeatForever(autoreverses: false), animationDelayThreshold: 5)
                        Spacer()
                        Image("winter")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300, alignment: .center)
                            .cornerRadius(300)
                        Spacer()
                    }
                } else if particleMode == 1 {
                    // spring
                    ZStack {
                        Circle()
                            .foregroundColor(.yellow)
                            .frame(width: 200, height: 100)
                            .position(x: 70, y: 90)
                            .shadow(color: .yellow, radius: 30, x: 0, y: 1)
                            .scaleEffect(pulsate ? 1 : 1.2)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1), value: pulsate)
                            .onAppear() {
                                self.pulsate.toggle()
                            }
                        EmitterView(images: ["spark"], particleCount: 100, creationRange: CGSize(width: 1, height: 1), colors: [.yellow, .white, .purple], alphaSpeed: -1, angleRange: .degrees(360), scale: 0.5, scaleRange: 0.2, scaleSpeed: -0.2, speed: 120, speedRange: 120, animation: Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), animationDelayThreshold: 1)
                        Spacer()
                        
                        Image("spring")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300, alignment: .center)
                            .cornerRadius(300)
                        Spacer()
                    }
                } else if particleMode == 2 {
                    // summer
                    ZStack {
                        Circle()
                            .foregroundColor(.yellow)
                            .frame(width: 200, height: 100)
                            .position(x: 70, y: 70)
                            .shadow(color: .yellow, radius: 30, x: 0, y: 1)
                            .scaleEffect(pulsate ? 1 : 1.2)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1), value: pulsate)
                            .onAppear() {
                                self.pulsate.toggle()
                            }
                        EmitterView(images: ["confetti"], particleCount: 50, creationPoint: .init(x: 0.5, y: -0.1), creationRange: CGSize(width: 1, height: 0), colors: [.red, .yellow, .blue, .green, .white, .orange, .purple], angle: Angle(degrees: 180), angleRange: Angle(radians: .pi / 4), rotationRange: Angle(radians: .pi * 2), rotationSpeed: Angle(radians: .pi), scale: 0.6, speed: 1200, speedRange: 800, animation: Animation.linear(duration: 5).repeatForever(autoreverses: false), animationDelayThreshold: 5)
                        Spacer()
                        Image("summer")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300, alignment: .center)
                            .cornerRadius(300)
                        Spacer()
                    }
                } else if particleMode == 3 {
                    // autumn
                    ZStack {
                        HStack {
                            ForEach(0..<2){_ in
                                ZStack {
                                    Capsule()
                                        .foregroundColor(.gray)
                                        .frame(width: 180, height: 70)
                                        .shadow(color: .gray, radius: 30, x: 0, y: 1)
                                        .scaleEffect(pulsate ? 1 : 1.2)
                                    Circle()
                                        .foregroundColor(.gray)
                                        .frame(width: 150, height: 100)
                                        .shadow(color: .gray, radius: 30, x: 0, y: 1)
                                        .scaleEffect(pulsate ? 1 : 1.2)
                                    
                                }
                            }.position(x: 100, y: 100)
                        }
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1), value: pulsate)
                        .onAppear() {
                            self.pulsate.toggle()
                        }
                        EmitterView(images: ["line"], particleCount: 100, creationPoint: .init(x: 0.5, y: -0.1), creationRange: CGSize(width: 1, height: 0), colors: [Color(red: 0.8, green: 0.8, blue: 1)], alphaRange: 1, angle: Angle(degrees: 180), scale: 0.6, speed: 1000, speedRange: 400, animation: Animation.linear(duration: 1).repeatForever(autoreverses: false), animationDelayThreshold: 1)
                        Spacer()
                        
                        Image("autumn")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300, alignment: .center)
                            .cornerRadius(300)
                        Spacer()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.scale)
            
            Picker("Select a mode", selection: $particleMode) {
                ForEach(0..<modes.count) { mode in
                    Text(self.modes[mode])
                }.animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: [modes])
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
