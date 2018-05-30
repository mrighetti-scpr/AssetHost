# if User.find_by(username: "admin")
#   User.create(username: "admin", password: "password", is_admin: true)
# end

# Output.find_or_create_by(name: "original")

Output.create(name: "thumb", prerender: false, render_options: [
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

Output.create(name: "lsquare", prerender: true, render_options: [
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

Output.create(name: "lead", prerender: false, render_options: [
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

Output.create(name: "wide", prerender: false, render_options: [
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

Output.create(name: "full", prerender: true, render_options: [
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

Output.create(name: "three", prerender: false, render_options: [
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


Output.create(name: "eight", prerender: true, render_options: [
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


Output.create(name: "four", prerender: false, render_options: [
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

Output.create(name: "six", prerender: false, render_options: [
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

Output.create(name: "five", prerender: false, render_options: [
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

Output.create(name: "small", prerender: true, render_options: [
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

