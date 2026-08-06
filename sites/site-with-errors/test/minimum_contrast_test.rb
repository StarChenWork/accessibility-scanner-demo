require "pathname"

BACKGROUND_COLOR = "#fdfdfd"
MINIMUM_CONTRAST_RATIO = 4.5
SITE_ROOT = Pathname(__dir__).join("..").expand_path
MAIN_SCSS_PATH = SITE_ROOT.join("assets/main.scss")

def assert(condition, message)
  return if condition

  warn(message)
  exit 1
end

def contrast_ratio(foreground_color, background_color)
  lighter, darker = [relative_luminance(foreground_color), relative_luminance(background_color)].minmax.reverse
  (lighter + 0.05) / (darker + 0.05)
end

def relative_luminance(hex_color)
  rgb = hex_color.delete_prefix("#").scan(/../).map { |component| component.to_i(16) / 255.0 }
  red, green, blue = rgb.map { |component| linearize(component) }

  (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
end

def linearize(component)
  return component / 12.92 if component <= 0.03928

  ((component + 0.055) / 1.055) ** 2.4
end

scss = MAIN_SCSS_PATH.read
grey_color_match = scss.match(/^\$grey-color:\s*(#[0-9a-fA-F]{6});$/)

assert(grey_color_match, "Expected assets/main.scss to override $grey-color")
assert(scss.match?(/^\s*@import\s+"minima";$/m), 'Expected assets/main.scss to import "minima"')
assert(scss.index(grey_color_match[0]) < scss.index('@import "minima";'), "Expected $grey-color override to appear before the minima import")
assert(contrast_ratio(grey_color_match[1], BACKGROUND_COLOR) >= MINIMUM_CONTRAST_RATIO, "Expected overridden grey color to meet WCAG AA contrast on the Minima page background")

puts "contrast regression check passed"
