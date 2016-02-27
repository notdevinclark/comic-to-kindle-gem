require 'rspec'

require 'fileutils'
require 'pry'

class Resizer
  attr_reader :file

  def initialize file
    @file = file
  end

  def resize
    if File.exists? file
      FileUtils.cp(file, "/tmp/#{file}.bak")
    end
  end
end

describe Resizer do
  let(:file) { 'Rakefile' }
  subject(:resizer) { Resizer.new(file) }
  it 'verify the file exists' do
    expect(File).to receive(:exists?).with(file)
    resizer.resize
  end

  it 'verifies it copies the file to /tmp directory' do
    expect(FileUtils).to receive(:cp).with(file, "/tmp/#{file}.bak")
    resizer.resize
  end

  it 'verifies that the file was moved to /tmp directory' do
    resizer.resize
    expect(File.exists? "/tmp/#{file}.bak").to be_truthy
  end
end
