require_relative 'base'

class Make10::MinCombinations < Make10::Base
  def _calc
    calc_min_combinations
  end

  def calc_min_combinations
    signs_num  = 3  #@nums.size - 1

    # [:-], [:/] means reverse :- and :/
    signs_c = [:+, :-, :*, :/, [:-], [:/]].repeated_permutation(signs_num).to_a

    # Case: 0 1 2 3 op1 op2 op3 -> ((0 op1 1) op2 2) op3 3
    #   2 and 3 can be switched
    #   so the needed numbers combination is as fllowings
    nums_c = [
      [0, 1, 2, 3],
      [0, 2, 1, 3],
      [0, 3, 1, 2],
      [1, 0, 2, 3],
      [1, 2, 0, 3],
      [1, 3, 0, 2],
      [2, 0, 1, 3],
      [2, 1, 0, 3],
      [2, 3, 0, 1],
      [3, 0, 1, 2],
      [3, 1, 0, 2],
      [3, 2, 0, 1]
    ]
    scan_cases(signs_c, nums_c){|s, n|
      n + s
    }

    # Case: 0 1 op1 2 3 op2 op3 -> (0 op1 1) op2 (2 op3 3)
    #   0 and 1, 2 and 3 can be switched respectively
    #   (0 1 pair) and (2 3 pair) can be switched
    #   so the needed numbers combination is as fllowings
    nums_c = [
      [0, 1, 2, 3],
      [0, 2, 1, 3],
      [0, 3, 1, 2]
    ]
    scan_cases(signs_c, nums_c){|s, n|
      [n[0], n[1], s[0], n[2], n[3], s[1], s[2]]
    }

    nil
  end

  def scan_cases(signs_c, nums_c, &fomula_proc)
    nums_c.map!{|a,b,c,d| [@nums[a], @nums[b], @nums[c], @nums[d]]}
    nums_c.uniq! if @remove_redundant
    print_params(signs_c, nums_c) if @verbose

    signs_c.each do |s|
      nums_c.each do |n|
        @trials += 1
        fomula = fomula_proc.call(s, n)
        r = rpn_calc(fomula)
        if r == @target
          found(rpn_to_s(fomula))
        end
      end
    end
  end

  # reverse polish notation calc
  def rpn_calc(fomula)
    stack = []
    fomula.each do |e|
      case e
      when Symbol
        aa, bb = stack.pop(2)
        e = aa.send(e, bb)
      when Array
        bb, aa = stack.pop(2)
        e = aa.send(e.first, bb)
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
      case e
      when Symbol
        aa, bb = stack.pop(2)
        aa = "(#{aa})" if aa =~ /[-\+\*\/]/
        bb = "(#{bb})" if bb =~ /[-\+\*\/]/
        e = "#{aa} #{e} #{bb}"
      when Array
        bb, aa = stack.pop(2)
        aa = "(#{aa})" if aa =~ /[-\+\*\/]/
        bb = "(#{bb})" if bb =~ /[-\+\*\/]/
        e = "#{aa} #{e.first} #{bb}"
      end
      stack << e.to_s
    end
    stack.join
  end

  def print_params(signs_c, nums_c)
    puts "Signs combination:"
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
  Make10::MinCombinations.cmdline
end
