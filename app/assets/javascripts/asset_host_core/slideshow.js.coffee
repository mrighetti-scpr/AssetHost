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
                initial:    @options.initial
                nav:        @nav

            @el.html @slides.el
            @slides.render()

            # -- bind slides and nav together -- #
            @nav.bind "slide", (idx) => @slides.slideTo(idx)
            @slides.bind "slide", (idx) => 
                @nav.setCurrent idx
                @trigger "slide", idx

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

            template:
                '''
                <img src="<%= url %>" />
                <div class="text" style="margin: 0 auto">
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

                @active = false
                @current = null
                @hasmouse = false

                $(window).bind "keydown", (evt) => @_keyhandler(evt)

            #----------

            render: () ->
                $(@el).attr "tabindex", -1

                if @options.nav
                    $(@el).html @options.nav.el
                    @options.nav.render()

                # create view tray
                @view = $ '<div/>', style:"background-color:#000"

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
                        @slideBy(-1)
                    else if e.which == 39
                        @slideBy(1)

            #----------

            slideTo: (idx) ->
                # figure out where slide[idx] is at
                @current = idx
                @trigger "slide", idx

            #----------

            slideBy: (idx) ->
                t = @current + idx

                if @slides[t]
                    @slideTo(t)

    #----------

    @NavigationLinks:
        Backbone.View.extend
            className: "nav"

            events:
                'click button': '_buttonClick'

            template:
                '''
                <div style="width: 15%;">
                    <button <% print(prev ? "data-idx='"+prev+"' class='prev-arrow'" : "class='disabled prev-arrow'"); %> >Prev</button>
                </div>
                <div class="buttons" style="width:70%;"></div>
                <div style="width: 15%">
                    <button <% print(next ? "data-idx='"+next+"' class='next-arrow'" : "class='disabled next-arrow'"); %> >Next</button>
                </div>
                <br style="clear:both;line-height:0;height:0"/>
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
                    @trigger "slide", idx

            #----------

            setCurrent: (idx) ->
                @current = Number(idx) + 1
                @render()

            #----------

            render: ->
                buttons = _([1..@total]).map (i) =>
                    $("<button/>", {"data-idx":i, text:i, class:if @current == i then "current" else ""})[0]

                $(@el).html _.template @template,
                    current:    @current,
                    total:      @total,
                    prev:       if @current - 1 > 0 then @current - 1 else null
                    next:       if @current + 1 <= @total then @current + 1 else null

                @$(".buttons").html buttons
