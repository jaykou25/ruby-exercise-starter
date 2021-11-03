require 'digest'
require 'taglib'
require 'csv'

def seconds_to_ms(sec)
  "%02d:%02d" % [sec / 60 % 60, sec % 60]
end

namespace :track do
  task upload_tracks: :environment do
    father_dir = "/Users/jaygao/Desktop"
    dir = 'level2'
    new_dir = dir + '_new'
    # 新建文件夹
    FileUtils.mkdir_p(File.join(father_dir, new_dir))

    # 读取文件夹
    file_names = Dir.children(File.join(father_dir, dir)).filter{|name| name != '.DS_Store' }.sort do |a, b| 
      a_index = a.split(' ')[0]
      b_index = b.split(' ')[0]
      a_index <=> b_index
    end

    f = File.new('/Users/jaygao/Desktop/output.json', 'wb') 
    arr = []

    # 遍历文件
    file_names.each_with_index do |file_name, index|
      puts file_name
      row = {}

      file_path = File.join(father_dir, dir, file_name)

      file_md5 = Digest::MD5.hexdigest(File.open(file_path, 'rb'){|fs|fs.read})
      file_ext = File.extname(file_name)

      new_file_path = File.join(father_dir, new_dir, file_md5 + file_ext)
      # 复制到新文件夹
      FileUtils.cp(file_path, new_file_path)

      row[:src] = File.join('/audios', file_md5 + file_ext)
      row[:sort] = index + 1
      row[:epId] = '859059a56174bdb601bf6535144c78d1'

      TagLib::FileRef.open(file_path) do |fileref|
        tag = fileref.tag
        row[:title] = tag.title

        seconds = fileref.audio_properties.length_in_seconds

        row[:length] = seconds_to_ms(seconds)
      end

      f.write(row.to_json)
    end

    f.close
  end
end
