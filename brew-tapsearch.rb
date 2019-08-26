#!/usr/bin/env ruby

require 'octokit'

def cache_or_search
  # cache results so quickly-rerun command doesn't use too much bandwith?
end

def search_taps
  client = Octokit::Client.new :access_token => ENV['TAPSEARCH_PERSONAL_TOKEN']

  _ = client.search_repos('homebrew in:name', :per_page => 100)
  last_response = client.last_response
  
  Enumerator.new do |x|
    until last_response.rels[:next].nil?
      last_response = last_response.rels[:next].get
      for item in last_response.data.items
        x.yield(item.full_name)
      end
    end
  end
end

def filter_taps(pattern)
  #tokens = cache_or_search

  Enumerator.new do |x|
    for token in search_taps
      _, repo = token.split("/")
      if repo.match(/^homebrew-/)
        if repo.match(pattern)
          x.yield(token)
        end
      end
    end
  end
end

def usage
  usage = "Usage:\n"\
    "brew-tapsearch <pattern>\n\tSearch for homebrew taps on github containing <pattern>"

  puts usage
end

# todo:
# command line parsing
# options:
#   --formula : search for formula name
#   --cask : search for Cask

if ARGV.length == 1
  results = filter_taps ARGV[0]

  puts "Results:"
  puts "\t(clone with `brew tap user/tapname`, where tapname doesn't include leading 'homebrew-')\n\n"
  for result in results
    puts result
  end
else
  usage
end
