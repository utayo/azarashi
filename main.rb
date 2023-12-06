require 'curses'

HEIGHT = 25
WIDTH = 80
    
module TaskArea
  class Area
    def initialize
      @data = {
        backlog: [
          { id: 1, title: 't1' },
          { id: 2, title: 't1' },
          { id: 3, title: 't1' },
        ],
        todo: [
          { id: 1, title: 't1' },
          { id: 2, title: 't1' },
          { id: 3, title: 't1' },
        ]
      }

      Curses.init_screen
      @win = Curses::Window.new(HEIGHT, WIDTH, 0, 0)
      @win.box(?|,?-,?*)
  
      @input = Input.new(@win, 1, 2)
      @backlog = List.new(@win, 4, 2, 'backlog', @data[:backlog])
      @win.refresh
  
      view
    end

    def view
      loop do
        refresh
        str = @input.wait_command     
        case str
        when 'i' then
          input
        when 'b' then
          backlog
        when 'q' then
          break
        else
        end
      end
    end

    def backlog
      focus = 0

      loop do
        refresh

        str = @backlog.move(focus)
        case str
        when 'j' then
          focus = focus + 1
        when 'k' then
          focus = focus - 1
        when 'd' then
          @backlog.done(focus)
        when 'q' then
          break
        else
        end
      end
    end

    def input
      str = @input.wait_task

      @backlog.add(str) if str != ''
      @input.refresh
    end

    def refresh
      @win = Curses::Window.new(HEIGHT, WIDTH, 0, 0)
      @win.box(?|,?-,?*)
      
      s = 'Azarashi'
  
      @win.setpos(0, (WIDTH - s.length) / 2)
      @win.addstr(s)

      @input.refresh
      @backlog.refresh
      @win.refresh
    end
  end
  
  class Input
    def initialize(win, line, col)
      @win = win
      @line = line
      @col = col
      @forcused = false
    end
  
    def focus
      @forcused = true
    end
  
    def unforcus
      @forcused = false
    end

    def header
      str = '[/i: Add Task, /q: Quit]'
      @win.setpos(@line, @col)
      @win.addstr(str)
    end

    def wait_command
      header
      str = '/'
      @win.setpos(@line + 1, @col)
      @win.addstr(str)

      @win.setpos(@line + 1, @col + str.length)
      @win.getch
    end
  
    def wait_task
      header
      str = 'task title:'
      @win.setpos(@line + 1, @col)
      @win.addstr(str)

      @win.setpos(@line + 1, @col + str.length + 1)
      @win.getstr
    end

    def refresh
      header
      @win.setpos(@line, @col)
      @win.addstr(' ' * (WIDTH - 3))
    end
  end
  
  class List
    def initialize(win, line, col, title, tasks)
      @win = win
      @line = line
      @col = col
      @title = title
      @tasks = tasks
      @focused = false
  
      show
    end

    def move(i)
      @win.setpos(@line + i + 1, @col)
      @win.getch
    end

    def show
      @win.setpos(@line, @col)
      @win.addstr(@title)

      @tasks.each_with_index do |task, i|
        @win.setpos(@line + i + 1, @col)
        @win.addstr(task[:title])
      end
    end

    def add(title)
      @tasks.push({ id: @tasks.length, title: title })
      show
    end

    def done(i)
      @tasks.delete_at(i)
    end

    def refresh
      show
    end
  end
end

class Main

  include TaskArea

  def initialize
    Area.new
  end
end


Main.new
