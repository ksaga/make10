module Make10
  def self.calc(nums, opt = {})
    case opt[:logic]
    when :all_combinations
      require_relative 'logics/all_combinations'
      AllCombinations.calc(nums, opt)

    when :recursive
      require_relative 'logics/recursive'
      Recursive.calc(nums, opt)

    when :min_combinations, nil
      require_relative 'logics/min_combinations'
      MinCombinations.calc(nums, opt)

    end
  end

  def self.cmdline
    require 'optparse'
    options = {output: STDOUT}
    opt = OptionParser.new(nil, 25, '  ')
    opt.on('-l', '--logic=LOGICNAME', 'recursive (default) or all_combinations'){|v| options[:logic] = v.to_sym }
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

if __FILE__ == $0
  Make10.cmdline
end
