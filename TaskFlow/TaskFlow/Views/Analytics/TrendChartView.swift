//
//  TrendChartView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 23/8/26.
//

import SwiftUI
import Charts

struct TrendChartView: View {
    let data: [ChartDataPoint]
    let level: ChartLevel
    var onBarTap: (ChartDataPoint) -> Void
    var onPinchZoomOut: () -> Void
    var body: some View {
        Chart{
            ForEach(data) { point in
                LineMark(
                    x: .value("Period", point.label),
                    y: .value("Tasks", point.tasksValue),
                    series: .value("Series", "Tasks")
                )
                .foregroundStyle(Color.accentPrimary)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .symbol {
                    Circle()
                        .fill(Color.accentPrimary)
                        .frame(width: 6, height: 6)
                }
                
                // MARK: - Habit % Line (এখন সব level এ দেখাবে)
                LineMark(
                    x: .value("Period", point.label),
                    y: .value("Habit %", point.habitValue),
                    series: .value("Series", "Habit")
                )
                .foregroundStyle(Color.success)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .symbol {
                    Circle()
                        .fill(Color.success)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis{
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.textSecondary)
                
            }
        }
        .frame(height: 180)
        .chartOverlay{ proxy in
            GeometryReader{ geo in
                Rectangle()
                    .fill(Color.clear)
                    .gesture(
                        // Tab kore drill-down (just 7-month view te kj kore)
                        SpatialTapGesture()
                            .onEnded { value in
                                guard level == .sevenMonth else { return }
                                guard let label: String = proxy.value(atX: value.location.x) else { return }
                                if let tapped = data.first(where: { $0.label == label }) {
                                    onBarTap(tapped)
                                }
                            }
                    )
                    .gesture(
                        // Pinch করে zoom out (bonus gesture)
                        MagnificationGesture()
                            .onEnded { scale in
                                if scale < 1.0 {
                                    onPinchZoomOut()
                                }
                            }
                    )
                
            }
            
        }
    }
}





#Preview("Trend Chart – Seven Months") {
    TrendChartView(
        data: [
            ChartDataPoint(
                label: "Jan",
                tasksValue: 42,
                habitValue: 68,
                referenceDate: Date()
            ),
            ChartDataPoint(
                label: "Feb",
                tasksValue: 55,
                habitValue: 74,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: Date()
                )!
            ),
            ChartDataPoint(
                label: "Mar",
                tasksValue: 48,
                habitValue: 71,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -2,
                    to: Date()
                )!
            ),
            ChartDataPoint(
                label: "Apr",
                tasksValue: 72,
                habitValue: 82,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -3,
                    to: Date()
                )!
            ),
            ChartDataPoint(
                label: "May",
                tasksValue: 64,
                habitValue: 78,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -4,
                    to: Date()
                )!
            ),
            ChartDataPoint(
                label: "Jun",
                tasksValue: 86,
                habitValue: 88,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -5,
                    to: Date()
                )!
            ),
            ChartDataPoint(
                label: "Jul",
                tasksValue: 79,
                habitValue: 91,
                referenceDate: Calendar.current.date(
                    byAdding: .month,
                    value: -6,
                    to: Date()
                )!
            )
        ],
        level: .sevenMonth,
        onBarTap: { point in
            print("Tapped:", point.label)
            print("Date:", point.referenceDate)
        },
        onPinchZoomOut: {
            print("Pinch zoom out")
        }
    )
    .padding()
}
