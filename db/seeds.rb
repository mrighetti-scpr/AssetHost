Asset.reindex

# if !User.find_by(username: "admin")
#   User.create(username: "admin", password: "password", is_admin: true)
# end

User.find_or_create_by(username: "admin").update(password: "password", is_admin: true)

Output.find_or_create_by(name: "original")

Output.find_or_create_by(name: "thumb").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 88
      },
      {
        name: "height",
        value: 88
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  },
  {
    name: "crop",
    properties: [
      {
        name: "width",
        value: 88
      },
      {
        name: "height",
        value: 88
      }
    ]
  }
])

Output.find_or_create_by(name: "lsquare").update(prerender: true, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 188
      },
      {
        name: "height",
        value: 188
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  },
  {
    name: "crop",
    properties: [
      {
        name: "width",
        value: 188
      },
      {
        name: "height",
        value: 188
      }
    ]
  }
])

Output.find_or_create_by(name: "lead").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 324
      },
      {
        name: "height",
        value: 324
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "wide").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 620
      },
      {
        name: "height",
        value: 414
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "full").update(prerender: true, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 1024
      },
      {
        name: "height",
        value: 1024
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "three").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 600
      },
      {
        name: "height",
        value: 350
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])


Output.find_or_create_by(name: "eight").update(prerender: true, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 730
      },
      {
        name: "height",
        value: 486
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])


Output.find_or_create_by(name: "four").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 600
      },
      {
        name: "height",
        value: 350
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "six").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 600
      },
      {
        name: "height",
        value: 350
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "five").update(prerender: false, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 600
      },
      {
        name: "height",
        value: 334
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

Output.find_or_create_by(name: "small").update(prerender: true, render_options: [
  {
    name: "scale",
    properties: [
      {
        name: "width",
        value: 450
      },
      {
        name: "height",
        value: 450
      },
      {
        name: "maintainRatio",
        value: true
      }
    ]
  }
])

