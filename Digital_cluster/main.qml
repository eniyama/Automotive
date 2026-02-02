import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 1280
    height: 480
    visible: true
    color: "#0b0b0b"
    title: "Digital Cluster"

    onSpeedChanged: speedoCanvas.requestPaint()

    /* Demo values */
    property int speed: Math.max(0, Math.min(g29.speedKmh, 200))
    property int maxSpeed: 200
    property real fuelLevel: 1.0   // 0.0 → empty, 1.0 → full
    property string gear: "N"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0b0b0b" }
            GradientStop { position: 1.0; color: "#161616" }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 100

            /* ================= SPEEDOMETER ================= */
            Item {
                width: 340
                height: 340

                Canvas {
                    id: speedoCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0,0,width,height)

                        var cx = width/2
                        var cy = height/2
                        var r = 140

                        // Arc
                        ctx.strokeStyle = "#ff3b3b"
                        ctx.lineWidth = 4
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, Math.PI*0.75, Math.PI*2.25)
                        ctx.stroke()

                        // Ticks + numbers
                        for (var i = 0; i <= maxSpeed; i += 20) {
                            var angle = (135 + (i/maxSpeed)*270) * Math.PI/180

                            var x1 = cx + (r-18)*Math.cos(angle)
                            var y1 = cy + (r-18)*Math.sin(angle)
                            var x2 = cx + r*Math.cos(angle)
                            var y2 = cy + r*Math.sin(angle)

                            ctx.strokeStyle = "white"
                            ctx.lineWidth = 3
                            ctx.beginPath()
                            ctx.moveTo(x1,y1)
                            ctx.lineTo(x2,y2)
                            ctx.stroke()

                            ctx.fillStyle = "white"
                            ctx.font = "14px sans-serif"
                            var tx = cx + (r-35)*Math.cos(angle)
                            var ty = cy + (r-35)*Math.sin(angle)
                            ctx.fillText(i.toString(), tx-8, ty+5)
                        }

                        // Needle
                        var needleAngle =
                            (135 + (speed/maxSpeed)*270) * Math.PI/180

                        ctx.strokeStyle = "white"
                        ctx.lineWidth = 5
                        ctx.beginPath()
                        ctx.moveTo(cx, cy)
                        ctx.lineTo(
                            cx + (r-40)*Math.cos(needleAngle),
                            cy + (r-40)*Math.sin(needleAngle)
                        )
                        ctx.stroke()

                        // Center dot
                        ctx.fillStyle = "#ff3b3b"
                        ctx.beginPath()
                        ctx.arc(cx, cy, 6, 0, Math.PI*2)
                        ctx.fill()
                    }
                }
            }

            /* ================= CENTER SPEED ================= */
            Item {
                width: 280
                height: 280

                Text {
                    text: speed
                    anchors.centerIn: parent
                    font.pixelSize: 96
                    font.bold: true
                    color: "#00e5ff"
                }

                Text {
                    text: "km/h"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.verticalCenter
                    anchors.topMargin: 60
                    font.pixelSize: 22
                    color: "white"
                }
            }

            /* ================= CIRCULAR FUEL GAUGE ================= */
            Item {
                width: 260
                height: 260

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()

                        var cx = width / 2
                        var cy = height / 2
                        var r  = 95

                        var startAngle = Math.PI * 0.75
                        var endAngle   = Math.PI * 2.25

                        /* ===== Background arc ===== */
                        ctx.strokeStyle = "#222"
                        ctx.lineWidth = 14
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, startAngle, endAngle)
                        ctx.stroke()

                        /* ===== Fuel arc (color logic fixed) ===== */
                        ctx.strokeStyle =
                            fuelLevel < 0.25 ? "red" :
                            fuelLevel < 0.75 ? "#66ff66" :
                                               "#00cc44"

                        ctx.beginPath()
                        ctx.arc(
                            cx, cy, r,
                            startAngle,
                            startAngle + fuelLevel * (endAngle - startAngle)
                        )
                        ctx.stroke()

                        /* ===== Fuel ticks ===== */
                        var totalTicks = 12

                        for (var i = 0; i <= totalTicks; i++) {
                            var angle = startAngle + (i / totalTicks) * (endAngle - startAngle)

                            var isBigTick =
                                    (i === 0 || i === totalTicks / 2 || i === totalTicks)

                            var tickLength = isBigTick ? 14 : 8
                            ctx.lineWidth  = isBigTick ? 3 : 2
                            ctx.strokeStyle = "white"

                            var x1 = cx + (r - tickLength) * Math.cos(angle)
                            var y1 = cy + (r - tickLength) * Math.sin(angle)
                            var x2 = cx + r * Math.cos(angle)
                            var y2 = cy + r * Math.sin(angle)

                            ctx.beginPath()
                            ctx.moveTo(x1, y1)
                            ctx.lineTo(x2, y2)
                            ctx.stroke()
                        }
                    }
                }

                /* ===== Needle (no overshoot) ===== */
                Rectangle {
                    width: 4
                    height: 80
                    radius: 2
                    color: "red"
                    anchors.centerIn: parent
                    transformOrigin: Item.Bottom
                    rotation: -135 + Math.max(0, Math.min(fuelLevel, 1)) * 270
                }

                /* ===== Center hub ===== */
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#666"
                    anchors.centerIn: parent
                }

                /* ===== Fuel icon ===== */
                Text {
                    text: "⛽"
                    font.pixelSize: 26
                    color: "white"
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 28
                }

                /* ===== E / F labels ===== */
                Text {
                    text: "E"
                    color: "white"
                    font.pixelSize: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "F"
                    color: "white"
                    font.pixelSize: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "FUEL"
                    color: "white"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -8
                }
            }
      }

        /* ================= GEAR INDICATOR ================= */
        Row {
            spacing: 22
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18

            Repeater {
                model: ["R","N","1","2","3","4","5"]
                delegate: Text {
                    text: modelData
                    font.pixelSize: 28
                    font.bold: true
                    color: modelData === gear ? "#00ff88" : "#555"
                }
            }
        }
    }
}
