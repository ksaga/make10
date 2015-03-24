module Make10; end

class Make10::Base
  def initialize(nums, opt = {})
    nums = nums.each_char.to_a if nums.is_a?(String)
    @nums = nums.map{|n| n.to_r}
    @target = opt[:target] || 10
    @count = 0
    @found = []
    @output_io = opt.has_key?(:output) ? opt[:output] : STDOUT
  end

  def calc(opt = {})
    @verbose = opt[:verbose]
    @results = []
    _calc
    output("found: #{@found.size}")
    output("count: #{@count}") if @verbose
    @results
  end

  # shold be overrided in sub-class
  def _calc
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
