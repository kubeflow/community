// Usage: typst compile thumbnail.typ out.png --input date="April 24, 2026" --input title="My Meeting Title"
#let meeting-date = sys.inputs.at("date", default: "April 24, 2026")
#let meeting-title = sys.inputs.at("title", default: "Notebooks 2.0 + WG Meeting")
#let meeting-group = sys.inputs.at("group", default: "NOTEBOOKS WG")

// 640pt × 360pt at default 144 PPI → 1280×720px output
#set page(
  width: 640pt,
  height: 360pt,
  margin: 0pt,
)

#set text(font: ("Lato", "Lato", "Lato"), fill: white)

// Kubeflow social card as full-bleed background
#place(top + left,
  image("social_base.png", width: 100%, height: 100%, fit: "cover")
)

// Dark gradient over the bottom half to ensure text readability
#place(bottom + left,
  rect(
    width: 100%,
    height: 55%,
    fill: gradient.linear(
      rgb(15, 23, 68, 0),
      rgb(15, 23, 68, 210),
      angle: 90deg,
    )
  )
)

// Meeting info in the lower half
#place(top + left, dx: 50pt, dy: 170pt,
  box(width: 580pt)[
    #text(size: 18pt, fill: rgb("#7eb3ff"), tracking: 2pt, weight: "bold")[#meeting-group]
    #v(3pt)
    #text(size: 34pt, weight: "bold")[#meeting-title]
    #v(3pt)
    #text(size: 20pt, fill: rgb("#c0d4f0"))[#meeting-date]
  ]
)
