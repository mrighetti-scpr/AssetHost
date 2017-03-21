# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

User.create username: "eddiecaspian", is_admin: true, password: "liebeistfuralleda"

[{"code"=>"thumb", "extension"=>"jpg", "id"=>1, "is_rich"=>false, "prerender"=>false, "size"=>"88x88#"},
 {"code"=>"lsquare", "extension"=>"jpg", "id"=>2, "is_rich"=>false, "prerender"=>true, "size"=>"188x188#"},
 {"code"=>"lead", "extension"=>"jpg", "id"=>3, "is_rich"=>false, "prerender"=>false, "size"=>"324x324>"},
 {"code"=>"wide", "extension"=>"jpg", "id"=>4, "is_rich"=>true, "prerender"=>false, "size"=>"620x414>"},
 {"code"=>"full", "extension"=>"jpg", "id"=>5, "is_rich"=>true, "prerender"=>true, "size"=>"1024x1024>"},
 {"code"=>"three", "extension"=>"jpg", "id"=>6, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
 {"code"=>"eight", "extension"=>"jpg", "id"=>8, "is_rich"=>true, "prerender"=>true, "size"=>"730x486>"},
 {"code"=>"four", "extension"=>"jpg", "id"=>9, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
 {"code"=>"six", "extension"=>"jpg", "id"=>10, "is_rich"=>false, "prerender"=>false, "size"=>"600x350>"},
 {"code"=>"five", "extension"=>"jpg", "id"=>11, "is_rich"=>false, "prerender"=>false, "size"=>"600x334>"},
 {"code"=>"small", "extension"=>"jpg", "id"=>12, "is_rich"=>false, "prerender"=>true, "size"=>"450x450>"},
 {"code"=>"pixel", "extension"=>"jpg", "id"=>15, "is_rich"=>false, "prerender"=>false, "size"=>"1x1#"}]
.each do |output|
  Output.create(output)
end