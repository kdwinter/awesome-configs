#!/usr/bin/env ruby

class ProcFile
  include Enumerable

  def self.parse_file(file)
    file = File.expand_path(file, "/proc")
    new(File.new(file))
  end

  def initialize(string_or_io)
    case string_or_io
    when String
      content = string_or_io
    when IO
      content = string_or_io.read
      string_or_io.close
    end
    @list = [{}]
    content.each_line do |line|
      if sep = line.index(":")
        @list[-1][line[0..sep-1].strip] = line[sep+1..-1].strip
      else
        @list << {}
      end
    end
    @list.pop if @list[-1].empty?
  end

  def each
    @list.each do |section|
      yield section
    end
  end

  def [](section)
    @list[section]
  end
end

def get_frequency(cpu=0)
  @cpu = cpu
  @speed = []

  ProcFile.parse_file('cpuinfo').each_with_index do |info, cpu|
    @speed[cpu] = info['cpu MHz'].to_i
  end

  ghz = @speed[@cpu] / 1000
  if @speed[@cpu] >= 1000
    "<span color='#3099DD'>%3.2f</span>GHz" % ghz
  else
    "<span color='#3099DD'>#{@speed[@cpu]}</span>MHz"
  end
end

def get_temperature
  @temperature = 0

  IO.popen('sensors', IO::RDONLY) do |s|
    out = s.read
    temps = out.scan(/:\s+\+(\d+)/x).flatten
    temps.each { |temp| @temperature += temp.to_i }
    @temperature = @temperature / temps.size
  end

  "<span color='#3099DD'>#@temperature</span>°C"
end

puts "#{get_frequency} @ #{get_temperature} ::"
