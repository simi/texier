require "#{File.dirname(__FILE__)}/../module"

module Texier::Modules
  # This module provides headings.
  #
  # How are the heading levels computed?
  #
  # The final heading level (h1, h2, ..., h6) of each heading depends on several
  # things:
  #
  # 1. It's relative level. This is determined by what character is used to
  #   underline the heading (in case of underlined style), or how many "#" or
  #   "=" characters are in front of it (in case of surrounded style).
  #
  #   Relative levels of underlined headings are determined by the "levels"
  #   option, which is a hash, where each character is maped to corresponding
  #   level.
  #
  #   Relative level of surrouned headings depends on the "more_means_higher"
  #   option. If it is true, then more characters in front of heading means
  #   higher relative level, otherwise, more characters means lower level.
  #
  # 2. The balancing mode (determined by the "balancing" option). If it is set
  #   to :fixed, no further calculations are performed. If it is set to :dynamic
  #   (which is default), Then the heading(s) with highest relative level (among
  #   all headings in he whole document) will be assigned level 1, the heading
  #   with second highest level 2, and so on. For example, if there are two
  #   headings in the document, one has relative level 2 and the other 4, then
  #   their final levels will be 1 and 2.
  #
  # 3. The value of the "top" option. This value is added to the levels at the
  #   end. Using this, the level of topmost heading can be set (by default, it
  #   is 1)
  class Heading < Texier::Module
    # Content of the first heading.
    attr_reader :title

    # Generated table of contents.
    attr_reader :toc

    options(
      # Autogenerate id's of heading
      :generate_id => false,

      # Prefix of autogenerated id's
      :id_prefix => 'toc-',

      # Level of top-level heading (1..6)
      :top => 1,

      # For surrounded headings: more #### means higher level.
      :more_means_higher => true,

      # Balancing mode (:dynamic or :fixed).
      :balancing => :dynamic,

      # Styles of underlined headings.
      :levels => {
        '#' => 0,
        '*' => 1,
        '=' => 2,
        '-' => 3
      }
    )

    block_element('surrounded') do
      # Surrounded headings
      marker = e(/ *(\#{2,}|={2,}) +/) do |line|
        # Calculate relative level of heading according to length of the marker.
        level = [line.strip.length, 7].min
        level = 7 - level if more_means_higher
        level
      end
      
      tail = discard(/ *(\#{2,}|={2,})? */) & optional(modifier) & discard(/$/)

      heading = marker & one_or_more(inline_element).up_to(tail)
      heading.map do |level, content, modifier|
        create_element(level, content, modifier)
      end
    end

    block_element('underlined') do
      # Underlined headings
      underline = empty
      levels.each do |char, value|
        underline << e(/ *#{Regexp.quote(char)}{3,} */) {value}
      end
      
      tail = optional(modifier) & discard("\n")

      heading = one_or_more(inline_element).up_to(tail) & underline
      heading.map do |content, modifier, level|
        create_element(level, content, modifier)
      end
    end

    def before_parse(input)
      @title = nil
      @toc = []
      @used_ids = {}

      input
    end

    def after_parse(dom)
      if balancing == :dynamic
        # Find highest heading level, then second highest, and so on. Then
        # create mapping table, where the highest level will be mapped to level
        # 1, second highest to level 2, and so on. Then modify levels of
        # headings according to this table.

        mapping = {}
        used_levels = {}
        toc.each do |element|
          used_levels[element.level] = true
        end

        used_levels = used_levels.keys.sort
        used_levels.each_with_index do |level, index|
          mapping[level] = [index + top, 6].min
        end

        # Assign new levels.
        toc.each do |element|
          element.name = "h#{mapping[element.level]}"
        end
      end

      # Remove "level" attributes.
      toc.each do |element|
        element.level = nil
      end
    end

    private

    # Create Heading dom element
    def create_element(level, content, modifier)
      heading = Texier::Element.new("h#{level + 1}", content, 'level' => level)
      heading.modify!(modifier)
      heading.id ||= auto_id(content)

      @title ||= Texier::Renderer.new.render_text(heading)
      @toc << heading

      heading
    end

    # Autogenerate unique id for heading.
    def auto_id(content)
      return nil unless generate_id

      id = Texier::Renderer.new.render_text(content)
      id = id_prefix + Texier::Utilities.webalize(id)
      id = Texier::Utilities.sequel(id) while @used_ids[id]

      @used_ids[id] = true
      id
    end
  end
end