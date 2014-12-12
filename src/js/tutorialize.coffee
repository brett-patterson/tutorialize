class Tutorialize
    constructor: (tutorial, options) ->
        defaultOptions =
            tutorial: []
            interactive: false
            arrows:
                weight: 1
                color: 'white'
                distance: 80
            backdrop: true
            closable: true
            annotationPadding: 10

        @tutorial = tutorial
        @options = $.extend true, defaultOptions, options
        @currentIndex = -1
        @container = null
        @canvas = null

    start: () =>
        if @options.backdrop
            tutorialBg = 'rgba(0, 0, 0, 0.8)'
        else
            tutorialBg = 'none'

        @container = $('<div/>', {
            class: 'tutorial-backdrop'
            css:
                background: tutorialBg
        }).appendTo $ 'body'

        if @options.closable and not @options.interactive
            @container.click @end

        if @options.closable
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
        $('body').find('.tutorial-show-element')
            .removeClass 'tutorial-show-element'

        @currentIndex = -1
        @container = null
        @canvas = null

    showPanel: (panel) =>
        @container.find('.tutorial-message, .tutorial-annotation').remove()
        $('body').find('.tutorial-show-element')
            .removeClass 'tutorial-show-element'
        @canvas.getContext('2d').clearRect 0, 0, @canvas.width, @canvas.height

        if @options.interactive
            @container.click(@next)
            $(document).keydown (e) =>
                switch e.which
                    when 37
                        @prev()
                    when 39
                        @next()

        for annotation in panel.annotations
            annotationElement = $('<div/>', {
                class: 'tutorial-annotation'

            }).append($('<p/>', {
                class: 'tutorial-annotation-text'
                html: annotation.text
            })).appendTo @container

            element = $ annotation.selector
            element.addClass 'tutorial-show-element'

            if $.type annotation.arrow == 'object'
                arrowOptions = {}
                $.extend arrowOptions, @options.arrows, annotation.arrow
            else
                arrowOptions = @options.arrows

            annotationPadding = annotation.padding ? @options.annotationPadding

            elOffset = element.offset()            
            switch annotation.position
                when 'top'
                    annotationX = elOffset.left + element.width() / 2 -
                                  annotationElement.width() / 2
                    annotationY = elOffset.top - arrowOptions.distance

                    arrowX = annotationX + annotationElement.width() / 2
                    arrowY = annotationY + annotationElement.height() +
                             annotationPadding

                when 'bottom'
                    annotationX = elOffset.left + element.width() / 2 -
                                  annotationElement.width() / 2
                    annotationY = elOffset.top + element.height() +
                                  arrowOptions.distance

                    arrowX = annotationX + annotationElement.width() / 2
                    arrowY = annotationY - annotationPadding

                when 'left'
                    annotationX = elOffset.left - arrowOptions.distance
                    annotationY = elOffset.top + element.height() / 2 -
                                  annotationElement.height() / 2

                    arrowX = annotationX + annotationElement.width() +
                             annotationPadding
                    arrowY = annotationY + annotationElement.height() / 2

                when 'right'
                    annotationX = elOffset.left + element.width() +
                                  arrowOptions.distance
                    annotationY = elOffset.top + element.height() / 2 -
                                  annotationElement.height() / 2

                    arrowX = annotationX - annotationPadding
                    arrowY = annotationY + annotationElement.height() / 2

            annotationElement.css 'left', annotationX
            annotationElement.css 'top', annotationY

            if annotation.arrow
                context = @canvas.getContext '2d'
                context.save()
                context.strokeStyle = arrowOptions.color
                context.lineWidth = arrowOptions.weight

                context.beginPath()
                context.moveTo arrowX, arrowY

                arrowX2 = elOffset.left + element.width() / 2
                arrowY2 = elOffset.top + element.height() / 2
                context.lineTo arrowX2, arrowY2

                context.stroke()
                context.closePath()
                context.restore()

    showPanelAtIndex: (index) =>
        @currentIndex = index
        @showPanel @tutorial[index]

    onFirstPanel: () =>
        return @currentIndex == 0

    onLastPanel: () =>
        return @currentIndex == @tutorial.length - 1

    next: () =>
        if @onLastPanel()
            @end()
        else
            @showPanelAtIndex @currentIndex + 1

    prev: () =>
        if not @onFirstPanel()
            @showPanelAtIndex @currentIndex - 1

(($) ->
    $.tutorialize = (options={}) ->
        tutorial = options.tutorial
        delete options.tutorial

        return new Tutorialize(tutorial, options)
) jQuery
