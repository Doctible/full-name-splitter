# -*- coding: utf-8 -*-
# requires full accessable first_name and last_name attributes
module FullNameSplitter

  PREFIXES = %w(de da la du del dei vda. dello della degli delle van von der den heer ten ter vande vanden vander voor ver aan mc).freeze

  class Splitter
    
    def initialize(full_name)
      @full_name  = full_name
      @first_name = []
      @last_name  = []
      split!
    end

    def split!
      if @full_name.include?(',')
        @units = @full_name.
          split(/\s*,\s*/, 2).reverse.    # ",George" produces  ["George", ""]
          map{ |u| u.empty? ? nil : u }   # but it should be ["George", nil] by lib convection
      else
        @units = @full_name.split(/\s+/)
      end
      while @unit = @units.shift do
        if prefix? or (first_name? and last_unit? and not initial?)
          @last_name << @unit and break
        else
          @first_name << @unit
        end
      end
      @last_name += @units

      adjust_exceptions!
      de_upcase!
    end

    def first_name
      @first_name.empty? ? nil : @first_name.join(' ')
    end

    def last_name
      @last_name.empty? ? nil : @last_name.join(' ')
    end

    private

    def prefix?
      PREFIXES.include?(@unit.downcase)
    end

    # M or W.
    def initial?
      @unit =~ /^\w\.?$/
    end

    def last_unit?
      @units.empty?
    end
    
    def first_name?
      not @first_name.empty?
    end
    
    def adjust_exceptions!
      return if @first_name.size <= 1
      
      # Adjusting exceptions like 
      # "Ludwig Mies van der Rohe"      => ["Ludwig",         "Mies van der Rohe"   ]
      # "Juan Martín de la Cruz Gómez"  => ["Juan Martín",    "de la Cruz Gómez"    ]
      # "Javier Reyes de la Barrera"    => ["Javier",         "Reyes de la Barrera" ]
      # Rosa María Pérez Martínez Vda. de la Cruz 
      #                                 => ["Rosa María",     "Pérez Martínez Vda. de la Cruz"]
      if last_name =~ /^(van der|(vda\. )?de la \w+$)/i
        loop do
          @last_name.unshift @first_name.pop
          break if @first_name.size <= 2
        end
      end
    end

    def de_upcase!
      @first_name = @first_name.map(&:capitalize) if all_caps? first_name
      @last_name = @last_name.map(&:capitalize) if all_caps? last_name
    end

    def all_caps? name
      name && name == name.upcase
    end
  end
  
  def full_name
    [first_name, last_name].compact.join(' ')
  end
  
  def full_name=(name)
    self.first_name, self.last_name = split(name)
  end

  private 
  
  def split(name)
    name = name.to_s.strip.gsub(/\s+/, ' ')

    splitter = Splitter.new(name)
    [splitter.first_name, splitter.last_name]
  end

  module_function :split
end
