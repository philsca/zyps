require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

require 'zyps'
require 'zyps/environmental_factors'

include Zyps


describe Accelerator do

  subject do
    Accelerator.new
  end

  before(:each) do
    @environment = Environment.new
    @creature = Creature.new
    @environment << @creature << subject
    subject.clock.stub!(:elapsed_time).and_return(0.1)
  end

  it "should alter target's Vector" do
    @creature.vector = Vector.new(0, 0)
    subject.vector = Vector.new(1, 270)
    subject.act(@environment)
    @creature.vector.speed.should == 0.1
    @creature.vector.pitch.should == 270
  end
  
  it "should slow target if it's moving in opposite direction" do
    @creature.vector = Vector.new(1, 90)
    subject.vector = Vector.new(1, 270)
    subject.act(@environment)
    @creature.vector.speed.should == 0.9
    @creature.vector.pitch.should == 90
  end

end


describe Friction do

  before(:each) do
    @environment = Environment.new
    @creature = Creature.new
    @friction = Friction.new
    @environment << @creature << @friction
    @friction.clock.stub!(:elapsed_time).and_return(0.1)
  end

  it "should slow target" do
    @creature.vector = Vector.new(1, 90)
    @friction.force = 1
    @friction.act(@environment)
    @creature.vector.speed.should == 0.9
    @creature.vector.pitch.should == 90
  end

  it "should have a cumulative effect" do
    @creature.vector = Vector.new(1, 90)
    @friction.force = 1
    @friction.act(@environment)
    @creature.vector.speed.should == 0.9
    @friction.act(@environment)
    @creature.vector.speed.should == 0.8
  end
  
  it "should not reverse Vector of target" do
    @creature.vector = Vector.new(0, 0)
    @friction.force = 1
    @friction.act(@environment)
    @creature.vector.speed.should == 0
    @creature.vector.pitch.should == 0
  end

end