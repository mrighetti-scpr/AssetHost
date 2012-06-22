#= require ./assethost
#= require backbone
#= require ./models

class AssetHost.Slideshow
    DefaultOptions:
        el: "#photo"
        start: 0
        
    constructor: (options) ->
        @options = _(_({}).extend(@DefaultOptions)).extend options||{}
        
        # add in events
        _.extend(this, Backbone.Events)

        $ => 
            # -- get our parent element -- #
            @el = $ @options.el
        
            # -- create asset collection -- #
            @assets = new Slideshow.Assets @options.assets
            
            # -- create our nav buttons -- #
            @nav = new Slideshow.NavigationLinks current:@options.start,total:@assets.length
            
            # -- set up our slides -- #
            @slides = new Slideshow.Slides 
                collection: @assets
                nav:        @nav

            @el.html @slides.el
            @slides.render()

            # -- bind slides and nav together -- #
            @nav.bind "switch", (idx) => @slides.switchTo(idx)
            @slides.bind "switch", (idx) =>
                @nav.setCurrent idx
                @trigger "switch", idx

    #----------

    @Asset:
        Backbone.Model.extend
            initialize: ->
                # do something

    @Assets:
        Backbone.Collection.extend
            url: "/"
            model: @Asset

    #----------

    @Slide:
        Backbone.View.extend
            className: "slide"
            attributes:
                style: "text-align: center; width: 100%;"
                
            template:
                '''
                <img src="<%= url %>"/>
                <div class="text" style="text-align: left">
                    <div class="credit"><%= credit %></div>
                    <p><%= caption %></p>
                </div>
                '''

            #----------

            initialize: ->
                @index = @options.index

            #----------

            render: ->
                # render caption and credit
                $(@el).html _.template @template,
                    credit:     @model.get("credit")
                    caption:    @model.get("caption")
                    url:        @model.get("urls")['eight']

                $(@el).hide() unless @index is 0
                @

    #----------

    @Slides:
        Backbone.View.extend
            className: "slideview"

            events:
                'mouseover': '_mouseover'
                'mouseout': '_mouseout'

            initialize: ->
                @slides = []

                @collection.each (a,idx) => 
                    s = new Slideshow.Slide model:a, index:idx
                    @slides[idx] = s

                @current = 0
                @hasmouse = false
                    
                $(window).bind "keydown", (evt) => @_keyhandler(evt)

            #----------

            render: () ->
                $(@el).attr "tabindex", -1

                if @options.nav
                    $(@el).html @options.nav.el
                    @options.nav.render()

                # TODO use SCPR classes for this
                title = $("<h6/>", style: "display: inline-block;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif")
                        .html "Slideshow"
                $(@el).prepend title
                
                # create view tray
                @view = $ '<div/>', style:""

                # drop view into element
                $(@el).append @view

                # add our slides
                _(@slides).each (s,idx) =>
                    $(@view).append s.render().el

            #----------

            _mouseover: (e) ->
                @hasmouse = true

            _mouseout: (e) ->
                @hasmouse = false

            _keyhandler: (e) ->
                if @hasmouse
                    # is this a keypress we care about?
                    if e.which == 37
                        @switchTo(@current - 1)
                    else if e.which == 39
                        @switchTo(@current + 1)

            #----------

            switchTo: (idx) ->
                $(@slides[@current].el).fadeOut 'slow', =>  
                    @current = idx
                    @trigger "switch", idx
                    $(@slides[idx].el).fadeIn 'slow'

    #----------

    @NavigationLinks:
        Backbone.View.extend
            className: "pager-nav"
            attributes:
                style: "padding: 0 5px;"
                    
            events:
                'click a.active': '_buttonClick'

            # The "next" and "prev" classes are being styled by SCPR's stylesheet
            # TODO: copy that style over to AH
            template:
                '''
                <a <% print(prev ? "data-idx='"+prev+"' class='prev active'" : "class='prev disabled'"); %>></a>
                <span style="color:#ccc;vertical-align: middle;height:30px;display:inline-block;padding:0 5px;"><%= current %> of <%= total %></span>
                <a <% print(next ? "data-idx='"+next+"' class='next active'" : "class='next disabled'"); %>></a>
                '''

            #----------

            initialize: ->
                @total = @options.total
                @current = Number(@options.current) + 1
                @render()

            #----------

            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx) - 1
                    @trigger "switch", idx

            #----------

            setCurrent: (idx) ->
                @current = Number(idx) + 1
                @render()

            #----------

            render: ->
                $(@el).html _.template @template,
                    current:    @current,
                    total:      @total,
                    prev:       if @current - 1 > 0 then @current - 1 else null
                    next:       if @current + 1 <= @total then @current + 1 else null
                