#import "@preview/polylux:0.4.0" as pl: *

#let slide_fg-color = state("fg_color", none)
#let slide_bg-color = state("bg_color", none)
#let slide_accent_fg-color = state("accent_fg_color", none)
#let slide_accent_bg-color = state("accent_bg_color", none)
#let slide_size = state("size", none)
#let slide_padding = state("padding")
#let slide_progress-indicator = state("progress-indicator", none)

#let slide-template(
  aspect-ratio: "16-9", // 16-9 or 4-3
  size: 20pt,
  fg-color: black,
  bg-color: white,
  accent-fg-color: white,
  accent-bg-color: rgb("#000055"),
  padding: 1.5em,
  progress-indicator: "progress", // none, dots, count, progress
  body,
) = {
  slide_fg-color.update(fg-color)
  slide_bg-color.update(bg-color)
  slide_accent_fg-color.update(accent-fg-color)
  slide_accent_bg-color.update(accent-bg-color)
  slide_size.update(size)
  slide_padding.update(padding)
  slide_progress-indicator.update(progress-indicator)

  set page(
    paper: "presentation-" + aspect-ratio,
    fill: bg-color,
    margin: 0pt,
    header: none,
    footer: none,
    header-ascent: 0pt,
    footer-descent: 0pt,
  )

  set text(
    fill: fg-color,
    size: size,
  )

  body
}

// Dot
#let slide(
  title: none,
  new-section: false, // If it should count in TOC
  progress-indicator: true,
  hide-header: false, // Should hide the section name
  padding: true,
  count-slide: true,
  body,
) = context {
  if new-section {
    if title != none {
      pl.toolbox.register-section(title)
    } else {
      panic("A title is required for a new section")
    }
  }

  let slide_padding = slide_padding.get()
  let accent-bg-color = slide_accent_bg-color.get()
  let accent-fg-color = slide_accent_fg-color.get()
  let normal-bg-color = slide_bg-color.get()
  let normal-fg-color = slide_fg-color.get()
  let slide_size = slide_size.get()

  let progress(fill) = context {
    let last = counter("logical-slide").final().first()
    let current = counter("logical-slide").get().first()
    let current = if count-slide { current } else { current - 1 }
    set text(size: slide_size, fill: fill)

    let method = slide_progress-indicator.get()

    if method == "none" {} else if method == "count" {
      set text(size: 0.8em)
      [*#current / #last*]
    } else if (
      method == "progress"
    ) {
      set text(size: 0.5em)
      let ratio = current / last * 100%
      block(width: 10em, height: 1em, radius: 100%)[
        #place(left)[#rect(width: 10em, height: 100%, radius: 100%, stroke: fill)]
        #place(left)[#rect(width: ratio, height: 100%, radius: 100%, fill: fill)]
      ]
    } else if method == "dots" {
      set text(size: 0.8em)
      let over_current = false
      for i in range(1, last + 1) {
        if current == i {
          $compose.o$
          over_current = true
        } else if (over_current) {
          $circle.stroked$
        } else { $circle.filled$ }
        h(0.1em)
      }
    } else {
      panic("progress-indicator must be either 'none', 'dots', 'count', or 'progress'")
    }

    let limit = calc.ceil(last / 2)

    // [#pl.toolbox.progress-ratio()]
    // TODO: Find page the logical slide is on
  }

  let progress_filled = {
    set align(left)
    if hide-header {
      progress(accent-bg-color)
    } else {
      progress(accent-fg-color)
    }
  }
  let header = {
    set text(fill: accent-fg-color)
    set align(horizon + left)
    pad(rest: slide_padding, {
      place(horizon + left, [= #title])
    })
  }

  let content = {
    if hide-header {
      block(width: 100%, height: 100%, pad(
        rest: if padding { slide_padding } else { 0em },
        {
          set heading(offset: 1)
          body
        },
      ))
    } else {
      block(fill: accent-bg-color, width: 100%, header)
      v(-1cm)
      block(fill: normal-bg-color, width: 100%, height: 1fr, pad(
        rest: if padding { slide_padding } else { 0em },
        {
          set heading(offset: 1)
          body
        },
      ))
    }
  }


  pl.slide({
    set text(size: slide_size)
    content
    if progress-indicator {
      place(top + right, dy: slide_padding + -0.4em, dx: -slide_padding, progress_filled)
    }
  })

  if not count-slide {
    counter("logical-slide").update(n => n - 1)
  }
}


#let toc-slide(title: none) = context {
  set page(
    margin: (top: 0cm, bottom: 0cm),
    header: none,
    footer: none,
    fill: slide_accent_bg-color.get(),
  )

  // TOC
  let content = {
    if title != none {
      align(center, text(size: 1.2em, weight: "bold", title))
      v(-0.5em)
    }
    pl.toolbox.all-sections((sections, current) => {
      for i in sections [
        + #text(i)
      ]
    })
  }

  pl.slide({
    set align(horizon + center)
    set text(
      size: slide_size.get() * 1.2,
      fill: slide_accent_fg-color.get(),
    )
    show: box
    set align(left)
    content
  })

  counter("logical-slide").update(n => n - 1)
}


#let title-slide(
  title: "title",
  subtitle: "subtitle",
  authors: "auther",
  date: "01.01.2026",
  body: none,
) = context {
  set text(
    size: slide_size.get(),
  )

  let slide_padding = slide_padding.get()
  let accent-bg-color = slide_accent_bg-color.get()
  let accent-fg-color = slide_accent_fg-color.get()
  let normal-bg-color = slide_bg-color.get()
  let normal-fg-color = slide_fg-color.get()


  let content = grid(
    inset: slide_padding,
    columns: 1fr,
    rows: (5fr, 4fr),
    fill: (x, y) => {
      if y == 0 { accent-bg-color } else { normal-bg-color }
    },
    [
      #set text(fill: accent-fg-color, size: 1.2em)
      #set align(left + bottom)
      = #title
    ],
    [
      #set text(fill: normal-fg-color)
      #set align(left + top)
      #show heading.where(level: 2): it => {
        text(fill: accent-bg-color, it.body)
      }
      // #show heading.where(level: 2): it => {
      //   text(fill: accent_fill_bg, it.body)
      // }
      == #subtitle\
      #date
      #set align(left + bottom)
      #authors
    ]
  )

  pl.slide({ content })

  counter("logical-slide").update(n => n - 1)
}

#let empty-slide(
  title: none,
  new-section: false, // If it should count in TOC
  progress-indicator: false,
  hide-header: true, // Should hide the section name
  padding: true,
  count-slide: false,
  body,
) = slide(
  title: title,
  new-section: new-section,
  progress-indicator: progress-indicator,
  hide-header: hide-header,
  padding: padding,
  count-slide: count-slide,
  body,
)

