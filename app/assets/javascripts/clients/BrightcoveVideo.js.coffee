window.BrightcoveVideos ?= {}

window.onTemplateLoaded = (id) ->
    @player = brightcove.api.getExperience(id)
    @modVP  = @player.getModule(brightcove.api.modules.APIModules.VIDEO_PLAYER)

window.onTemplateReady = (event) ->
    @BrightcoveVideos[@player.id].swap()



class AssetHost.Client.BrightcoveVideo
    DefaultOptions:
        playerKey:      "AQ~~,AAAAmtVKbGE~,pW41hkPiaos27C7knwyeOWQgVlG4w7v5"
        playerId:       "1247178207001"
        brightcoveJS:   "http://admin.brightcove.com/js/BrightcoveExperiences.js"

    template: JST['clients/templates/brightcove_embed']

    constructor: (el, options={}) ->
        @opts = _.defaults options, @DefaultOptions
        @el   = $(el) # The asset

        # we're given an img element.  we'll stick an overlay with a play
        # button on it, and then on click we'll launch the video

        # get width and height from the img
        @w = $(el).attr("width")
        @h = $(el).attr("height")

        # get videoid from data-ah-videoid attribute
        @videoid = @el.attr("data-ah-videoid")

        $(document).ready =>
            @launch()

    #----------

    launch: ->
        @el.parent().spin(color: "#fff", shadow: true)

        # render template
        @video = $ @template(
            width:      @w
            height:     @h
            videoid:    @videoid
            playerid:   @opts.playerId
            playerkey:  @opts.playerKey
        )

        window.BrightcoveVideos[$("object", @video).attr('id')] = @

        @el.after @video

        if window.brightcove?
            brightcove.createExperiences()
        else
            $.getScript @opts.brightcoveJS, ->
                brightcove.createExperiences()

    swap: ->
        @el.parent().spin(false)
        @el.hide()
        @video.show()
