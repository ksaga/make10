class Make10
  def initialize(nums, opt = {})
    nums = nums.each_char.to_a if nums.is_a?(String)
    @nums = nums.map{|n| n.to_r}
    @target = opt[:target] || 10
    @count = 0
    @found = []
    @output_io = opt.has_key?(:output) ? opt[:output] : STDOUT
  end

  def calc(opt = {logic: :recursive})
    @verbose = opt[:verbose]
    @results = []
    case opt[:logic]
    when :all_combinations
      calc_all_combinations
    else
      calc_recursive([], *@nums)
    end
    output("found: #{@found.size}")
    output("count: #{@count}") if @verbose
    @results
  end

  def found(s)
    if @verbose
      orig_s = s.dup
      r1 = eval(s.gsub(/\d/, '\&.0'))
    end
    # remove unnecessary parentheses
    # ((1 * 2) * 3) + 4
    while s =~ /([-\+\* ] |\(|^)\((\d(?: \* \d)+)\)( [-\+\* ]|\)|$)/
      s.gsub!(/([-\+\* ] |\(|^)\((\d(?: \* \d)+)\)( [-\+\* ]|\)|$)/, '\1\2\3')
    end
    # ((1 + 2) - 3) + 4, (1 + 2 * 3) + 4
    while s =~ /([\+ ] |\(|^)\((\d(?: [-\+\*\/] \d)+)\)( [-\+ ]|\)|$)/
      s.gsub!(/([\+ ] |\(|^)\((\d(?: [-\+\*\/] \d)+)\)( [-\+ ]|\)|$)/, '\1\2\3')
    end
    # sort some elems
    # 1 * 3 * 2 * 4  ->  1 * 2 * 3 * 4
    s.gsub!(/( |\(|^| [-\+] )(\d(?: \* \d)+)( [-\+\/] |\)|$)/){
      a, b, c = $1, $2, $3
      "#{a}#{b.split(/ \* /).sort.join(' * ')}#{c}"
    }
    # 1 - 3 + 2 + 4  ->  1 + 2 + 4 - 3
    s.gsub!(/(\(|^| [-\+] )(\d(?: [-\+] \d)+)(\)|$| [-\+])/){
      a, b, c = $1, $2, $3
      if a =~ / [-\+] /
        b = "#{a}#{b}"
        "#{b.scan(/ [-\+] \d/).sort.join}#{c}"
      else
        b = " + #{b}"
        "#{a}#{b.scan(/ [-\+] \d/).sort.join.sub(/^ \+ /,'')}#{c}"
      end
    }
    if @verbose
      begin
        r2 = eval(s.gsub(/\d/, '\&.0'))
        raise 'error' if r1 != r2
      rescue SyntaxError, ZeroDivisionError, RuntimeError
        raise "error: #{orig_s} = #{r1}, #{s} = #{r2}"
      end
    end
    # check dict and show the result
    unless @found.index(s)
      output("#{s} = #{@target}")
      @found << s
    end
  end

  def calc_recursive(fomula, *nums)
    @count += 1
    if nums.size == 1
      if nums.first == @target
        found(fomula.first)
      else
        #output("#{fomula.first} = #{@target}")
      end
      return
    end
    pos = (0..(nums.size - 1)).to_a.combination(2).to_a
    pos.each do |pos_a, pos_b|
      nn = nums.dup
      ff = fomula.dup
      bb = nn.delete_at(pos_b)
      bbs = bb.to_f.to_s.sub(/\.0$/,'')
      bbs = "(#{ff.delete_at(pos_b)})" if ff[pos_b]
      aa = nn.delete_at(pos_a)
      aas = aa.to_f.to_s.sub(/\.0$/,'')
      aas = "(#{ff.delete_at(pos_a)})" if ff[pos_a]
      calc_recursive(["#{aas} + #{bbs}", *ff], aa + bb, *nn)
      calc_recursive(["#{aas} - #{bbs}", *ff], aa - bb, *nn)
      calc_recursive(["#{aas} * #{bbs}", *ff], aa * bb, *nn)
      calc_recursive(["#{aas} / #{bbs}", *ff], aa / bb, *nn) unless bb == 0
      calc_recursive(["#{bbs} - #{aas}", *ff], bb - aa, *nn)
      calc_recursive(["#{bbs} / #{aas}", *ff], bb / aa, *nn) unless aa == 0
    end
    nil
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

  def output(str)
    @results << str
    @output_io.puts(str) if @output_io
  end
end

if __FILE__ == $0
  require 'optparse'
  result = 10
  opt = OptionParser.new
  opt.on('-r', '--result=N'){|v| result = v }
  Make10.new(ARGV.shift, target: result.to_i).calc
end
