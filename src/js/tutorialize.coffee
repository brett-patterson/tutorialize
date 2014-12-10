class Tutorialize
    constructor: (tutorial, options) ->
        defaultOptions =
            tutorial: []
            interactive: false
            arrows:
                weight: 6
                color: 'white'
            backdrop: true
            exitOnBackgroundClick: false

        @tutorial = tutorial
        @options = $.extend true, defaultOptions, options
        @currentIndex = -1
        @container = null
        @canvas = null

    start: () =>
        if @options.backdrop
            tutorialBg = 'rgba(0, 0, 0, 0.5)'
        else
            tutorialBg = 'none'

        @container = $('<div/>', {
            class: 'tutorial-backdrop'
            css:
                background: tutorialBg
        }).appendTo $ 'body'

        if @options.exitOnBackgroundClick
            @container.click @end

        @container.append($('<a/>', {
            class: 'tutorial-close'
            html: '&#10006;'
        }).click @end)

        @canvas = $('<canvas/>', {
            class: 'tutorial-canvas'
        }).appendTo(@container)
        .attr('width', @container.width())
        .attr('height', @container.height())[0]

        @showPanelAtIndex 0

    end: () =>
        @container.remove()
        $(@canvas).remove()

        @currentIndex = -1
        @container = null
        @canvas = null

    showPanel: (panel) =>
        @container.find('.tutorial-message, .tutorial-annotation').remove()
        @canvas.getContext('2d').clearRect 0, 0, @canvas.width, @canvas.height

        if @options.interactive
            message = $('<div/>', {
                class: 'tutorial-message'
                html: """
                 <div class='tutorial-message-title'>#{ panel.title }</div>
                 <div class='tutorial-message-text'>#{ panel.text }</div>
                """
            }).appendTo(@container)
            .append $('<button/>', {
                class: 'tutorial-message-next'
                text: if @onLastPanel() then 'Finish' else 'Next'
            }).click(@next)

            message.css 'margin-left', message.width() / -2

        for annotation in panel.annotations
            annotationX = annotation.position.x
            annotationY = annotation.position.y

            annotationElement = $('<div/>', {
                class: 'tutorial-annotation'
                css:
                    left: annotationX
                    top: annotationY

            }).append($('<p/>', {
                class: 'tutorial-annotation-text'
                html: annotation.text
            })).appendTo @container

            if annotation.arrow
                elements = $ annotation.selector

                for element in elements
                    element = $ element
                    context = @canvas.getContext '2d'
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

                    context.strokeStyle = @options.arrows.color
                    context.lineWidth = @options.arrows.weight
                    context.stroke()
                    context.closePath()


                    slope = (arrowY2 - arrowY) / (arrowX2 - arrowX)
                    angle = Math.atan(slope)
                    extraDegrees = if arrowX2 > arrowX then 90 else -90
                    angle += extraDegrees * Math.PI / 180;

                    context.beginPath()
                    context.translate(arrowX2, arrowY2)
                    context.rotate(angle)
                    context.moveTo(0, -10)
                    context.lineTo(8, 8)
                    context.lineTo(-8, 8)

                    context.fillStyle = @options.arrows.color
                    context.fill()

                    context.closePath()
                    context.restore()

    showPanelAtIndex: (index) =>
        @currentIndex = index
        @showPanel @tutorial[index]

    onLastPanel: () =>
        return @currentIndex == @tutorial.length - 1

    next: () =>
        if @onLastPanel()
            @end()
        else
            @showPanelAtIndex @currentIndex + 1


(($) ->
    $.tutorialize = (options={}) ->
        tutorial = options.tutorial
        delete options.tutorial

        return new Tutorialize(tutorial, options)
) jQuery
