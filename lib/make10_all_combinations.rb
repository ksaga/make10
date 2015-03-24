require_relative 'make10_base'

class Make10AllCombinations < Make10Base
  def _calc
    calc_all_combinations
  end

  def calc_all_combinations
    @places_num = @nums.size - 1
    @signs_num  = @nums.size - 1
    place_c = sign_placing
    signs_c = [:+, :-, :*, :/].repeated_permutation(@signs_num).to_a
    nums_c  = @nums.permutation.to_a.uniq
    if @verbose
      p place_c; p place_c.size
      p signs_c; p signs_c.size
      p nums_c;  p nums_c.size
    end

    place_c.each do |l|
      signs_c.each do |s|
        ss = s.dup
        signs = l.dup.map{|n| ss.shift(n)}
        raise "error" unless ss.empty?
        nums_c.each do |n|
          @count += 1
          nums = n.dup
          fomula = nums.shift(1)
          fomula += [nums, signs].transpose.flatten
          r = rpn_calc(fomula)
          if r == @target
            found(rpn_to_s(fomula))
          else
            #output("#{rpn_to_s(fomula)} = #{r.is_a?(Numeric) ? r.to_f : r}")
          end
        end
      end
    end
    nil
  end

  def sign_placing
    piece = Array.new(@places_num, 0)
    piece[0] = 1
    base = @places_num.times.map{|n| piece.rotate(-n)}
    pattern = base.dup  # take one
    (@signs_num - 2).times do  # this -2 are taken above/below ones
      pattern = pattern.product(base).map do |aa,bb|
        ar = [aa,bb].transpose.map{|aaa,bbb| aaa+bbb}
        too_much = false
        ar.each_with_index do |n, i|
          if i + 1 < n
            too_much = true
          end
        end
        too_much ? nil : ar
      end.compact.uniq
    end
    pattern.each{|ar| ar[-1] += 1}  # take one
    pattern
  end

  # reverse polish notation calc
  def rpn_calc(fomula)
    fomula = fomula.dup
    stack = []
    while 0 < fomula.size
      e = fomula.shift
      if e.is_a?(Symbol)
        aa, bb = stack.pop(2)
        e = aa.send(e, bb)
      end
      stack << e
    end
    raise "error" unless 1 == stack.size
    stack.first
  rescue ZeroDivisionError
    ZeroDivisionError
  end

  # reverse polish notation show
  def rpn_to_s(fomula)
    fomula = fomula.map{|e| Numeric === e ? e.to_i : e}
    stack = []
    while 0 < fomula.size
      e = fomula.shift
      if e.is_a?(Symbol)
        aa, bb = stack.pop(2)
        #case e
        #when :*, :/, :-
        #  aa = "(#{aa})" if aa =~ /[-\+]/
        #  bb = "(#{bb})" if bb =~ /[-\+]/
        #  e = "#{aa} #{e} #{bb}"
        #else
        #  e = "#{aa} #{e} #{bb}"
        #end
        aa = "(#{aa})" if aa =~ /[-\+\*\/]/
        bb = "(#{bb})" if bb =~ /[-\+\*\/]/
        e = "#{aa} #{e} #{bb}"
      end
      stack << e.to_s
    end
    stack.join
  end
end

if __FILE__ == $0
  require 'optparse'
  result = 10
  opt = OptionParser.new
  opt.on('-r', '--result=N'){|v| result = v }
  Make10AllCombinations.new(ARGV.shift, target: result.to_i).calc
end
