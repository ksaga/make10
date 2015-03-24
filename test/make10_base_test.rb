require 'test/unit'
require_relative '../lib/logics/base'

class TestSample < Test::Unit::TestCase
  def test_nomalize_formula_dont_break_results
    nums_size = 4
    signs_c = [:+, :-, :*, :/].repeated_permutation(nums_size - 1).to_a
    patterns = [
      "4 %s 3 %s 2 %s 1",
      "(4 %s 3) %s 2 %s 1",
      "4 %s (3 %s 2) %s 1",
      "4 %s 3 %s (2 %s 1)",
      "(4 %s 3) %s (2 %s 1)",
      "((4 %s 3) %s 2) %s 1",
      "(4 %s (3 %s 2)) %s 1",
      "4 %s ((3 %s 2) %s 1)",
      "4 %s (3 %s (2 %s 1))"
    ]

    m = Make10::Base.new('0000')
    patterns.each do |pattern|
      signs_c.each do |signs|
        s = pattern % signs
        r1 = eval(s.gsub(/\d/, '\&.0'))
        ss = m.nomalize_formula(s)
        r2 = eval(ss.gsub(/\d/, '\&.0'))
        assert_equal(r1.round(6), r2.round(6))
      end
    end
  end
end
