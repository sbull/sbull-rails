if Rails.env.development?

  checks =
    [
     { exe: 'rbenv', url: 'https://github.com/sstephenson/rbenv' },
     { exe: 'pre-commit', url: 'https://github.com/jish/pre-commit', install: 'gem install pre-commit && rbenv rehash' },
     { file: '.git/hooks/pre-commit', match: /\brequire "pre-commit".*\bPreCommit.run\b/m, url: 'https://github.com/jish/pre-commit', install: 'pre-commit install' },
     { exe: 'coffeelint', url: 'http://www.coffeelint.org/', install: 'sudo npm install -g coffeelint' },
     { exe: 'scss-lint', url: 'https://github.com/causes/scss-lint', install: 'gem install scss-lint && rbenv rehash' },
     { exe: 'rubocop', url: 'https://github.com/bbatsov/rubocop', install: 'gem install rubocop && rbenv rehash' },
     {
       name: 'BUNDLE_GEMFILE',
       url: ['https://groups.google.com/forum/#!topic/ruby-bundler/5zVMtUSNSd0', 'https://github.com/gerrywastaken/Gemfile.local'],
       custom: lambda do
         repo_gemlock = Rails.root.join('Gemfile.lock').to_s
         return true unless (gemfile = ENV['BUNDLE_GEMFILE']) && gemfile != repo_gemlock.sub(/\.lock$/,'')
         gemlock = Rails.root.join("#{gemfile}.lock").to_s
         cmd = "diff #{repo_gemlock} #{gemlock}"
         diff = `#{cmd}`
         conflicts = diff.split(/\n\s*/).select{|d| d[0] == '<' }
         if conflicts.present?
           raise "#{gemlock} has different gem versions than Gemfile.lock.\n  #{cmd}\n"+conflicts.join("\n")+"\nPlease copy Gemfile.lock to #{gemlock} first, then try again:\n\n    cp #{repo_gemlock} #{gemlock}"
         else
           true
         end
       end,
     },
    ]

  failed = []

  checks.each do |check|
    checked = false

    if check[:exe]
      checked = true
      failed << check unless `which #{check[:exe]}`.present?
    end

    if check[:file]
      checked = true
      file_path = Rails.root.join(check[:file])
      pass = File.exist?(file_path)
      if pass && check[:match]
        pass = File.read(file_path).match(check[:match])
      end
      failed << check unless pass
    end

    if check[:custom]
      checked = true
      begin
        pass = check[:custom].call
      rescue => e
        check[:error] = e
      end
      failed << check unless pass
    end

    unless checked
      failed << check
    end
  end

  if failed.present?
    err = "Development checks failed\n"
    failed.each do |check|
      file_name = check[:exe] || check[:file]
      name = check[:name] || file_name || check.inspect
      lines = [ name, '' ]
      if check[:error]
        lines << "ERROR: #{check[:error]}"
      end
      if file_name
        lines << "Unable to find #{file_name}"+(check[:match] ? " matching #{check[:match]}" : '')+'.'
      end
      if check[:install]
        lines << 'Please install:'
        lines << ''
        lines << "    #{check[:install]}"
      end
      if check[:url]
        lines << ''
        lines << 'Reference:'
        lines.concat(Array(check[:url]).map{|url| "  #{url}" })
      end
      err += "\n###\n"+lines.map{|l| "# "+l.gsub(/\n/, "\n# ") }.join("\n")+"\n#\n###\n"
    end
    raise err
  end

end
