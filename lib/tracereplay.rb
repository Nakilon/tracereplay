require "erb"
module TraceReplay
  def self.start out, *prefixes
    thread_main = ::Thread.main

    backtraces = []
    next_time = ::Time.now
    thread = ::Thread.new do
      loop do
        backtraces.push [
          ::Time.now,
          thread_main.backtrace_locations.map do |loc|
            [
              loc.absolute_path,
              loc.lineno,
              loc.base_label,
            ] if loc.absolute_path
          end.compact,
        ]
        next_time += 1/60.0
        sleep [next_time - ::Time.now, 0].max
      end
    end

    tracepoints = []
    tracepoint = ::TracePoint.new(:call) do |tp|
      next unless tp.callee_id
      next unless thread_main == eval("::Thread.current", tp.binding)
      time = ::Time.now
      tracepoints.push [
        time,
        caller_locations[1].absolute_path,
        caller_locations[1].lineno,
        tp.defined_class,
        tp.callee_id,
        tp.self,
      ]
    end.tap(&:enable)

    at_exit do
      tracepoint.disable
      thread.kill
      puts "dumping #{backtraces.size} backtraces"
      h = {}
      history = backtraces.map do |time_bt, bt|
        tracepoints.reject! do |time_tp, path, lineno, cls, mtd, s|
          break if time_bt < time_tp
          h[[path, lineno, mtd]] ||= [0, Module === s ? "#{cls.to_s[8..-2]}::#{mtd}" : "#{cls}##{mtd}"]
          h[[path, lineno, mtd]][0] += 1
          true
        end
        [
          time_bt,
          bt.reverse.each_cons(2).map do |(path, lineno, _), (_, _, mtd)|
            n, name = h[[path, lineno, mtd.to_sym]]
            [n, name || mtd, "#{prefixes.reduce(path){ |path, prefix| path.delete_prefix prefix }} : #{lineno}"]
          end,
        ]
      end
      sizes = history.flat_map(&:last).transpose.map do |col|
        col.map(&:to_s).map(&:size).max
      end
      history.map! do |time, table|
        [
          time.inspect,
          *table.map{ |row| row.zip(sizes).map{ |cell, size| cell.to_s.ljust size }.join " " }
        ]
      end
      out.write ::ERB.new(<<~HEREDOC, trim_mode: ">").result binding
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { margin: 0; }
                pre {
                    display: block;
                    width: 100vw;
                    height: 100vh;
                    margin: 0;
                    padding: 10px;
                    box-sizing: border-box;
                }
            </style>
        </head>
        <body>
            <pre id="tracker"></pre>
            <script>

                const history = <%= history.inspect %>;

                const tracker = document.getElementById('tracker');
                tracker.addEventListener('mousemove', (e) => {
                    const rect = tracker.getBoundingClientRect();
                    const percentage = (e.clientX - rect.left) / rect.width;
                    tracker.textContent = history[Math.floor(percentage * (history.length - 1))].join('\\n');
                });

            </script>
        </body>
        </html>
      HEREDOC
    end
  end
end
