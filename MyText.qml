import QtQuick 2.3
import QtQuick.Controls 2.15
import QtMultimedia 6.5
//import QtQuick.Controls 1.4
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Extras 1.4
import QtQuick.Window 2.0



Rectangle {
    visible: true
    id: root
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height
    anchors.fill: parent
    color: "white"

    property int arr: 0//hud_id.arr
    property int gear : 0
    property int arr_bat: 0
    property int arr_temp: 0
    property int steering: 0
    property int lastSteering: 0
    property int indicatorCode: 0
    property int lastIndicatorCode: 0
    property bool leftIndicatorActive: false
    property bool rightIndicatorActive: false
    property bool indicatorBlinkOn: false
    property int indicatorDurationMs: 8000
    property int indicatorBlinkMs: 500
    property real indicatorGapPx: 2
    property int speedAlertThreshold: 48
    property bool speedAlertActive: false
    property bool speedAlertBlinkOn: false
    property int speedAlertBlinkMs: 500
    //property int arr: 0
    property double ref: 0.01//hud_id.ref
    property double ref_bat: 0.01
    property double ref_temp: 0.01
    //property double ref: 0.01
    property int icons: 0
    Timer{
        id:trip_timer
        repeat: true
        interval:2500
        running: true

        onTriggered: {
            text_trip_A.trip_A++;
            distance.total++;
        }
    }

    Timer{
        id: timer_speed
        repeat: true
        interval:25
        running: true

        onTriggered: {
            ///if(progress1.speed >= ref  && progress1.speed < ref+ 0.01 ) {
                arr = can_speed.sendSpeed()
              //  console.log("mytext-val======mjb======="+arr)
                ref = arr/100
                //console.log("ref--======mjb======="+ref)
            //}
            progress1.speed = ref
            speedAlertActive = arr > speedAlertThreshold
            //if(progress1.speed < ref)
            //    progress1.speed = progress1.speed + 0.01
            //else if(progress1.speed > ref)
            //    progress1.speed = progress1.speed - 0.01
        }
    }
    Timer{
        id: timer_steering
        repeat: true
        interval:200
        running: true

        onTriggered: {
            steering = can_speed.sendSteering()
            if (steering !== lastSteering) {
                lastSteering = steering
                console.log("steering-wheel="+steering)
            }
        }
    }
    Timer{
        id: timer_indicator
        repeat: true
        interval:100
        running: true

        onTriggered: {
            indicatorCode = can_speed.sendIndicator()
            if (indicatorCode !== lastIndicatorCode) {
                if (indicatorCode === 292) {
                    if (rightIndicatorActive) {
                        rightIndicatorActive = false
                        leftIndicatorActive = false
                        indicatorBlinkOn = false
                        blink_timer.stop()
                        duration_timer.stop()
                    } else {
                        rightIndicatorActive = true
                        leftIndicatorActive = false
                        indicatorBlinkOn = true
                        blink_timer.restart()
                        duration_timer.restart()
                    }
                } else if (indicatorCode === 293) {
                    if (leftIndicatorActive) {
                        leftIndicatorActive = false
                        rightIndicatorActive = false
                        indicatorBlinkOn = false
                        blink_timer.stop()
                        duration_timer.stop()
                    } else {
                        leftIndicatorActive = true
                        rightIndicatorActive = false
                        indicatorBlinkOn = true
                        blink_timer.restart()
                        duration_timer.restart()
                    }
                }
                lastIndicatorCode = indicatorCode
            }
        }
    }
    Timer{
        id: blink_timer
        repeat: true
        interval: indicatorBlinkMs
        running: leftIndicatorActive || rightIndicatorActive

        onTriggered: {
            indicatorBlinkOn = !indicatorBlinkOn
        }
        onRunningChanged: {
            if (!running) {
                indicatorBlinkOn = false
            }
        }
    }
    Timer{
        id: duration_timer
        repeat: false
        interval: indicatorDurationMs
        onTriggered: {
            leftIndicatorActive = false
            rightIndicatorActive = false
            lastIndicatorCode = 0
        }
    }
    Timer{
        id: speed_alert_blink_timer
        repeat: true
        interval: speedAlertBlinkMs
        running: speedAlertActive
        onTriggered: {
            speedAlertBlinkOn = !speedAlertBlinkOn
        }
        onRunningChanged: {
            if (!running) {
                speedAlertBlinkOn = false
            }
        }
    }
    Timer{
        id: timer_gear
        repeat: true
        interval:25
        running: true

        onTriggered: {
            gear = can_speed.sendgear()
           //  console.log("Gear Num"+gear)
        }
    }

    Timer{
        id: timer_battery
        repeat: true
        interval:100
        running: true

        onTriggered: {
            //battery
            if(progress3.temp >= ref_bat  && progress3.temp < ref_bat+ 0.01 ) {
                arr_bat = can_speed.sendTemp()
                //console.log("val======mjb_arr_bat======="+arr_bat)
                ref_bat = arr_bat/50
                //console.log("ref--======mjb_ref_bat======="+ref_bat)
            }
            if(progress3.temp < ref_bat)
                progress3.temp = progress3.temp + 0.01
            else if(progress3.temp > ref_bat)
                progress3.temp = progress3.temp - 0.01

            //temperature
            if(progress4.temp >= ref_temp  && progress4.temp < ref_temp+ 0.01 ) {
                arr_temp = can_speed.sendFuel()
                //console.log("val======mjb_temp======="+arr_temp)
                ref_temp = arr_temp/100
                //console.log("ref--======mjb_temp======="+ref_temp)
            }
            if(progress4.temp < ref_temp)
                progress4.temp = progress4.temp + 0.01
            else if(progress4.temp > ref_temp)
                progress4.temp = progress4.temp - 0.01
        }
    }

    Timer{
        id: id_timer_1
        repeat: true
        interval:2000
        running: true
        onTriggered: {
            icons = can_speed.sendIcon()
            engine_oil_icon.eng = icons & 1
            battery_icon.bat = icons & 2
            child_lock_icon.childlock = icons & 4
            seat_belt_icon.seat = icons & 8
            head_light.light = icons & 16
            tyre_pressure_icon.tyre = icons & 32
            glowing_bulb.bulb = icons & 64            
            parking_icon.parking = icons & 128
            car.door = can_speed.sendDoor()
        }
    }

    Image {
        id: white
        width: root.width  //1024
        height: root.height  //600
        source: "images_2/back_rect.png"
        //fillMode: Image.PreserveAspectFit
    }
    Image {
        id: group_34
        x: -2
        y: root.height*0.1583//95
        width: root.width//1024
        height: root.height*0.4083//245
        source: "images_2/group_34.png"
       // fillMode: Image.PreserveAspectFit
    }
    Image {
        id: bg
        width: root.width//1024
        height: root.height//600
        source: "images_2/bg.png"
       // fillMode: Image.PreserveAspectFit
    }
    Image {
        property int door: 0
        id: car
        x: root.width*0.1718//176
        y: root.height*0.6666//400
        width: root.width*0.3857 //395
        height: root.height*0.2216//133
        source: door == 1 ? "images/door_1.png" : door == 2 ? "images/door_2.png" : door == 3 ? "images/doors_3.png" : door == 4 ? "images/door_4.png" : door == 8 ? "images/door_8.png" : door == 14 ? "images/doors_14.png" : door == 15 ? "images/doors_15.png" : "images_2/car.png"
        fillMode: Image.PreserveAspectFit

        TextEdit {
            property int total: 86669
            id: distance
            x: car.width*0.3468//137
            y: car.height*0.9646//109
            width: car.width*0.2 //79
            height: car.height*0.1503//20
            text: qsTr("Total ") + total + qsTr(" Kms")
            font.pixelSize: car.height*0.1130 //15
            font.family: "Verdana"
        }
    }
    Image {
        id: car_front_sceeen
        x: root.width*0.3232//331
        y: root.height*0.6416 //385
        width: root.width*0.0820//84
        height: root.height*0.1033 //62
        source: "images_2/car_front_sceeen.png"
        fillMode: Image.PreserveAspectFit
    }
    Image {
        id: line111
        x: root.width*0.1289//132
        y: root.height*0.0283 //17
        width: root.width*0.0664//68
        height: root.height*0.12 //72
        source: "images_2/line 11.png"
        fillMode: Image.PreserveAspectFit
    }
    Image {
        id: left_indicator
        x: gear_num.x - width - (root.width * 0.01)
        y: gear_num.y - height - (root.height * 0.01)
        width: root.width * 0.07
        height: root.height * 0.08
        source: "cluser_demo_images/left_sgl.png"
        visible: leftIndicatorActive && indicatorBlinkOn
        fillMode: Image.PreserveAspectFit
    }
    Image {
        id: right_indicator
        x: gear_num.x + width
        y: gear_num.y - height - (root.height * 0.01)
        width: root.width * 0.07
        height: root.height * 0.08
        source: "cluser_demo_images/right_sgl.png"
        mirror: false
        visible: rightIndicatorActive && indicatorBlinkOn
        fillMode: Image.PreserveAspectFit
    }
    Popup {
        id: speed_alert_popup
        modal: false
        focus: false
        x: root.width - width - (root.width * 0.05)
        y: root.height * 0.02
        width: root.width * 0.2
        height: root.height * 0.08
        closePolicy: Popup.NoAutoClose
        visible: speedAlertActive && speedAlertBlinkOn

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "transparent"
            border.width: 0
            radius: 6
        }

        Text {
            text: "\u26A0 Over speed"
            color: "red"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.height * 0.5
            font.bold: true
        }
    }
    Image {
        id: music_1
        width: root.width * 0.1719 //176
        height: root.height * 0.1484 //89
        x: root.width * 0.8067 //826
        y: root.height * 0.42 //251
        source: "images_2/stitches.png"
    }
    Image {
        id: music_2
        width: root.width * 0.137 //140
        height: root.height * 0.1 //60
        x: root.width * 0.842 //862
        y: root.height * 0.57 //341
        source: "images_2/cold_play.png"
    }
    /*Image {
        id: rectangle
        x: root.width * 0.7393//757
        y: root.height * 0.11//66
        width: root.width * 0.2393 //245
        height: root.height * 0.2584
        source: "images_2/rect_59.png"

        Text {
            id: textEdit
            width: rectangle.width * 0.5 // 775//117
            height: rectangle.height * 0.155//24
            x: rectangle.width/2 - width/2 //69
            y: rectangle.height * 0.72 //112
            color: "black"
            text: qsTr("4th Main road")
            opacity: 0.8
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            font.pointSize: rectangle.height * 0.07 //5
        }

        Text{
            id: textEdit1
            width: rectangle.width * 0.28 // 1//59
            height: rectangle.height * 0.194//30
            x: rectangle.width/2 - width/2 //98
            y: rectangle.height * 0.555 //86
            color: "black"
            text: qsTr("300m")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            font.pixelSize: rectangle.height * 0.1 //10
        }
        Image {
            id: arrow
            width: rectangle.width * 0.21 //51.5
            height: rectangle.height * 0.471 //73
            x: rectangle.width/2 - width/2 //83
            y: rectangle.height * 0.052 //8
            source: "images_2/arrow_left.png"
        }
    }*/
    Rectangle {
        id: rectangle
        x: root.width * 0.7393
        y: root.height * 0.11
        width: root.width * 0.2393
        height: root.height * 0.2584
        radius: 8
        clip: true
        visible: gear === -1

        Camera {
            id: cameraObj
            active: true
        }
        CaptureSession{
           id:capturesession
           camera:cameraObj
           videoOutput:videoOutput
        }

        VideoOutput {
                   id: videoOutput
                   anchors.fill: parent
                   fillMode: VideoOutput.PreserveAspectCrop
                   visible: gear === -1
               }

        // Optional overlay text (can remove if not needed)
        Text {
            text: "Back Camera"
            color: "white"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height * 0.08
            opacity: 0.7
        }
    }

    Image {
        id: cloud
        x: root.width*0.1767//181
        y: root.height*0.04//24
        width: root.width*0.0453//55
        height: root.height*0.0916//55
        source: "images_2/cloud.png"
        //fillMode: Image.PreserveAspectFit
    }
    Text {
        id: time_text
        //text: qsTr("17.25")
        x: root.width * 0.0557 //57
        y: root.height * 0.0443 //26
        width: root.width * 0.0811 //83
        height: root.height * 0.09 //54
        color: "black"
        font.pixelSize: root.height * 0.05 //16
        text: Qt.formatTime(new Date(),"hh:mm")

        Timer {
            id: timer
            interval: 1000
            repeat: true
            running: true
            triggeredOnStart: true

            onTriggered:
            {
                time_text.text = Qt.formatTime(new Date(),"hh:mm")
            }
        }
    }
    Text {
        id: weather_report
        text: qsTr("27\xB0C, Partly Cloudy  ") // + arr
        x: root.width * 0.2383 //244
        y: root.height * 0.07 //42
        width: root.width * 0.184 //188
        height: root.height * 0.05 //30
        color: "black"
        font.pixelSize: root.height * 0.037 //10
    }

    Image {
        id: line_2
        x: root.width*-0.1308 //-134
        y: root.height*0.3233//194
        width: root.width*0.4804 //492
        height: root.height*1.1733//704
        source: "images_2/Line_2.png"
        fillMode: Image.PreserveAspectFit
        }

    Image {
        id: line_3
        x: root.width*0.3886 //398
        y: root.height*0.2066 //124
        width: root.width*0.2929 //300
        height: root.height*0.8466//508
        source: "images_2/Line_3.png"
        fillMode: Image.PreserveAspectFit
        }


    Image {
        id: rect_131
        x: root.width*0.6875//704
        y: root.height*0.8433//506
        width:root.width*0.1191//122
        height: root.height*0.1666//100
        source: "images_2/Rect_131.png"
        fillMode: Image.PreserveAspectFit

            TextEdit {
                id: textEdit10
                x: rect_131.width*0.1557//19
                y: rect_131.height*0.31//31
                width: rect_131.width*0.6557//80
                height: rect_131.height*0.2//20
                text: "Trip B"
                font.pixelSize: height * 0.322258 //10
                font.weight: Font.ExtraLight
                font.family: "Verdana"
            }

            TextEdit {
                id: textEdit11
                x: rect_131.width*0.4508//55
                y: rect_131.height*0.31//31
                width: rect_131.width*0.6557//80
                height: rect_131.height*0.2//20
                text: qsTr("1225 Kms")
                font.pixelSize: height * 0.322258 //10
                font.weight: Font.ExtraLight
                font.family: "Verdana"
            }
        }

    Text {
        id: gear_num
        x: root.width*0.3296//395
        y: root.height*0.2433//146
        width: root.width * 0.22
        height: root.height * 0.16
        text: gear === 0 ? "N" : (gear === -1 ? "R" : gear)
        color: "black"
        font.pixelSize: root.height * 0.11
    }
    Text {
        id: gear_label
        x: gear_num.x
        y: gear_num.y + gear_num.font.pixelSize * 0.95
        width: gear_num.width
        height: gear_num.height
        text: "Gear"
        color: "black"
        font.pixelSize: root.height * 0.04
    }

    Image {
            id: rpm_circle
            x: root.width*0.3856//395
            y: root.height*0.2433//146
            width: root.height*0.49//root.width*0.2871//294
            height: root.height*0.49//294
            source: "images_2/Ellipse_38.png"
            fillMode: Image.PreserveAspectFit

        Image {
            id: rpm_arc
            //x: rpm_circle.width*0.1
            x: rpm_circle.width*0.1 //496//44
            y: rpm_circle.height*0.1020//30
            width: rpm_circle.width*0.8166//240
            height: rpm_circle.height*0.8166//240
            source: "images/rpm_arc.png"
            fillMode: Image.PreserveAspectFit
        }
        ArcProgressBar {
                    id: progress2
                    property double temp: 0.01
                    x: rpm_circle.width*0.1 //422
                    y: rpm_circle.height*0.1020 //180
                    value: progress1.value //progress2.temp
                    start_angle_val: 130
                    end_angle_val:-260
                    move:true
                    size: rpm_circle.width*0.8166 //240
                    width: rpm_circle.width*0.8166 //240
                    height: rpm_circle.width*0.8166
                    primaryColor: "#a5ecb4" //"#00ff00"64D483//a5ecb4
                    lineWidth: height * 0.085 //20
                    //secondaryColor: "#00ff00"//"#e0e0e0"
                    //"#00ff00"//"#29b6f6"

                    Text {
                        color: "#516e57"
                        text: parseInt(progress1.value * 10000/2)+qsTr("RPM")
                        anchors.centerIn: parent
                        font.pointSize: 20
                    }
        }
    }

    Image {
        id: battery_above
        width: root.width * 0.01751 //17.93
        height: root.height * 0.0317 //19
        x: root.width * 0.5812 //595
        y: root.height * 0.795 //477
        source: "images_2/Battery.png"
    }
    Image {
        id: temp
        width: root.width * 0.0167 //17
        height: root.height * 0.0284 //17
        x: root.width * 0.55947 //572.89
        y: root.height * 0.7684 //461.37
        source: "images_2/temperature.png"
    }
    Image {
        id: fuel_bar
        width: root.width * 0.101 //10254 //105
        height: root.height * 0.22165 //133
        x: root.width * 0.61 //72 //632
        y: root.height * 0.5865 //352
        source: "images_2/fuel_bar.png"
        //fillMode: Image.PreserveAspectFit
    }
    Image {
        id: temp_bar
        width: root.width * 0.1101 //1153 //118
        height: root.height * 0.19835 //119
        x: root.width *  0.58 //0.585 //599
        y: root.height * 0.5867 //352
        source: "images_2/temp_bar.png"
        //fillMode: Image.PreserveAspectFit
    }

    Image {
            id: rect_71
             x: root.width*0.6503//666
             y: root.height*0.7616//457
             width: root.width*0.1933//198
             height: root.height*0.155//93
             source: "images_2/Rect_71.png"
             fillMode: Image.PreserveAspectFit

                TextEdit {
                        id: textEdit12
                        x: rect_71.width*0.1575//26
                        y: rect_71.height*0.2625//21
                        width:rect_71.width*0.4848 //80
                        height: rect_71.height*0.25//20
                        text: qsTr("Trip A")
                        font.pixelSize: height * 0.71428 //15
                    }

                TextEdit {
                    property int trip_A: 60
                        id: text_trip_A
                        x: rect_71.width*0.4545//75
                        y: rect_71.height*0.2625//21
                        width: rect_71.width*0.4848//80
                        height: rect_71.height*0.25//20
                        text: trip_A + qsTr(" Kms")
                        font.pixelSize: height * 0.71428 //15
                        //font.family: "Verdana"
                    }
              }


    Image {
            id: vector_10
            x: root.width*0.1298//133
            y: root.height*0.9//540
            width: root.width*0.4863//498
            height: root.height*0.1316//79
            source: "images_2/Vector_10.png"
            fillMode: Image.PreserveAspectFit

            Image {
                property bool eng: false
                id: engine_oil_icon
                x: vector_10.width*0.0963//48
                y: vector_10.height*0.3924//31
                width: vector_10.width*0.0682//34
                height: vector_10.height*0.1898//15
                //source: "images_2/Petrol_fill.png"
                source: eng == false ? "images_2/Petrol_fill.png" : "images/engine_oil_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool bat: false
                id: battery_icon
                x: vector_10.width*0.2108//105
                y: vector_10.height*0.3670//29
                width: vector_10.width*0.0522//26
                height: vector_10.height*0.2278//18
                source: bat == false ? "images_2/Battery.png" : "images/battery_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool childlock: false
                id: child_lock_icon
                x: vector_10.width*0.3172//158
                y: vector_10.height*0.3417//27
                width: vector_10.width*0.0441//22
                height: vector_10.height*0.2658//21
                source: childlock == false ? "images_2/childlock.png" : "images/childlock_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool parking: false
                id: parking_icon
                x: vector_10.width*0.4156//207
                y: vector_10.height*0.3670//29
                width: vector_10.width*0.0562//28
                height: vector_10.height*0.2405////19
                source: parking == false ? "images_2/Parking.png" :"images/parking_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool light: false
                id: head_light
                x: vector_10.width*0.5261//262
                y: vector_10.height*0.3797//30
                width: vector_10.width*0.0502//25
                height: vector_10.height*0.2658//21
                source: light == false ? "images_2/lowbeam_on.png" :"images/highbeam_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool tyre: false
                id: tyre_pressure_icon
                x: vector_10.width*0.6305//314
                y: vector_10.height*0.3797//30
                width: vector_10.width*0.0421//21
                height: vector_10.height*0.2658//21
                source: tyre == false ?  "images_2/unknown.png" : "images/tyre_pressure_icon_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool bulb: false
                id: glowing_bulb
                x: vector_10.width*0.7269//362
                y: vector_10.height*0.3670//29
                width: vector_10.width*0.0401//20
                height: vector_10.height*0.2658//21
                source: bulb == false ? "images_2/gowing_bulb.png" : "images/bulb_on_red.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                property bool seat: false
                id: seat_belt_icon
                x: root.width*0.3974//407
                y: root.height*0.045//27
                width: root.width*0.0205//21
                height: root.height*0.0383//23
                source: seat == false ? "images_2/seatbelt.png" : "images/seatbelt_red.png"
                fillMode: Image.PreserveAspectFit
            }
        }

    Image {
        id: ellipse_45
        x: root.width*0.0263//27
        y: root.height*0.2433//145
        width: root.height*0.49 //root.width*0.2871//294
        height: root.height*0.49 //294
        source: "images_2/Ellipse_45.png"
        fillMode: Image.PreserveAspectFit

        Image {
            id: speed_arc
            x: ellipse_45.width*0.1 //340//10
            y: ellipse_45.height*0.1020//28
            width: ellipse_45.width*0.8166//240
            height: ellipse_45.height*0.8166//240
            source: "images/speed_arc.png"
            fillMode: Image.PreserveAspectFit
        }
        ArcProgressBar {
                    id: progress1
                    property double speed: 0.01
                    x: ellipse_45.width*0.1//61328 //36
                    y: ellipse_45.height*0.1020//833 //180
                    value: progress1.speed
                    start_angle_val: 50
                    end_angle_val:260
                    size: ellipse_45.width*0.8166 //240
                    width: ellipse_45.width*0.8166 //240
                    height: ellipse_45.width*0.8166 //240
                    lineWidth: height * 0.085
                    //secondaryColor: "#00ff00"//"#e0e0e0"
                    primaryColor: "#a5ecb4" //"#00ff00"64D483//a5ecb4

                    Text {
                        color: "#516e57"
                        text: parseInt(progress1.value * 250)+qsTr("Kmph")
                        anchors.centerIn: parent
                        font.pointSize: 20
                    }
        }

      }

    ArcProgressBar {
                id: progress3
                property double temp: 0.01
                x: root.width * 0.4561 //467
                y: root.height * 0.36834 //221
                value: progress3.temp
                start_angle_val: 84
                end_angle_val:-80
                move:true
                size: root.height * 0.4167 //250
                width: root.height * 0.4167 //250
                height: root.height * 0.4167 //250
                lineWidth: height * 0.0365 // 9
                //secondaryColor: "#00ff00"//"#e0e0e0"
                primaryColor: "#a5ecb4" //"#00ff00"//"#29b6f6"
    }
    ArcProgressBar {
                id: progress4
                property double temp: 0.01
                x: root.width * 0.4756 //487
                y: root.height * 0.395 //237
                value: progress4.temp
                start_angle_val: 78.5
                end_angle_val:-80
                move:true
                size: root.height * 0.4167 //250
                width: root.height * 0.4167 //250
                height: root.height * 0.4167 //250
                lineWidth: height * 0.0365 // 9
                //secondaryColor: "#00ff00"//"#e0e0e0"
                primaryColor: "#a5ecb4" //"#00ff00"//"#29b6f6"
    }
    
}
