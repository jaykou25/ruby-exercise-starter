require 'digest'
require 'taglib'
require 'csv'

namespace :track do
  task upload_tracks: :environment do
    father_dir = "/home/jaygao/files"
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

    f = File.new('/home/jaygao/files/output.json', 'wb') 
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
      # FileUtils.cp(file_path, new_file_path)

      row[:filePath] = File.join('/audios', file_md5 + file_ext)
      row[:sort] = index + 1

      TagLib::FileRef.open(file_path) do |fileref|
        tag = fileref.tag
        row[:title] = tag.title

        row[:length] =  fileref.audio_properties.length_in_seconds
      end

      f.write(row.to_json)
    end

    f.close
  end
end
