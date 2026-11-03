//
//  MassSpectrumView.swift
//  Organic Games
//
//  A stick mass spectrum: m/z across, relative abundance up, the important peaks labelled with their mass.
//  Black on white like a printed spectrum, in light and dark mode.
//

import SwiftUI

struct MassSpectrumView: View {
    let compound: MSCompound
    var showHighlight = false

    var body: some View {
        let peaks = compound.peaks
        let maxMZ = Double((compound.mass + 12 + 19) / 20 * 20)    // a little past M+2, rounded up to 20
        Canvas { context, size in
            let label = max(9, min(13, size.width / 34))
            // Room above for peak labels, at the right for the last axis number
            let frame = CGRect(x: label * 2.6, y: label * 2.8, width: size.width - label * 5.2, height: size.height - label * 5.6)
            func x(_ mz: Double) -> CGFloat { frame.minX + CGFloat(mz / maxMZ) * frame.width }
            func y(_ i: Double) -> CGFloat { frame.maxY - CGFloat(i / 100) * frame.height }

            // Faint gridlines and abundance labels
            for level in stride(from: 25.0, through: 100, by: 25) {
                var line = Path()
                line.move(to: CGPoint(x: frame.minX, y: y(level)))
                line.addLine(to: CGPoint(x: frame.maxX, y: y(level)))
                context.stroke(line, with: .color(.black.opacity(0.12)), lineWidth: 0.5)
                if level.truncatingRemainder(dividingBy: 50) == 0 {
                    context.draw(Text(verbatim: String(Int(level))).font(.system(size: label)).foregroundStyle(.black),
                                 at: CGPoint(x: frame.minX - 4, y: y(level)), anchor: .trailing)
                }
            }

            if showHighlight {
                for mz in compound.giveaway where mz > 0 {
                    let rect = CGRect(x: x(Double(mz)) - 6, y: frame.minY, width: 12, height: frame.height)
                    context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(.orange.opacity(0.3)))
                }
            }

            // Sticks
            for p in peaks {
                var stick = Path()
                stick.move(to: CGPoint(x: x(Double(p.mz)), y: frame.maxY))
                stick.addLine(to: CGPoint(x: x(Double(p.mz)), y: y(p.intensity)))
                context.stroke(stick, with: .color(.black), lineWidth: 2)
            }

            // Mass labels: always M⁺, a visible M+2 (stacked above M⁺'s label) and 127; then the tallest other
            // peaks, skipping any that would crowd a label already placed.
            let byMZ = Dictionary(uniqueKeysWithValues: peaks.map { ($0.mz, $0) })
            var placed: [CGFloat] = []
            func put(_ p: MSPeak, lift: CGFloat = 0) {
                // A taller peak right next to this one would run through a centred label: move it to the other side
                let tallerLeft = peaks.contains { $0.mz < p.mz && p.mz - $0.mz <= 2 && $0.intensity > p.intensity }
                let tallerRight = peaks.contains { $0.mz > p.mz && $0.mz - p.mz <= 2 && $0.intensity > p.intensity }
                let anchor: UnitPoint = tallerLeft ? .bottomLeading : (tallerRight ? .bottomTrailing : .bottom)
                let dx: CGFloat = tallerLeft ? 3 : (tallerRight ? -3 : 0)
                context.draw(Text(verbatim: String(p.mz)).font(.system(size: label, weight: .semibold)).foregroundStyle(.black),
                             at: CGPoint(x: x(Double(p.mz)) + dx, y: y(p.intensity) - 2 - lift), anchor: anchor)
                placed.append(x(Double(p.mz)))
            }
            if let m = byMZ[compound.mass] { put(m) }
            if let m2 = byMZ[compound.mass + 2], m2.intensity >= 2 {
                let m = byMZ[compound.mass]?.intensity ?? 0
                put(m2, lift: m2.intensity > m - 12 ? label * 1.1 : 0)   // M and M+2 sit close: stack when level
            }
            if let i = byMZ[127], compound.atom == .iodine { put(i) }
            for p in peaks.sorted(by: { $0.intensity > $1.intensity }) where p.intensity >= 25 {
                let px = x(Double(p.mz))
                if placed.contains(where: { abs($0 - px) < label * 2.4 }) { continue }
                put(p)
            }

            // Axes
            var axes = Path()
            axes.move(to: CGPoint(x: frame.minX, y: frame.minY))
            axes.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
            axes.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
            context.stroke(axes, with: .color(.black), lineWidth: 1)
            let step = maxMZ > 160 ? 40.0 : 20.0
            for mz in stride(from: 0.0, through: maxMZ, by: step) {
                var tick = Path()
                tick.move(to: CGPoint(x: x(mz), y: frame.maxY))
                tick.addLine(to: CGPoint(x: x(mz), y: frame.maxY + 4))
                context.stroke(tick, with: .color(.black), lineWidth: 1)
                context.draw(Text(verbatim: String(Int(mz))).font(.system(size: label)).foregroundStyle(.black),
                             at: CGPoint(x: x(mz), y: frame.maxY + 5), anchor: .top)
            }
            context.draw(Text("m/z").font(.system(size: label).italic()).foregroundStyle(.black),
                         at: CGPoint(x: frame.midX, y: frame.maxY + 6 + label * 1.3), anchor: .top)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .accessibilityElement()
        .accessibilityLabel("Mass spectrum, molecular ion at m/z \(compound.mass)")
    }
}
