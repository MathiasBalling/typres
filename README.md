# Typres

Template for presentations in Typst.

## Installation

```bash
git clone https://github.com/MathiasBalling/typres
# Or add as submodule
git submodule add https://github.com/MathiasBalling/typres
```

## Example usage

```typst
#import "typres/lib.typ": *

// Use this for defaults
#show: typres-template.with()
// Or customize it
#show: typres-template.with(
  aspect-ratio: "16-9", // 16-9 or 4-3
  size: 20pt, // Size of text
  fg-color: black, // Text color
  bg-color: white, // Background color
  accent-fg-color: white, // Accent text color
  accent-bg-color: rgb("#000055"), // Accent background color
  padding: 1.5em, // Padding around the slide
  progress-indicator: "progress", // none, dots, count, progress
)

// Built-in title slides: title-slide, toc-slide, slide, empty-slide
#title-slide(
  title: "Main Title",
  subtitle: "Subtitle",
  authors: "Auther",
  date: "01.01.2026",
)

#toc-slide(title: "Outline")

#slide(
  title: none,
  new-section: false, // If it should be in the TOC
  progress-indicator: true, // Show progress indicator
  hide-header: false, // Should hide the section name
  padding: true, // Apply the padding around the slide
  count-slide: true, // Count the slide in the progress indicator
)[= Example slide]

#empty-slide()
```
