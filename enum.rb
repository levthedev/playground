module MyEnumerable
  def to_a
    each {|e| [] << e}
  end

  def count(&block)
    block ||= Proc.new { true }
    count = 0
    each {|e| count += 1 if block.call(e) }
    count
  end

  def find(&block)
    each { |e| return e if block.call(e) }
    nil
  end

  def find_all(&block)
    array = []
    each { |e| array << e if block.call(e) }
    array
  end

  def map(&block)
    array = []
    each { |e| array << block.call(e) }
    array
  end
end

RSpec.describe 'MyEnumerable' do
  class MyArray
    include MyEnumerable
    def initialize(array)
      @array = array
    end

    def each(&block)
      @array.each(&block)
    end
  end

  def assert_enum(array, method_name, *args, expected, &block)
    actual = MyArray.new(array).__send__(method_name, *args, &block)
    expect(actual).to eq expected
  end


  specify 'to_a returns an array of the items iterated over' do
    assert_enum [1,2,2], :to_a, [1,2,2]
  end

  describe 'count' do
    specify 'returns how many items the block returns true for' do
      assert_enum([],              :count, 0) { true }
      assert_enum(['a', 'a'],      :count, 2) { true }
      assert_enum(['a', 'b', 'a'], :count, 2) { |char| char == 'a' }
    end

    specify 'returns how many items are in the array, if no block is given' do
      assert_enum [],         :count, 0
      assert_enum ['a'],      :count, 1
      assert_enum ['a', 'a'], :count, 2
    end
  end

  specify 'find returns the first item where the block returns true' do
    assert_enum([],                       :find,   nil) { true }
    assert_enum([1, 2],                   :find,     1) { true }
    assert_enum(['a', 'bcd', 'a', 'xyz'], :find, 'bcd') { |str| str.length == 3 }
    assert_enum([1, 2],                   :find,   nil) { false }
  end

  specify 'find_all returns all the items where the block returns true' do
    assert_enum([], :find_all, []) { true }
    assert_enum([], :find_all, []) { false }

    ary = [1,2,1,3,2,6]
    assert_enum(ary, :find_all,       ary) { true }
    assert_enum(ary, :find_all,        []) { false }
    assert_enum(ary, :find_all, [1, 1, 3]) { |i| i.odd? }
    assert_enum(ary, :find_all, [2, 2, 6]) { |i| i.even? }
  end

  specify 'map returns an array of elements that have been passed through the block' do
    assert_enum([],         :map,         []) { 1 }
    assert_enum(['a', 'b'], :map,     [1, 1]) { 1 }
    assert_enum(['a', 'b'], :map, ['A', 'B']) { |char| char.upcase }
  end
end
