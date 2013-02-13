#!/usr/bin/env ruby

require 'fileutils'

def run
  Dir.chdir File.dirname __FILE__
  git_pull
  install_oh_my_zsh
  switch_to_zsh
  symlink_all_files
end

def git_pull
  system %Q{git pull}
  system %Q{git submodule init}
  system %Q{git submodule update}
end

def symlink_all_files
  get_file_roots.each do |file|
    link = File.join Dir.home, ".#{file}"
    link_dir = File.dirname(link)
    file_path = File.absolute_path file

    unless File.exists?(link_dir)
      FileUtils.mkdir_p(link_dir, verbose: true)
    end

    if File.exists?(link) || File.symlink?(link)
      unless File.symlink?(link) && File.readlink(link) == file_path
        FileUtils.rm_r link, force: true, verbose: true
        FileUtils.ln_s file_path, link, verbose: true
      end
    else
      FileUtils.ln_s file_path, link, verbose: true
    end
  end
end

def get_file_roots

  # All files except special files like this script
  files = Dir['**/*'].reject{|file| File.directory? file }
  files -= %w[install.rb]

  # vim/bundle and vim/UltiSnips should just be linked with one link
  %w[vim/bundle vim/UltiSnips].each do |dir|
    files = files.reject{|file| file =~ /^#{dir}\// }
    files << dir
  end

  files
end

def install_oh_my_zsh
  unless File.exist?(File.join(Dir.home, '.oh-my-zsh'))
    print "install oh-my-zsh? [ynq] "
    case $stdin.gets.chomp
    when 'y'
      puts "installing oh-my-zsh"
      system %Q{git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"}
    when 'q'
      exit
    else
      puts "skipping oh-my-zsh, you will need to change ~/.zshrc"
    end
  end
end

def switch_to_zsh
  unless ENV["SHELL"] =~ /zsh/
    print "switch to zsh? [ynq] "
    case $stdin.gets.chomp
    when 'y'
      puts "switching to zsh"
      system %Q{chsh -s `which zsh`}
    when 'q'
      exit
    else
      puts "skipping zsh"
    end
  end
end


run
