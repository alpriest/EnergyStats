//
//  Icon.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/04/2024.
//

import SwiftUI

private enum IconStyle {
    static let darkLineColor = Color.gray
    static let lineWidth = 8.0
}

struct _DarkIconView: View {
    var body: some View {
        VStack {
            darkBody()
                .frame(width: 512, height: 512, alignment: .center)

            Spacer()

            Button {
                saveImage(self.asImage(), fileName: "dark-icon.png")
            } label: {
                Text(String(stringLiteral: "Save Image"))
            }
        }
    }

    func darkBody() -> some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                let widthPoint = proxy.size.width/100
                let heightPoint = proxy.size.height/100

                ZStack(alignment: .center) {
                    darkBackground()

                    horizontalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: IconStyle.lineWidth, lineCap: CGLineCap.round))
                        .foregroundStyle(IconStyle.darkLineColor)

                    verticalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: IconStyle.lineWidth, lineCap: CGLineCap.round))
                        .foregroundStyle(IconStyle.darkLineColor)

                    rightFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(IconStyle.darkLineColor)

                    leftFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(IconStyle.darkLineColor)

                    downFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(IconStyle.darkLineColor)

                    upFacingArrow(pointWidth: widthPoint, pointHeight: heightPoint)
                        .fill(IconStyle.darkLineColor)

                    sunOuterRing(outerWidthPoint: widthPoint)

                    sunInnerCircle(outerWidthPoint: widthPoint, fillStyle: Gradient(colors: [Color.yellow, Color.yellow, Color.orange]))

                    sunShimmerLine(widthPoint: widthPoint, heightPoint: heightPoint)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }

    func darkBackground() -> some View {
        Rectangle()
            .fill(Color.black.gradient)
    }
}

struct _MonochromeIconView: View {
    var body: some View {
        VStack {
            monoChromeBody()
                .frame(width: 512, height: 512, alignment: .center)

            Spacer()

            Button {
                saveImage(self.asImage(), fileName: "monochrome-icon.png")
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

                    sunInnerCircle(outerWidthPoint: widthPoint, fillStyle: Color.black)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct _IconView: View {
    var body: some View {
        VStack {
            sunBody()
                .frame(width: 512, height: 512, alignment: .center)

            Spacer()

            Button {
                saveImage(self.asImage(), fileName: "icon.png")
            } label: {
                Text(String(stringLiteral: "Save Image"))
            }
        }
    }

    func sunBody() -> some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                let widthPoint = proxy.size.width/100
                let heightPoint = proxy.size.height/100

                ZStack(alignment: .center) {
                    lightBackground()

                    horizontalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: IconStyle.lineWidth, lineCap: CGLineCap.round))
                        .foregroundStyle(Color.white)

                    verticalLines(pointWidth: widthPoint, pointHeight: heightPoint)
                        .stroke(style: StrokeStyle(lineWidth: IconStyle.lineWidth, lineCap: CGLineCap.round))
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

                    sunInnerCircle(outerWidthPoint: widthPoint, fillStyle: Gradient(colors: [Color.yellow, Color.yellow, Color.orange]))

                    sunShimmerLine(widthPoint: widthPoint, heightPoint: heightPoint)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }

    func lightBackground() -> some View {
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
}

private func sunShimmerLine(widthPoint: CGFloat, heightPoint: CGFloat) -> some View {
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

private func sunInnerCircle<S>(outerWidthPoint: CGFloat, fillStyle: S) -> some View where S: ShapeStyle {
    Group {
        Circle()
            .fill(fillStyle)
    }
    .frame(width: outerWidthPoint * 40)
    .rotationEffect(Angle(degrees: 280))
}

private func sunOuterRing(outerWidthPoint: CGFloat) -> some View {
    Circle()
        .fill(Color.white)
        .frame(width: outerWidthPoint * 50, alignment: .center)
}

private func horizontalLines(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()
    for y in 0 ... 3 {
        path.addLines([
            CGPoint(x: pointWidth * 3, y: pointHeight * (CGFloat(y) * 23) + (pointHeight * 15)),
            CGPoint(x: pointWidth * 97, y: pointHeight * (CGFloat(y) * 23) + (pointHeight * 15))
        ])
    }
    return path
}

private func verticalLines(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()
    for x in 1 ... 5 {
        path.addLines([
            CGPoint(x: pointWidth * CGFloat(x * 18) - (pointWidth * 4), y: pointHeight * 3),
            CGPoint(x: pointWidth * CGFloat(x * 18) - (pointWidth * 4), y: pointHeight * 97)
        ])
    }
    return path
}

private func rightFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()

    path.addLines([
        CGPoint(x: pointWidth * 32, y: pointHeight * 15),
        CGPoint(x: pointWidth * 32, y: pointHeight * 84),
        CGPoint(x: pointWidth * 64, y: pointHeight * 50)
    ])

    return path
}

private func leftFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()

    path.addLines([
        CGPoint(x: pointWidth * 68, y: pointHeight * 15),
        CGPoint(x: pointWidth * 68, y: pointHeight * 84),
        CGPoint(x: pointWidth * 36, y: pointHeight * 50)
    ])

    return path
}

private func downFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()

    path.addLines([
        CGPoint(x: pointWidth * 14, y: pointHeight * 38),
        CGPoint(x: pointWidth * 51, y: pointHeight * 60),
        CGPoint(x: pointWidth * 86, y: pointHeight * 38)
    ])

    return path
}

private func upFacingArrow(pointWidth: CGFloat, pointHeight: CGFloat) -> Path {
    var path = Path()

    path.addLines([
        CGPoint(x: pointWidth * 14, y: pointHeight * 61),
        CGPoint(x: pointWidth * 51, y: pointHeight * 40),
        CGPoint(x: pointWidth * 86, y: pointHeight * 61)
    ])

    return path
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

struct WelcomeLogoView: View {
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    HStack {
                        Text(verbatim: "E")
                        Spacer()
                    }
                    .foregroundStyle(Color("background_inverted").opacity(0.3))
                    .font(.system(size: 430, weight: .bold))

                    HStack {
                        Spacer()
                        Text(verbatim: "S")
                    }
                    .foregroundStyle(Color("background_inverted").opacity(0.3))
                    .font(.system(size: 418, weight: .bold))
                }
                .frame(width: 390)
            }

            Button {
                saveImage(self.asImage(), fileName: "es-icon.png")
            } label: {
                Text(String(stringLiteral: "Save Image"))
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            //        _IconView()
            _DarkIconView()
            //        _MonochromeIconView()
        }
    }
}
