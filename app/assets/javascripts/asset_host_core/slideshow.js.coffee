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
                
            @overlayNav = new Slideshow.OverlayNav
                current:    @options.start
                total:      @assets.length

            # -- set up our slides -- #
            @slides = new Slideshow.Slides 
                collection:   @assets
                nav:          @nav
                overlayNav:   @overlayNav
            
            # Fill the slideview in with the different elements
            @el.html    @nav.el
            @el.append  @slides.el
            
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
                @overlayNav.setCurrent idx
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

                $(@el).hide() unless @index is 0
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

            render: () ->
                # add our slides
                _(@slides).each (s,idx) =>
                    $(@el).append s.render().el
                    
                @options.nav.render()

                # Add in the overlay navigation
                $(@el).append @options.overlayNav.el
                @options.overlayNav.render()

            _mouseenter: (e) ->
                console.log "mouseenter, hasmouse is", @hasmouse
                if @hasmouse is false
                    @hasmouse = true
                    @options.overlayNav._show @el
                
            _mouseleave: (e) ->
                console.log "mouseenter, hasmouse is", @hasmouse
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
                        @current = idx
                        @trigger "switch", idx
                        @nextEl.fadeIn 'fast'

    #----------
    
    @OverlayNav:
        Backbone.View.extend
            className: "overlay-nav"
            
            events:
                'click a.active': "_buttonClick"
    
            # This is being styled by SCPR's stylesheet
            template:
                '''
                <a <% print(prev ? "data-idx='"+prev+"' class='bar prev active'" : "class='bar prev disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>"></div>
                </a>
                <a <% print(next ? "data-idx='"+next+"' class='bar next active'" : "class='bar next disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>"></div>
                </a>
                '''
               
            #----------

            initialize: ->
                @total = @options.total
                @current = Number(@options.current) + 1
                
                # set default "top" position
                @top = "40%"

                $(@el).hide()
                @render()
                $(@el).fadeIn(1000)
                
            #----------

            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx) - 1
                    @trigger "switch", idx


            #----------
            # Handle the hiding and showing of the buttons
            
            _show: (slidesEl) ->
                $(@el).stop(false, true)
                @lock slidesEl
                $(@el).fadeIn 'fast'
                
            _hide: (slidesEl) ->
                $(@el).stop(false, true)
                $(@el).fadeOut 'fast', => @unlock slidesEl
            

            #----------
            # Lock/Unlock the button's top position
                
            lock: (slidesEl) ->
                # .84 is from "84%" height in CSS in SCPRv4
                height = $(slidesEl).height() * .84
                @top = (height * .4) + "px"
                @_setTop @top
                console.log "locked, top is", @top

            unlock: (slidesEl) ->
                @top = "40%"
                @_setTop @top
                console.log "unlocked"

            _setTop: (top) ->
                @.$('.arrow').css top: @top
                
            #----------

            setCurrent: (idx) ->
                @current = Number(idx) + 1
                @render()

            #----------

            render: ->
                $(@el).html _.template @template,
                    prev:       if @current - 1 > 0 then @current - 1 else null
                    next:       if @current + 1 <= @total then @current + 1 else null
                    top:        @top
                
                
                
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
            
            
    
    
    
    
        
