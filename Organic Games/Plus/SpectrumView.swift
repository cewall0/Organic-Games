//
//  SpectrumView.swift
//  Organic Games
//
//  Draws an IR spectrum in the textbook's style: framed plot from 3800 to 600 cm⁻¹, ticks every 200,
//  peaks hanging from the top. Always black on white, like a printed spectrum, in light and dark mode.
//

import SwiftUI

struct SpectrumView: View {
    let spectrum: IRSpectrum
    var showHighlight = false

    private let start = 3800.0, end = 600.0

    var body: some View {
        Canvas { context, size in
            let labelSize = max(9, min(14, size.width / 40))
            let frame = CGRect(x: 6, y: 4, width: size.width - 12, height: size.height - labelSize * 3.2 - 8)
            func x(_ wn: Double) -> CGFloat { frame.minX + CGFloat((start - wn) / (start - end)) * frame.width }
            // Peaks reach down to here, leaving a strip at the bottom for the C=O labels
            let depth = frame.height - labelSize * 1.4

            if showHighlight {
                for range in spectrum.highlight {
                    let rect = CGRect(x: x(range.upperBound), y: frame.minY,
                                      width: x(range.lowerBound) - x(range.upperBound), height: frame.height)
                    context.fill(Path(rect), with: .color(.orange.opacity(0.25)))
                }
            }

            // The curve, one point per pixel column
            var curve = Path()
            let steps = Int(frame.width * 2)
            for i in 0...steps {
                let px = frame.minX + frame.width * CGFloat(i) / CGFloat(steps)
                let wn = start - Double(i) / Double(steps) * (start - end)
                let y = frame.minY + CGFloat(spectrum.absorbance(at: wn)) * depth
                if i == 0 { curve.move(to: CGPoint(x: px, y: y)) } else { curve.addLine(to: CGPoint(x: px, y: y)) }
            }
            context.stroke(curve, with: .color(.black), style: StrokeStyle(lineWidth: 1.4, lineJoin: .round))
            context.stroke(Path(frame), with: .color(.black), lineWidth: 1)

            // C=O peaks are only ~20 cm⁻¹ apart (1705 vs 1725), too close to read off the axis: label each one
            // just below its tip
            for p in spectrum.peaks where (1660...1800).contains(p.center) {   // not the alkene C=C at 1655
                let tip = frame.minY + CGFloat(spectrum.absorbance(at: p.center)) * depth
                context.draw(Text(verbatim: String(Int(p.center))).font(.system(size: labelSize * 0.9, weight: .semibold)).foregroundStyle(.black),
                             at: CGPoint(x: x(p.center), y: tip + 1), anchor: .top)
            }

            // Ticks and labels every 200 cm⁻¹ (labels every 400 when the plot is narrow)
            let labelEvery = size.width < 420 ? 400.0 : 200.0
            for wn in stride(from: start, through: end, by: -200) {
                var tick = Path()
                tick.move(to: CGPoint(x: x(wn), y: frame.maxY))
                tick.addLine(to: CGPoint(x: x(wn), y: frame.maxY + 4))
                context.stroke(tick, with: .color(.black), lineWidth: 1)
                if wn.truncatingRemainder(dividingBy: labelEvery) == 0 {
                    context.draw(Text(verbatim: String(Int(wn))).font(.system(size: labelSize)).foregroundStyle(.black),
                                 at: CGPoint(x: x(wn), y: frame.maxY + 5), anchor: .top)
                }
            }
            context.draw(Text("wavenumber, cm⁻¹").font(.system(size: labelSize)).foregroundStyle(.black),
                         at: CGPoint(x: frame.midX, y: frame.maxY + 7 + labelSize * 1.3), anchor: .top)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .accessibilityElement()
        .accessibilityLabel("IR spectrum")
    }
}

#Preview {
    SpectrumView(spectrum: IRSpectrum.all[0], showHighlight: true)
        .frame(height: 220)
        .padding()
        .background(Color.gray)
}
