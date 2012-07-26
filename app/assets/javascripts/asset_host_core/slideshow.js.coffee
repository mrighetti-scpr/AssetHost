#= require ./assethost
#= require backbone
#= require ./models

class AssetHost.Slideshow
    DefaultOptions:
        el:         "#photo"
        deeplink:   false

    constructor: (options) ->
        @options = _(_({}).extend(@DefaultOptions)).extend options||{}
        
        # add in events
        _.extend(this, Backbone.Events)

        $ => 
            # -- get our parent element -- #
            @el = $ @options.el

            # -- create asset collection -- #
            @assets = new Slideshow.Assets @options.assets
            @total  = @assets.length

            # Set the starting slide.
            # We only want to work with the slide's index internally to avoid confusion.
            # If the requested slide is in between 0 and the total slides, use it
            # Otherwise just go to slide 0
            @start      = 0 # default starting position
            @deeplink   = @options.deeplink
            
            console.log @start
            console.log @total

            if @deeplink
                startingSlide = Number(@options.start)
                if startingSlide > 0 and startingSlide <= @total
                    @start = startingSlide - 1

            #----------
            # Create the elements we need for the complete slideshow
            
            @header = $("<div/>", class: "slideshow-header")
            @title = $("<h6/>").html "Slideshow"
            
            @nav = new Slideshow.NavigationLinks 
                start:  @start
                total:  @total
            
            @overlayNav = new Slideshow.OverlayNav
                start:  @start
                total:  @total

            @slides = new Slideshow.Slides
                collection:   @assets
                start:        @start

            @slides.overlayNav = @overlayNav
            @overlayNav.slides = @slides

            @thumbtray = new Slideshow.Thumbtray
                collection: @assets
                slides:     @slides
            
            @traytoggler = new Slideshow.ThumbtrayToggler
                thumbtray:  @thumbtray
            
            #----------            
            # Fill in the main element with all the pieces
            @el.html        @header
            @header.append  @title
            @header.append  @nav.el
            @header.append  @traytoggler.el
            
            @el.append      @thumbtray.el
            @el.append      @slides.el
            
            #----------
            # Render the elements
            @traytoggler.render()
            @nav.render()
            @slides.render()

            #----------
            # bind slides and nav together
            # Click on a nav button, send switchTo() to Slides
            @nav.bind           "switch", (idx) =>
                @slides.switchTo idx
                
            @overlayNav.bind    "switch", (idx) =>
                @slides.switchTo idx

            @thumbtray.bind     "switch", (idx) =>
                @slides.switchTo idx
            
            # switchTo() emits "switch" on slides, which sends setCurrent()
            # to those who need it. Also emits "switch" on Slideshow for
            # Google Analytics
            @slides.bind        "switch", (idx) =>
                @nav.setCurrent        idx
                @overlayNav.setCurrent idx
                @slides.setCurrent     idx
                @thumbtray.setCurrent  idx
                @trigger "switch",     idx

                if @deeplink and window.history.replaceState
                    slideNum = idx + 1
                    window.history.replaceState { slide: slideNum }, document.title + ": Slide #{slideNum}", window.location.pathname + "?slide=#{slideNum}"

            #----------
            # Keyboard Navigation
            @hasmouse = false
            $(window).on 
                keydown: (e) =>
                    if @hasmouse
                        # is this a keypress we care about?
                        switch e.keyCode
                            when 37 then @slides.switchTo(@slides.current - 1)
                            when 39 then @slides.switchTo(@slides.current + 1)

            #----------
            # Show/Hide targets
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
                @slides     = []
                @current    = @options.start
                @overlayNav = @options.overlayNav
                
                @collection.each (a,idx) => 
                    s = new Slideshow.Slide 
                        model:  a
                        index:  idx
                        start:  @options.start

                    @slides[idx] = s
                
                @total = @slides.length


           #----------

            switchTo: (idx) ->
                if idx >= 0 and idx <= @total - 1
                    @currentEl  = $ @slides[@current].el
                    @nextEl     = $ @slides[idx].el

                    @currentEl.stop(true, true).fadeOut 'fast', =>
                        @currentEl.removeClass 'active'
                        @trigger "switch", idx
                        @nextEl.addClass('active').fadeIn('fast')

            #----------

            setCurrent: (idx) ->
                @current = idx

            #----------

            render: ->
                # add our slides
                _(@slides).each (s,idx) =>
                    $(@el).append s.render().el
                
                # And the overlay nav
                $(@el).append @overlayNav.el

                setTimeout () =>
                    @overlayNav.showTargets()
                , 2000

    #----------
    
    @OverlayNav:
        Backbone.View.extend
            className: "overlay-nav"
            
            events:
                'click .active':    "_buttonClick"
                "mouseenter":       "showTargets"
                "mouseleave":       "hideTargets"

    
            template:
                '''
                <div <% print(prev ? "data-idx='"+prev+"' class='bar prev active'" : "class='bar prev disabled'"); %>>
                </div>
                <div <% print(next ? "data-idx='"+next+"' class='bar next active'" : "class='bar next disabled'"); %>>
                </div>
                '''
               
            #----------

            initialize: ->
                @height     = 0
                @total      = @options.total
                @current    = @options.start
                @hasmouse   = false

            #----------
            # Handle the hiding and showing of the buttons
            # Only for mouseenter and mouseleave
            
            showTargets: ->
                if @hasmouse is false
                    @hasmouse = true
                    $(@el).stop false, true
                    $(@el).css height: @_getTargetHeight()
                    @render()
                    $(@el).css opacity: 1
                
            hideTargets: (evt) ->
                if @hasmouse is true
                    @hasmouse = false
                    $(@el).stop(true, true).animate opacity: 0, 'fast'

            #----------
            
            setCurrent: (idx) ->
                @current = idx
                @render()
    
            #----------

            render: ->
                $(@el).html _.template @template,
                    prev:     if @current > 0           then String(@current - 1) else null
                    next:     if @current < @total - 1  then String(@current + 1) else null
                
                @


            #----------
            # Private
    
            #----------
            # Lock/Unlock the button's top position and click target height
            
            _getTargetHeight: ->
                $(@slides.el).find(".slide.active img").height()

            #----------
            
            _buttonClick: (evt) ->
                idx = $(evt.target).attr "data-idx"

                if idx
                    idx = Number(idx)
                    @trigger "switch", idx

            #----------

    #----------

                
    @NavigationLinks:
        Backbone.View.extend
            className: "pager-nav"
                    
            events:
                'click a.active': '_buttonClick'

            template:
                '''
                <a <% print(prev ? "data-idx='"+prev+"' class='prev active'" : "class='prev disabled'"); %>></a>
                <span class="page-count"><%= count %> of <%= total %></span>
                <a <% print(next ? "data-idx='"+next+"' class='next active'" : "class='next disabled'"); %>></a>
                '''

            #----------

            initialize: ->
                @total      = @options.total
                @current    = @options.start
                @render()

            #----------

            setCurrent: (idx) ->
                @current = idx
                @render()

            #----------

            render: ->
                $(@el).html _.template @template,
                    count:    @current + 1,
                    total:    @total,
                    prev:     if @current > 0           then String(@current - 1) else null
                    next:     if @current < @total - 1  then String(@current + 1) else null
               
            
            #----------
            # Private

            _buttonClick: (evt) ->
                idx = $(evt.target).attr "data-idx"

                if idx
                    idx = Number(idx)
                    @trigger "switch", idx
                

    #----------

    @ThumbtrayToggler:
        Backbone.View.extend
            tagName:    'span'
            className: 'thumbtray-toggler'
            
            events:
                'click':    '_toggleThumbTray'
                
            #----------

            initialize: ->
                @thumbtray = @options.thumbtray
                @thumbtrayEl = $ @thumbtray.el
                
            #----------             

            render: ->
                # We just need the element, 
                # we'll do the rest with CSS
                @
                

            #----------
            # Private

            _toggleThumbTray: ->
                if @thumbtrayEl.is(":visible")
                    @thumbtrayEl.fadeOut 75
                    @thumbtray.thumbidx = 0
                    $(@el).removeClass 'active'
                else
                    $(@el).addClass 'active'
                    @thumbtray.render()
                    @thumbtray.setCurrent @thumbtray.slides.current
                    @thumbtrayEl.fadeIn()
    

    #----------

    @Thumbtray:
        Backbone.View.extend
            className: "thumbtray"

            events:
                "click .nav.active":    "_buttonClick"

            options:
                per_page: 5


            prev_template:
                '''
                <a <% print(prev ? "data-page='"+prev+"' class='nav prev active'" : "class='nav prev disabled'"); %>></a>
                '''

            next_template:
                '''
                <a <% print(next ? "data-page='"+next+"' class='nav next active'" : "class='nav next disabled'"); %>></a>
                '''

            #----------

            initialize: ->    
                @thumbnailView = new Slideshow.Thumbnails
                    collection: @collection
                    per_page:   @options.per_page   
                    thumbtray:  @

                @slides         = @options.slides
                @thumbs         = @thumbnailView.thumbs
                @per_page       = @options.per_page
                @total_pages    = Math.ceil(@thumbs.length / @per_page)
                @current_page   = @_currentPage()

                $(@el).html     @thumbnailView.el
                $(@el).prepend  @_prevTemplate()
                $(@el).append   @_nextTemplate()
                
            #----------
    
            setCurrent: (idx) ->
                @thumbnailView.setCurrent idx

            #----------
                
            switchTo: (page) ->
                if page >= 1 and page <= @total_pages and page isnt @current_age
                    @_moveThumbIdx if page > @current_page then 'forward' else 'backward'
                    $(@thumbnailView.el).stop(true, true).animate opacity: 0, 'fast', =>
                        @render()

            #----------

            render: ->
                @thumbnailView.render()
                @current_page = @_currentPage()
                @.$(".nav.prev").replaceWith @_prevTemplate()
                @.$(".nav.next").replaceWith @_nextTemplate()
                $ @el
            

            #----------
            # Private

            _prevTemplate: ->
                _.template @prev_template,
                    prev: if @current_page > 1 then String(@current_page - 1) else null

            _nextTemplate: ->
                _.template @next_template,
                    next: if @current_page < @total_pages then String(@current_page + 1) else null

            #----------

            _currentPage: ->
                @thumbnailView.thumbidx / @per_page + 1
                
            #----------

            _moveThumbIdx: (direction) ->
                if direction is "forward"
                    @thumbnailView.thumbidx += @per_page
                else if direction is "backward"
                    @thumbnailView.thumbidx -= @per_page

            #----------

            _buttonClick: (evt) ->
                page = $(evt.target).attr "data-page"

                if page
                    page = Number(page)
                    @switchTo page
           
 
    #----------

    @Thumbnails:
        Backbone.View.extend
            className: "thumbnails"
                
            initialize: ->
                @thumbs     = []
                @thumbidx   = 0
                @per_page   = @options.per_page

                @collection.each (asset,idx) => 
                    thumb = new Slideshow.Thumbnail
                        model:      asset
                        index:      idx
                        thumbtray:  @options.thumbtray

                    @thumbs[idx] = thumb
                
                _(@thumbs).each (thumb) =>
                    $(@el).append thumb.render().el

            #----------

            setCurrent: (idx) ->
                @.$('.active').removeClass 'active'
                active = _(@thumbs).find (thumb) -> thumb.index is idx
                $(active.el).addClass 'active'
                
            #----------

            render: ->
                @.$(".thumbnail").removeClass 'current-set'

                thumbSlice = @thumbs.slice @thumbidx, @thumbidx + @per_page
                
                _(thumbSlice).each (thumb) ->
                    $(thumb.el).addClass 'current-set'
            
                $(@el).animate opacity: 1, 'fast'
                @


    #----------

    @Thumbnail:
        Backbone.View.extend
            className: "thumbnail"

            events:
                'click': '_thumbClick'

            template:
                '''
                <img src="<%= url %>"/>
                '''

            #----------

            initialize: ->
                @thumbtray  = @options.thumbtray
                @index      = @options.index
                
            #----------

            render: ->
                $(@el).html _.template @template,
                    url:    @model.get("urls")['thumb']

                @
                

            #----------
            # Private

            _thumbClick: (evt) ->
                @thumbtray.trigger "switch", @index
                

    #----------
            
