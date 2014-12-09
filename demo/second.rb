#!/usr/bin/env ruby
require 'chunky_png'

class Visualizer
  def initialize(file, scale)
    @file = file
    @scale = scale
    @prefix = File.basename(file, ".csv")
  end

  def run
    data = File.readlines(@file)

    imgnum = 0
    while line = data.shift
      imgnum += 1
      puts "Image #{imgnum}"

      pic = line.split(',').map(&:to_i)

      width = 20
      height = 20

      png = ChunkyPNG::Image.new(width * @scale, height * @scale, ChunkyPNG::Color::WHITE)

      (width*@scale).times do |i|
        (height*@scale).times do |j|
          if pic[(j/@scale)*width + i/@scale] == 1
            png[i, j] = ChunkyPNG::Color::BLACK
          end
        end
      end
      png.save("pic_#{@prefix}_#{imgnum}.png", interlace: true)
    end
  end
end

if $0 == __FILE__
  file = ARGV.shift
  scale = ARGV.shift
  unless file
    puts "Usage: #{$0} [file] [scale=1]"
    exit
  end

  scale ||= 10
  scale = scale.to_i

  Visualizer.new(file, scale).run
end
