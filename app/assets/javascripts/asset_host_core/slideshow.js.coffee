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
            @start = Number(@options.start) - 1

            # -- create asset collection -- #
            @assets = new Slideshow.Assets @options.assets
            
            #----------
            # Create the elements we need for the complete slideshow
                        
            @nav = new Slideshow.NavigationLinks 
                start:  @start
                total:  @assets.length
            
            @overlayNav = new Slideshow.OverlayNav
                start:  @start
                total:  @assets.length

            @slides = new Slideshow.Slides
                collection:   @assets
                start:        @start

            @slides.overlayNav = @overlayNav
            @overlayNav.slides = @slides
            
            # Fill in the main element with all the pieces
            @el.html      $("<h6/>").html "Slideshow"
            @el.append    @nav.el
            @el.append    @slides.el
            @el.append    @overlayNav.el
            
            
            # Render the elements
            @nav.render()
            @slides.render()
            setTimeout () =>
                @overlayNav.showTargets()
            , 2000

            # -- bind slides and nav together -- #
            # Click on a next button, send switchTo() to Slides
            @nav.bind           "switch", (idx) =>
                @slides.switchTo idx
                
            @overlayNav.bind    "switch", (idx) =>
                @slides.switchTo idx
            
            # switchTo() emits "switch" on slides, which sends setCurrent()
            # to those who need it. Also emits "switch" on Slideshow for
            # Google Analytics
            @slides.bind        "switch", (idx) =>
                @nav.setCurrent         idx
                @overlayNav.setCurrent  idx
                @slides.setCurrent      idx
                @trigger "switch",      idx


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
                        @overlayNav.showTargets()

                mouseleave: (e) =>
                    if @hasmouse is true
                        @hasmouse = false
                        @overlayNav.hideTargets()

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
                <img src="<%= url %>"/>
                <div class="text">
                    <h4><%= credit %></h4>
                    <p><%= caption %></p>
                </div>
                '''

            #----------

            initialize: ->
                @index = @options.index
                @start = @options.start

            #----------

            render: ->
                # render caption and credit
                $(@el).html _.template @template,
                    credit:     @model.get("credit")
                    caption:    @model.get("caption")
                    url:        @model.get("urls")['eight']

                if @index is @start
                    $(@el).addClass("active")

                @

    #----------

    @Slides:
        Backbone.View.extend
            className: "slides asset-block"
                
            #----------

            initialize: ->
                @slides = []
                @current = @options.start
                
                @collection.each (a,idx) => 
                    s = new Slideshow.Slide 
                        model:  a
                        index:  idx
                        start: @options.start

                    @slides[idx] = s
                
                @total = @slides.length
 
           #----------

            switchTo: (idx) ->
                if idx >= 0 and idx <= @total - 1
                    @currentEl  = $ @slides[@current].el
                    @nextEl     = $ @slides[idx].el
                                        
                    @currentEl.stop(true, true).fadeOut 'fast', =>
                        @currentEl.removeClass('active')
                        @trigger "switch", idx
                        @nextEl.fadeIn('fast')
                               .addClass('active')

            #----------

            render: ->
                # add our slides
                _(@slides).each (s,idx) =>
                    $(@el).append s.render().el

            setCurrent: (idx) ->
                @current = idx

    #----------
    
    @OverlayNav:
        Backbone.View.extend
            className: "overlay-nav"
            
            events:
                'click .active': "_buttonClick"
    
            # This is being styled by SCPR's stylesheet
            template:
                '''
                <div style="height:<%=height%>px" <% print(prev ? "data-idx='"+prev+"' class='bar prev active'" : "class='bar prev disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>px"></div>
                </div>
                <div style="height:<%=height%>px" <% print(next ? "data-idx='"+next+"' class='bar next active'" : "class='bar next disabled'"); %>>
                    <span class="arrow" style="top:<%=top%>px"></div>
                </div>
                '''
               
            #----------

            initialize: ->
                @height     = 0
                @top        = 0

                @total      = @options.total
                @current    = @options.start
                
                @buttonHeight = $(@el).find('.arrow.prev').height() || 48
                
            #----------
            # Handle the hiding and showing of the buttons
            # Only for mouseenter and mouseleave
            
            showTargets: ->
                $(@el).stop false, true
                @height = @_getTargetHeight()
                @top = @_getArrowTop(@height, @buttonHeight)
                @render()
                
            hideTargets: ->
                $(@el).stop false, true
                $(@el).find('.arrow').fadeOut 'fast'

            #----------
            
            setCurrent: (idx) ->
                @current = idx
                @render()
    
            #----------

            render: ->
                $(@el).html _.template @template,
                    prev:     if @current > 0 then String(@current - 1) else null
                    next:     if @current < @total - 1 then String(@current + 1) else null
                    top:      @top
                    height:   @height


            #----------
            # Private
    
            #----------
            # Lock/Unlock the button's top position and click target height
            
            _getTargetHeight: ->
                $(@slides.el).find(".slide.active img").height()

            _getArrowTop: (height, buttonHeight) ->
                ((height - @.$(".text").height()) / 2) - (buttonHeight / 2)

            #----------
            
            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx)
                    @trigger "switch", idx

            #----------

    #----------

                
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
                <span class="page-count"><%= count %> of <%= total %></span>
                <a <% print(next ? "data-idx='"+next+"' class='next active'" : "class='next disabled'"); %>></a>
                '''

            #----------

            initialize: ->
                @total = @options.total
                @current = @options.start
                @render()

            #----------

            _buttonClick: (evt) ->
                idx = $(evt.currentTarget).attr "data-idx"

                if idx
                    idx = Number(idx)
                    @trigger "switch", idx

            #----------

            setCurrent: (idx) ->
                @current = idx
                @render()

            #----------

            render: ->
                $(@el).html _.template @template,
                    count:    @current + 1,
                    total:    @total,
                    prev:     if @current > 0 then String(@current - 1) else null
                    next:     if @current < @total - 1 then String(@current + 1) else null
               
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
            
            
    
    
    
    
        
