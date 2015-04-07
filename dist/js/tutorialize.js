// Generated by CoffeeScript 1.7.1
var loader,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

loader = (function(_this) {
  return function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery'], factory);
    } else if (typeof exports === 'object') {
      return module.exports = factory(require('jquery'));
    } else {
      return root.Tutorialize = factory(root.jQuery);
    }
  };
})(this);

loader(this, (function(_this) {
  return function($) {
    var Tutorialize;
    return Tutorialize = (function() {
      function Tutorialize(tutorial, options) {
        _this.prev = __bind(_this.prev, this);
        _this.next = __bind(_this.next, this);
        _this.closeOnKeyDown = __bind(_this.closeOnKeyDown, this);
        _this.changePageOnKeyDown = __bind(_this.changePageOnKeyDown, this);
        _this.showPanelAtIndex = __bind(_this.showPanelAtIndex, this);
        _this.showPanel = __bind(_this.showPanel, this);
        _this.updateCounter = __bind(_this.updateCounter, this);
        _this.end = __bind(_this.end, this);
        _this.start = __bind(_this.start, this);
        var defaultOptions;
        defaultOptions = {
          interactive: false,
          arrows: {
            weight: 1,
            color: 'white',
            distance: 80
          },
          backdrop: true,
          closable: true,
          annotationPadding: 10,
          counter: true
        };
        this.tutorial = tutorial;
        this.options = $.extend(true, defaultOptions, options);
        this.currentIndex = -1;
        this.container = null;
        this.backdrop = null;
        this.canvas = null;
        this.counter = null;
      }

      Tutorialize.prototype.start = function() {
        if (this.options.backdrop) {
          this.backdrop = $('<div/>', {
            "class": 'tutorial-backdrop',
            css: {
              background: 'rgba(0, 0, 0, 0.8)'
            }
          }).appendTo($('body'));
        }
        this.container = $('<div/>', {
          "class": 'tutorial-container'
        }).appendTo($('body'));
        if (this.options.counter) {
          this.counter = $('<div/>', {
            "class": 'tutorial-panel-counter'
          }).appendTo(this.container);
        }
        if (this.options.interactive) {
          this.container.click(this.next);
          $(document).keydown(this.changePageOnKeyDown);
        }
        if (this.options.closable && !this.options.interactive) {
          this.container.click(this.end);
        }
        if (this.options.closable) {
          this.container.append($('<a/>', {
            "class": 'tutorial-close',
            html: '&#10006;'
          }).click(this.end));
          $(document).keydown(this.closeOnKeyDown);
        }
        this.canvas = $('<canvas/>', {
          "class": 'tutorial-canvas'
        }).appendTo(this.container).attr('width', this.container.width()).attr('height', this.container.height())[0];
        return this.showPanelAtIndex(0);
      };

      Tutorialize.prototype.end = function() {
        var _ref;
        this.container.off('click', this.next);
        $(document).off('keydown', this.changePageOnKeyDown);
        $(document).off('keydown', this.closeOnKeyDown);
        this.container.remove();
        if ((_ref = this.backdrop) != null) {
          _ref.remove();
        }
        $(this.canvas).remove();
        $('body').find('.tutorial-show-element').removeClass('tutorial-show-element');
        this.currentIndex = -1;
        this.container = null;
        return this.canvas = null;
      };

      Tutorialize.prototype.updateCounter = function() {
        var _ref;
        return (_ref = this.counter) != null ? _ref.text("" + (this.currentIndex + 1) + " / " + this.tutorial.length) : void 0;
      };

      Tutorialize.prototype.showPanel = function(panel) {
        var annotation, annotationElement, annotationPadding, annotationX, annotationY, arrowOptions, arrowX, arrowX2, arrowY, arrowY2, context, elOffset, element, _i, _len, _ref, _results;
        this.container.find('.tutorial-message, .tutorial-annotation').remove();
        $('body').find('.tutorial-show-element').removeClass('tutorial-show-element');
        this.canvas.getContext('2d').clearRect(0, 0, this.canvas.width, this.canvas.height);
        _results = [];
        for (_i = 0, _len = panel.length; _i < _len; _i++) {
          annotation = panel[_i];
          annotationElement = $('<div/>', {
            "class": 'tutorial-annotation'
          }).append($('<p/>', {
            "class": 'tutorial-annotation-text',
            html: annotation.text
          })).appendTo(this.container);
          element = $(annotation.selector);
          element.addClass('tutorial-show-element');
          if ($.type(annotation.arrow === 'object')) {
            arrowOptions = {};
            $.extend(arrowOptions, this.options.arrows, annotation.arrow);
          } else {
            arrowOptions = this.options.arrows;
          }
          annotationPadding = (_ref = annotation.padding) != null ? _ref : this.options.annotationPadding;
          elOffset = element.offset();
          switch (annotation.position) {
            case 'top':
              annotationX = elOffset.left + element.width() / 2 - annotationElement.width() / 2;
              annotationY = elOffset.top - arrowOptions.distance;
              arrowX = annotationX + annotationElement.width() / 2;
              arrowY = annotationY + annotationElement.height() + annotationPadding;
              break;
            case 'bottom':
              annotationX = elOffset.left + element.width() / 2 - annotationElement.width() / 2;
              annotationY = elOffset.top + element.height() + arrowOptions.distance;
              arrowX = annotationX + annotationElement.width() / 2;
              arrowY = annotationY - annotationPadding;
              break;
            case 'left':
              annotationX = elOffset.left - arrowOptions.distance;
              annotationY = elOffset.top + element.height() / 2 - annotationElement.height() / 2;
              arrowX = annotationX + annotationElement.width() + annotationPadding;
              arrowY = annotationY + annotationElement.height() / 2;
              break;
            case 'right':
              annotationX = elOffset.left + element.width() + arrowOptions.distance;
              annotationY = elOffset.top + element.height() / 2 - annotationElement.height() / 2;
              arrowX = annotationX - annotationPadding;
              arrowY = annotationY + annotationElement.height() / 2;
          }
          annotationElement.css('left', annotationX);
          annotationElement.css('top', annotationY);
          if (annotation.arrow) {
            context = this.canvas.getContext('2d');
            context.save();
            context.strokeStyle = arrowOptions.color;
            context.lineWidth = arrowOptions.weight;
            context.beginPath();
            context.moveTo(arrowX, arrowY);
            arrowX2 = elOffset.left + element.width() / 2;
            arrowY2 = elOffset.top + element.height() / 2;
            context.lineTo(arrowX2, arrowY2);
            context.stroke();
            context.closePath();
            _results.push(context.restore());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      Tutorialize.prototype.showPanelAtIndex = function(index) {
        this.currentIndex = index;
        this.showPanel(this.tutorial[index]);
        return this.updateCounter();
      };

      Tutorialize.prototype.changePageOnKeyDown = function(e) {
        switch (e.which) {
          case 37:
            return this.prev();
          case 39:
            return this.next();
        }
      };

      Tutorialize.prototype.closeOnKeyDown = function(e) {
        if (e.which === 27) {
          return this.end();
        }
      };

      Tutorialize.prototype.next = function() {
        var _ref;
        if ((-1 < (_ref = this.currentIndex) && _ref < this.tutorial.length - 1)) {
          return this.showPanelAtIndex(this.currentIndex + 1);
        } else {
          return this.end();
        }
      };

      Tutorialize.prototype.prev = function() {
        var _ref;
        if ((this.tutorial.length > (_ref = this.currentIndex) && _ref > 0)) {
          return this.showPanelAtIndex(this.currentIndex - 1);
        }
      };

      return Tutorialize;

    })();
  };
})(this));
