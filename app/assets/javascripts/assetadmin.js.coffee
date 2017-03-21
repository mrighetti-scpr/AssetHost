class AssetHost.AssetAdmin
    DefaultOptions:
        el:             ""
        replace:        ''
        replacePath:    ''

    constructor: (asset,options = {}) ->
        @options = _.defaults options, @DefaultOptions

        @asset      = new AssetHost.Models.Asset    asset
        @preview    = new AssetAdmin.PreviewView    model: @asset
        @form       = new AssetAdmin.FormView       model: @asset

        $( @options.el ).html @preview.el

        if @options.replace
            # set up replace image uploader
            @chooser = new AssetHost.ChooserUI
                dropEl:             @options.replace
                assets:             false
                uploads:            true
                limit:              1
                uploadPath:         @options.replacePath
                saveButton:         false
                afterUploadText:    "Refresh",
                afterUploadURL:     window.location

    #----------

    class @FormView extends Backbone.View
        el: "#editform"

    #----------

    class @PreviewView extends Backbone.View
        template: JST['templates/asset_preview']
        events:
            'click .asset_sizes li': '_sizeClick'

        initialize: ->
            @size = AssetHost.SIZES.detail
            @render()

        _sizeClick: (evt) ->
            size = $(evt.currentTarget).attr("data-size")

            if size != @size
                @size = size
                @render()

        render: ->
            $(@el).html @template
                asset: @model.toJSON()
                tag: @size

            @
