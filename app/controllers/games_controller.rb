require "json"
require "open-uri"
class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @answer = params[:answer]
    end_time = Time.now
    @score = run_game(@answer, params[:letters], params[:start_time].to_i, end_time.to_i)
  end

  def generate_grid(grid_size)
    grid = []
    grid_size.times { grid.push(("A".."Z").to_a.sample)}
    return grid
  end

  def checks_word_in_grid?(word, grid)
    arr = []
    word.upcase.each_char do |x|
      arr << (grid.count(x) >= word.upcase.chars.count(x))
    end
    return !arr.include?(false)
  end

  def get_json(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    attempt_check = URI.open(url).read
    return JSON.parse(attempt_check)
  end

  def run_game(attempt, grid, start_time, end_time)
    attempt_return = get_json(attempt)
    attempt_return[:time] = end_time - start_time
    attempt_return[:score] = 0
    if attempt_return["found"] && checks_word_in_grid?(attempt, grid)
      attempt_return[:message] = "Well Done!"
      attempt_return[:score] += ((attempt_return[:time]).to_i * attempt_return["length"])
    elsif checks_word_in_grid?(attempt, grid) == false
      attempt_return[:message] = "not in the grid"
    else
      attempt_return[:message] = "not an english word"
    end
    return attempt_return
  end
end
