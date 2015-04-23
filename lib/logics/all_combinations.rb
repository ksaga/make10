require_relative 'base'

class Make10::AllCombinations < Make10::Base
  def _calc
    calc_all_combinations
  end

  def calc_all_combinations
    signs_num  = @nums.size - 1
    place_c = sign_placing(@nums.size)
    signs_c = [:+, :-, :*, :/].repeated_permutation(signs_num).to_a
    nums_c  = @nums.permutation.to_a
    nums_c.uniq! if @remove_redundant
    print_params(place_c, signs_c, nums_c) if @verbose

    place_c.each do |l|
      signs_c.each do |s|
        ss = s.dup
        signs = l.dup.map{|n| ss.shift(n)}
        raise "error" unless ss.empty?
        nums_c.each do |n|
          @trials += 1
          nums = n.dup
          fomula = nums.shift(1)
          fomula += [nums, signs].transpose.flatten
          r = rpn_calc(fomula)
          if r == @target
            found(rpn_to_s(fomula))
          else
            # failed trial
            #output("#{rpn_to_s(fomula)} = #{r.is_a?(Numeric) ? r.to_f : r}")
          end
        end
      end
    end
    nil
  end

  def sign_placing(nums_size)
    # if nums_size == 4
    #   return [[1, 1, 1], [1, 0, 2], [0, 2, 1], [0, 1, 2], [0, 0, 3]]
    # end
    # actually the following is just for the nums_size != 4
    places_num = nums_size - 1
    signs_num  = nums_size - 1
    piece = Array.new(places_num, 0)
    piece[0] = 1
    base = places_num.times.map{|n| piece.rotate(-n)}
    pattern = base.dup  # take one
    (signs_num - 2).times do  # this -2 are taken above/below ones
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
    stack = []
    fomula.each do |e|
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
    fomula.each do |e|
      if e.is_a?(Symbol)
        aa, bb = stack.pop(2)
        aa = "(#{aa})" if aa =~ /[-\+\*\/]/
        bb = "(#{bb})" if bb =~ /[-\+\*\/]/
        e = "#{aa} #{e} #{bb}"
      end
      stack << e.to_s
    end
    stack.join
  end

  def print_params(place_c, signs_c, nums_c)
    puts "Sign positions combination after numbers for reverse polish notation:"
    print "[#{place_c.map(&:inspect).join(', ')}] "
    p place_c.size
    puts

    puts "Signs combination for each position:"
    puts "["
    signs_c.each_slice(4) do |l|
      l.each{|x| print " #{x.inspect},"}
      puts
    end
    print "] "
    p signs_c.size
    puts

    puts "Numbers combination:"
    puts "["
    nums_c.each_slice(4) do |l|
      l.each{|x| print " #{x.map{|n| n.to_i}},"}
      puts
    end
    print "] "
    p nums_c.size

    puts
    puts "Results:"
  end
end

if __FILE__ == $0
  Make10::AllCombinations.cmdline
end
