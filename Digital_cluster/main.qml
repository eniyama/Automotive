import QtQuick 6.5
import QtQuick.Window 6.5
import QtQuick.Controls 6.5
import QtQuick.Shapes 6.5

Window {
    id: root
    visible: true
    width: 400
    height: 400
    title: "Digital Speedometer2"

    property int speed: Math.max(0, Math.min(g29.speedKmh, 180))

    Rectangle {
        anchors.fill: parent
        color: "#1b1b1b"
        radius: width/2
    }

    // Circular Gauge
    Canvas {
        id: gauge
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.translate(width/2, height/2)
            ctx.lineWidth = 6

            // Draw outer circle
            ctx.strokeStyle = "#444"
            ctx.beginPath()
            ctx.arc(0, 0, width/2 - 20, Math.PI*0.75, Math.PI*0.25, false)
            ctx.stroke()

            // Draw ticks
            for (var i=0; i<=180; i+=20) {
                var angle = Math.PI*0.75 + (i/180) * (Math.PI*1.5)
                var x1 = Math.cos(angle) * (width/2 - 20)
                var y1 = Math.sin(angle) * (height/2 - 20)
                var x2 = Math.cos(angle) * (width/2 - 40)
                var y2 = Math.sin(angle) * (height/2 - 40)
                ctx.strokeStyle = "#aaa"
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()

                // Draw numbers along the arc
                ctx.fillStyle = "#00ffcc"
                ctx.font = "bold 14px Arial"
                var nx = Math.cos(angle) * (width/2 - 55) - 10
                var ny = Math.sin(angle) * (height/2 - 55) + 5
                ctx.fillText(i.toString(), nx, ny)
            }
        }
    }

    // Needle
    Rectangle {
        id: needle
        width: 4
        height: gauge.width/2 - 60
        color: "red"
        radius: 2
        anchors.centerIn: gauge
        transform: Rotation {
            origin.x: needle.width/2
            origin.y: needle.height
            angle: 225 + (g29.speedKmh / 180) * 270 // 0 km/h at bottom-left
        }
    }

    // Digital speed number
    Text {
        text: g29.speedKmh + " km/h"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: needle.bottom
        font.pixelSize: 24
        color: "#00ffcc"
        font.bold: true
    }

    // Optional: center circle
    Rectangle {
        anchors.centerIn: gauge
        width: 12
        height: 12
        radius: 6
        color: "#fff"
    }
}
