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
            @nav = new Slideshow.NavigationLinks 
                current:    @options.start
                total:      @assets.length
            
            # Create the overlay navigation
            @overlayNav = new Slideshow.OverlayNav
                current:    @options.start
                total:      @assets.length

            # -- set up our slides -- #
            @slides = new Slideshow.Slides 
                collection:   @assets
                overlayNav:   @overlayNav
            
            @overlayNav.slides = @slides
            
            # Fill the slideview in with the different elements
            @el.html    @nav.el
            @el.append  @slides.el
            $(@slides.el).append @overlayNav.el
            
            # Setup the title
            title = $("<h6/>", style: "display: inline-block;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif")
                    .html "Slideshow"
            @el.prepend title
            
            # Render the elements
            @nav.render()
            @slides.render()

            # -- bind slides and nav together -- #
            @nav.bind           "switch", (idx) => @slides.switchTo(idx)
            @overlayNav.bind    "switch", (idx) => @slides.switchTo(idx)
            
            @slides.bind        "switch", (idx) =>
                @nav.setCurrent idx
                @overlayNav.setCurrent idx, @slides.el
                @trigger "switch", idx

            # Keyboard Navigation
            @hasmouse = false
            $(window).bind "keydown", (e) => 
                if @hasmouse
                    # is this a keypress we care about?
                    if e.which == 37
                        @slides.switchTo(@slides.current - 1)
                    else if e.which == 39
                        @slides.switchTo(@slides.current + 1)

            @el.on
                mouseenter: (e) =>
                    if @hasmouse is false
                        @hasmouse = true

                mouseleave: (e) =>
                    if @hasmouse is true
                        @hasmouse = false

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

                if @index is 0
                    $(@el).addClass("active").show()
                else if @index isnt 0
                    $(@el).hide()

                @

    #----------

    @Slides:
        Backbone.View.extend
            className: "slides"
            attributes:
                style: "clear: both;"

            events:
                "mouseenter": "_mouseenter"
                "mouseleave": "_mouseleave"
                
            initialize: ->
                @slides = []
                @current = 0
                @hasmouse = false

                @collection.each (a,idx) => 
                    s = new Slideshow.Slide 
                        model:  a
                        index:  idx
                        
                    @slides[idx] = s
            #----------

            render: ->
                # add our slides
                _(@slides).each (s,idx) =>
                    $(@el).append s.render().el
                
                @options.overlayNav._show()
                                
            _mouseenter: (e) ->
                if @hasmouse is false
                    @hasmouse = true
                    @options.overlayNav._show @el
                
            _mouseleave: (e) ->
                if @hasmouse is true
                    @hasmouse = false
                    @options.overlayNav._hide @el
        
            #----------

            switchTo: (idx) ->
                if idx >= 0 and idx <= _(@slides).size() - 1
                    @currentEl  = $ @slides[@current].el
                    @nextEl     = $ @slides[idx].el
                    
                    # Stop the animations
                    @currentEl.stop false, true
                    @nextEl.stop false, true

                    # Fade out, send switch signal, fade in
                    @currentEl.fadeOut 'fast', =>
                        @currentEl.removeClass 'active'
                        @nextEl.addClass 'active'

                        @current = idx
                        @trigger "switch", idx

                        @nextEl.fadeIn 'fast'

    #----------
    
    @OverlayNav:
        Backbone.View.extend
            className: "overlay-nav"
            
            events:
                'click div.active': "_buttonClick"
    
            # This is being styled by SCPR's stylesheet
            template:
                '''
                <div style="height:<%=height%>" <% print(prev ? "data-idx='"+prev+"' class='bar prev active'" : "class='bar prev disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>"></div>
                </div>
                <div style="height:<%=height%>" <% print(next ? "data-idx='"+next+"' class='bar next active'" : "class='bar next disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>"></div>
                </div>
                '''
               
            #----------

            initialize: ->
                @height     = 0
                @top        = 0

                @total      = @options.total
                @current    = Number(@options.current) + 1
                
                $(@el).hide()

                @buttonHeight = $(@el).find('.arrow.prev').height()
                
            #----------

            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx) - 1
                    @trigger "switch", idx


            #----------
            # Handle the hiding and showing of the buttons
            
            _show: ->
                if !$(@el).is(":visible")
                    $(@el).stop false, true
                    @__lock()
                    @render()
                    $(@el).fadeIn 'fast'
                
            _hide: ->
                $(@el).stop false, true
                $(@el).fadeOut 'fast'
            
            #----------
            # Lock/Unlock the button's top position
                
            __lock: ->
                console.log "image is", $(@slides.el).find(".slide.active img")
                height = $(@slides.el).find(".slide.active img").height()
                top = ((height - @.$(".text").height()) / 2) - (@buttonHeight / 2)
                                
                @__setTop top
                @__setTargetHeight height

            __setTop: (top) ->
                @top = top + "px"
                # @.$('.arrow').css top: @top
                # console.log "_setTop with", @top

            __setTargetHeight: (height) ->
                @height = height + "px"
                # @.$('.bar').css height: @height
                # console.log "_setTargetHeight with", @height            
            
            #----------

            setCurrent: (idx) ->
                @current = Number(idx) + 1
                @render()

            #----------

            
            render: ->
                console.log "rendering overlay nav, top, height is", @top, @height
                $(@el).html _.template @template,
                    prev:       if @current - 1 > 0 then @current - 1 else null
                    next:       if @current + 1 <= @total then @current + 1 else null
                    top:        @top
                    height:     @height
                                
                
                
                
    @NavigationLinks:
        Backbone.View.extend
            className: "pager-nav"
            attributes:
                style: "padding: 0 5px;"
                    
            events:
                'click a.active': '_buttonClick'

            # The "next" and "prev" classes are being styled by SCPR's stylesheet
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
               
    #----------
    
    @Thumnails:
        Backbone.View.extend
            className: "thumbnailview"
            
            events:
                'click a.thumbnail_toggle': '_toggleThumbTray'
            
            initialize: ->
                #
            
            _toggleThumbTray: ->
                #
            
            
    
    
    
    
        
