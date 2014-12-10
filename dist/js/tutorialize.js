// Generated by CoffeeScript 1.7.1
(function() {
  var Tutorialize,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Tutorialize = (function() {
    function Tutorialize(tutorial, options) {
      this.showPanelAtIndex = __bind(this.showPanelAtIndex, this);
      this.showPanel = __bind(this.showPanel, this);
      this.end = __bind(this.end, this);
      this.start = __bind(this.start, this);
      var defaultOptions;
      defaultOptions = {
        tutorial: [],
        interactive: false,
        arrows: {
          weight: 6,
          color: 'white'
        },
        backdrop: true,
        exitOnBackgroundClick: false
      };
      this.tutorial = tutorial;
      this.options = $.extend(true, defaultOptions, options);
      this.currentIndex = -1;
      this.container = null;
      this.canvas = null;
    }

    Tutorialize.prototype.start = function() {
      var tutorialBg;
      if (this.options.backdrop) {
        tutorialBg = 'rgba(0, 0, 0, 0.5)';
      } else {
        tutorialBg = 'none';
      }
      this.container = $('<div/>', {
        "class": 'tutorial-backdrop',
        css: {
          background: tutorialBg
        }
      }).appendTo($('body'));
      if (this.options.exitOnBackgroundClick) {
        this.container.click(this.end);
      }
      this.container.append($('<a/>', {
        "class": 'tutorial-close',
        html: '&#10006;'
      }).click(this.end));
      this.canvas = $('<canvas/>', {
        "class": 'tutorial-canvas'
      }).appendTo(this.container).attr('width', this.container.width()).attr('height', this.container.height())[0];
      return this.showPanelAtIndex(0);
    };

    Tutorialize.prototype.end = function() {
      this.container.remove();
      $(this.canvas).remove();
      this.currentIndex = -1;
      this.container = null;
      return this.canvas = null;
    };

    Tutorialize.prototype.showPanel = function(panel) {
      var angle, annotation, annotationElement, annotationX, annotationY, arrowX, arrowX2, arrowY, arrowY2, context, element, elements, extraDegrees, slope, _i, _len, _ref, _results;
      _ref = panel.annotations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        annotation = _ref[_i];
        annotationX = annotation.position.x;
        annotationY = annotation.position.y;
        annotationElement = $('<div/>', {
          "class": 'tutorial-annotation',
          css: {
            left: annotationX,
            top: annotationY
          }
        }).append($('<p/>', {
          html: annotation.text
        })).appendTo(this.container);
        if (annotation.arrow) {
          elements = $(annotation.selector);
          _results.push((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = elements.length; _j < _len1; _j++) {
              element = elements[_j];
              element = $(element);
              context = this.canvas.getContext('2d');
              context.save();
              context.beginPath();
              arrowX = annotationX + annotationElement.outerWidth() / 2;
              arrowY = annotationY + annotationElement.outerHeight() / 2;
              context.moveTo(arrowX, arrowY);
              arrowX2 = element.offset().left + element.width() / 2;
              arrowY2 = element.offset().top + element.height() / 2;
              context.lineTo(arrowX2, arrowY2);
              context.strokeStyle = this.options.arrows.color;
              context.lineWidth = this.options.arrows.weight;
              context.stroke();
              context.closePath();
              slope = (arrowY2 - arrowY) / (arrowX2 - arrowX);
              angle = Math.atan(slope);
              extraDegrees = arrowX2 > arrowX ? 90 : -90;
              angle += extraDegrees * Math.PI / 180;
              context.beginPath();
              context.translate(arrowX2, arrowY2);
              context.rotate(angle);
              context.moveTo(0, -10);
              context.lineTo(8, 8);
              context.lineTo(-8, 8);
              context.fillStyle = this.options.arrows.color;
              context.fill();
              context.closePath();
              _results1.push(context.restore());
            }
            return _results1;
          }).call(this));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Tutorialize.prototype.showPanelAtIndex = function(index) {
      this.showPanel(this.tutorial[index]);
      return this.currentIndex = index;
    };

    return Tutorialize;

  })();

  (function($) {
    return $.tutorialize = function(options) {
      var tutorial;
      if (options == null) {
        options = {};
      }
      tutorial = options.tutorial;
      delete options.tutorial;
      return new Tutorialize(tutorial, options);
    };
  })(jQuery);

}).call(this);
