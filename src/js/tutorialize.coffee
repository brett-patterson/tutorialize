loader = (root, factory) ->
    if typeof define == 'function' && define.amd
        define(['jquery'], factory);
    else if typeof exports == 'object'
        module.exports = factory(require('jquery'));
    else
        root.Tutorialize = factory(root.jQuery);

loader this, ($) ->
   return class Tutorialize
        constructor: (tutorial, options) ->
            defaultOptions =
                interactive: false
                arrows:
                    weight: 1
                    color: 'white'
                    distance: 80
                backdrop: true
                closable: true
                annotationPadding: 10
                counter: true

            @tutorial = tutorial
            @options = $.extend true, defaultOptions, options
            @currentIndex = -1
            @container = null
            @backdrop = null
            @canvas = null
            @counter = null

        start: () =>
            if @options.backdrop
                @backdrop = $('<div/>', {
                    class: 'tutorial-backdrop'
                }).appendTo $ 'body'

            @container = $('<div/>', {
                class: 'tutorial-container'
            }).appendTo $ 'body'

            if @options.counter
                @counter = $('<div/>', {
                    class: 'tutorial-panel-counter'
                }).appendTo @container

            if @options.interactive
                @container.click @next
                $(document).keydown @changePageOnKeyDown

            if @options.closable and not @options.interactive
                @container.click @end

            if @options.closable
                @container.append($('<a/>', {
                    class: 'tutorial-close'
                    html: '&#10006;'
                }).click @end)

                $(document).keydown @closeOnKeyDown

            @canvas = $('<canvas/>', {
                class: 'tutorial-canvas'
            }).appendTo(@container)
            .attr('width', @container.width())
            .attr('height', @container.height())[0]

            @showPanelAtIndex 0

        end: () =>
            @container.off 'click', @next
            $(document).off 'keydown', @changePageOnKeyDown
            $(document).off 'keydown', @closeOnKeyDown

            @container.remove()
            @backdrop?.remove()
            $(@canvas).remove()
            $('body').find('.tutorial-show-element')
                .removeClass 'tutorial-show-element'

            @currentIndex = -1
            @container = null
            @canvas = null

        updateCounter: () =>
            @counter?.text "#{ @currentIndex + 1 } / #{ @tutorial.length }"

        showPanel: (panel) =>
            @container.find('.tutorial-message, .tutorial-annotation').remove()
            $('body').find('.tutorial-show-element')
                .removeClass 'tutorial-show-element'
            @canvas.getContext('2d').clearRect 0, 0, @canvas.width, @canvas.height

            for annotation in panel
                annotationElement = $('<div/>', {
                    class: 'tutorial-annotation'

                }).append($('<p/>', {
                    class: 'tutorial-annotation-text'
                    html: annotation.text
                })).appendTo @container

                element = $ annotation.selector
                element.addClass 'tutorial-show-element'

                if !annotation.noBackground
                    element.addClass 'tutorial-show-element-background'

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
            @updateCounter()

        changePageOnKeyDown: (e) =>
            switch e.which
                when 37
                    @prev()
                when 39
                    @next()

        closeOnKeyDown: (e) =>
            if e.which == 27
                @end()

        next: () =>
            if -1 < @currentIndex < @tutorial.length - 1
                @showPanelAtIndex @currentIndex + 1
            else
                @end()

        prev: () =>
            if @tutorial.length > @currentIndex > 0
                @showPanelAtIndex @currentIndex - 1
