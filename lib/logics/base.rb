module Make10; end

class Make10::Base
  def initialize(nums, opt = {})
    nums = nums.each_char.to_a if nums.is_a?(String)
    @nums = nums.map{|n| n.to_r}
    @target = (opt[:target] || 10).to_i
    @verbose = opt[:verbose]
    @output_io = opt.has_key?(:output) ? opt[:output] : nil
    @buffered_output = opt.has_key?(:buffered) ? opt[:buffered] : true
    @remove_redundant = opt.has_key?(:remove_redundant) ? opt[:remove_redundant] : true
  end

  def calc(opt = {})
    @verbose = opt[:verbose] if opt.has_key?(:verbose)
    @trials = 0
    @found = []
    @results = []

    _calc
    @results.sort_by!{|i| i.tr('+\-*/(', 'abcd@')}  # ( is to be later

    s = "found: #{@found.size}\n#{@verbose && "trials: #{@trials}\n"}"
    if @output_io
      @output_io.puts(@results) if @buffered_output
      @output_io.puts(s)
    end
    @results.unshift(s)
    @results
  end

  # shold be overrided in sub-class
  def _calc
    raise "you have to imprement your _calc"
  end

  # normalizations to remove the same result for human
  def nomalize_formula(s)
    if @verbose
      orig_s = s.dup
      r1 = eval(s.gsub(/\d/, '\&.0'))
    end
    s = s.dup

    # remove unnecessary parentheses
    # ((1 * 2) * 3) + 4
    while s =~ /([-\+\* ] |\(|^)\((\d(?: [\*\/] \d)+)\)( [-\+\* ]|\)|$)/
      s.gsub!(/([-\+\* ] |\(|^)\((\d(?: [\*\/] \d)+)\)( [-\+\* ]|\)|$)/, '\1\2\3')
    end
    # ((1 + 2) - 3) + 4, (1 + 2 * 3) + 4
    while s =~ /([\+ ] |\(|^)\((\d(?: [-\+\*\/] \d)+)\)( [-\+ ]|\)|$)/
      s.gsub!(/([\+ ] |\(|^)\((\d(?: [-\+\*\/] \d)+)\)( [-\+ ]|\)|$)/, '\1\2\3')
    end
    # sort some elems
    # 1 * 3 * 2 * 4  ->  1 * 2 * 3 * 4
    s.gsub!(/(\(|^| [-\+] )(\d(?: \* \d)+)/){
      a, b = $1, $2
      "#{a}#{b.split(/ \* /).sort.join(' * ')}"
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
      # validation
      begin
        r2 = eval(s.gsub(/\d/, '\&.0'))
        raise 'error' if r1 != r2
      rescue SyntaxError, ZeroDivisionError, RuntimeError
        raise "error: #{orig_s} = #{r1}, #{s} = #{r2}"
      end
    end
    s
  end

  def found(s)
    s = nomalize_formula(s)
    # check dict and show the result
    unless @found.index(s)
      output("#{s} = #{@target}")
      @found << s
    end
  end

  def output(str)
    @results << str
    @output_io.puts(str) if @output_io and not @buffered_output
  end

  def self.calc(nums, opt = {})
    self.new(nums, opt).calc
  end

  def self.cmdline
    require 'optparse'
    options = {output: STDOUT}
    opt = OptionParser.new(nil, 25, '  ')
    opt.on('-t', '--target=N', 'default: 10'){|v| options[:target] = v.to_i }
    opt.on('-b', '--no-buffered', 'default: results is buffered and sorted'){ options[:buffered] = false }
    opt.on('-s', '--simple', 'do simple algorithm, stop additional tuning'){ options[:remove_redundant] = false }
    opt.on('-v', '--verbose'){ options[:verbose] = true }
    opt.getopts
    if ARGV.size == 0
      puts opt.help
      exit
    end
    self.calc(ARGV.shift, options)
  end
end
