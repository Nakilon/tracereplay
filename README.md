It's something similar to flamegraph but without an image (yet? feel free to pull request).
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
In this specific usage example we may decide to reduce the number of `#random_example` calls to the third-party gem we use in line `./document.rb:265`. It may also give a hint that there is some mistake in your algorithm, or explain that big time of time (the width of the page that you hover with your mouse) is some slow pre- or post- execution step.
