//
//  AnimatedBlobBackground.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 3.06.2026.
//

import SwiftUI

struct AnimatedBlobBackground: View {

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.white,
                        Color.blue.opacity(0.08),
                        Color.purple.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                blob(
                    color: .blue,
                    size: geo.size.width * 0.88,
                    x1: -160,
                    y1: -210,
                    x2: 90,
                    y2: -90
                )

                blob(
                    color: .purple,
                    size: geo.size.width * 0.78,
                    x1: 170,
                    y1: -40,
                    x2: -150,
                    y2: 140
                )

                blob(
                    color: .cyan,
                    size: geo.size.width * 0.68,
                    x1: -120,
                    y1: geo.size.height * 0.48,
                    x2: 160,
                    y2: geo.size.height * 0.34
                )

                blob(
                    color: .pink,
                    size: geo.size.width * 0.72,
                    x1: 190,
                    y1: geo.size.height * 0.62,
                    x2: -130,
                    y2: geo.size.height * 0.72
                )

                VStack {
                    Spacer()

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.78),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 230)
                }
                .ignoresSafeArea()
            }
            .blur(radius: 56)
            .saturation(1.25)
            .drawingGroup()
            .onAppear {
                animate = true
            }
        }
    }

    @ViewBuilder
    private func blob(
        color: Color,
        size: CGFloat,
        x1: CGFloat,
        y1: CGFloat,
        x2: CGFloat,
        y2: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.58),
                        color.opacity(0.18),
                        color.opacity(0.02)
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .offset(
                x: animate ? x2 : x1,
                y: animate ? y2 : y1
            )
            .animation(
                .easeInOut(duration: Double.random(in: 13...20))
                .repeatForever(autoreverses: true),
                value: animate
            )
    }
}
