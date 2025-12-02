For example, add this to your program:
```ruby
if ENV["MY_TRACEREPLAY_FLAG"]
  require "tracereplay"
  TraceReplay.start File.new("temp.htm", "w"),
    "/Users/nakilon/.rbenv/versions/2.7.8/lib/ruby/gems/2.7.0/gems/",
    "/Users/nakilon/.rbenv/versions/2.7.8/lib/ruby/gems/2.7.0/bundler/gems/",
    "/Users/nakilon/.rbenv/versions/2.7.8/lib/ruby/2.7.0/",
    "/Users/nakilon/my_repo/"
end
```
and run it like this:
```console
$ MY_TRACEREPLAY_FLAG=_ bundle exec rspec test.rb:463
```
The program will run several times slower because it's tracing, and in the end there will be a local file `./temp.htm`, that you open in browser and move the mouse around to see traces with call counts, smth like this:
<img width="1566" height="668" alt="image" src="https://github.com/user-attachments/assets/eec14dc0-d79d-430a-8341-c1b94cb2b96c" />
In this specific example on first glance there isn't much we can do because it's about how a third-party gem works, but in your code you might discover own algorithm mistakes or that there is some slow pre- or post- execution step.
