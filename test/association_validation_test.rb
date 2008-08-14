require File.dirname(__FILE__) + '/test_helper'

class Foo < ActiveRecord::Base
  has_one :bar, :validate => true
  has_one :bar2, :class_name => "Bar", :validate => false
end

class Bar < ActiveRecord::Base

  validates_presence_of :zeta 
end

class AssociationValidationTest < ActiveSupport::TestCase
  def test_truth
    assert true
  end

  def setup
    ActiveRecord::Base.connection.create_table :foos do |foo|
      foo.string :bar
    end
    ActiveRecord::Base.connection.create_table :bars do |bar|
      bar.belongs_to :foo
      bar.string :zeta
    end

    @foo = Foo.new
    @bar = Bar.new
  end

  def test_has_one_with_validation
    assert @foo.valid?, "Foo should be valid because @bar is nil and there is no presence validation."

    @foo.bar = @bar
    assert !@foo.valid?, "Foo should be still invalid since bar is invalid."
    assert @foo.errors.on(:bar) =~ /zeta/i, "Foo should have complains about bar's zeta, but was: #{@foo.errors.on(:bar).inspect}."

    @bar.zeta = "zeta"
    assert @foo.valid?, "Foo should be valid since bar is valid."

    @foo.bar2 = Bar.new

    assert !@foo.bar2.valid?, "bar2 should be invalid since zeta was not specified."
    assert @foo.valid?, "@foo should be valid anyway since :validate is false for bar2."
  end

  def teardown
    ActiveRecord::Base.connection.drop_table :bars
    ActiveRecord::Base.connection.drop_table :foos
  end
end
