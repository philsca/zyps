# Copyright 2007 Jay McGavren, jay@mcgavren.com.
# 
# This file is part of Zyps.
# 
# Zyps is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


require 'zyps'
require 'zyps/actions'
require 'test/unit'


include Zyps


#Allowed deviation for assert_in_delta.
REQUIRED_ACCURACY = 0.001


#Redefine Clock to return a predictable time.
ELAPSED_TIME = 0.1
class Clock
	def elapsed_time; ELAPSED_TIME; end
end


class TestActions < Test::Unit::TestCase


	#Create and populate an environment.
	def setup
		@actor = Creature.new(:name => 'actor', :location => Location.new(0, 0))
		@target1 = Creature.new(:name => 'target1', :location => Location.new(1, 1))
		@target2 = Creature.new(:name => 'target2', :location => Location.new(-2, -2))
		#Create an environment, and add the objects.
		@environment = Environment.new
		#Order is important - we want to act on target 1 first.
		@environment.objects << @actor << @target1 << @target2
	end
	
	#Add a new behavior to a creature with the given action.
	def add_action(action, creature)
		behavior = Behavior.new
		behavior.actions << action
		creature.behaviors << behavior
	end


	#A FaceAction turns directly toward the target.
	def test_face_action
		add_action(FaceAction.new, @actor)
		@environment.interact
		assert_in_delta(45, @actor.vector.pitch, REQUIRED_ACCURACY)
	end
	
	
	#An AccelerateAction speeds up the actor at a given rate.
	def test_accelerate_action
		#Accelerate 1 unit per second.
		add_action(AccelerateAction.new(1), @actor)
		@environment.interact
		#Clock always returns 0.1 seconds, so actor should be moving 0.1 unit/second faster.
		assert_in_delta(0.1, @actor.vector.speed, REQUIRED_ACCURACY)
	end
	
	
	#A TurnAction turns the actor at a given rate.
	def test_turn_action
		@actor.vector = Vector.new(1, 0)
		#Turn 45 degrees off-heading at 1 unit/second.
		add_action(TurnAction.new(1, 45), @actor)
		@environment.interact
		#Clock always returns 0.1 seconds, so ensure actor's vector is adjusted accordingly.
		assert_in_delta(3.778, @actor.vector.pitch, REQUIRED_ACCURACY)
		assert_in_delta(1.073, @actor.vector.speed, REQUIRED_ACCURACY)
	end
	
	
	#An ApproachAction pushes the actor toward the target.
	def test_approach_action
	
		#Create an ApproachAction with 1 unit/sec thrust.
		@actor.vector = Vector.new(0, 0)
		add_action(ApproachAction.new(1), @actor)
		#Act.
		@environment.interact
		#Ensure actor's vector is correct after action's thrust is applied for 0.1 seconds.
		assert_in_delta(0.1, @actor.vector.speed, REQUIRED_ACCURACY)
		assert_in_delta(45, @actor.vector.pitch, REQUIRED_ACCURACY)

	end
	
	#A FleeAction pushes the actor away from a target.
	def test_flee_action

		#Create a FleeAction with a 0-degree vector, turn rate of 40 degrees/sec.
		@actor.vector = Vector.new(0, 0)
		action = FleeAction.new(1)
		add_action(action, @actor)
		#Act.
		@environment.interact
		#Ensure actor's resulting vector is correct after 0.1 seconds of thrust.
		assert_in_delta(0.1, @actor.vector.speed, REQUIRED_ACCURACY)
		assert_in_delta(225, @actor.vector.pitch, REQUIRED_ACCURACY)
	end
	
	#A DestroyAction removes the target from the environment.
	def test_destroy_action
		#Create a DestroyAction, linked to the environment.
		add_action(DestroyAction.new(@environment), @actor)
		#Act.
		@environment.interact
		#Verify target is removed from environment.
		assert(! @environment.objects.include?(@target1))
		#Verify non-target is removed from environment.
		assert(@environment.objects.include?(@target2))
		#Act again.
		@environment.interact
		#Verify targets were switched.
		assert(! @environment.objects.include?(@target2), "Targets should have been switched.")
	end
	
	
	#An EatAction is like a DestroyAction, but also makes the actor grow in size.
	def test_eat_action
		#Create an EatAction, linked to the environment.
		add_action(EatAction.new(@environment), @actor)
		#Act.
		@actor.size = 1
		@target1.size = 1
		@environment.interact
		#Verify target is removed from environment.
		assert(! @environment.objects.include?(@target1))
		#Verify creature has grown by the appropriate amount.
		assert_in_delta(2, @actor.size, REQUIRED_ACCURACY)
	end
	
	
	#A TagAction adds a tag to the target.
	def test_tag_action
		#Create a TagAction, and act.
		add_action(TagAction.new("tag"), @actor)
		@environment.interact
		#Verify target has appropriate tag.
		assert(@target1.tags.include?("tag"))
	end
	
	
	#A BlendAction shifts the target's color toward the given color.
	def test_blend_action_black
		#Create a BlendAction that blends to black.
		add_action(BlendAction.new(Color.new(0, 0, 0)), @actor)
		#Set the target's color.
		@target1.color = Color.new(0.5, 0.5, 0.5)
		#Act.
		@environment.interact
		#Verify the target's new color.
		assert_in_delta(0.25, @target1.color.red, REQUIRED_ACCURACY)
		assert_in_delta(0.25, @target1.color.green, REQUIRED_ACCURACY)
		assert_in_delta(0.25, @target1.color.blue, REQUIRED_ACCURACY)
	end
		
	#Test shifting colors toward white.
	def test_blend_action_white
		#Create a BlendAction that blends to white.
		add_action(BlendAction.new(Color.new(1, 1, 1)), @actor)
		#Set the target's color.
		@target1.color = Color.new(0.5, 0.5, 0.5)
		#Act.
		@environment.interact
		#Verify the target's new color.
		assert_in_delta(0.75, @target1.color.red, REQUIRED_ACCURACY)
		assert_in_delta(0.75, @target1.color.green, REQUIRED_ACCURACY)
		assert_in_delta(0.75, @target1.color.blue, REQUIRED_ACCURACY)
	end
	
	
	#A PushAction pushes the target away.
	def test_push_action
		#Create a PushAction, and act.
		add_action(PushAction.new(1), @actor)
		@environment.interact
		#Verify target's speed and direction are correct.
		assert_in_delta(0.1, @target1.vector.speed, REQUIRED_ACCURACY, "@target1 should have been pushed away from @actor.")
		assert_in_delta(45.0, @target1.vector.pitch, REQUIRED_ACCURACY, "@target1's angle should be facing away from @actor.")
	end

	
	#A PullAction pulls the target toward the actor.
	def test_pull_action
		#Create a PullAction, and act.
		add_action(PullAction.new(1), @actor)
		@environment.interact
		#Verify target's speed and direction are correct.
		assert_in_delta(0.1, @target1.vector.speed, REQUIRED_ACCURACY, "@target1 should have been pulled toward @actor.")
		assert_in_delta(225.0, @target1.vector.pitch, REQUIRED_ACCURACY, "@target1's angle should be facing toward @actor.")
	end
	
	
	#A BreedAction creates a new Creature by combining the actor's color and behaviors with another creature.
	def test_breed_action
		#Create two creatures with different colors and behaviors.
		@actor.color = Color.new(1, 1, 1)
		@target1.color = Color.new(0, 0, 0)
		add_action(TagAction.new("1"), @actor)
		add_action(TagAction.new("2"), @target1)
		#Set actor's location to a non-standard place.
		@actor.location = Location.new(33, 33)
		#Create a BreedAction using the Environment, and act.
		add_action(BreedAction.new(@environment, 0.2), @actor) #0.1 delay ensures modified Clock will trigger action on second operation.
		@environment.interact
		@environment.interact #Act twice to trigger action on actor (and only actor).
		#Find child.
		child = @environment.objects.last
		#Ensure child's color is a mix of parents'.
		assert_equal(Color.new(0.5, 0.5, 0.5), child.color)
		#Ensure child's behaviors combine the parents', but exclude those with BreedActions.
		assert_equal("1", child.behaviors[0].actions.first.tag)
		assert_equal("2", child.behaviors[1].actions.first.tag)
		assert_equal(2, child.behaviors.length)
		#Ensure child appears at actor's location.
		assert_equal(@actor.location.x, child.location.x)
		assert_equal(@actor.location.y, child.location.y)
	end
	
end
