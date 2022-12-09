require 'fileutils'

PROJECT_ROOT = `git rev-parse --show-toplevel`.strip
BUILD_DIR    = File.join(PROJECT_ROOT, "build")
GH_PAGES_REF = File.join(BUILD_DIR, ".git/refs/remotes/origin/main")
DOMAINS =
  {
    "jonrowe-dot-co-dot-uk" => "jonrowe.co.uk",
    "jonrowe-dot-uk" => "jonrowe.uk",
    "jonrowe-dot-dev" => "jonrowe.dev",
  }
main_repo = "jonrowe-dot-co-dot-uk"
repos = {}

directory BUILD_DIR

file GH_PAGES_REF => BUILD_DIR do
  repo_url = nil

  cd PROJECT_ROOT do
    DOMAINS.each do |origin, _|
      repos[origin] = `git config --get remote.#{origin}.url`.strip
    end
  end

  cd BUILD_DIR do
    sh "git init"
    DOMAINS.each do |origin, _|
      if `git remote -v` =~ /#{origin}/
        sh "git remote set-url #{origin} #{repos[origin]}"
      else
        sh "git remote add #{origin} #{repos[origin]}"
      end
    end
    sh "git fetch --all"

    if `git branch -l` =~ /main/
      sh "git checkout main"
    elsif `git branch -r` =~ /main/
      sh "git checkout -b main -t #{main_repo}/main"
    else
      sh "git checkout --orphan main"
      sh "touch index.html"
      sh "git add ."
      sh "git commit -m 'initial main commit'"
    end
  end
end

# Alias to something meaningful
task :prepare_git_remote_in_build_dir => GH_PAGES_REF

# Fetch upstream changes on main branch
task :sync do
  cd BUILD_DIR do
    sh "git fetch --all"
    sh "git reset --hard #{main_repo}/main"
  end
end

# Prevent accidental publishing before committing changes
task :not_dirty do
  puts "***#{ENV['ALLOW_DIRTY']}***"
  unless ENV['ALLOW_DIRTY']
    fail "Directory not clean" if /nothing to commit/ !~ `git status`
  end
end

desc "Compile all files into the build directory"
task :build do
  cd PROJECT_ROOT do
    sh "bundle exec middleman build --clean #{ARGV.find { |arg| arg == "--verbose" }}"
  end
end

desc "Build and publish to Github Pages"
task :publish => [:not_dirty, :prepare_git_remote_in_build_dir, :sync, :build] do
  message = nil

  cd PROJECT_ROOT do
    head = `git log --pretty="%h" -n1`.strip
    message = "Site updated to #{head}"
  end

  cd BUILD_DIR do
    if /nothing to commit/ =~ `git status`
      puts "No changes to commit."
    else
      sh 'git add --all'
      sh "git commit -m \"#{message}\""
    end

    DOMAINS.each do |origin, domain|
      sh "git co -b #{origin}-update"
      sh "echo '#{domain}' > CNAME"
      sh "git add CNAME"
      sh "git commit -m \"Set CNAME\" --allow-empty"
      sh "git push #{origin} #{origin}-update:main --force"
      sh "git co main"
      sh "git branch -D #{origin}-update"
    end
  end
end
