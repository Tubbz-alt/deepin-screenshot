import QtQuick 2.1

Canvas {
    id: canvas
    width: parent.width
    height: parent.height

    property bool recording: false
    property string shapeName: "rect"
    property var shapes: []
    property var currenRecordingShape
    property var linewidth: 3
    property color paintColor: "red"

    onPaint: {
        var ctx = canvas.getContext("2d")
        ctx.clearRect(x, y, width, height)
        ctx.strokeStyle = "red"
        for (var i = 0; i < shapes.length; i++) {
            shapes[i].draw(ctx)
        }
    }

    function clickOnPoint(p) {
        for (var i = 0; i < shapes.length; i++) {
            if (shapes[i].selected || shapes[i].reSized) {
                shapes[i].rotateOnPoint(p)
            }
        }

        for (var i = 0; i < shapes.length; i++) {
            if (shapes[i].clickOnPoint(p)){
                var selectedShape = i
            }
        }

        if (selectedShape != null ) {
            for (var i = 0; i < shapes.length && i != selectedShape; i++) {
                shapes[i].selected = false
                shapes[i].reSized = false
            }
            return true
        } else {
            for (var i = 0; i < shapes.length; i++) {
                shapes[i].selected = false
                shapes[i].reSized = false
                shapes[i].rotated = false
            }
            return false
        }
    }
    function resizeOnPoint(p) {
        for (var i = 0; i < shapes.length; i++) {
            if (shapes[i].resizeOnPoint(p)) {
                return true
            }
        }
        return false
    }
    function rotateOnPoint(p) {
        for (var i = 0; i < shapes.length; i++) {
            if (shapes[i].rotateOnPoint(p)) {
                return true
            }
        }
        return false
    }
    Component {
        id: rect_component
        RectangleCanvas {}
    }
    Component {
        id: ellipse_component
        EllipseCanvas {}
    }
    Component {
        id: arrow_component
        ArrowCanvas {}
    }
    Component {
        id: blur_component
        BlurCanvas {}
    }
    Component {
        id: mosaic_component
        MosaicCanvas {}
    }
    MouseArea {
        id: canvasArea
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: {

            if (!canvas.clickOnPoint(Qt.point(mouse.x, mouse.y))) {
                    canvas.recording = true
                    if (canvas.shapeName == "rect") {
                        canvas.currenRecordingShape = rect_component.createObject(canvas, {})

                    }
                    if (canvas.shapeName == "ellipse") {
                        canvas.currenRecordingShape = ellipse_component.createObject(canvas, {})

                    }
                    if (canvas.shapeName == "arrow") {
                        canvas.currenRecordingShape = arrow_component.createObject(canvas, {})
                    }
                    if (canvas.shapeName == "blur") {
                        print("blurblurblurblur")
                        canvas.currenRecordingShape = blur_component.createObject(canvas, {})
                    }
                    if (canvas.shapeName == "mosaic") {
                        canvas.currenRecordingShape = mosaic_component.createObject(canvas, {})
                    }
                    canvas.currenRecordingShape.linewidth = canvas.linewidth
                    canvas.currenRecordingShape.drawColor = canvas.paintColor
                    canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
                    canvas.shapes.push(canvas.currenRecordingShape)
            }
            print("*****")
            canvas.requestPaint()
        }
        onReleased: {
            if (canvas.recording) {
                canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
                canvas.currenRecordingShape.firstDraw = true
                canvas.recording = false
            }

            canvas.requestPaint()
        }

        onPositionChanged: {
            if (canvas.recording) {
                canvas.currenRecordingShape.points.push(Qt.point(mouse.x, mouse.y))
            } else {
                var selectedShape = null,reSizedShape = null,rotatedShape = null
                for (var i = 0; i < canvas.shapes.length; i++) {
                    if (canvas.shapes[i].reSized||drag.active)  reSizedShape = canvas.shapes[i]
                    if (canvas.shapes[i].rotated||drag.active) rotatedShape = canvas.shapes[i]
                    if (canvas.shapes[i].selected||drag.active)  selectedShape = canvas.shapes[i]
                }

                if (selectedShape != null) {
                    selectedShape.handleDrag(Qt.point(mouse.x, mouse.y))
                }
                if (reSizedShape != null) {
                    reSizedShape.handleResize(Qt.point(mouse.x, mouse.y), reSizedShape.clickedKey)
                }
                if (rotatedShape != null) {
                    rotatedShape.handleRotate(Qt.point(mouse.x, mouse.y))
                }
            }
            canvas.requestPaint()
        }
    }


}