class Beer
  # ==================================================
  #                      SET UP
  # ==================================================
  # add attribute readers for instance accesss
  attr_reader :id, :beer, :tried, :liked

  # connect to postgres
  if(ENV['https://project-4-api.herokuapp.com/beers/'])
    uri = URI.parse(ENV['https://project-4-api.herokuapp.com/beers/'])
    db = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
  else
    DB = PG.connect({:host => "localhost", :port => 5432, :dbname => 'project-4-api_development'})
  end

  # initialize options hash
  def initialize(opts = {}, id = nil)
    @id = id.to_i
    @brewery_name = opts["brewery_name"]
    @location = opts["location"]
    @beer_name = opts["beer_name"]
    @beer_style = opts["beer_style"]
    @ranking = opts["ranking"]
    @tried = opts["tried"]
    @liked = opts["liked"]
    @img = opts["img"]
  end

  # ==================================================
  #                 PREPARED STATEMENTS
  # ==================================================
  # find beer
  DB.prepare("find_beer",
    <<-SQL
      SELECT beers.*
      FROM beers
      WHERE beers.id = $1;
    SQL
  )

  # create beer
  DB.prepare("create_beer",
    <<-SQL
      INSERT INTO beers (brewery_name, location, beer_name, beer_style, ranking, comments, tried, liked, img)
      VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 )
      RETURNING id, brewery_name, location, beer_name, beer_style, ranking, comments, tried, liked, img;
    SQL
  )

  # delete beer
  DB.prepare("delete_beer",
    <<-SQL
      DELETE FROM beers
      WHERE id=$1
      RETURNING id;
    SQL
  )

  # update beer
  DB.prepare("update_beer",
    <<-SQL
      UPDATE beers
      SET brewery_name = $2, location = $3, beer_name = $4, beer_style = $5, ranking = $6, comments = $7, liked = $8, img = $9
      WHERE id = $1
      RETURNING id, brewery_name, location, beer_name, beer_style, ranking, comments, tried, liked, img;
    SQL
  )

  # ==================================================
  #                      ROUTES
  # ==================================================
  # get all beers
  def self.all
    results = DB.exec("SELECT * FROM beers;")
    return results.map do |result|
      # turn completed value into boolean
      if result["tried"] === 'f'
        result["tried"] = false
      else
        result["tried"] = true
      end
      if result["liked"] === 'f'
        result["liked"] = false
      else
        result["liked"] = true
      end
      # create and return the beers
      beer = Beer.new(result, result["id"])
    end
  end

  # get one beer by id
  def self.find(id)
    # find the result
    result = DB.exec_prepared("find_beer", [id]).first
    p result
    p '---'
    # turn tried value into boolean
    if result["tried"] === 'f'
      result["tried"] = false
    else
      result["tried"] = true
    end
    if result["liked"] === 'f'
      result["liked"] = false
    else
      result["liked"] = true
    end
    p result
    # create and return the beer
    beer = Beer.new(result, result["id"])
  end

  # create one
  def self.create(opts)
    # if opts["tried"] does not exist, default it to false
    if opts["tried"] === nil
      opts["tried"] = false
    end
    if opts["liked"] === nil
      opts["liked"] = false
    end
     # create the beer
    results = DB.exec_prepared("create_beer", [opts["brewery_name"], opts["location"], opts["beer_name"], opts["beer_style"], opts["ranking"], opts["comments"], opts["tried"], opts["liked"], opts["img"]])
    # turn tried value into boolean
    if results.first["tried"] === 'f'
      tried = false
    else
      tried = true
    end
    if results.first["liked"] === 'f'
      liked = false
    else
      liked = true
    end
    # return the beer
    beer = Beer.new(
      {
        "brewery_name" => results.first["brewery_name"],
        "location" => results.first["location"],
        "beer_name" => results.first["beer_name"],
        "beer_style" => results.first["beer_style"],
        "ranking" => results.first["ranking"],
        "comments" => results.first["comments"],
        "tried" => tried,
        "liked" => liked,
        "img" => results.first["img"]
      },
      results.first["id"]
    )
  end

  # delete one
  def self.delete(id)
    # delete one
    results = DB.exec_prepared("delete_beer", [id])
    # if results.first exists, it successfully deleted
    if results.first
      return { deleted: true }
    else # otherwise it didn't, so leave a message that the delete was not successful
      return { message: "sorry cannot find beer at id: #{id}", status: 400}
    end
  end

  # update one
  def self.update(id, opts)
    # update the beer
    results = DB.exec_prepared("update_beer", [id, opts["brewery_name"], opts["location"], opts["beer_name"], opts["beer_style"], opts["ranking"], opts["comments"], opts["tried"], opts["liked"], opts["img"]])
    # if results.first exists, it was successfully updated so return the updated beer
    if results.first
      if results.first["tried"] === 'f'
        tried = false
      else
        tried = true
      end
      if results.first["liked"] === 'f'
        liked = false
      else
        liked = true
      end
      # return the beer
      beer = Beer.new(
        {
          "brewery_name" => results.first["brewery_name"],
          "location" => results.first["location"],
          "beer_name" => results.first["beer_name"],
          "beer_style" => results.first["beer_style"],
          "ranking" => results.first["ranking"],
          "comments" => results.first["comments"],
          "tried" => tried,
          "liked" => liked,
          "img" => results.first["img"]
        },
        results.first["id"]
      )
    else # otherwise, alert that update failed
      return { message: "sorry, cannot find beer at id: #{id}", status: 400 }
    end
  end

end
