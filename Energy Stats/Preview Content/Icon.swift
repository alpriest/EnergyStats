//
//  Icon.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2024.
//

import SwiftUI

struct _IconView: View {
    var body: some View {
        VStack {
            monoChromeBody()
                .frame(width: 108, height: 108, alignment: .center)

//            sunBody()
//                .frame(width: 512, height: 512, alignment: .center)

            Button {
                saveImage(self.asImage(), fileName: "icon.png")
            } label: {
                Text(String(stringLiteral: "Save Image"))
            }
        }
    }

    func monoChromeBody() -> some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                let widthPoint = proxy.size.width/100
                let heightPoint = proxy.size.height/100

                ZStack(alignment: .center) {
                    Color.white

                    rightFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.black)

                    leftFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.black)

                    downFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.black)

                    upFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.black)

                    sunOuterRing(outerWidthPoint: widthPoint)

                    sunInnerRing(outerWidthPoint: widthPoint, color: false)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    func sunBody() -> some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                let widthPoint = proxy.size.width/100
                let heightPoint = proxy.size.height/100

                ZStack(alignment: .center) {
                    background()

                    horizontalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: CGLineCap.round))
                        .foregroundStyle(Color.white)

                    verticalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: CGLineCap.round))
                        .foregroundStyle(Color.white)

                    rightFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.white)

                    leftFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.white)

                    downFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.white)

                    upFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(Color.white)

                    sunOuterRing(outerWidthPoint: widthPoint)

                    sunInnerRing(outerWidthPoint: widthPoint, color: true)

                    sunShimmerLine(widthPoint: widthPoint, heightPoint: heightPoint)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }

    func sunShimmerLine(widthPoint: CGFloat, heightPoint: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(stops: [
                    Gradient.Stop(color: Color.white.opacity(0.4), location: 0.1),
                    Gradient.Stop(color: Color.white, location: 1.0)
                ],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1.0, y: 1.0))
            )
            .frame(width: widthPoint * 12, height: heightPoint * 50)
            .rotationEffect(Angle(degrees: 40))
            .opacity(0.4)
            .offset(x: -5, y: -5)
            .mask {
                Circle()
                    .frame(width: widthPoint * 50, height: heightPoint * 50)
            }
    }

    func sunInnerRing(outerWidthPoint: CGFloat, color: Bool) -> some View {
        Group {
            if color {
                Circle()
                    .fill(Gradient(colors: [Color.yellow, Color.yellow, Color.orange]))
            } else {
                Circle()
                    .fill()
            }
        }
        .frame(width: outerWidthPoint * 40)
        .rotationEffect(Angle(degrees: 280))
    }

    func sunOuterRing(outerWidthPoint: CGFloat) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: outerWidthPoint * 50, alignment: .center)
    }

    func background() -> some View {
        Rectangle()
            .fill(
                LinearGradient(stops: [
                    Gradient.Stop(color: Color(red: 27/256, green: 50/256, blue: 100/256), location: 0.0),
                    Gradient.Stop(color: Color.teal, location: 0.5),
                    Gradient.Stop(color: Color(red: 27/256, green: 50/256, blue: 100/256), location: 1.0)
                ],
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1))
            )
    }

    func horizontalLines(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()
        for y in 0 ... 3 {
            path.addLines([
                CGPoint(x: pointWidth * 3, y: pointHeight * (CGFloat(y) * 23) + (pointHeight * 15)),
                CGPoint(x: pointWidth * 97, y: pointHeight * (CGFloat(y) * 23) + (pointHeight * 15))
            ])
        }
        return path
    }

    func verticalLines(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()
        for x in 0 ... 5 {
            path.addLines([
                CGPoint(x: pointWidth * CGFloat(x * 18) - (pointWidth * 4), y: pointHeight * 3),
                CGPoint(x: pointWidth * CGFloat(x * 18) - (pointWidth * 4), y: pointHeight * 97)
            ])
        }
        return path
    }

    func rightFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()

        path.addLines([
            CGPoint(x: pointWidth * 32, y: pointHeight * 15),
            CGPoint(x: pointWidth * 32, y: pointHeight * 84),
            CGPoint(x: pointWidth * 64, y: pointHeight * 50)
        ])

        return path
    }

    func leftFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()

        path.addLines([
            CGPoint(x: pointWidth * 68, y: pointHeight * 15),
            CGPoint(x: pointWidth * 68, y: pointHeight * 84),
            CGPoint(x: pointWidth * 36, y: pointHeight * 50)
        ])

        return path
    }

    func downFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()

        path.addLines([
            CGPoint(x: pointWidth * 14, y: pointHeight * 38),
            CGPoint(x: pointWidth * 51, y: pointHeight * 60),
            CGPoint(x: pointWidth * 86, y: pointHeight * 38)
        ])

        return path
    }

    func upFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
        var path = Path()

        path.addLines([
            CGPoint(x: pointWidth * 14, y: pointHeight * 61),
            CGPoint(x: pointWidth * 51, y: pointHeight * 40),
            CGPoint(x: pointWidth * 86, y: pointHeight * 61)
        ])

        return path
    }
}

private extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    func saveImage(_ image: UIImage, fileName: String) {
        guard let data = image.pngData() else { return }
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = directory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            print("Image saved to: \(fileURL)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
}

#Preview {
    _IconView()
}
