(($) ->
    defaultOptions =
        tutorial: []
        interactive: false
        arrows:
            weight: 6
            color: 'white'
        backdrop: true

    $.tutorialize = (options={}) ->
        options = $.extend defaultOptions, options
        tutorialize = {
            currentIndex: 0,
            options: options
        }

        tutorial = options.tutorial
        tutorialBg = if options.backdrop then 'rgba(0, 0, 0, 0.5)' else 'none'
        tutorialContainer = $('<div/>', {
            class: 'backdrop'
            css:
                background: tutorialBg
        }).appendTo $ 'body'

        canvas = $('<canvas/>', {
            class: 'tutorial-canvas'
        }).appendTo(tutorialContainer)
        .attr('width', tutorialContainer.width())
        .attr('height', tutorialContainer.height())[0]
        context = canvas.getContext '2d'

        tutorialize.showPanel = (panel) ->
            for annotation in panel
                annotationX = annotation.position.x
                annotationY = annotation.position.y

                annotationElement = $('<div/>', {
                    class: 'annotation'
                    css:
                        left: annotationX
                        top: annotationY

                }).append($('<p/>', {
                    html: annotation.text
                })).appendTo tutorialContainer

                if annotation.arrow
                    elements = $ annotation.selector

                    for element in elements
                        element = $ element
                        context.save()

                        context.beginPath()
                        arrowX = annotationX +
                                 annotationElement.outerWidth() / 2
                        arrowY = annotationY +
                                 annotationElement.outerHeight() / 2
                        context.moveTo arrowX, arrowY

                        arrowX2 = element.offset().left + element.width() / 2
                        arrowY2 = element.offset().top + element.height() / 2
                        context.lineTo arrowX2, arrowY2

                        context.strokeStyle = options.arrows.color
                        context.lineWidth = options.arrows.weight
                        context.stroke()
                        context.closePath()


                        slope = (arrowY2 - arrowY) / (arrowX2 - arrowX)
                        angle = Math.atan(slope)
                        extraDegrees = if arrowX2 > arrowX then 90 else -90
                        angle +=  extraDegrees * Math.PI / 180;

                        context.beginPath()
                        context.translate(arrowX2, arrowY2)
                        context.rotate(angle)
                        context.moveTo(0, -10)
                        context.lineTo(8, 8)
                        context.lineTo(-8, 8)

                        context.fillStyle = options.arrows.color
                        context.fill()

                        context.closePath()
                        context.restore()

        tutorialize.showPanelAtIndex = (index) ->
            this.showPanel tutorial[index]
            this.currentIndex = index

        tutorialize.start = () ->
            this.showPanelAtIndex 0

        return tutorialize
) jQuery
