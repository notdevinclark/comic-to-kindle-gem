require 'rspec'

require 'fileutils'
require 'zip'

require 'pry'

class Resizer
  class FileNotFound < StandardError; end
  class IncorrectExtension < StandardError; end

  EXTS = %w(.zip .rar .cbz .cbr)

  attr_reader :file

  def initialize file
    @file = file
  end

  def resize
    if File.exists? file
      if EXTS.include? File.extname(file)
        FileUtils.cp(file, temp_file)
      else
        raise IncorrectExtension, "#{file} is not of the correct extension. (#{EXTS.join('|')})"
      end
    else
      raise FileNotFound, "#{file} does not exist"
    end
  end

  def tmp_extension
    case File.extname(file)
    when '.cbr' then '.rar'
    when '.cbz' then '.zip'
    else File.extname(file)
    end
  end

  private

  def temp_file
    "/tmp/#{File.basename(file, ".*")}#{tmp_extension}"
  end
end

class ZipHandler
  attr_reader :archive

  def initialize archive
    @archive = archive
  end

  def unzip
    FileUtils.mkdir(unarchive_folder)
    Zip::File.open(archive).each { |file| file.extract "#{unarchive_folder}/#{file.name}" }
  end

  private

  def unarchive_folder
    "#{File.dirname(archive)}/#{File.basename(archive, '.*')}"
  end
end

describe ZipHandler do
  let(:archive) { '/tmp/comic.zip' }
  let(:unarchive_folder) { "#{File.dirname(archive)}/#{File.basename(archive, '.*')}" }
  let(:opened_archive) { double(:opened_archive) }
  let(:archive_entry) { double(:archive_entry, name: 'archive_file_name') }
  subject(:zip_handler) { ZipHandler.new(archive) }
  before do
    allow(FileUtils).to receive(:mkdir).with('/tmp/comic')
    allow(Zip::File).to receive(:open).with(archive).and_return opened_archive
    allow(opened_archive).to receive(:each).and_yield archive_entry
    allow(archive_entry).to receive(:extract)
  end

  describe '#unzip' do
    it 'creates a new directory in the same path with the same name as the archive' do
      expect(FileUtils).to receive(:mkdir).with(unarchive_folder)
      zip_handler.unzip
    end
    it 'opens the file with Zip::File class' do
      expect(Zip::File).to receive(:open).with(archive)
      zip_handler.unzip
    end
    it 'calls extract on the files in the zip' do
      expect(archive_entry).to receive(:extract).with("#{unarchive_folder}/archive_file_name")
      zip_handler.unzip
    end
  end
end

describe Resizer do
  let(:file) { 'comic' }
  subject(:resizer) { Resizer.new(file) }

  before do
    allow(FileUtils).to receive(:cp)
    allow(FileUtils).to receive(:rm)
  end

  describe '#tmp_extension' do
    context 'when extension is .zip' do
      let(:file) { 'comic.zip' }
      it 'returns .zip' do
        expect(resizer.tmp_extension).to eq '.zip'
      end
    end
    context 'when extension is .rar' do
      let(:file) { 'comic.rar' }
      it 'returns .rar' do
        expect(resizer.tmp_extension).to eq '.rar'
      end
    end
    context 'when extension is .cbr' do
      let(:file) { 'comic.cbr' }
      it 'returns .cbr' do
        expect(resizer.tmp_extension).to eq '.rar'
      end
    end
    context 'when extension is .cbz' do
      let(:file) { 'comic.cbz' }
      it 'returns .zip' do
        expect(resizer.tmp_extension).to eq '.zip'
      end
    end
  end

  context "when the file exists" do
    before do
      allow(File).to receive(:exists?) { true }
    end

    context 'when file has correct extension' do
      let(:file) { 'comic.cbr' }
      it 'copies the file to /tmp directory with the correct extension' do
        expect(FileUtils).to receive(:cp).with(file, "/tmp/#{File.basename(file, ".*")}.rar")
        resizer.resize
      end
    end

    context 'when file does not have correct extension' do
      it 'raises an error' do
        expect { resizer.resize }.to raise_error Resizer::IncorrectExtension
      end
    end
  end

  context "when the file doesn't exist" do
    before do
      allow(File).to receive(:exists?) { false }
    end

    it 'raises an error' do
      expect { resizer.resize }.to raise_error(Resizer::FileNotFound)
    end
  end
end
