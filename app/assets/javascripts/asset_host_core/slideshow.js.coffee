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
                start:      @start
            
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

            @thumbtray.bind     "switch_page", (page) =>
                # do something

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
    
    @Navigation:
        initialize: ->
            @total      = @options.total
            @current    = @options.start
            @hasmouse   = false

        #----------

        setCurrent: (idx) ->
               @current = idx
               @render()

        #----------

        render: ->
            $(@el).html _.template @template,
                count:      @current + 1
                total:      @total
                prev_class: @_activeIf @current > 0
                next_class: @_activeIf @current < @total - 1
            @

        #----------

        _activeIf: (condition) ->
            if condition then "active" else "disabled"

        #----------

        _buttonClick: (event) ->
            target = $(event.target)

            if target.hasClass 'next'
                idx = @current + 1
            else if target.hasClass 'prev'
                idx = @current - 1
            
            if idx?
                @trigger "switch", idx


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
                <div class="bar prev <%=prev_class%>"></div>
                <div class="bar next <%=next_class%>"></div>
                '''

            #----------
            # Handle the hiding and showing of the buttons
            
            showTargets: ->
                if @hasmouse is false
                    @hasmouse = true
                    $(@el).stop(false, true).css(height: @_getTargetHeight())
                    @render()
                    $(@el).css opacity: 1
                
            hideTargets: ->
                if @hasmouse is true
                    @hasmouse = false
                    $(@el).stop(true, true).animate(opacity: 0, 'fast')

            #----------

            _getTargetHeight: ->
                $(@slides.el).find(".slide.active img").height()

    #----------
    _.extend @OverlayNav.prototype, @Navigation


    #----------
                
    @NavigationLinks:
        Backbone.View.extend
            className: "pager-nav"

            events:
                'click .active': '_buttonClick'

            template:
                '''
                <a class="prev <%=prev_class%>"></a>
                <span class="page-count"><%=count%> of <%=total%></span>
                <a class="next <%=next_class%>"></a>
                '''
                
    #----------
    _.extend @NavigationLinks.prototype, @Navigation


    #----------

    @ThumbtrayToggler:
        Backbone.View.extend
            className: 'thumbtray-toggler'
            
            events:
                'click':    '_toggleThumbTray'

            _toggleThumbTray: ->
                @options.thumbtray.toggle()
                $(@el).toggleClass 'active'

    #----------

    @Thumbtray:
        Backbone.View.extend
            className: "thumbtray"

            events:
                "click .nav.active":    "_buttonClick"

            options:
                per_page: 5

            template:
                prev:
                    '''
                    <a class="nav prev <%=prev_class%>"></a>
                    '''
                next:       
                    '''
                    <a class="nav next <%=next_class%>"></a>
                    '''

            #----------

            initialize: ->
                @per_page   = @options.per_page
                @current    = @options.start
                @visible    = false

                @thumbnailView = new Slideshow.ThumbnailsView
                    collection: @collection
                    per_page:   @options.per_page   
                    thumbtray:  @

                @thumbs    = @thumbnailView.thumbs

                @current_page   = @_currentPage @current
                @total_pages    = @_currentPage @thumbs.length - 1
                
                $(@el).html     @thumbnailView.el
                $(@el).prepend  @_prevTemplate()
                $(@el).append   @_nextTemplate()
                
            #----------
            
            setCurrent: (idx) ->
                @current = idx
                @thumbnailView.setCurrent idx

                page = @_currentPage(idx)
                if page isnt @current_page
                    @switchTo page
                
            switchTo: (page) ->
                if page >= 1 and page <= @total_pages and page isnt @current_page
                    @current_page = page
                    $(@thumbnailView.el).stop(true, true).animate opacity: 0, 'fast', =>
                        @render()

            #----------

            toggle: ->
                if @visible then @hide() else @show()
                
            show: ->
                @current_page = @_currentPage @current
                @render()
                @thumbnailView.setCurrent @current
                $(@el).fadeIn()
                @visible = true

            hide: ->
                $(@el).fadeOut 75
                @visible = false

            #----------

            render: ->
                @thumbnailView.sliceThumbs @current_page
                @thumbnailView.render()

                @.$(".nav.prev").replaceWith @_prevTemplate()
                @.$(".nav.next").replaceWith @_nextTemplate()
                @
            
            #----------

            _prevTemplate: ->
                _.template @template.prev,
                    prev_class: @_activeIf @current_page > 1

            _nextTemplate: ->
                _.template @template.next,
                    next_class: @_activeIf @current_page < @total_pages

            _activeIf: (condition) ->
                if condition then "active" else "disabled"
                
            #----------

            _currentPage: (idx) ->
                Math.ceil (idx + 1) / @per_page

            #----------

            _buttonClick: (event) ->
                target = $(event.target)

                if target.hasClass 'next'
                    page = @current_page + 1
                else if target.hasClass 'prev'
                    page = @current_page - 1

                if page?
                    @switchTo page
           
 
    #----------

    @ThumbnailsView:
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

            sliceThumbs: (page) ->
                start = (page - 1) * @per_page
                end   = start + @per_page
                @thumbSlice = @thumbs.slice start, end
    
            #----------

            render: ->
                @.$(".thumbnail").removeClass 'current-set'
                
                _(@thumbSlice).each (thumb) ->
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
                    url: @model.get("urls")['thumb']
                @

            #----------

            _thumbClick: (evt) ->
                @thumbtray.trigger "switch", @index
                
    #----------
