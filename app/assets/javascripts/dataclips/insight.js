$.widget("dataclips.insight", {
  options: {
    adjustHeight: function(){}
  },
  _create: function(){
    this.element
      .attr("width", "100%")
      .attr("scrolling", "no")
      .attr("frameborder", "no")
      .prop("allowfullscreen", true)
      .attr("src", this.options.src + '?format=html');
  },
  _init: function(){
    this.filters = {};

    this.frameWindow = this.element.get(0).contentWindow;

    var self = this;
    var options     = this.options;
    var frame       = this.element.get(0);
    var iframe      = this.element;

    // resizing
    var resizeIframe = function(){
      frame.height = options.adjustHeight() || 500;
    };
    window.addEventListener('resize', resizeIframe, true);

    frame.addEventListener('load', function(){
      self.setFilter(self.options.defaultFilter);
      resizeIframe();
      self._trigger("load");
    }, true);


    // communication
    window.addEventListener('message', function (e) {
      if (e.source === self.frameWindow) {
        self._trigger("proxy", null, e.data);

        if (e.data['row-clicked']) {
          var record = e.data["row-clicked"];
          self._trigger("rowClick", null, record);
        }

      }
    });
  },

  _sendMessage: function(message){
    this.frameWindow.postMessage(message, '*');
  },

  refresh: function(){
    this._sendMessage({refresh: true});
  },

  setFilter: function(filters) {
    // $.extend({date_of_order: {from: X}}, {date_of_order: {to: Y}})
    // {date_of_order: {to: Y}}
    if (filters !== undefined) {
      Object.keys(filters).forEach(function(key) {
        if (typeof(filters[key]) === 'object' && typeof(this.filters[key]) === 'object') {
          // merge nested objects values
          return this.filters[key] = $.extend(this.filters[key], filters[key]);
        } else {
          // replace value
          return this.filters[key] = filters[key];
        };
      }.bind(this));
      this._sendMessage({filters: this.filters});
    };
  }
});
