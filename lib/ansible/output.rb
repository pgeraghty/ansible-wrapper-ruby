require 'strscan'
require 'erb'

module Ansible
  # Output module provides formatting of Ansible output
  module Output
    # Generate HTML for an output string formatted with ANSI escape sequences representing colours and styling
    # @param ansi [String] an output string formatted with escape sequences to represent formatting
    # @param stream [String] a stream or string (that supports +<<+) to which generated HTML will be appended
    # @return the stream provided or a new String
    # @example List hosts with an inline inventory that only contains localhost
    #   to_html "\e[90mGrey\e[0m" => '<span style="color: grey;">Grey</span>'
    def self.to_html(ansi, stream='')
      Ansi2Html.new(ansi).to_html stream
    end

    # Converter for strings containing with ANSI escape sequences
    class Ansi2Html
      # Hash of colors to convert shell colours to CSS
      COLOR = {
        '1' => 'font-weight: bold',
        '30' => 'color: black',
        '31' => 'color: red',
        '32' => 'color: green',
        '33' => 'color: yellow',
        '34' => 'color: blue',
        '35' => 'color: magenta',
        '36' => 'color: cyan',
        '37' => 'color: white',
        '90' => 'color: grey'
      }

      SUPPORTED_STYLE_PATTERN = /\e\[([0-1])?[;]?(3[0-7]|90|1)m/
      END_ESCAPE_SEQUENCE_PATTERN = /\e\[0m/
      UNSUPPORTED_STYLE_PATTERN = /\e\[[^0]*m/
      IGNORED_OUTPUT = /./m

      OPEN_SPAN_TAG = %{<span>}
      CLOSE_SPAN_TAG = %{</span>}

      # Create StringScanner for string
      # @param line [String] a stream or string (that supports +<<+) to which generated HTML will be appended
      def initialize(line)
        # ensure any HTML tag characters are escaped
        @strscan = StringScanner.new(ERB::Util.h line)
      end

      # Generate HTML from string formatted with ANSI escape sequences
      # @return [String, IO] the HTML
      def to_html(stream)
        until @strscan.eos?
          stream << generate_html
        end

        stream
      end


      private

      # Scan string and generate HTML
      def generate_html
        if @strscan.scan SUPPORTED_STYLE_PATTERN
          open_tag
        elsif @strscan.scan END_ESCAPE_SEQUENCE_PATTERN
          CLOSE_SPAN_TAG
        elsif @strscan.scan UNSUPPORTED_STYLE_PATTERN
          OPEN_SPAN_TAG
        else
          @strscan.scan IGNORED_OUTPUT
        end
      end

      # Generate opening HTML tag, which may contain a style attribute
      # @return [String] opening tag
      def open_tag
        bold, colour = @strscan[1], @strscan[2]
        styles = []

        styles << COLOR[bold] if bold.to_i == 1
        styles << COLOR[colour]

        # in case of invalid colours, although this may be impossible
        if styles.compact.empty?
          OPEN_SPAN_TAG
        else
          %{<span style="#{styles*'; '};">}
        end
      end
    end
  end
end