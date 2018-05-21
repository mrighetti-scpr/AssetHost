# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# User.create username: "admin", is_admin: true, password: "password"

# [{"code"=>"thumb", "extension"=>"jpg", "id"=>1, "is_rich"=>false, "prerender"=>false, "size"=>"88x88#"},
#  {"code"=>"lsquare", "extension"=>"jpg", "id"=>2, "is_rich"=>false, "prerender"=>true, "size"=>"188x188#"},
#  {"code"=>"lead", "extension"=>"jpg", "id"=>3, "is_rich"=>false, "prerender"=>false, "size"=>"324x324>"},
#  {"code"=>"wide", "extension"=>"jpg", "id"=>4, "prerender"=>false, "size"=>"620x414>"},
#  {"code"=>"full", "extension"=>"jpg", "id"=>5, "is_rich"=>true, "prerender"=>true, "size"=>"1024x1024>"},
#  {"code"=>"three", "extension"=>"jpg", "id"=>6, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
#  {"code"=>"eight", "extension"=>"jpg", "id"=>8, "is_rich"=>true, "prerender"=>true, "size"=>"730x486>"},
#  {"code"=>"four", "extension"=>"jpg", "id"=>9, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
#  {"code"=>"six", "extension"=>"jpg", "id"=>10, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
#  {"code"=>"five", "extension"=>"jpg", "id"=>11, "is_rich"=>false, "prerender"=>false, "size"=>"600x334>"},
#  {"code"=>"small", "extension"=>"jpg", "id"=>12, "is_rich"=>false, "prerender"=>true, "size"=>"450x450>"},
#  {"code"=>"pixel", "extension"=>"jpg", "id"=>15, "is_rich"=>false, "prerender"=>false, "size"=>"1x1#"}]
# .each do |output|
#   Output.create(output)
# end

# Permission.create resource: "Asset", ability: "read"
# Permission.create resource: "Asset", ability: "write"
# Permission.create resource: "Output", ability: "read"
# Permission.create resource: "Output", ability: "write"

# Asset.reindex

# field :name,           type: String
# field :render_options, type: Array,   default: []
# field :prerender,      type: Boolean, default: false
# field :extension,      type: String
# field :created_at,     type: DateTime
# field :updated_at,     type: DateTime

# validates :name, uniqueness: true, presence: true
# validate  :check_extension
# validates_presence_of :options


# Asset.reindex

# o = Output.find_or_create_by({ name: "original", prerender: true, render_options: []})

# Output.first_or_create({
#   name: "thumb",
#   prerender: true,
#   render_options: [
#     {
#       name: "scale",
#       properties: {
#         width: 120,
#         height: 120
#       }
#     },
#     {
#       name: "crop",
#       properties: {
#         width: 120,
#         height: 120,
#         offsetX: 0,
#         offsetY: 0
#       }
#     }
#   ]
# })

[
  {"name" => "original", "prerender" => true},
  {"name"=>"thumb", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 88, 
        height: 88
      } 
    }, 
    {
      name: "crop", 
      properties: {
        width: 88, 
        height: 88
      }
    }
  ]},
  {"name"=>"lsquare", "prerender"=>true, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 188, 
        height: 188
      } 
    }, 
    {
      name: "crop", 
      properties: {
        width: 188, 
        height: 188
      }
    }
  ]},
  {"name"=>"lead", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 324, 
        height: 324
      } 
    }
  ]},
  {"name"=>"lead", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 324, 
        height: 324
      } 
    }
  ]},
  {"name"=>"wide", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 620, 
        height: 414
      } 
    }
  ]},
  {"name"=>"lead", "prerender"=>true, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 1024, 
        height: 1024
      } 
    }
  ]},
  {"name"=>"full", "prerender"=>true, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 1024, 
        height: 1024
      } 
    }
  ]},
  {"name"=>"three", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 600, 
        height: 350
      } 
    }
  ]},
  {"name"=>"eight", "prerender"=>true, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 730, 
        height: 486
      } 
    }
  ]},
  {"name"=>"four", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 600, 
        height: 350
      } 
    }
  ]},
  {"name"=>"six", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 600, 
        height: 350
      } 
    }
  ]},
  {"name"=>"five", "prerender"=>false, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 600, 
        height: 334
      } 
    }
  ]},
  {"name"=>"small", "prerender"=>true, "render_options": [
    { 
      name: "scale", 
      properties: {
        width: 450, 
        height: 450
      } 
    }
  ]}
]
.each do |output|
  Output.where(name: output["name"]).first_or_create(output)
end

