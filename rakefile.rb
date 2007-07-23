#!/usr/bin/ruby -w

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'


#Configuration variables.
PRODUCT_NAME = "Zyps"
PRODUCT_VERSION = "0.0.1"
SUMMARY = "A simulation/game with autonomous creatures"
AUTHOR = "Jay McGavren"
AUTHOR_EMAIL = "jay@mcgavren.com"
WEB_SITE = "http://jay.mcgavren.com/#{PRODUCT_NAME.downcase}/"
REQUIREMENTS = [
	"Ruby-GNOME2"
]


#Set up rdoc.
RDOC_OPTIONS = [
	"--title", "#{PRODUCT_NAME} - #{SUMMARY}",
	"--main", "README.txt"
]


desc "Create a gem by default"
task :default => [:test, :gem]


desc "Create documentation"
Rake::RDocTask.new do |rdoc|
	rdoc.rdoc_dir = "doc"
	rdoc.rdoc_files = FileList[
		"lib/**/*",
		"*.txt"
	].exclude(/\bsvn\b/).to_a
	rdoc.options = RDOC_OPTIONS
end


desc "Test the package"
Rake::TestTask.new do |test|
	test.libs << "lib"
	test.test_files = FileList["test/test_*.rb"]
end


desc "Package a gem"
specification = Gem::Specification.new do |spec|
	spec.name = PRODUCT_NAME.downcase
	spec.version = PRODUCT_VERSION
	spec.author = AUTHOR
	spec.email = AUTHOR_EMAIL
	spec.homepage = WEB_SITE
	spec.platform = Gem::Platform::RUBY
	spec.summary = SUMMARY
	spec.requirements << REQUIREMENTS
	spec.rubyforge_project = PRODUCT_NAME.downcase
	spec.require_path = "lib"
	spec.autorequire = PRODUCT_NAME.downcase
	spec.test_files = Dir.glob("test/test_*.rb")
	spec.has_rdoc = true
	spec.rdoc_options = RDOC_OPTIONS
	spec.extra_rdoc_files = ["README.txt", "COPYING.LESSER.txt", "COPYING.txt"]
	spec.files = FileList[
		"*.txt",
		"bin/**/*",
		"lib/**/*",
		"test/**/*",
		"doc/**/*"
	].exclude(/\bsvn\b/).to_a
	spec.executables << PRODUCT_NAME.downcase
end
Rake::GemPackageTask.new(specification) do |package|
	package.need_tar = true
end


CLOBBER.include(%W{doc})